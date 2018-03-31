#!/usr/bin/env nim
import math, os, ospaths, osproc, parseopt, re, strutils

# Parse arguments
var options: tuple[inputPath: string, outputPath: string]
for kind, key, val in getopt():
  case kind
  of cmdArgument:
    continue
  of cmdLongOption, cmdShortOption:
    case key
    of "input", "i": options.inputPath = val
    of "output", "o": options.outputPath = val
  of cmdEnd: assert(false)

# Ensure directory paths end in slashes
if options.inputPath[^1] != '/':
  options.inputPath = options.inputPath & "/"
if options.outputPath[^1] != '/':
  options.outputPath = options.outputPath & "/"

# Main part of program
for file in walkDirRec(options.inputPath):
  if file.contains(re"mp3") == true:
    var spPath = file.split(re"/")
    var artist = spPath[4]
    var album = spPath[5]

    var result = execProcess("ffprobe -v error -show_entries format=duration \"$1\"" % [file])
    var lmArr = result.findAll(re"\d+\.\d+")
    var length = ceil(parseFloat(lmArr[0]))
    var outputFile: string

    if artist == "Various Artists":
      outputFile = "VA_" & album & "_" & spPath[6]
    else:
      outputFile = artist & "_" & album & "_" & spPath[6]

    outputFile = outputFile.replace(" ", "_")
    outputFile = outputFile.replace("mp3", "png")
    outputFile = options.outputPath & outputFile

    let errC = execCmd("audiowaveform -i \"$1\" -o \"$2\" -e $3 -w 1600 -h 500" % [file, outputFile, length.formatFloat(ffDecimal, 3)])
