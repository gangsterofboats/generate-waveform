#!/usr/bin/env ruby
require 'mp3info'
require 'optparse'

# Input/output directory options
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: genwavfm.rb --input PATH --output PATH"

  opts.on("-i", "--input PATH", "Input path") do |i|
    options[:input] = i
  end

  opts.on("-o", "--output PATH", "Output path") do |o|
    options[:output] = o
  end
end
optparse.parse!

mp3s = Dir.glob(options[:input] + '**/*.mp3')
mp3s.each do |f|
  # Get the artist and album from the filepath
  artist = File.basename(File.dirname(File.dirname(f)))
  album = File.basename(File.dirname(f))
  # Workaround for audiowaveform bug; seemingly it should read length
  # correctly and automatically, but it doesn't for me
  length = Mp3Info.open(f).length
  length = length.ceil

  if artist == 'Various Artists' # Soundtracks and compilations
    output_filename = 'VA_' + album + '_' + File.basename(f)
    output_filename.gsub!(/ /, '_')
    output_filename.gsub!(/mp3/, 'png')
  else # All else
    output_filename = artist + '_' + album + '_' + File.basename(f)
    output_filename.gsub!(/ /, '_')
    output_filename.gsub!(/mp3/, 'png')
  end

  output_filename = options[:output] + output_filename

  system('audiowaveform', '-i', File.absolute_path(f), '-o', output_filename, '-e', length.to_s, '-w', '1600', '-h', '500')
end
