use strict;
use warnings;
use v5.36;
use Text::Levenshtein 'distance';
use lib './lib';

use Exam_Reader;
use Cheating;
use Regex ':regex';
use Statistics ':subs';

# Master multiple choice exam, all students and their performance details.
my $master = undef;
my @students = ();
(my $assessment, my %missing_questions, my %instead_questions, my %missing_answers, my %instead_answers, my %result, my %cheaters);

# Calculates the score for each completed multiple choice exam and prints out information about it.
sub print_score () {
    if ($master && @students) {
        my $question_num = $master->question_amount();

        # For each student, compare the chosen answer with the master file.
        for my $student (@students) {
            my $student_questions = 0;
            my $student_score = 0;

            # Go through each question and compare it with the master solution.
            for my $num (1 .. $question_num) {
                
                # Retrieve the exact or similar question from the student for each question from the master file. 
                my $norm_question_master = $master->question_through_num ($num);
                my $norm_question_student = $student->question_through_toleranz ($norm_question_master);
                
                # Retrieve the selected answer from both the master file and the student’s responses.
                my @master_answers_marked = $master->marked_answers_through_norm_question($norm_question_master);
                my @student_answers_marked = $student->marked_answers_through_norm_question($norm_question_student);
                
                # Check whether the student has a question.
                if (defined $norm_question_student) {
                    
                    # Check if the student had the exact same question.
                    if ($norm_question_master eq $norm_question_student) {
                        $student_questions++;
                    }
                    # The student had a question similar to the original one and logging is required.
                    else {
                        $student_questions++;
                        my $missing_q = $master->pretty_question_through_norm($norm_question_master);
                        my $instead_q = $student->pretty_question_through_norm($norm_question_student);
                        my $filename = $student->get_filename(); 
                        my $filename_and_question = $filename . $missing_q;       
                        
                        push (@{$missing_questions{$filename}}, $missing_q);
                        $instead_questions{$filename_and_question} = $instead_q;
                    }
                    
                    # Check if the student has provided exactly one answer. If multiple or no answers were provided, the question is considered incorrectly answered.
                    if (scalar(@student_answers_marked) == 1) {
                        
                        # Check if the student had the exact same answer as the master file.
                        if ($master_answers_marked[0] eq $student_answers_marked[0]) {
                            $student_score++;
                        }
                        # Check if the student had a answer similar to the original one. Logging is required if condition is met.
                        elsif (correct_according_distance ($master_answers_marked[0], $student_answers_marked[0])) {
                            $student_score++;
                            my $missing_a = $master->pretty_answer_through_norm($master_answers_marked[0]);
                            my $instead_a = $student->pretty_answer_through_norm($student_answers_marked[0]);
                            my $filename = $student->get_filename();        
                            my $filename_and_answer = $filename . $missing_a;
                            
                            push (@{$missing_answers{$filename}}, $missing_a);
                            $instead_answers{$filename_and_answer} = $instead_a;
                        }
                        # The answer was incorrect and is logged in the cheater object.
                        else {
                            my $filename = $student->get_filename();
                            
                            if (not exists $cheaters{$filename}) {
                                $cheaters{$filename} = Cheating->new($filename);
                            }

                            $cheaters{$filename}->add_wrong_answer ($norm_question_master, $student_answers_marked[0]);                            
                        }
                    }
                    
                    # Now check if the student has provided all the answers.
                    my @master_answers_norm = $master->all_answers_through_norm_question($norm_question_master);
                    my @student_answers_norm = $student->all_answers_through_norm_question($norm_question_student);
                    
                    for my $norm_answer (@master_answers_norm) {
                        
                        # Log the answers that are in the master file but missing from the student's multiple choice exam.
                        unless (grep { $_ eq $norm_answer } @student_answers_norm) {
                            my $filename = $student->get_filename();
                            my $missing_a = $master->pretty_answer_through_norm($norm_answer);
                            my $filename_and_answer = $filename . $missing_a;

                            if (not exists $instead_answers{$filename_and_answer}) {
                                push (@{$missing_answers{$filename}}, $missing_a);
                            }
                        }
                    }

                }
                # Log the missing question in the student's multiple choice exam.
                else {
                    my $filename = $student->get_filename();        
                    my $missing_q = $master->pretty_question_through_norm($norm_question_master);
                    push (@{$missing_questions{$filename}}, $missing_q);
                }
            }

            # Prepare the final score to be printed on the console.
            my $filename = $student->get_filename();
            my $final_score = $student_score . "/" . $student_questions;
            my $output = $filename . ('.' x (80-length($filename)-length($final_score))) . $final_score;
            
            $assessment .= "$output\n";
            $result{$filename} = [$student_score, $student_questions];
        }

        # At the end of the calculation, print all the information to the console.
        print_assessment ();
        print_missing_questions ();
        print_missing_answers ();
        print_statistics ();
        print_cheating ($question_num);
    }
    else {
        die ("Exams are not loaded");
    }
}

