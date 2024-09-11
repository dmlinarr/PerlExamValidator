use strict;
use warnings;
use v5.36;
use List::Util 'shuffle';
use POSIX 'strftime';
use lib './lib';

use Exam_Reader;
use Exam_Writer ':subs';
use Regex ':regex';

# Reads in a master muliple choice exam, randomizes the questions and answers options, and then creates a randomized multiple choice file out of it
sub create_random_exam ($reader){
    # Create a number bucket from 1 till total amount of questions in the master exam.
    my $question_num = $reader->question_amount();
    my @num_bucket = shuffle(1 .. $question_num);
    my $count = 1;

    # Writes the introduction into the randomized multiple choice exam.
    my $intro = $reader->get_layout(0);
    Exam_Writer::write_intro_or_outro($intro);
    
    # Graps a number randomly out of the bucket. 
    while (my $num = shift (@num_bucket)) {  
        
        # Get the normalized question from the master exam according the number, then randomize the order of the normalized answer options. 
        my $norm_question = $reader->question_through_num($num);
        my @random_norm_answers = shuffle($reader->all_answers_through_norm_question($norm_question));

        # Make layout, question and answers ready in their print form.
        # The number for each question must be adjusted according their order.
        my $layout = $reader->get_layout($num);
        my $question = $reader->printed_question_through_norm($norm_question);
        $question =~ s{$Regex::QUESTION_PATTERN_REPLACE}{$count++}e;
        my @random_answers = map { $reader->printed_answer_through_norm($_) } @random_norm_answers;
        
        # Writes the question in the randomized multiple choice exam.
        Exam_Writer::write_one_question($layout, $question, @random_answers);
    }

    # Writes the concluding into the randomized multiple choice exam.
    my $outro = $reader->get_layout($question_num+1);
    Exam_Writer::write_intro_or_outro($outro);
}

# Randomized multiple choice exam receives the name YYYYMMDD-HHMMSS-<name of master multiple choice exam file>.
my $exam_name = strftime('%Y%m%d-%H%M%S-', localtime());
if ($ARGV[0] =~ $Regex::FILENAME_PATTERN_REGEX) {
    $exam_name .= "$1";
}

# Reads in master multiple choice exam file and creates randomized multiple choice exam.
my $reader = Exam_Reader->new($ARGV[0]);
Exam_Writer::load_file($exam_name);
create_random_exam($reader);

=head1 NAME 

Exam_Randomizer - Reads in master multiple choice exam file and creates randomized multiple choice exam.

=head1 USAGE 
    
    # To create and store randomized multiple choice exam in the folder resource/output-exam.
    perl src/Exam_Randomizer.pl resource/normal-exam/IntroPerlEntryExam.txt
    perl src/Exam_Randomizer.pl resource/short-exam/IntroPerlEntryExamShort.txt
    
=head1 REQUIRED ARGUMENTS 

The first argument should specify the path to the master multiple choice exam file, which is located in a subfolder of ./resource.

=head1 DESCRIPTION

This module reads a master multiple choice exam, randomizes the order of questions and answer options, 
and generates a new randomized exam file.
The output file is named based on the current timestamp and the name of the master exam file.

The master multiple-choice exam should look like: 

INSTRUCTIONS:
...

__________________________________________________

1. First question:

    [X] First answer
    [ ] Second answer
    [ ] Third answer
    ...

...

__________________________________________________

N. Last question:

    [X] Last first answer
    [ ] Last second answer
    [ ] Last third answer
    ...

==================================================

                    END OF EXAM

==================================================


=head1 DIAGNOSTICS 

Could not open file: Make sure that the master muliple choice exam file is readable 
and uses the format described by the description section. 

=head1 CONFIGURATION AND ENVIRONMENT 

Exam_Randomizer requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later.
It requires the following module:
    
    List::Util
    POSIX
    Exam_Reader
    Exam_Writer
    Regex

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This application is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.