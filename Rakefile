
task :fetch_emojis do
  require 'fileutils'

  original = "/System/Library/Fonts/Apple Color Emoji.ttf"
  raise "Could not find font file at path '#{original}'" unless File.exist?(original)
  FileUtils.cp(original, "./TheMoji")
  puts "Successfully fetched Emoji font"
end

task :default => [:fetch_emojis]
