package Exam_Reader;

use v5.36;
use warnings;
use strict;
use Exporter 'import';
use lib './lib';

use Regex ':regex';

sub new ($class,$filename) {
    my $self = {
        class         => $class,
        layouts       => [],
        questions     => [],
        marked_answer => {},
        answers       => {},
    };
    
    my $reader = bless ($self, $class);
    load_file($reader,$filename);
    return $reader;
}

sub load_file ($self,$filename) {
    open (my $fh_in, '<', $filename) or die ("Could not open file: $filename");
    
    while (my $line = readline($fh_in)) {
        
        if ($line =~ $Regex::STARTLINE_DETECT_REGEX) {
            my ($layout,$question,$position);
            
            while ($line !~ $Regex::QUESTION_START_DETECT_REGEX) {
                $layout .= $line;
                $line = readline ($fh_in);
            }
            $layout .= "Q";

            while ($line !~ $Regex::QUESTION_END_DETECT_REGEX) {
                $question .= $line;
                $line = readline ($fh_in);
            }

            while ($line !~ $Regex::ANSWER_START_DETECT_REGEX) {
                $layout .= $line;
                $line = readline ($fh_in);
            }
            $layout .= "A";
            
            while ($line !~ $Regex::ANSWER_END_DETECT_REGEX) {
                if ($line =~ $Regex::ANSWER_PATTERN_REGEX){
                    push (@{$self->{marked_answer}{$question}}, $line);
                    $line =~ s{$Regex::ANSWER_PATTERN_REGEX}{[ ]$1};
                }
                
                push (@{$self->{answers}{$question}}, $line);
                $line = readline ($fh_in);
            }
            
            while ($line !~ qr{$Regex::STARTLINE_DETECT_REGEX|$Regex::ENDLINE_DETECT_REGEX}) {
                $layout .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
            }
            seek ($fh_in,$position,0);

            push (@{$self->{questions}}, $question);
            push (@{$self->{layouts}}, $layout);
        }
        elsif ($line =~ $Regex::ENDLINE_DETECT_REGEX) {
            my $outro = $line;
            while ($line = readline($fh_in)) {
                $outro .= $line;
            }
            
            push (@{$self->{layouts}}, $outro);
        }
        else {
            my ($intro,$position);
            while ($line !~ $Regex::STARTLINE_DETECT_REGEX) {
                $intro .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
            }
            seek ($fh_in,$position,0);
            
            push (@{$self->{layouts}}, $intro);
        }
    }
}

sub get_question_total ($self) {
    return scalar(@{$self->{questions}});
}

sub get_marked_answer ($self,$num) {
    my $question = $self->get_question($num);
    return @{$self->{marked_answer}{$question}};
}

sub get_answers ($self,$num) {
    my $question = $self->get_question($num);
    return @{$self->{answers}{$question}};
}

sub get_question ($self,$num) {
    return $self->{questions}[$num - 1];
}

sub get_layout ($self,$num) {
    return $self->{layouts}[$num];
}

1;