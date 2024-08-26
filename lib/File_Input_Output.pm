package File_Input_Output;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    subs => qw( read ),
);

sub read () {
    return "I am a read function\n";
}

1;