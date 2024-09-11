package Exam_Reader;

use v5.36;
use warnings;
use strict;
use Lingua::StopWords 'getStopWords';
use Text::Levenshtein 'distance';
use Exporter 'import';
use lib './lib';

use Regex ':regex';

# Create a multiple choice test-taker.
sub new ($class,$filename) {
    my $self = {
        class               => $class,
        filename            => $filename,
        layouts             => [],
        questions           => [],
        all_norm_answers    => {},
        marked_norm_answers => {},
        pretty_question     => {},
        pretty_answer       => {},
        printed_question    => {},
        printed_answer      => {},
    };
    
    my $reader = bless ($self, $class);
    load_file($reader,$filename);
    return $reader;
}

# Parses the multiple-choice exam and constructs a data structure that facilitates easy retrieval of answers in the future.
sub load_file ($self,$filename) {
    open (my $fh_in, '<', $filename) or die ("Could not open file: $filename");
    
    # Reads the multiple choice exam line by line.
    while (my $line = readline($fh_in)) {
        
        # When the line indicates a question block starting.
        if (is_start_exercise_line ($line)) {
            my ($layout,$question,$position);
            
            # Read layout lines till the question line appears.
            while (not is_start_question ($line)) {
                $layout .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            $layout .= "Q" if defined ($line);

            # Read the question till the question ends.
            while (defined($line) && not is_end_question_or_answer ($line)) {
                $question .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            my $norm_question = normalized_question($question) if defined ($question);
            my $pretty_question = pretty_question($question) if defined ($question);

            # Read layout between question and answer.
            while (defined($line) && not is_start_answer ($line)) {
                $layout .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            $layout .= "A" if defined ($line);
            
            # Reads answer lines until no more answers are left.
            while (defined($line) && not is_end_question_or_answer ($line)) {
                my $norm_answer = normalized_answer($line);
                my $pretty_answer = pretty_answer($line);

                # Recognize the answer that was marked by the square brackets.
                if (is_marked_answer ($line)){
                    push (@{$self->{marked_norm_answers}{$norm_question}}, $norm_answer) if defined ($norm_question);
                    $line =~ s{$Regex::ANSWER_PATTERN_REPLACE}{[ ]$1};
                }
                
                # Store the answers into the datastructure.
                push (@{$self->{all_norm_answers}{$norm_question}}, $norm_answer) if defined ($norm_question);
                $self->{pretty_answer}{$norm_answer} = $pretty_answer if defined ($norm_question);
                $self->{printed_answer}{$norm_answer} = $line if defined ($norm_question);
                
                $line = readline ($fh_in);
                last unless defined $line;
            }
            
            # Read layout at the end of the question block.
            while (defined($line) && not (is_start_exercise_line ($line) || is_end_exam_line ($line))) {
                $layout .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
                last unless defined $line;
            }
            seek ($fh_in,$position,0) if defined ($line);

            # Store the layout into the datastructure.
            push (@{$self->{layouts}}, $layout) if defined ($layout);
            
            # Store the question into the datastructure.
            push (@{$self->{questions}}, $norm_question) if defined ($question);
            $self->{pretty_question}{$norm_question} = $pretty_question if defined ($norm_question);
            $self->{printed_question}{$norm_question} = $question if defined ($norm_question); 
        
        }
        # When the line indicates the exam ending.
        elsif (is_end_exam_line ($line)) {
            
            # Read the concluding text and store it into the datastructure.
            my $outro = $line;
            while ($line = readline($fh_in)) {
                $outro .= $line;
            }
            push (@{$self->{layouts}}, $outro) if defined ($outro);

        }
        # When the the line does not indicate exam ending or question block, then the line must be part of the introduction.
        else {
            
            # Read the introduction and store it into the datastructure.
            my ($intro,$position);
            while (defined($line) && not is_start_exercise_line ($line)) {
                $intro .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
                last unless defined $line;
            }
            seek ($fh_in,$position,0) if defined ($line);
            push (@{$self->{layouts}}, $intro) if defined ($intro);

        }
    }
}

# Get the total number questions stored.
sub question_amount ($self) {
    return scalar(@{$self->{questions}});
}

# Returns the normalized question corresponding to the given number as it appears in the exam.
sub question_through_num ($self, $num) {
    if (defined $self->{questions}[$num - 1]) {
        return $self->{questions}[$num - 1];
    } 
    else {
        return undef; 
    }
}

# Returns the normalized question if its edit distance is less than or equal to 10% of the given normalized question.
sub question_through_toleranz ($self, $original_norm_question) {
    
    # First, check if the exact same normalized question already exists.
    foreach my $norm_exact_question (@{$self->{questions}}) {
        if ($norm_exact_question eq $original_norm_question) {
            return $norm_exact_question; 
        }
    }

    # If not, search for a similar question with an edit distance of 10% or less from the given normalized question.
    foreach my $norm_maybe_question (@{$self->{questions}}) {
        my $edit_distance = distance($original_norm_question, $norm_maybe_question);
        my $max_toleranz = 0.10 * length($original_norm_question);
        if ($edit_distance <= $max_toleranz) {
            return $norm_maybe_question;
        };
    }

    return undef;
}

# Returns the pretty version of the question when its normalized form is provided.
sub pretty_question_through_norm ($self, $norm_question) {
    if (exists $self->{pretty_question}{$norm_question}) {
        return $self->{pretty_question}{$norm_question};
    }
    else {
        return undef;
    }
}

# Returns the printed version of the question when its normalized form is provided.
sub printed_question_through_norm ($self, $norm_question) {
    if (exists $self->{printed_question}{$norm_question}) {
        return $self->{printed_question}{$norm_question};
    }
    else {
        return undef;
    }
}

# Returns all normalized answer choices for a given question.
sub all_answers_through_norm_question ($self, $norm_question) {
    if (exists $self->{all_norm_answers}{$norm_question}) {
        return @{$self->{all_norm_answers}{$norm_question}}
    }
    else {
        return ();
    }
}

# Returns all selected normalized answers for the given question.
sub marked_answers_through_norm_question ($self, $norm_question) {
    if (defined $norm_question && exists $self->{marked_norm_answers}{$norm_question}) {
        return @{$self->{marked_norm_answers}{$norm_question}}
    }
    else {
        return ();
    }
}

# Returns the pretty version of the answer when its normalized form is provided.
sub pretty_answer_through_norm ($self, $norm_answer) {
    if (exists $self->{pretty_answer}{$norm_answer}) {
        return $self->{pretty_answer}{$norm_answer};
    }
    else {
        return undef;
    }
}

# Returns the printed version of the answer when its normalized form is provided.
sub printed_answer_through_norm ($self, $norm_answer) {
    if (exists $self->{printed_answer}{$norm_answer}) {
        return $self->{printed_answer}{$norm_answer};
    }
    else {
        return undef;
    }
}

# Generates a normalized question from the printed version.
sub normalized_question ($printed_question) {
    
    # Removes leading and ending spaces.
    $printed_question =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g; # remove leading & ending spaces
    
    # Removes leading number and spaces till the first character.
    $printed_question =~ s{$Regex::QUESTION_NUM_DETECT}{}; 
    
    # Removes line breaks.
    $printed_question =~ s{$Regex::LINE_BREAK_DETECT}{}g; 
    
    # Removes multiple spaces between words and replaces them with one space.
    $printed_question =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g; 
    
    # All characters to lower case.
    $printed_question = lc($printed_question); 
    
    # Removes stop words.
    $printed_question = clear_stop_words  ($printed_question); 
    
    return $printed_question;
}

# Generates a pretty question from the printed version.
sub pretty_question ($printed_question) {
    
    # Removes leading and ending spaces.
    $printed_question =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;

    # Removes leading number and spaces till the first character. 
    $printed_question =~ s{$Regex::QUESTION_NUM_DETECT}{};

    # Removes line breaks. 
    $printed_question =~ s{$Regex::LINE_BREAK_DETECT}{}g;

    # Removes multiple spaces between words and replaces them with one space.
    $printed_question =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g;
    
    return $printed_question;
}

# Generates a normalized answer from the printed version.
sub normalized_answer ($printed_answer) {
    
    # Removes leading and ending spaces.
    $printed_answer =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    
    # Removes bracket with content and spaces till first character.
    $printed_answer =~ s{$Regex::ANSWER_BRACKET_DETECT}{}; 
    
    # Removes line breaks.
    $printed_answer =~ s{$Regex::LINE_BREAK_DETECT}{}g;

    # Removes multiple spaces between words and replaces them with one space.
    $printed_answer =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g;

    # All characters to lower case.
    $printed_answer = lc($printed_answer);
    
    # Removes stop words.
    $printed_answer = clear_stop_words  ($printed_answer);
    
    return $printed_answer;
}

# Generates a pretty answer from the printed version.
sub pretty_answer ($printed_answer) {
    
    # Removes leading and ending spaces.
    $printed_answer =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;

    # Removes bracket with content and spaces till first character.
    $printed_answer =~ s{$Regex::ANSWER_BRACKET_DETECT}{};

    # Removes line breaks.
    $printed_answer =~ s{$Regex::LINE_BREAK_DETECT}{}g;

    # Removes multiple spaces between words and replaces them with one space.
    $printed_answer =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g;

    return $printed_answer;
}

# Returns "true" if the line indicates the start of a new question box (by leading "_" characters).
sub is_start_exercise_line ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::STARTLINE_EXERCISE_DETECT;
}

# Returns "true" if the line indicates the end of the exam (by leading "=" characters).
sub is_end_exam_line ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ENDLINE_EXAM_DETECT;
}

# Returns "true" if the line indicates a question (by a question number).
sub is_start_question ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::QUESTION_NUM_DETECT;
}

