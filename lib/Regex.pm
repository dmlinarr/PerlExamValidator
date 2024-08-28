package Regex;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    regex => qw ( 
        $QUESTION_START_DETECT_REGEX
        $QUESTION_END_DETECT_REGEX 
        $QUESTION_PATTERN_REGEX 

        $ANSWER_START_DETECT_REGEX 
        $ANSWER_END_DETECT_REGEX 
        $ANSWER_PATTERN_REGEX 

        $STARTLINE_DETECT_REGEX
        $ENDLINE_DETECT_REGEX 
        
        $FILENAME_PATTERN_REGEX
        $LAYOUTSPLIT_PATTERN_REGEX
        ... 
    ),
);

our $QUESTION_START_DETECT_REGEX = qr{^\d+\.};
our $QUESTION_END_DETECT_REGEX = qr{^\s*$};
our $QUESTION_PATTERN_REGEX = qr{^\d+};

our $ANSWER_START_DETECT_REGEX = qr{\[[X ]\]};
our $ANSWER_END_DETECT_REGEX = qr{^\s*$};
our $ANSWER_PATTERN_REGEX = qr{\[X\](.*)};

our $STARTLINE_DETECT_REGEX = qr{^_{2,}$};
our $ENDLINE_DETECT_REGEX = qr{^={2,}$};

our $FILENAME_PATTERN_REGEX = qr{([^/]+)$};
our $LAYOUTSPLIT_PATTERN_REGEX = qr{^(.*?)(?:Q)(.*?)(?:A)(.*)$}s;

1;