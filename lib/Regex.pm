package Regex;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    regex => qw ( 
        $QUESTION_START_DETECT_REGEX
        $QUESTION_END_DETECT_REGEX
        $ANSWER_DETECT_REGEX
        
        $QUESTION_PATTERN_REGEX
        $ANSWER_PATTERN_REGEX
    ),
);

our $QUESTION_START_DETECT_REGEX = qr{^\d+\.};
our $QUESTION_END_DETECT_REGEX = qr{(\?\s*|\.\.\.\s*|:\s*)\n$};;
our $ANSWER_DETECT_REGEX = qr{\[[X ]\]};

our $QUESTION_PATTERN_REGEX = qr{^\d+};
our $ANSWER_PATTERN_REGEX = qr{\[X\](.*)};

1;