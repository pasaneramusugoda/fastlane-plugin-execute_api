describe Fastlane::Actions::ExecuteApiAction do
  describe Fastlane::FastFile do
    describe '#run' do
      it "raise an error if no endPoint was given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            execute_api({
            })
          end").runner.execute(:test)
        end.to raise_error("No endPoint given, pass using endPoint: 'endpoint'")
      end
      it "raise an error if both ipa and apk were given" do
        expect do
          Fastlane::FastFile.new.parse("lane :test do
            execute_api({
              endPoint: 'https://yourdomain.com',
              apk:'apkpath',
              ipa: 'ipapath'
            })
          end").runner.execute(:test)
        end.to raise_error("Please only give IPA path or APK path (not both)")
      end
    end
  end
end
