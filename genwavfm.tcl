#!/usr/bin/tclsh

# Parse arguments
set inputPath [lindex $argv 1]
set outputPath [lindex $argv 3]

# Ensure directory paths end in slashes
if {[string index $inputPath end] != "/"} {
    append inputPath "/"
}
if {[string index $outputPath end] != "/"} {
    append outputPath "/"
}

# Main part of script
set artists [glob -directory $inputPath *]
foreach artist $artists {
    set albums [glob -dir $artist *]
    foreach album $albums {
        set mp3s [glob -dir $album *.mp3]
        foreach mp3 $mp3s {
            set artistB [file tail $artist]
            set albumB [file tail $album]
            set mp3B [file tail $mp3]
            set result [exec ffprobe -v error -show_entries format=duration "$mp3"]
            regexp {\d+\.\d+} $result length
            set length [expr ceil($length)]
            if {$artistB == "Various Artists"} {
                set outputFile [join [list "VA_" $albumB "_" $mp3B] ""]
            } else {
                set outputFile [join [list $artistB "_" $albumB "_" $mp3B] ""]
            }
            set outputFile [string map {" " "_"} $outputFile]
            set outputFile [string map {"mp3" "png"} $outputFile]
            set outputFile [join [list $outputPath $outputFile] ""]

            exec audiowaveform -i "$mp3" -o $outputFile -e $length -w 1600 -h 500
        }
    }
}