# Returns "true" if the line indicates a answer (by square brackets).
sub is_start_answer ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ANSWER_BRACKET_DETECT;
}

# Returns "true" if the line indicates a question ending (by spaces only).
sub is_end_question_or_answer ($line) {
    return $line =~ $Regex::WHITESPACE_SINGLE_DETECT;
}

# Returns "true" if the line indicates choosen answer in the multiple choice exam (by any character in the square brackets).
sub is_marked_answer ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ANSWER_MARK_DETECT;
}

# Cleans the line by removing stop words.
sub clear_stop_words  ($line) {
    my $stopwords = getStopWords('en');
    my @words = split ' ', $line;
    my @filtered_words = grep { !$stopwords->{$_} } @words;
    my $no_stop_words_string = join ' ', @filtered_words;
    return $no_stop_words_string; 
}

# Retrieve the layout for each question number, or 
# where 0 represents the introduction and 
# the total number of questions plus 1 represents the concluding text.
sub get_layout ($self, $num) {
    if (defined $self->{layouts}[$num]) {
        return $self->{layouts}[$num];
    }
    else {
        return undef;
    }
}

# Returns the filename of the multiple choice exam.
sub get_filename ($self) {
    return $self->{'filename'};
}

1;

=head1 NAME 

Exam_Reader - Parse and manage multiple-choice exams by accessing questions and answers.

