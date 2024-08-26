package Regex;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    regex => qw ( $REGEX ),
);

our $REGEX = "I am a regex\n";

1;