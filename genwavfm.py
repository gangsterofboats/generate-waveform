#!/usr/bin/env python
import argparse
import glob
import math
import os
import subprocess
from mutagen.mp3 import MP3

# Parse the arguments
parser = argparse.ArgumentParser(description='A waveform image generator')
parser.add_argument('-i', '--input', required=True, help='Input directory')
parser.add_argument('-o', '--output', required=True, help='Output directory')
options = parser.parse_args()

# Ensure the directory paths end in slashes
if (options.input[-1] != '/'):
    options.input = options.input + '/'
if (options.output[-1] != '/'):
    options.output = options.output + '/'

# Main part of script
mp3s = glob.glob(options.input + '**/*.mp3', recursive=True)
for f in mp3s:
    artist = os.path.basename(os.path.dirname(os.path.dirname(f)))
    album = os.path.basename(os.path.dirname(f))
    length = MP3(f).info.length
    length = math.ceil(length)

    if artist == 'Various Artists':
        output_filename = 'VA_' + album + '_' + os.path.basename(f)
        output_filename = output_filename.replace(' ', '_')
        output_filename = output_filename.replace('mp3', 'png')
    else:
        output_filename = artist + '_' + album + '_' + os.path.basename(f)
        output_filename = output_filename.replace(' ', '_')
        output_filename = output_filename.replace('mp3', 'png')

    output_filename = options.output + output_filename

    subprocess.run(['audiowaveform', '-i', os.path.abspath(f), '-o', output_filename, '-e', str(length), '-w', '1600', '-h', '500'])
