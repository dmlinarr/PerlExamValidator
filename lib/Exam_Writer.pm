package Exam_Writer;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    subs => qw( 
        load_file 
        write_one_question 
        write_other
    ), 
);

my $fh_out;

sub load_file ($filename) {
    my $path = "./resource/output-exam/$filename";
    open ($fh_out, '>', $path) or die ("Could not create file: $filename");
}

sub write_other ($other) {
    if (defined $fh_out) {
        print ($fh_out $other);
    } 
    else {
        die ("File handle is not opened.");
    }
}

sub write_one_question ($question, @answers) {
    if (defined $fh_out) {
        print ($fh_out $question);
        for my $answer (@answers) {
            print ($fh_out $answer);
        }
    } 
    else {
        die ("File handle is not opened.");
    }
}

1;