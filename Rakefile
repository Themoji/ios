
task :fetch_emojis do
  require 'fileutils'

  original = "/System/Library/Fonts/Apple Color Emoji.ttf"
  FileUtils.cp(original, "./TheMoji")
end

task :default => [:fetch_emojis]