# Print the achieved score of each student in the multiple choice exam. 
sub print_assessment () {
    print '#' x 80 . "\n";
    print "\n";
    print $assessment;
    print "\n";
    print '#' x 80 . "\n";
    print "\n";
}

# Print the missing questions of each student in the multiple choice exam. 
sub print_missing_questions () {
    
    # Go through every student who was logged as having missing questions.
    for my $filename (sort keys %missing_questions) {
        print "$filename:\n";
        
        # Print out the missing questions and any alternative questions used, if applicable.
        for my $question (@{ $missing_questions{$filename} }) {
            print "     Missing question: $question\n";
            my $filename_and_question = $filename . $question;
            
            if (exists $instead_questions{$filename_and_question}) {
                my $instead_q = $instead_questions{$filename_and_question};
                print "     Used this instead: $instead_q\n";
            }
        }
        print "\n";
    }
    print "\n";
    print '#' x 80 . "\n";
    print "\n";
}

# Print the missing answers of each student in the multiple choice exam. 
sub print_missing_answers () {
    
    # Go through every student who was logged as having missing answers.
    for my $filename (sort keys %missing_answers) {
        print "$filename:\n";

        # Print out the missing answers and any alternative answers used, if applicable.
        for my $answer (@{ $missing_answers{$filename} }) {
            print "     Missing answer: $answer\n";
            my $filename_and_answer = $filename . $answer;
            
            if (exists $instead_answers{$filename_and_answer}) {
                my $instead_a = $instead_answers{$filename_and_answer};
                print "     Used this instead: $instead_a\n";
            }
        }
        print "\n";
    }
    print "\n";
    print '#' x 80 . "\n";
    print "\n";
}

# Print statistical information, including the minimum, average, and maximum overall performance of the students.
sub print_statistics () {
    Statistics::add_students (%result);
    
    # Calculate statistical information based on the collected data.
    my $avg_question = Statistics::avg_question();
    my @min_question_stats = Statistics::min_question();
    my @max_question_stats = Statistics::max_question();

    my $avg_answer = Statistics::avg_answer();
    my @min_answer_stats = Statistics::min_answer();
    my @max_answer_stats = Statistics::max_answer();
    
    my %less_half_total_question = Statistics::less_than_half_the_total_question($master->question_amount());
    my %less_half_answers_correct = Statistics::less_than_half_the_answers_correct();
    
    # Print the minimum, average, and maximum number of answered questions.
    if (scalar(@min_question_stats) == 2 && scalar(@max_question_stats) == 2) {
        my $min_question = $min_question_stats[0];
        my $min_question_amount = $min_question_stats[1];
        my $max_question = $max_question_stats[0];
        my $max_question_amount = $max_question_stats[1];

        print "Average number of questions answered:" . ('.' x (80-length("Average number of questions answered:")-length($avg_question))) . "$avg_question\n";
        print "     Minimum:" . ('.' x (80-length("     Minimum:")-length($min_question))) . "$min_question  (So many: $min_question_amount)\n";
        print "     Maximum:" . ('.' x (80-length("     Maximum:")-length($max_question))) . "$max_question  (So many: $max_question_amount)\n";
        print "\n";
    }
    
    # Print the minimum, average, and maximum number of answered questions correctly.
    if (scalar(@min_answer_stats) == 2 && scalar(@max_answer_stats) == 2) {
        my $min_answer = $min_answer_stats[0];
        my $min_answer_amount = $min_answer_stats[1];
        my $max_answer = $max_answer_stats[0];
        my $max_answer_amount = $max_answer_stats[1];
        
        print "Average number of correct answers:" . ('.' x (80-length("Average number of correct answers:")-length($avg_answer))) . "$avg_answer\n";
        print "     Minimum:" . ('.' x (80-length("     Minimum:")-length($min_answer))) . "$min_answer  (So many: $min_answer_amount)\n";
        print "     Maximum:" . ('.' x (80-length("     Maximum:")-length($max_answer))) . "$max_answer  (So many: $max_answer_amount)\n";
        print "\n";
    }

    # Ensure that 'Results below expectation:' is printed only once.
    my $header;

    # Print the students who answered fewer than 50% of their questions.
    if (%less_half_total_question) {
        $header = "Results below expectation:\n";
        print $header;
        
        for my $less_half_tot (keys %less_half_total_question) {
            my $score = $less_half_total_question{$less_half_tot}[0];
            my $tot_question = $less_half_total_question{$less_half_tot}[1];
            my $final_score = $score . "/" . $tot_question;
            print "     $less_half_tot" . ('.' x (80-length("     $less_half_tot")-length($final_score))) . "$final_score  (Question answered < 50%)\n";
        }
    }

    # Print the students who answered fewer than 50% of the questions correctly.
    if (%less_half_answers_correct) {
        if(not defined($header)) {
            $header = "Results below expectation:\n";
            print $header;
        }

        for my $less_half_answer (keys %less_half_answers_correct) {
            my $score = $less_half_answers_correct{$less_half_answer }[0];
            my $tot_question = $less_half_answers_correct{$less_half_answer }[1];
            my $final_score = $score . "/" . $tot_question;
            print "     $less_half_answer" . ('.' x (80-length("     $less_half_answer")-length($final_score))) . "$final_score  (Answers correct < 50%)\n";
        }
    }
    print "\n";
    print '#' x 80 . "\n";
    print "\n";
}

