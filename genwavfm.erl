#!/usr/bin/env escript
-export([main/1]).

main(Args) ->
    Mp3s = filelib:fold_files(".", ".*mp3", true, fun(File, Acc) -> [File|Acc] end, []),
    lists:foreach(fun(L) ->
                          generate_waveform(L)
                  end, Mp3s).

generate_waveform(List) ->
    Trtst = filename:dirname(filename:dirname(List)),
    Artist = string:replace(Trtst, "./", ""),
    Album = filename:basename(filename:dirname(List)),
    Lcmd = io_lib:format("ffprobe -v error -show_entries format=duration \"~s\"", [filename:absname(List)]),
    Tlen = os:cmd(io_lib:format("~s", [Lcmd])),
    {_, Tlen2} = re:run(Tlen, "[0-9]+\.[0-9]+", [{capture, all, list}]),
    {Tlen3, _} = string:to_float(Tlen2),
    Length = erlang:trunc(math:ceil(Tlen3)),

    case string:equal(Artist, "Various Artists") of
        true ->
            Opfn = io_lib:format("VA_~s_~s", [Album, filename:basename(List)]),
            Oupufina = re:replace(Opfn, " ", "_", [global, {return, list}]),
            io:format("~s\n", [Oupufina]);
        false ->
            Opfn = io_lib:format("~s_~s_~s", [Artist, Album, filename:basename(List)]),
            Oupufina = re:replace(Opfn, " ", "_", [global, {return, list}]),
            io:format("~s\n", [Oupufina])
    end.
    


%% io:format("~s\n", [string:join(Args, " ")]),

    %% if artist == 'Various Artists':
        %% output_filename = 'VA_' + album + '_' + os.path.basename(f)
        %% output_filename = output_filename.replace(' ', '_')
        %% output_filename = output_filename.replace('mp3', 'png')
    %% else:
        %% output_filename = artist + '_' + album + '_' + os.path.basename(f)
        %% output_filename = output_filename.replace(' ', '_')
        %% output_filename = output_filename.replace('mp3', 'png')

    %% output_filename = '/home/michael/Temp/' + output_filename

    %% subprocess.run(['audiowaveform', '-i', os.path.abspath(f), '-o', output_filename, '-e', str(length), '-w', '1600', '-h', '500'])
