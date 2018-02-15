#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use File::Find;
use MP3::Info;
use POSIX;
use feature qw{ say };

find(\&generate_waveform, '.');

sub generate_waveform
{
    my $file = $File::Find::name;
    if ($file =~ /\.mp3$/i)
    {
        my $artist = dirname(dirname($file));
        my $album = basename(dirname($file));
        $artist =~ s/\.\///g;
        my $info = get_mp3info(basename($file));
        my $length = $info->{SECS};
        $length = ceil($length);
        my $output_filename;
        
        if ($artist =~ 'Various Artists')
        {
            $output_filename = 'VA_' . $album . '_' . basename($file);
            $output_filename =~ s/ /_/g;
            $output_filename =~ s/mp3/png/g;
        }
        else
        {
            $output_filename = $artist . '_' . $album . '_' . basename($file);
            $output_filename =~ s/ /_/g;
            $output_filename =~ s/mp3/png/g;
        }

        $output_filename = '/home/michael/Temp/' . $output_filename;
        $file =~ s/\./\/home\/michael\/Music/;
        system('audiowaveform', '-i', $file, '-o', $output_filename, '-e', $length, '-w', '1600', '-h', '500');
    }
}
