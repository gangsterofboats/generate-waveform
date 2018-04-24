#!/usr/bin/escript
-export([main/1]).

main(Args) ->
    % Parse arguments
    InputP = lists:nth(2, Args),
    OutputP = lists:nth(4, Args),

    % Ensure paths end in slashes
    InputPa = case string:sub_string(InputP, length(InputP)) /= "/" of
                  true -> string:concat(InputP, "/");
                  false -> InputP
    end,
    OutputPa = case string:sub_string(OutputP, length(OutputP)) /= "/" of
                  true -> string:concat(OutputP, "/");
                  false -> OutputP
    end,
    Mp3s = filelib:fold_files(InputPa, ".*\.mp3", true, fun(File, Acc) -> [File|Acc] end, []),
    lists:foreach(fun(N) ->
                          generate_waveform(N, OutputPa)
                  end, Mp3s).

% Function to run for each MP3 file
generate_waveform(File, Path) ->
    Album = filename:basename(filename:dirname(File)),
    Artist = filename:basename(filename:dirname(filename:dirname(File))),
    Results = os:cmd(io_lib:format("ffprobe -v error -show_entries format=duration \"~s\"", [File])),
    {_, [Capt]} = re:run(Results, "\\d+\.\\d+", [{capture, first, binary}, global]),
    {Captu, _} = string:to_float(Capt),
    Length = ceil(Captu),
    OutputFi = case Artist == "Various Artists" of
                  true -> io_lib:format("VA_~s_~s.png", [Album, filename:basename(File, ".mp3")]);
                  false -> io_lib:format("~s_~s_~s.png", [Artist, Album, filename:basename(File, ".mp3")])
               end,
    OFilename = re:replace(OutputFi, " ", "_", [global, {return, list}]),
    Output_File = string:concat(Path, OFilename),
    CToRun = io_lib:format("audiowaveform -i \"~s\" -o \"~s\" -e ~p -w 1600 -h 500", [File, Output_File, Length]),
    os:cmd(CToRun).