# Print the students who have a probability of cheating greater than 50%.
sub print_cheating ($question_num) {
    my %log_history;

    # Go through every student who was logged as beeing a possible cheater.
    for my $cheater_file (sort keys %cheaters) {
        my $cheater = $cheaters{$cheater_file};
        $cheater->check_if_I_am_cheater ($question_num, %cheaters);
        
        # Retrieve the logs about cheating for students flagged as a cheater.
        for my $log_name (keys %{$cheater->{log_cheater}}) {
            my $names = $cheater_file . $log_name;
            my $reverse_names = $log_name . $cheater_file;
            
            # Print out only the two students who have not been printed out yet together.
            unless (exists $log_history{$reverse_names}) {
                print $cheater->{log_cheater}{$log_name};
                print "\n";
                $log_history{$names} = 1;
            }
        }
    }
    print "\n";
    print '#' x 80 . "\n";
    print "\n";
}

# Accept or deny answers based on whether they are similar, with similarity determined by an edit distance of 10% or less. 
sub correct_according_distance ($master_string, $student_string) {
    my $edit_distance = distance($master_string, $student_string);
    my $max_toleranz = 0.10 * length($master_string);
    return $edit_distance <= $max_toleranz;
}

# Create a test-taker object for each file name and load their answers from the exam.
sub read_in_exams ($master_file,@students_files) {
    $master = Exam_Reader->new($master_file);
    for my $student_file (@students_files) {
        push (@students,Exam_Reader->new($student_file));
    }
}

# Create a list containing every filename provided through the console arguments.
sub read_in_files (@inputs) {
    my @files = ();
    for my $input (@inputs) {
        
        # If it's a single file, add it to the list.
        if (-f $input) {
            push (@files, $input);
        }
        # Wildcard pattern matches every file that fits the pattern. 
        else {
            my @wild_files = glob ($input);
            push (@files, @wild_files);
       }
    }
    return @files;
}

# Read in arguments from the console and execute the assessment.
my $master_file = $ARGV[0];
my @students_files = read_in_files(@ARGV[1..scalar(@ARGV)-1]);
read_in_exams ($master_file,@students_files);
print_score ();

=head1 NAME 

Exam_Scorer - Reads the master multiple choice exam and a list of completed multiple choice exams, then prints out the assessment.

=head1 USAGE 
    
    # To make an assessment:
    perl src/Exam_Scorer.pl resource/normal-exam/IntroPerlEntryExam.txt resource/normal-exam/*
    perl src/Exam_Scorer.pl resource/short-exam/IntroPerlEntryExamShort.txt resource/short-exam/*
    
=head1 REQUIRED ARGUMENTS 

The first argument should specify the path to the master multiple choice exam file, 
and the second argument should be a list of completed multiple choice exams.

=head1 DESCRIPTION

This software evaluates multiple choice exams by comparing student responses 
against a master exam file. It calculates and prints each student's score, 
identifies missing or incorrect answers, and logs potential cheating instances. 
Additionally, it provides detailed statistics on student performance.

The multiple-choice exam should look like: 

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

Exams are not loaded: This error occurs if the master exam file 
or student exam files are not successfully loaded before attempting 
to calculate scores. Ensure that the file paths provided are correct and that the files are accessible. 

=head1 CONFIGURATION AND ENVIRONMENT 

Exam_Scorer requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later.
It requires the following module:
    
    Text::Levenshtein
    Exam_Reader
    Cheating
    Regex
    Statistics

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This application is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.