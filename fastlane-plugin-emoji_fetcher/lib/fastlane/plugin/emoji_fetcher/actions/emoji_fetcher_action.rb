module Fastlane
  module Actions
    class EmojiFetcherAction < Action
      def self.run(params)
        require 'fileutils'

        paths = ["/System/Library/Fonts/Apple Color Emoji.ttc", "/System/Library/Fonts/Apple Color Emoji.ttf"]
        paths = paths.delete_if? { |a| !File.exist?(a) }
        UI.user_error!("Could not find Emoji font.") if paths.count == 0
        FileUtils.cp(paths.first, params[:path])
        UI.success("Successfully fetched Emoji font")
      end

      def self.description
        "Fetch the emoji font file and copy it into a local directory"
      end

      def self.authors
        ["Felix Krause"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                  env_name: "EMOJI_FETCHER_PATH",
                               description: "Path to which the emoji file should be copied to",
                                  optional: false,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
