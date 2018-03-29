#!/usr/bin/env crystal
require "option_parser"

# Parse arguments
options = {} of Symbol => String
OptionParser.parse! do |opts|
  opts.banner = "Usage: genwavfm.cr --input PATH --output PATH"

  opts.on("-i", "--input PATH", "Input path") { |i| options[:input] = i }
  opts.on("-o", "--output PATH", "Output path") { |o| options[:output] = o }
end

# Ensure directory paths end in slashes
options[:input] += "/" unless options[:input][-1] == "/"
options[:output] += "/" unless options[:output][-1] == "/"

mp3s = Dir.glob(options[:input] + "**/*.mp3")
mp3s.each do |f|
  # Get the artist and album from the filepath
  artist = File.basename(File.dirname(File.dirname(f)))
  album = File.basename(File.dirname(f))

  # Workaround for audiowaveform bug; seemingly it should read length
  # correctly and automatically, but it doesn't for me
  result = `ffprobe -v error -show_entries format=duration \"#{f}\"`
  length = result.match(/\d+\.\d+/)
  length = length[0].to_f.ceil if length

  if artist == "Various Artists" # Soundtracks and compilations
    output_filename = "VA_" + album + "_" + File.basename(f)
  else # All else
    output_filename = artist + "_" + album + "_" + File.basename(f)
  end
  output_filename = output_filename.gsub(/ /, "_")
  output_filename = output_filename.gsub(/mp3/, "png")
  output_filename = options[:output] + output_filename

  system("audiowaveform -i \"#{File.expand_path(f)}\" -o \"#{output_filename}\" -e #{length.to_s} -w 1600 -h 500")
end
