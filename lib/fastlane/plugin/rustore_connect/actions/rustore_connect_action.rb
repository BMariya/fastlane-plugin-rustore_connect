require 'fastlane/action'
require_relative '../helper/rustore_connect_helper'

module Fastlane
  module Actions
    class RustoreConnectAction < Action
      def self.run(params)
        key_id_path = params[:key_id_path]
        private_key_path = params[:private_key_path]
        package_name = params[:package_name]
        aab_google_path = params[:aab_google_path]
        apk_hms_path = params[:apk_hms_path]
        release_notes_path = params[:release_notes_path]
        release_percent = params[:release_percent]

        # Получение авторизационного токена.
        token = Helper::RustoreConnectHelper.get_token(key_id_path, private_key_path)
        # Создание черновика версии.
        draft_id = Helper::RustoreConnectHelper.create_draft(token, package_name, release_notes_path, release_percent)
        # Загрузка файла aab с google-сервисами.
        Helper::RustoreConnectHelper.upload_aab_google(token, package_name, draft_id, aab_google_path)
        # Загрузка файла apk с hms-сервисами.
        Helper::RustoreConnectHelper.upload_apk_hms(token, package_name, draft_id, apk_hms_path)
        # Отправка на модерацию черновика версии приложения.
        Helper::RustoreConnectHelper.send_draft(token, package_name, draft_id)
      end

      def self.description
        "Publish to Rustore"
      end

      def self.authors
        ["Mariia Bazhina"]
      end

      def self.details
        "Plugin allows to publish aab with google services and apk with hms services same version to Rustore"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :key_id_path,
                                  env_name: "RUSTORE_KEY_ID_PATH",
                               description: "Путь до файла с идентификатором ключа rustore",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :private_key_path,
                                  env_name: "RUSTORE_PRIVATE_KEY_PATH",
                               description: "Путь до файла с приватным ключом rustore",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :package_name,
                                  env_name: "RUSTORE_PACKAGE_NAME",
                               description: "Наименование пакета приложения",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :aab_google_path,
                                  env_name: "RUSTORE_AAB_GOOGLE_PATH",
                               description: "Путь до файла aab с google-сервисами",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :apk_hms_path,
                                  env_name: "RUSTORE_APK_HMS_PATH",
                               description: "Путь до файла apk с hms-сервисами",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_notes_path,
                                  env_name: "RUSTORE_RELEASE_NOTES_PATH",
                               description: "Путь до файла с описанием «Что нового»",
                                  optional: false,
                                      type: String),
          FastlaneCore::ConfigItem.new(key: :release_percent,
                                  env_name: "RUSTORE_RELEASE_PERCENT",
                               description: "Процент для частичной публикации приложения",
                                  optional: false,
                                      type: Integer)
        ]
      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
