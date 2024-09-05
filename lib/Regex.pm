package Regex;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    regex => qw ( 
        $STARTLINE_EXERCISE_DETECT
        $ENDLINE_EXAM_DETECT

        $WHITESPACE_START_END_DETECT
        $WHITESPACE_MULTIPLE_DETECT
        $WHITESPACE_SINGLE_DETECT

        $QUESTION_NUM_DETECT
        $QUESTION_PATTERN_REPLACE
        $ANSWER_BRACKET_DETECT
        $ANSWER_MARK_DETECT
        $ANSWER_PATTERN_REPLACE
        
        $LINE_BREAK_DETECT
        $FILENAME_PATTERN_REGEX
        $LAYOUTSPLIT_PATTERN_REGEX
    ),
);

our $STARTLINE_EXERCISE_DETECT = qr{^_{2,}$};
our $ENDLINE_EXAM_DETECT = qr{^={2,}$};

our $WHITESPACE_START_END_DETECT = qr{^\s+|\s+$};
our $WHITESPACE_MULTIPLE_DETECT = qr{\s{2,}};
our $WHITESPACE_SINGLE_DETECT = qr{^\s*$};

our $QUESTION_NUM_DETECT = qr{^\d+\.\s*};
our $QUESTION_PATTERN_REPLACE = qr{^\d+};
our $ANSWER_BRACKET_DETECT = qr{^\[\s*.*?\]\s*};
our $ANSWER_MARK_DETECT = qr{^\s*\[\s*\S+\s*\]};
our $ANSWER_PATTERN_REPLACE = qr{\[\s*\S\s*\](.*)};

our $LINE_BREAK_DETECT = qr{\R};
our $FILENAME_PATTERN_REGEX = qr{([^/]+)$};
our $LAYOUTSPLIT_PATTERN_REGEX = qr{^(.*?)(?:Q)(.*?)(?:A)(.*)$}s;

1;