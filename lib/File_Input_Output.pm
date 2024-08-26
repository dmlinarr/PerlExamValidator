package File_Input_Output;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    subs => qw ( load_file ),
);

my %data = ();

sub load_file ($filename) {
    open(my $fh_in, '<', $filename) or die ("Could not open file: $filename");
    
    while (my $line = readline($fh_in)) {
        print $line;           
    }
}

sub get_header () {
    if (%data) {
        # give back data{'header'}
    }
    else {
        die ("File needs to be loaded first");
    }
}

sub get_question_num () {
    if (%data) {
        # give back data{'header'}
    }
    else {
        die ("File needs to be loaded first");
    }
}

sub get_answers ($question) {
    if (%data) {
        # give back data{'header'}
    }
    else {
        die ("File needs to be loaded first");
    }
}

sub get_question() {
    if (%data) {
        # give back data{'header'}
    }
    else {
        die ("File needs to be loaded first");
    }
}

1;