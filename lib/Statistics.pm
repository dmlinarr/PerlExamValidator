package Statistics;

use v5.36;
use warnings;
use strict;
use Exporter 'import';

our %EXPORT_TAGS = (
    subs => qw( 
        add_students
        min_question
        max_question
        avg_question
        min_answer
        max_answer
        avg_answer
        less_than_half_the_total_question
        less_than_half_the_answers_correct
    ), 
);

# Hashmap where key is student that points to a list with two values.
my %data;

# Add a hashmap where for each student showing the total number of correct answers and the total number of answers chosen.
sub add_students (%students) {
    %data = %students;
}

# Check which and how much students have answered the fewest number of questions.
sub min_question () {
    if (%data) {
        my $min = 'inf';
        my $amount = 0;
        
        # Check for each student the amount of answered questions.
        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
                
                # If they have lower amount of questions answered as current minimum, the minimum gets overridden and counter set to one.
                if ($min > $data{$student}[1]) {
                    $min = $data{$student}[1];
                    $amount = 1;
                }
                # If they have the same amount of questions answered as current minimum, the counter gets incremented.
                elsif ($min == $data{$student}[1]) {
                    $amount++;
                }
            }
        }
        return ($min,$amount);
    }
    else {
        return undef;
    }
}

# Check which and how much students have answered the most number of questions.
sub max_question () {
    if (%data) {
        my $max = '-inf';
        my $amount = 0;

        # Check for each student the amount of answered questions.
        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
                
                # If they have higher amount of questions answered as current maximum, the maximum gets overridden and counter set to one.
                if ($max < $data{$student}[1]) {
                    $max = $data{$student}[1];
                    $amount = 1;
                }
                # If they have the same amount of questions answered as current maximum, the counter gets incremented.
                elsif ($max == $data{$student}[1]) {
                    $amount++;
                }
            }
        }
        return ($max,$amount);
    }
    else {
        return undef;
    }
}

# Check whats the average amount of questions answered.
sub avg_question () {
    if (%data) {
        my $sum = 0;
        my $count = 0;

        # Check for each student the amount of answered questions.
        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
                
                # Sum up the amount of questions answered and increment the counter.
                $sum += $data{$student}[1];
                $count++;
            }
        }
        return $sum/$count;
    }
    else {
        return undef;
    }
}

# Check which and how much students have answered the fewest number of questions correct.
sub min_answer () {
    if (%data) {
        my $min = 'inf';
        my $amount = 0;

        # Check for each student the amount of answered questions correct.
        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
                
                # If they have lower amount of questions answered correct as current minimum, the minimum gets overridden and counter set to one.
                if ($min > $data{$student}[0]) {
                    $min = $data{$student}[0];
                    $amount = 1;
                }
                # If they have the same amount of questions answered correct as current minimum, the counter gets incremented.
                elsif ($min == $data{$student}[0]) {
                    $amount++;
                }
            }
        }
        return ($min,$amount);
    }
    else {
        return undef;
    }
}

# Check which and how much students have answered the most number of questions correct.
sub max_answer () {
    if (%data) {
        my $max = '-inf';
        my $amount = 0;

        # Check for each student the amount of answered questions correct.
        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
                
                # If they have higher amount of questions answered correct as current maximum, the maximum gets overridden and counter set to one.
                if ($max < $data{$student}[0]) {
                    $max = $data{$student}[0];
                    $amount = 1;
                }
                # If they have the same amount of questions answered correct as current maximum, the counter gets incremented.
                elsif ($max == $data{$student}[0]) {
                    $amount++;
                }
            }
        }
        return ($max,$amount);
    }
    else {
        return undef;
    }
}

# Check whats the average amount of questions answered correctly.
sub avg_answer () {
    if (%data) {
        my $sum = 0;
        my $count = 0;

        # Check for each student the amount of answered questions correctly.
        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
                
                # Sum up the amount of questions answered correctly and increment the counter.
                $sum += $data{$student}[0];
                $count++;
            }
        }
        return $sum/$count;
    }
    else {
        return undef;
    }
}

