#!/usr/bin/elixir
{options, _, _} = OptionParser.parse(System.argv(), switches: [input: :string, output: :string], aliases: [i: :input, o: :output])

# Ensure paths end in slashes
input_path = cond do
  String.last(options[:input]) != "/" -> options[:input] <> "/"
  true -> options[:input]
end
output_path = cond do
  String.last(options[:output]) != "/" -> options[:output] <> "/"
  true -> options[:output]
end

mp3s = Path.wildcard(input_path <> "**/*.mp3")
for f <- mp3s do
    artist = Path.basename(Path.dirname(Path.dirname(f)))
    album = Path.basename(Path.dirname(f))
    {length, _} = System.cmd("ffprobe", ["-v", "error", "-show_entries", "format=duration", f])
    {length, _} = Float.parse(hd(Regex.run(~r/\d+\.\d+/, length)))

    output_file = cond do
      artist == "Various Artists" -> "VA_" <> album <> "_" <> Path.basename(f, ".mp3") <> ".png"
      true -> artist <> "_" <> album <> "_" <> Path.basename(f, ".mp3") <> ".png"
    end
    output_file = String.replace(output_file, " ", "_")
    output_file = output_path <> output_file

    System.cmd("audiowaveform", ["-i", f, "-o", output_file, "-e", Float.to_string(length), "-w", "1600", "-h", "500"])
end