=head1 SYNOPSIS 
    
    # To import the module.
    use Exam_Reader
    
    # Create new test-taker object.
    my $test_taker = Exam_Reader->new($filename)
    
    # Get the total number questions stored.
    $test_taker->question_amount()

    # Returns the normalized question corresponding to the given number as it appears in the exam.
    $test_taker->question_through_num($num)

    # Returns the normalized question if its edit distance is less than or equal to 10% of the given normalized question.
    $test_taker->question_through_toleranz($original_norm_question)

    # Returns the pretty version of the question when its normalized form is provided.
    $test_taker->pretty_question_through_norm($norm_question)

    # Returns the printed version of the question when its normalized form is provided.
    $test_taker->printed_question_through_norm($norm_question)

    # Returns all normalized answer choices for a given question.
    $test_taker->all_answers_through_norm_question($norm_question)

    # Returns all selected normalized answers for the given question.
    $test_taker->marked_answers_through_norm_question($norm_question)

    # Returns the pretty version of the answer when its normalized form is provided.
    $test_taker->pretty_answer_through_norm($norm_answer)

    # Returns the printed version of the answer when its normalized form is provided.
    $test_taker->printed_answer_through_norm($norm_answer)

    # Retrieve the layout for introduction, question block or concluding text.
    $test_taker->get_layout($num)

    # Returns the filename of the multiple choice exam.
    $test_taker->get_filename()

