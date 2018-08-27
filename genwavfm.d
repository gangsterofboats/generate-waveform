import std.algorithm;
import std.conv;
import std.file;
import std.getopt;
import std.math;
import std.path;
import std.process;
import std.regex;
import std.stdio;
import std.string;

// Struct to group getopt arguments
struct Op
{
    string inputPath;
    string outputPath;
}

void main(string[] args)
{
    Op options;
    getopt(
        args,
        "input|i", &options.inputPath,
        "output|o", &options.outputPath,
    );

    // Ensure directory paths end in slashes
    if (options.inputPath[options.inputPath.length - 1] != '/')
    {
        options.inputPath = options.inputPath ~ "/";
    }
    if (options.outputPath[options.outputPath.length - 1] != '/')
    {
        options.outputPath = options.outputPath ~ "/";
    }

    auto mp3s = dirEntries(options.inputPath, SpanMode.depth).filter!(item => item.name.endsWith(".mp3"));
    foreach (f; mp3s)
    {
        string artist = baseName(dirName(dirName(f)));
        string album = baseName(dirName(f));
        auto stdo = executeShell(format("ffprobe -v error -show_entries format=duration \"%s\"", f));
        auto tms = regex(r"\d+\.\d+");
        auto mtch = matchFirst(stdo[1], tms);
        auto length = ceil(to!double(mtch[0]));
        string outputFile = "";

        if (artist == "Various Artists")
        {
            outputFile = "VA_" ~ album ~ "_" ~ baseName(f);
        }
        else
        {
            outputFile = artist ~ "_" ~ album ~ "_" ~ baseName(f);
        }
        outputFile = replaceAll(outputFile, regex(" "), "_");
        outputFile = replaceAll(outputFile, regex("mp3"), "png");
        outputFile = options.outputPath ~ outputFile;

        executeShell(format("audiowaveform -i \"%s\" -o %s -e %s -w 1600 -h 500", f, outputFile, length));
    }
}
