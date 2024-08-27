package Regex;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    regex => qw ( 
        $QUESTION_DETECT_REGEX 
        $ANSWER_DETECT_REGEX

        $ANSWER_PATTERN_REGEX
    ),
);

our $QUESTION_DETECT_REGEX = qr{^\d+\.};
our $ANSWER_DETECT_REGEX = qr{\[[X ]\]};

our $ANSWER_PATTERN_REGEX = qr{\[X\](.*)};

1;