=head1 DESCRIPTION 

This module is designed to parse and manage multiple-choice exams from a specified file. 
It reads the exam, extracts and normalizes questions and answers, and organizes them into 
a structured format for easy retrieval. The module provides various methods to access different 
aspects of the exam, including normalized questions, pretty-printed versions, and layouts, 
facilitating efficient handling and querying of exam data.

The normalized version of a string is when it has no stop words, only a single space between words, 
and all words are in lowercase. 
The "pretty" version of a string is when there is only a single space between words. 
The "printed" version of a string is the exact line as it was read from the multiple-choice file.

The test-taker multiple-choice exam should look like: 

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

=head1 SUBROUTINES/METHODS 

"question_amount($self)"
    
    # Get the total number questions stored.
    $self: The current test-taker object.

"question_through_num($self, $num)"
    
    # Returns the normalized question corresponding to the given number as it appears in the exam or undef.
    $self: The current test-taker object.
    $num: From 1 till the total number of questions.

"question_through_toleranz($self, $original_norm_question)" 
    
    # Returns the normalized question if its edit distance is less than or equal to 10% of the given normalized question or undef.
    $self: The current test-taker object.
    $original_norm_question: The normalized question to compare against.

"pretty_question_through_norm($self, $norm_question)"
    
    # Returns the pretty version of the question when its normalized form is provided or undef.
    $self: The current test-taker object.
    $norm_question: Question in normalized form.

"printed_question_through_norm($self, $norm_question)" 
    
    # Returns the printed version of the question when its normalized form is provided or undef.
    $self: The current test-taker object.
    $norm_question: Question in normalized form.

"all_answers_through_norm_question($self, $norm_question)" 
    
    # Returns all normalized answer choices as a list for a given question or an empty list.
    $self: The current test-taker object.
    $norm_question: Question in normalized form.

"marked_answers_through_norm_question($self, $norm_question)" 
    
    # Returns all selected normalized answers for the given question or an empty list.
    $self: The current test-taker object.
    $norm_question: Question in normalized form.

"pretty_answer_through_norm($self, $norm_answer)"
    
    # Returns the pretty version of the answer when its normalized form is provided or undef.
    $self: The current test-taker object.
    $norm_answer: Answer in normalized form.

"printed_answer_through_norm($self, $norm_answer)" 
    
    # Returns the printed version of the answer when its normalized form is provided or undef.
    $self: The current test-taker object.
    $norm_answer: Answer in normalized form.

"get_layout($self, $num)"

    # Retrieve the layout for introduction, question block or concluding text or undef.
    $self: The current test-taker object.
    $num: 0 for introduction, 1...total number of questions for question block layout, number of questions + 1 for concluding text.

"get_filename($self)"
    
    # Returns the filename of the multiple choice exam.
    $self: The current test-taker object.

=head1 DIAGNOSTICS 

Could not open file: Ensure the file path is correct and that you have permission to access the file.
Undefined value error: If you encounter an error related to "undefined value," check if all required inputs are provided correctly. 

=head1 CONFIGURATION AND ENVIRONMENT 

Exam_Reader requires no configuration files or environment variables.

=head1 DEPENDENCIES 

Only works under Perl 5.36 and later. It requires the following module:
    
    Lingua::StopWords
    Text::Levenshtein
    Regex

=head1 AUTHOR 

Damjan Mlinar "mlidam@hotmail.com" 

=head1 LICENCE AND COPYRIGHT 

Copyright (c) 2024, Damjan Mlinar "mlidam@hotmail.com". All rights reserved. 
 
This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself. See L<perlartistic>. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
