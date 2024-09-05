package Exam_Reader;

use v5.36;
use warnings;
use strict;
use Exporter 'import';
use lib './lib';

use Regex ':regex';

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

sub load_file ($self,$filename) {
    open (my $fh_in, '<', $filename) or die ("Could not open file: $filename");
    
    while (my $line = readline($fh_in)) {
        
        if (is_start_exercise_line ($line)) {
            my ($layout,$question,$position);
            
            while (not is_start_question ($line)) {
                $layout .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            $layout .= "Q" if defined ($line);

            while (defined($line) && not is_end_question_or_answer ($line)) {
                $question .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            my $norm_question = normalized_question($question) if defined ($question);
            my $pretty_question = pretty_question($question) if defined ($question);

            while (defined($line) && not is_start_answer ($line)) {
                $layout .= $line;
                $line = readline ($fh_in);
                last unless defined $line;
            }
            $layout .= "A" if defined ($line);
            
            while (defined($line) && not is_end_question_or_answer ($line)) {
                my $norm_answer = normalized_answer($line);
                my $pretty_answer = pretty_answer($line);

                if (is_marked_answer ($line)){
                    push (@{$self->{marked_norm_answers}{$norm_question}}, $norm_answer) if defined ($norm_question);
                    $line =~ s{$Regex::ANSWER_PATTERN_REPLACE}{[ ]$1};
                }
                
                push (@{$self->{all_norm_answers}{$norm_question}}, $norm_answer) if defined ($norm_question);
                $self->{pretty_answer}{$norm_answer} = $pretty_answer if defined ($norm_question);
                $self->{printed_answer}{$norm_answer} = $line if defined ($norm_question);
                
                $line = readline ($fh_in);
                last unless defined $line;
            }
            
            while (defined($line) && not (is_start_exercise_line ($line) || is_end_exam_line ($line))) {
                $layout .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
                last unless defined $line;
            }
            seek ($fh_in,$position,0) if defined ($line);

            push (@{$self->{layouts}}, $layout) if defined ($layout);
            
            push (@{$self->{questions}}, $norm_question) if defined ($question);
            $self->{pretty_question}{$norm_question} = $pretty_question if defined ($norm_question);
            $self->{printed_question}{$norm_question} = $question if defined ($norm_question); 
        }
        elsif (is_end_exam_line ($line)) {
            my $outro = $line;
            while ($line = readline($fh_in)) {
                $outro .= $line;
            }
            
            push (@{$self->{layouts}}, $outro) if defined ($outro);
        }
        else {
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

##### QUESTION #####

sub question_amount ($self) {
    return scalar(@{$self->{questions}});
}

sub question_through_num ($self, $num) {
    if (defined $self->{questions}[$num - 1]) {
        return $self->{questions}[$num - 1];
    } 
    else {
        return undef; 
    }
}

sub pretty_question_through_norm ($self, $norm_question) {
    if (exists $self->{pretty_question}{$norm_question}) {
        return $self->{pretty_question}{$norm_question};
    }
    else {
        return undef;
    }
}

sub printed_question_through_norm ($self, $norm_question) {
    if (exists $self->{printed_question}{$norm_question}) {
        return $self->{printed_question}{$norm_question};
    }
    else {
        return undef;
    }
}

##### ANSWER #####

sub all_answers_through_norm_question ($self, $norm_question) {
    if (exists $self->{all_norm_answers}{$norm_question}) {
        return @{$self->{all_norm_answers}{$norm_question}}
    }
    else {
        return ();
    }
}

sub marked_answers_through_norm_question ($self, $norm_question) {
    if (exists $self->{marked_norm_answers}{$norm_question}) {
        return @{$self->{marked_norm_answers}{$norm_question}}
    }
    else {
        return ();
    }
}

sub pretty_answer_through_norm ($self, $norm_answer) {
    if (exists $self->{pretty_answer}{$norm_answer}) {
        return $self->{pretty_answer}{$norm_answer};
    }
    else {
        return undef;
    }
}

sub printed_answer_through_norm ($self, $norm_answer) {
    if (exists $self->{printed_answer}{$norm_answer}) {
        return $self->{printed_answer}{$norm_answer};
    }
    else {
        return undef;
    }
}

##### PRIVAT HELPER #####

sub normalized_question ($printed_question) {
    $printed_question =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g; # remove leading & ending spaces
    $printed_question =~ s{$Regex::QUESTION_NUM_DETECT}{}; # remove num & spaces till first character
    $printed_question =~ s{$Regex::LINE_BREAK_DETECT}{}g; # remove line breaks
    $printed_question =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g; # remove multiple spaces between words
    $printed_question = lc($printed_question); # all words to lower case
    # $printed_question = stop words 
    return $printed_question;
}

sub pretty_question ($printed_question) {
    $printed_question =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g; # remove leading & ending spaces
    $printed_question =~ s{$Regex::QUESTION_NUM_DETECT}{}; # remove num & spaces till first character
    $printed_question =~ s{$Regex::LINE_BREAK_DETECT}{}g; # remove line breaks
    $printed_question =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g; # remove multiple spaces between words
    return $printed_question;
}

sub normalized_answer ($printed_answer) {
    $printed_answer =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g; # remove leading & ending spaces
    $printed_answer =~ s{$Regex::ANSWER_BRACKET_DETECT}{}; # remove bracket with content & spaces till first character
    $printed_answer =~ s{$Regex::LINE_BREAK_DETECT}{}g; # remove line breaks
    $printed_answer =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g; # remove multiple spaces between words
    $printed_answer = lc($printed_answer); # all words to lower case
    # $printed_question = stop words 
    return $printed_answer;
}

sub pretty_answer ($printed_answer) {
    $printed_answer =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g; # remove leading & ending spaces
    $printed_answer =~ s{$Regex::ANSWER_BRACKET_DETECT}{}; # remove bracket with content & spaces till first character
    $printed_answer =~ s{$Regex::LINE_BREAK_DETECT}{}g; # remove line breaks
    $printed_answer =~ s{$Regex::WHITESPACE_MULTIPLE_DETECT}{ }g; # remove multiple spaces between words
    return $printed_answer;
}

sub is_start_exercise_line ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::STARTLINE_EXERCISE_DETECT;
}

sub is_end_exam_line ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ENDLINE_EXAM_DETECT;
}

sub is_start_question ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::QUESTION_NUM_DETECT;
}

sub is_start_answer ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ANSWER_BRACKET_DETECT;
}

sub is_end_question_or_answer ($line) {
    return $line =~ $Regex::WHITESPACE_SINGLE_DETECT;
}

sub is_marked_answer ($line) {
    $line =~ s{$Regex::WHITESPACE_START_END_DETECT}{}g;
    return $line =~ $Regex::ANSWER_MARK_DETECT;
}

##### PUBLIC HELPER #####

sub get_layout ($self, $num) {
    if (defined $self->{layouts}[$num]) {
        return $self->{layouts}[$num];
    }
    else {
        return undef;
    }
}

sub has_question ($self, $norm_question) {
    foreach my $question (@{$self->{questions}}) {
        if ($question eq $norm_question) {
            return 1; 
        }
    }
    return 0;
}

sub get_filename ($self) {
    return $self->{'filename'};
}

1;