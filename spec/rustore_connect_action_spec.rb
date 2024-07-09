describe Fastlane::Actions::RustoreConnectAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The rustore_connect plugin is working!")

      Fastlane::Actions::RustoreConnectAction.run(nil)
    end
  end
end
