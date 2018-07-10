#!/usr/bin/env perl6
use File::Find;

sub MAIN (Str :i($input), Str :o($output))
{
    # Parse paths and ensure they end in slashes
    my %options = input => $input, output => $output;
    %options<input> = %options<input> ~ '/' unless %options<input>.match(/\/$/);
    %options<output> = %options<output> ~ '/' unless %options<output>.match(/\/$/);

    # Iterate over each mp3 file
    my @mp3s = find(dir => %options<input>, name => /.mp3$/);
    for @mp3s -> $file
    {
        my $artist = $file.IO.parent.parent.basename;
        my $album = $file.IO.parent.basename;
        my $length = qq:x/ffprobe -v error -show_entries format=duration "$file"/;
        $length.match(/(\d+)\.(\d+)/);
        $length = ceiling($/);
        my $output_filename;

        if ($artist ~~ 'Various Artists')
        {
            $output_filename = 'VA_' ~ $album ~ '_' ~ $file.basename;
            $output_filename .= subst(/\s/, '_', :g);
            $output_filename .= subst(/mp3/, 'png');
        }
        else
        {
            $output_filename = $artist ~ '_' ~ $album ~ '_' ~ $file.basename;
            $output_filename .= subst(/\s/, '_', :g);
            $output_filename .= subst(/mp3/, 'png');
        }

        $output_filename = %options<output> ~ $output_filename;
        run 'audiowaveform', '-i', $file.absolute, '-o', $output_filename, '-e', $length, '-w', '1600', '-h', '500';
    }
}
