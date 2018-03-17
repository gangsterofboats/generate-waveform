require 'lfs'

-- Parse arguments
inputpath = arg[2]
outputpath = arg[4]

-- Ensure directory paths end in slashes
if string.sub(inputpath, -1) ~= '/' then
   inputpath = inputpath .. '/'
end

if string.sub(outputpath, -1) ~= '/' then
   outputpath = outputpath .. '/'
end

-- Main part of script
for artist in lfs.dir(inputpath) do
   if artist ~= "." and artist ~= ".." then
      for album in lfs.dir(inputpath .. artist) do
         if album ~= "." and album ~= ".." then
            for mp3 in lfs.dir(inputpath .. artist .. '/' .. album) do
               if mp3:match("%.mp3$") then
                  ffpath = inputpath .. artist .. '/' .. album .. '/' .. mp3
                  ch = io.popen('ffprobe -v error -show_entries format=duration "' .. ffpath .. '"')
                  result = ch:read('*a')
                  length = string.match(result, "%d+.%d+")
                  length = math.ceil(length)

                  if artist == 'Various Artists' then
                     outputF = 'VA_' .. album .. '_' .. mp3
                  else
                     outputF = artist .. '_' .. album .. '_' .. mp3
                  end
                  outputF = string.gsub(outputF, ' ', '_')
                  outputF = string.gsub(outputF, 'mp3', 'png')
                  outputF = outputpath .. outputF

                  os.execute('audiowaveform -i "' .. ffpath .. '" -o ' .. outputF .. ' -e ' .. length .. ' -w 1600 -h 500')
               end
            end
         end
      end
   end
end
