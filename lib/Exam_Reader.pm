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
    ),
);

my @questions = ();
my %answers = ();

sub load_file ($filename) {
    open (my $fh_in, '<', $filename) or die ("Could not open file: $filename");
    my $question = undef;

    while (my $line = readline($fh_in)) {
        chomp($line);
        if ($line =~ $Regex::QUESTION_DETECT_REGEX) {
            $question = $line;
            push (@questions, $question); 
        }
        elsif ($line =~$Regex::ANSWER_DETECT_REGEX and defined $question) {
            $line =~ s{$Regex::ANSWER_PATTERN_REGEX}{[ ]$1};
            push (@{$answers{$question}}, $line);   
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

1;