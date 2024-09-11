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

# Filehandler returned by load_file.
my $fh_out;

# Creates a file in the output-exam folder and returns a filehandler.
sub load_file ($filename) {
    my $path = "./resource/output-exam/$filename";
    open ($fh_out, '>', $path) or die ("Could not create file: $filename");
}

# Used for writing the intro or outro for the multiple choice exam.
sub write_intro_or_outro ($input) {
    if (defined $fh_out) {
        print ($fh_out $input);
    } 
    else {
        die ("File handle is not opened.");
    }
}

# Used for writing one question for the multiple choice exam. 
sub write_one_question ($layout, $question, @answers) {
    if (defined $fh_out) {
        
        # Split the layout into three parts: before "Q", between "Q" and "A", and after "A".
        my ($pre, $middle, $post) = $layout =~ $Regex::LAYOUTSPLIT_PATTERN_REGEX;
        
        # 1. pre layout, 2. question, 3. middle layout, 4. answers, 5. post layout.
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

=head1 NAME 

Exam_Writer - Writes a multiple choice exam into a file.

=head1 SYNOPSIS 
    
    # To import the module.
    use Exam_Writer ':subs';
    
    # Create file and load filehandler.
    Exam_Writer::load_file ($filename)

    # Used for writing the intro or outro for the multiple choice exam.
    Exam_Writer::write_intro_or_outro ($input)

    # Used for writing one question for the multiple choice exam. 
    sub write_one_question ($layout, $question, @answers)

=head1 DESCRIPTION 

The module provides functions for creating and writing 
to a file for generating multiple-choice exams.

=head1 SUBROUTINES/METHODS 

"load_file ($filename)"
    
    # Creates a file in the "output-exam" folder and opens it for writing.
    $filename: The name for the file.
    
"write_intro_or_outro ($input)"
    
    # Writes introductory or concluding text to the open file.
    $input: Text to write into the open file.

"write_one_question ($layout, $question, @answers)"
    
    # Writes a formatted multiple-choice question with its answers to the open file.
    $layout: Will be splitted into pre, middle and post string, separated by before "Q", between "Q" and "A", and after "A".
    $question: Question string.
    @answers: Set of possible answers for the question.

=head1 DIAGNOSTICS 

File could not be created: Make sure that there is a ./resource/output-exam/ folder.
Filehandle not defined: Make sure to first load the file befor using write subroutines.

=head1 CONFIGURATION AND ENVIRONMENT 

Exam_Writer requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later. Requires the Regex module.

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 
