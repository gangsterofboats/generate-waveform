#!/usr/bin/env python
import glob
import math
import os
import subprocess
from mutagen.mp3 import MP3

mp3s = glob.glob('**/*.mp3', recursive=True)
for f in mp3s:
    artist = os.path.dirname(os.path.dirname(f))
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

    output_filename = '/home/michael/Temp/' + output_filename

    subprocess.run(['audiowaveform', '-i', os.path.abspath(f), '-o', output_filename, '-e', str(length), '-w', '1600', '-h', '500'])
