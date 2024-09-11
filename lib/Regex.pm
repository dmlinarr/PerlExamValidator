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

# Detects the next question when a line with two or more "_" appears.
our $STARTLINE_EXERCISE_DETECT = qr{^_{2,}$};
# Detects the end of the multiple choice exam when a line with two or more "=" appears.
our $ENDLINE_EXAM_DETECT = qr{^={2,}$};

# Detects and captures leading or trailing whitespace characters in a line.
our $WHITESPACE_START_END_DETECT = qr{^\s+|\s+$};
# Detects multiple consecutive spaces in a line. 
our $WHITESPACE_MULTIPLE_DETECT = qr{\s{2,}};
# Detects lines that consist of only whitespace characters (or are empty). 
our $WHITESPACE_SINGLE_DETECT = qr{^\s*$};

# Detects question numbers at the beginning of a line in a typical format (e.g., "1. ", "25. ").
our $QUESTION_NUM_DETECT = qr{^\d+\.\s*};
# Used for replacing question numbers at the beginning of a line. 
our $QUESTION_PATTERN_REPLACE = qr{^\d+};
# Detects answer choices.
our $ANSWER_BRACKET_DETECT = qr{^\[\s*.*?\]\s*};
# Detects choosen answer by matching any character inside brackets.
our $ANSWER_MARK_DETECT = qr{^\s*\[\s*\S+\s*\]};
# Used for replacing the choosen answer bracket with an empty bracket.
our $ANSWER_PATTERN_REPLACE = qr{\[\s*\S\s*\](.*)};

# Detects any kind of line break.
our $LINE_BREAK_DETECT = qr{\R};
# Extracts the filename from a given file path.
our $FILENAME_PATTERN_REGEX = qr{([^/]+)$};
# Used to split a string into three parts: before "Q", between "Q" and "A", and after "A".
our $LAYOUTSPLIT_PATTERN_REGEX = qr{^(.*?)(?:Q)(.*?)(?:A)(.*)$}s;

1;

=head1 NAME 

Regex - Just a file with regex expression to handle formatted multiple choice exams.

=head1 SYNOPSIS 
    
    # To import the module.
    use Regex ':regex';
    
    # Use of regex.
    $Regex::REGEX_EXPRESSION
    
=head1 DESCRIPTION 

This file is designed to handling formatted multiple choice exams 
by making it easier to extract, format, or manipulate lines.
It detects and handles key elements like questions, answers, 
whitespace, and special markers.

=over 

=item B<STARTLINE_EXERCISE_DETECT>

Detects the next question when a line with two or more underscores ("_") appears.

=item B<ENDLINE_EXAM_DETECT>

Detects the end of the multiple choice exam when a line with two or more "=" appears.
 
=item B<WHITESPACE_START_END_DETECT> 

Detects and captures leading or trailing whitespace characters in a line.

=item B<WHITESPACE_MULTIPLE_DETECT>

Detects multiple consecutive spaces in a line. 

=item B<WHITESPACE_SINGLE_DETECT> 

Detects lines that consist of only whitespace characters (or are empty). 

=item B<QUESTION_NUM_DETECT> 

Detects question numbers at the beginning of a line in a typical format (e.g., "1. ", "25. ").

=item B<QUESTION_PATTERN_REPLACE>

Used for replacing question numbers at the beginning of a line. 

=item B<ANSWER_BRACKET_DETECT>

Detects answer choices.

=item B<ANSWER_MARK_DETECT>

Detects choosen answer by matching any character inside brackets.

=item B<ANSWER_PATTERN_REPLACE>

Used for replacing the choosen answer bracket with an empty bracket.

=item B<LINE_BREAK_DETECT>

Detects any kind of line break.

=item B<FILENAME_PATTERN_REGEX>

Extracts the filename from a given file path.

=item B<LAYOUTSPLIT_PATTERN_REGEX>

Used to split a string into three parts: before "Q", between "Q" and "A", and after "A".

=back

=head1 SUBROUTINES/METHODS 

Regex does not have any subroutines.

=head1 DIAGNOSTICS 

Regex does not have any diagnostics.

=head1 CONFIGURATION AND ENVIRONMENT 

Regex requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later.

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 
