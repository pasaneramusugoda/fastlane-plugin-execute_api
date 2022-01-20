require 'fastlane/action'
require 'rest-client'
require_relative '../helper/execute_api_helper'

module Fastlane
  module Actions
    class ExecuteApiAction < Action
      def self.run(config)
        params = {}
        # extract parms from config received from fastlane
        params[:uploadArtifacts] = config[:uploadArtifacts]
        params[:endPoint] = config[:endPoint]
        params[:apk] = config[:apk]
        params[:ipa] = config[:ipa]
        params[:file] = config[:file]
        params[:method] = config[:method]

        params[:multipartPayload] = config[:multipartPayload]
        params[:headers] = config[:headers]

        upload_artifacts = params[:uploadArtifacts]
        apk_file = params[:apk]
        ipa_file = params[:ipa]
        custom_file = params[:file]
        
        end_point = params[:endPoint]

        UI.user_error!("No endPoint given, pass using endPoint: 'endpoint'") if end_point.to_s.length == 0 && end_point.to_s.length == 0
        UI.user_error!("No IPA or APK or a file path given, pass using `ipa: 'ipa path'` or `apk: 'apk path' or file:`") if upload_artifacts && ipa_file.to_s.length == 0 && apk_file.to_s.length == 0 && custom_file.to_s.length == 0
        UI.user_error!("Please only give IPA path or APK path (not both)") if upload_artifacts && ipa_file.to_s.length > 0 && apk_file.to_s.length > 0

        if upload_artifacts
          upload_custom_file(params, apk_file) if apk_file.to_s.length > 0
          upload_custom_file(params, ipa_file) if ipa_file.to_s.length > 0
          upload_custom_file(params, custom_file) if custom_file.to_s.length > 0
        else
          multipart_payload = params[:multipartPayload]
          multipart_payload[:multipart] = false
          upload_request(params, multipart_payload)
        end
      end

      def self.upload_custom_file(params, custom_file)
        multipart_payload = params[:multipartPayload]
        multipart_payload[:multipart] = true
        if multipart_payload[:fileFormFieldName]
          key = multipart_payload[:fileFormFieldName]
          multipart_payload["#{key}"] = File.new(custom_file, 'rb')
        else
          multipart_payload[:file] = File.new(custom_file, 'rb')
        end

      UI.message multipart_payload
      upload_request(params, multipart_payload)
      end

      def self.upload_request(params, multipart_payload)
        request = RestClient::Request.new(
          method: params[:method],
          url: params[:endPoint],
          payload: multipart_payload,
          headers: params[:headers],
          log: Logger.new(STDOUT)
        )

        response = request.execute
        UI.message(response)
        if params[:uploadArtifacts]
          UI.success("Successfully finished uploading the fille") if response.code == 200 || response.code == 201
        else
          UI.success("Successfully finished executing the request") if response.code == 200 || response.code == 201
        end
      end

      def self.description
        "This plugin will be used to execute an api"
      end

      def self.authors
        ["Pasan Eramusugoda"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Plugin can be used to execute an api or file upload, which will be usefull when need to notify your self hosted backend"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :uploadArtifacts,
                                  env_name: "",
                                  description: "uploading any file or not",
                                  optional: true,
                                  default_value: false),
          FastlaneCore::ConfigItem.new(key: :apk,
                                  env_name: "",
                                  description: ".apk file for the build",
                                  optional: true,
                                  default_value: Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :ipa,
                                  env_name: "",
                                  description: ".ipa file for the build ",
                                  optional: true,
                                  default_value: Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]),
          FastlaneCore::ConfigItem.new(key: :file,
                                  env_name: "",
                                  description: "file to be uploaded to the server",
                                  optional: true),
          FastlaneCore::ConfigItem.new(key: :multipartPayload,
                                  env_name: "",
                                  description: "payload for the multipart request ",
                                  optional: true,
                                  type: Hash),
          FastlaneCore::ConfigItem.new(key: :headers,
                                    env_name: "",
                                    description: "headers of the request ",
                                    optional: true,
                                    type: Hash),
          FastlaneCore::ConfigItem.new(key: :endPoint,
                                  env_name: "",
                                  description: "file upload request url",
                                  optional: false,
                                  default_value: "",
                                  type: String),
          FastlaneCore::ConfigItem.new(key: :method,
                                  env_name: "",
                                  description: "request method",
                                  optional: true,
                                  default_value: :post,
                                  type: Symbol)

        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        platform == :ios || platform == :android
      end
    end
  end
end
