package Cheating;

use v5.36;
use warnings;
use strict;

use Exporter 'import';

# Create a possible cheater.
sub new ($class,$filename) {
    my $self = {
        class               => $class,
        filename            => $filename,
        wrong_answers       => {},
        log_cheater         => {},
    };
    
    my $cheater = bless ($self, $class);
    return $cheater;
}

# Add the incorrect answer selected for the question.
sub add_wrong_answer ($self, $norm_master_question, $norm_wrong_answer) {
    $self->{wrong_answers}{$norm_master_question} = $norm_wrong_answer;
}

# Compares the incorrect answers with those of other students.
# Calculates the probability of cheating by dividing the number of identical incorrect answers 
# by the total number of incorrect answers selected.
sub check_if_I_am_cheater ($self, $total_questions, %cheaters) {
    my $amount_wrong_questions = scalar(keys %{$self->{wrong_answers}});
    my $amount_identical_answer = 0;

    # Compare the incorrect answers with those of every other student.
    for my $cheater_name (sort keys %cheaters) {
        next if $cheater_name eq $self->{filename};
        my $cheater = $cheaters{$cheater_name};
        
        # First, check if the same question was answered incorrectly.
        for my $wrong_question (sort keys %{$cheater->{wrong_answers}}) {
            if (exists $self->{wrong_answers}{$wrong_question}) { 

                # Second, if the same question was answered incorrectly, check if the wrong answer is the same.
                if ($self->{wrong_answers}{$wrong_question} eq $cheater->{wrong_answers}{$wrong_question}) {
                    $amount_identical_answer++;
                }
            }
        }
        
        # Calculate the likelihood of cheating by dividing the number of matching incorrect answers 
        # by the total number of incorrect answers selected.
        if ($amount_identical_answer > 0 && $amount_wrong_questions/$total_questions > 0.1) {
            my $probability = int(($amount_identical_answer/$amount_wrong_questions) * 100);

            # Log anything above 50%.
            if ($probability > 50) {
                my $filename = $self->{filename};
                my $log = "     $filename\nand  $cheater_name" . ('.' x (80-length("and   $cheater_name")-length("probability: $probability"))) .  "probability: $probability  ($amount_identical_answer out of $amount_wrong_questions exactly same false)\n";
                $self->{log_cheater}{$cheater_name} = $log;
            }
            $amount_identical_answer = 0;
        }
    }
    
}

1;

=head1 NAME 

Cheating - Detect if someone has cheated on the multiple choice exam.

=head1 SYNOPSIS 
    
    # To import the module.
    use Cheating;
    
    # Create new cheater object.
    my $cheater = Cheating->new($filename);
    
    # Add the incorrect answer selected for the normalized master question.
    $cheater->add_wrong_answer ($norm_master_question, $norm_wrong_answer);
    
    # The %cheaters hashmap is filled with other cheater objects, where key is the $filename.
    # Stores possible cheating logs in the %log_cheater hashmap.
    $cheater->check_if_I_am_cheater ($total_questions, %cheaters);
    
=head1 DESCRIPTION 

This module is for identifying if a student might have cheated by looking at 
how many wrong answers they have in common with other students. If a student 
has too many identical wrong answers compared to someone else, the module logs 
this as a potential cheating case.

=head1 SUBROUTINES/METHODS 

"new ($class,$filename)"
    
    # Creates a new cheater object, which represents a multiple choice test-taker.
    $class: The name of the class (usually Cheating).
    $filename: The name of the test-taker file.

"add_wrong_answer ($self, $norm_master_question, $norm_wrong_answer)"
    
    # Records a wrong answer for a specific question.
    $self: The current student object.
    $norm_master_question: The normalized master question that the student answered wrong.
    $norm_wrong_answer: The wrong answer they gave to the master question.

"check_if_I_am_cheater ($self, $total_questions, %cheaters)"

    # Compares this student's wrong answers with the wrong answers of other students.
    # Logs cases where cheating is likely (if more than 50% of wrong answers are identical).
    $self: The current student object.
    $total_questions: The total number of questions in the test.
    %cheaters: A list of all students and their wrong answers.

=head1 DIAGNOSTICS 

Empty Set of Cheaters in check_if_I_am_cheater: Ensure the %cheaters hash contains valid student objects for comparison.
Division by Zero in check_if_I_am_cheater: Ensure $total_questions is not zero.

=head1 CONFIGURATION AND ENVIRONMENT 

Cheating requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later.

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 
