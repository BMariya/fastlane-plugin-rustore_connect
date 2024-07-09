require 'fastlane_core/ui/ui'
require 'digest'
require 'json'

module Fastlane
  module Helper
    class RustoreConnectHelper
      def self.connection
        require 'faraday'
        require 'faraday_middleware'

        options = {
          url: "https://public-api.rustore.ru",
          request = {
            timeout: 1200,
            open_timeout: 180
          }
        }

        logger = Logger.new($stderr)
        logger.level = Logger::DEBUG

        Faraday.new(options) do |builder|
          builder.request(:multipart)
          builder.request(:json)
          builder.request(:url_encoded)
          builder.response(:json, content_type: /\bjson$/)
          builder.response(:logger, logger)
          builder.use(FaradayMiddleware::FollowRedirects)
          builder.adapter(:net_http)
        end
      end

      def self.rsa_sign(timestamp, key_id, private_key)
        key = OpenSSL::PKey::RSA.new("-----BEGIN RSA PRIVATE KEY-----\n#{private_key}\n-----END RSA PRIVATE KEY-----")
        signature = key.sign(OpenSSL::Digest.new('SHA512'), key_id + timestamp)
        Base64.encode64(signature)
      end

      def self.get_token(key_id_path, private_key_path)
        timestamp = DateTime.now.iso8601(3)
        key_id = File.read(key_id_path)
        private_key = File.read(private_key_path)
        signature = rsa_sign(timestamp, key_id, private_key)
        url = "/public/auth/"
        response = connection.post(url) do |req|
          req.body = { keyId: key_id, timestamp: timestamp, signature: signature }
        end

        if response.body["body"]
          if response.body["body"]["jwe"]
            return response.body["body"]["jwe"]
          end
        end

        raise "get_token--> #{response.body}"
      end

      def self.try_to_get_current_draft_id(token, package_name)
        url = "/public/v1/application/#{package_name}/version"
        response = connection.get(url) do |req|
          req.headers['Public-Token'] = token
        end

        if response.body["code"] == "OK"
          drafts = response.body["body"]["content"].select {|e| e["versionStatus"] == "DRAFT"}
          if drafts.size == 1
            draft_id = drafts[0]["versionId"]
            UI.message("try_to_get_current_draft_id --> draft_id=#{draft_id}")
            return draft_id
          end
        end

        raise "try_to_get_current_draft_id --> #{response.body}"
      end

      def self.create_draft(token, package_name, release_notes_path, release_percent)
        url = "/public/v1/application/#{package_name}/version"
        response = connection.post(url) do |req|
          req.headers['Public-Token'] = token
          req.body = { whatsNew: File.read(release_notes_path), partialValue: release_percent}
        end

        if response.body["code"] == "OK"
          draft_id = response.body["body"]
          UI.message("create_draft --> draft_id=#{draft_id}")
          return draft_id
        else
          return try_to_get_current_draft_id(token, package_name)
        end

        raise "create_draft --> #{response.body}"
      end

      def self.upload_aab_google(token, package_name, draft_id, file_path)
        url = "/public/v1/application/#{package_name}/version/#{draft_id}/aab"

        response = connection.post(url) do |req|
          req.headers['Public-Token'] = token
          req.body = { file: Faraday::Multipart::FilePart.new(file_path, 'application/x-authorware-bin') }
        end

        if response.body["code"] == "OK"
          UI.message("upload_aab_google --> OK")
        else
          raise "upload_aab_google --> #{response.body}"
        end
      end

      def self.upload_apk_hms(token, package_name, draft_id, file_path)
        url = "/public/v1/application/#{package_name}/version/#{draft_id}/apk"

        response = connection.post(url) do |req|
          req.headers['Public-Token'] = token
          req.params['servicesType'] = "HMS"
          req.params['isMainApk'] = false
          req.body = { file: Faraday::Multipart::FilePart.new(file_path, 'application/vnd.android.package-archive') }
        end

        if response.body["code"] == "OK"
          UI.message("upload_apk_hms --> OK")
        else
          raise "upload_apk_hms --> #{response.body}"
        end
      end

      def self.send_draft(token, package_name, draft_id)
        url = "/public/v1/application/#{package_name}/version/#{draft_id}/commit"
        response = connection.post(url) do |req|
          req.headers['Public-Token'] = token
        end

        if response.body["code"] == "OK"
          UI.message("send_draft --> OK")
        else
          raise "send_draft --> #{response.body}"
        end
      end
    end
  end
end
