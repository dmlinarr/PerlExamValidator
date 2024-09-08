package Cheating;

use v5.36;
use warnings;
use strict;

use Exporter 'import';

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

sub add_wrong_answer ($self, $norm_master_question, $norm_wrong_answer) {
    $self->{wrong_answers}{$norm_master_question} = $norm_wrong_answer;
}

sub check_if_I_am_cheater ($self, $total_questions, %cheaters) {
    my $amount_wrong_questions = scalar(keys %{$self->{wrong_answers}});
    my $amount_identical_answer = 0;

    for my $cheater_name (sort keys %cheaters) {
        # Vergleiche mit jedem $cheater in %cheaters AUSSER mit sich selbst    
        next if $cheater_name eq $self->{filename};
        
        my $cheater = $cheaters{$cheater_name};
        # Erstens: Check ob gleiche Master Frage falsch
        for my $wrong_question (sort keys %{$cheater->{wrong_answers}}) {
            if (exists $self->{wrong_answers}{$wrong_question}) { 

                # Wenn gleich, -> Check ob gleiche Antwort
                if ($self->{wrong_answers}{$wrong_question} eq $cheater->{wrong_answers}{$wrong_question}) {
                    
                    # Wenn gleich -> $amount_identical_answer++
                    $amount_identical_answer++;
                }
            }
        }
        
        if ($amount_identical_answer > 0 && $amount_wrong_questions/$total_questions > 0.1) {
            my $probability = int(($amount_identical_answer/$amount_wrong_questions) * 100);

            # Alles ueber 50%: $self->{log_cheater}{$cheater_name} = $log
            if ($probability > 50) {
                my $filename = $self->{filename};
                my $log = "     $filename\nand  $cheater_name" . ('.' x (80-length("and   $cheater_name")-length("probability: $probability"))) .  "probability: $probability  ($amount_identical_answer out of $amount_wrong_questions exactly same false)\n";
                $self->{log_cheater}{$cheater_name} = $log;
            }
            $amount_identical_answer = 0;
        }
    }
    
}

sub cheaters_logged ($self, $cheater) {
    return $self->{log_cheater}{$cheater};
}

1;