# Filters and returns students who have answered fewer than half of the total questions.
sub less_than_half_the_total_question ($max_amount) {
    my %filter;
    if (%data) {
        
        # Check for each student the amount of answered questions.
        for my $student (keys %data) {
            if (defined $data{$student}[0] && defined $data{$student}[1]) {
                
                # If the student answered fewer than half of the total questions, they are added to the filter with their number of correct answers and total questions answered. 
                if ($data{$student}[1] < $max_amount / 2) {
                    $filter{$student} = [$data{$student}[0], $data{$student}[1]];
                }
            }
        }
        return %filter;
    } 
    else {
        return undef;
    }
}

# Filters and returns students who have answered correctly fewer than half of their total answers.
sub less_than_half_the_answers_correct () {
    my %filter;
    if (%data) {
        
        # Check for each student the amount of answered questions correctly.
        for my $student (keys %data) {
            if (defined $data{$student}[0] && defined $data{$student}[1]) {
                
                # If the student answered fewer than half of the answerer questions correctly, they are added to the filter with their number of correct answers and total questions answered. 
                if ($data{$student}[0] < $data{$student}[1] / 2) {
                    $filter{$student} = [$data{$student}[0], $data{$student}[1]];
                }
            }
        }
        return %filter;
    } 
    else {
        return undef;
    }
}

1;

=head1 NAME 

Statistics - Analyze the minimum, maximum, and average number of questions answered and the number of correct answers.

=head1 SYNOPSIS 
    
    # To import the module.
    use Statistics ':subs'
    
    # Add all students stored in a hashmap.
    Statistics::add_students(%students)

    # Get minimum amount of questions answered.
    Statistics::min_question()
    
    # Get maximum amount of questions answered.
    Statistics::max_question()

    # Get average of questions answered.
    Statistics::avg_question()

    # Get minimum amount of questions answered correctly.
    Statistics::min_answer()
    
    # Get maximum amount of questions answered correctly.
    Statistics::max_answer()

    # Get average of questions answered correctly.
    Statistics::avg_answer()

    # Get students who have answered fewer than half of the total questions.
    Statistics::less_than_half_the_total_question ($max_amount)

    # Get students who have answered fewer than half of their answered questions correctly.
    Statistics::less_than_half_the_answers_correct()


=head1 DESCRIPTION 

The module provides functions for analyzing student performance data, 
including calculating minimum, maximum, and average values for the number of questions answered 
and the number of correct answers. It also includes filters to identify students who answered fewer 
than half of the total questions or fewer than half of their answers correctly.

=head1 SUBROUTINES/METHODS 

"add_students(%students)"
    
    # Add all students stored in a hashmap.
    # For each student showing the total number of correct answers and the total number of answers chosen as list.
    %students: student => (correct answers,total answered questions)

"min_question()"

    # Check which and how much students have answered the fewest number of questions.
    # Returns list (minimum amount questions answered, how much students had minimum amount of questions answered)

"max_question()"

    # Check which and how much students have answered the most number of questions.
    # Returns list (maximum amount questions answered, how much students had maximum amount of questions answered)

"avg_question()"

    # Check whats the average amount of questions answered.

"min_answer()"

    # Check which and how much students have answered the fewest number of questions correct.
    # Returns list (minimum amount questions answered correctly, how much students had minimum amount of questions answered correctly)

"max_answer()"

    # Check which and how much students have answered the most number of questions correct.
    # Returns list (maximum amount questions answered correctly, how much students had maximum amount of questions answered correctly)

"avg_answer()"

    # Check whats the average amount of questions answered correctly.

"less_than_half_the_total_question ($max_amount)"

    # Filters and returns students who have answered fewer than half of the total questions.
    # Returns hashmap which is a part of %students.
    $max_amount: The total amount of questions in the exam. 

"less_than_half_the_answers_correct()"

    # Filters and returns students who have answered correctly fewer than half of their total answers.
    # Returns hashmap which is a part of %students.


=head1 DIAGNOSTICS 

Subroutines give back "undef": Make sure to give an non empty hashmap filled with student => (correct answers,total answered questions).

=head1 CONFIGURATION AND ENVIRONMENT 

Statistics requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later. 

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
