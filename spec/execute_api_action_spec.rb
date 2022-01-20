describe Fastlane::Actions::ExecuteApiAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The execute_api plugin is working!")

      Fastlane::Actions::ExecuteApiAction.run(nil)
    end
  end
end
