package Exam_Writer;

use v5.36;
use warnings;
use strict;
use Exporter 'import';
use lib './lib';

use Regex ':regex';

our %EXPORT_TAGS = (
    subs => qw( 
        load_file 
        write_one_question 
        write_intro_or_outro
    ), 
);

my $fh_out;

sub load_file ($filename) {
    my $path = "./resource/output-exam/$filename";
    open ($fh_out, '>', $path) or die ("Could not create file: $filename");
}

sub write_intro_or_outro ($input) {
    if (defined $fh_out) {
        print ($fh_out $input);
    } 
    else {
        die ("File handle is not opened.");
    }
}

sub write_one_question ($layout, $question, @answers) {
    if (defined $fh_out) {
        my ($pre, $middle, $post) = $layout =~ $Regex::LAYOUTSPLIT_PATTERN_REGEX;
        
        print ($fh_out $pre);
        print ($fh_out $question);
        print ($fh_out $middle);
        for my $answer (@answers) {
            print ($fh_out $answer);
        }
        print ($fh_out $post);
    } 
    else {
        die ("File handle is not opened.");
    }
}

1;