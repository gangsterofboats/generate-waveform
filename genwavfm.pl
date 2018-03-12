#!/usr/bin/env perl
use strict;
use warnings;
use File::Basename;
use File::Find;
use Getopt::Long;
use MP3::Info;
use POSIX;
use feature qw{ say };

# Parse arguments
GetOptions(
    'input|i=s' => \my $input,
    'output|o=s' => \my $output
);
my %options = ( input => $input, output => $output );

# Ensure directory paths end in slashes
$options{input} .= '/' unless substr($options{input}, -1) =~ m/\//;
$options{output} .= '/' unless substr($options{output}, -1) =~ m/\//;

# Sub to feed to File::Find sub
sub generate_waveform
{
    my $file = $File::Find::name;
    if ($file =~ /\.mp3$/i)
    {
        my $artist = basename(dirname(dirname($file)));
        my $album = basename(dirname($file));
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

        $output_filename = $options{output} . $output_filename;
        system('audiowaveform', '-i', $file, '-o', $output_filename, '-e', $length, '-w', '1600', '-h', '500');
    }
}

# Main part of script
find(\&generate_waveform, $options{input});
