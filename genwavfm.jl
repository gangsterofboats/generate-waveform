#!/usr/bin/env julia

# Parse arguments
inputpath = ARGS[2]
outputpath = ARGS[4]

# Ensure directory paths end in slashes
if inputpath[end] != '/'
    inputpath = inputpath * "/"
end

if outputpath[end] != '/'
    outputpath = outputpath * "/"
end

# Main part of script
for (root, dirs, files) in walkdir(inputpath)
    mp3s = filter(x -> contains(x, "mp3"), files)
    for mp3 in mp3s
        # Set artist and album variables; ffpath for system commands
        artist = basename(dirname(root))
        album = basename(root)
        ffpath = joinpath(root, mp3)

        # Get length of mp3 via ffprobe
        length = readstring(`ffprobe -v error -show_entries format=duration $ffpath`)
        length = match(r"\d+\.\d+", length)
        length = ceil(float(length.match))

        if artist == "Various Artists" # Soundtracks/compilations
            output_filename = "VA_" * album * "_" * mp3
        else # Everything else
            output_filename = artist * "_" * album * "_" * mp3
        end
        output_filename = replace(output_filename, " ", "_")
        output_filename = replace(output_filename, "mp3", "png")
        outputP = joinpath(outputpath, output_filename)

        run(`audiowaveform -i $ffpath -o $outputP -e $length -w 1600 -h 500`)
    end
end
