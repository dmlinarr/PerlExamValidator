package Exam_Reader;

use v5.36;
use warnings;
use strict;
use Exporter 'import';
use lib './lib';

use Regex ':regex';

our %EXPORT_TAGS = (
    subs => qw( 
        load_file
        get_question_total
        get_answers
        get_question
        get_right_answer
        get_layout
        ... 
    ),
);

my @layouts = ();
my @questions = ();
my %answers = ();

sub load_file ($filename) {
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
                $line =~ s{$Regex::ANSWER_PATTERN_REGEX}{[ ]$1};
                push (@{$answers{$question}}, $line);
                $line = readline ($fh_in);
            }
            
            while ($line !~ qr{$Regex::STARTLINE_DETECT_REGEX|$Regex::ENDLINE_DETECT_REGEX}) {
                $layout .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
            }
            seek ($fh_in,$position,0);

            push (@questions, $question);
            push (@layouts, $layout);
        }
        elsif ($line =~ $Regex::ENDLINE_DETECT_REGEX) {
            my $outro = $line;
            while ($line = readline($fh_in)) {
                $outro .= $line;
            }
            
            push (@layouts, $outro);
        }
        else {
            my ($intro,$position);
            while ($line !~ $Regex::STARTLINE_DETECT_REGEX) {
                $intro .= $line;
                $position = tell($fh_in);
                $line = readline ($fh_in);
            }
            seek ($fh_in,$position,0);
            
            push (@layouts, $intro);
        }
    }
}

sub get_question_total () {
    if (@questions) {
        return scalar (@questions);    
    }
    else {
        die ("File not loaded yet");
    }
}

sub get_right_answer ($num) {
    if (%answers) {
        my @ans = get_answers ($num);
        return $ans[0];    
    }
    else {
        die ("File not loaded yet");
    }
}

sub get_answers ($num) {
    if (%answers) {
        my $question = get_question ($num);
        return @{$answers{$question}};    
    }
    else {
        die ("File not loaded yet");
    }
}

sub get_question ($num) {
    if (@questions) {
        return $questions[$num-1];    
    }
    else {
        die ("File not loaded yet");
    }
}

sub get_layout ($num) {
    if (@layouts) {
        return $layouts[$num];    
    }
    else {
        die ("File not loaded yet");
    }
}

1;