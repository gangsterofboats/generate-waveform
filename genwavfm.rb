#!/usr/bin/env ruby
require 'mp3info'

mp3s = Dir.glob('**/*.mp3')
mp3s.each do |f|
  artist = File.dirname(File.dirname(f))
  album = File.basename(File.dirname(f))
  length = Mp3Info.open(f).length
  length = length.ceil

  if artist == 'Various Artists'
    output_filename = 'VA_' + album + '_' + File.basename(f)
    output_filename.gsub!(/ /, '_')
    output_filename.gsub!(/mp3/, 'png')
  else
    output_filename = artist + '_' + album + '_' + File.basename(f)
    output_filename.gsub!(/ /, '_')
    output_filename.gsub!(/mp3/, 'png')
  end
  output_filename = '/home/michael/Temp/' + output_filename
  
  system('audiowaveform', '-i', File.absolute_path(f), '-o', output_filename, '-e', length.to_s, '-w', '1600', '-h', '500')
end
