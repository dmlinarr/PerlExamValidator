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
    push (@{$self->{wrong_answers}{$norm_master_question}}, $norm_wrong_answer)
}

sub check_if_I_am_cheater ($self, $question_amount, $answer_amount, %cheaters) {
    # n = Anzahl Fragen gesamt
    # y = Anzahl FALSCHE Antwortmoeglichkeiten pro Frage
    # k = Anzahl der Fragen, die beide Studenten gleich falsch geloesst haben
    my $n = $question_amount;
    my $y = $answer_amount - 1;
    my $k = 0;

    # Binomialkoeffizient (n//k):
    # 1/(n//k) Warscheinlichkeit, dass beide Studenten von n vielen Fragen die gleichen k vielen Fragen falsch
    # (1/y)^k Warscheinlichkeit, dass beide Studenten bei k vielen Fragen die gleiche falsche Antwort nehmen
    # Result: 1/(n//k) * (1/y)^k Warscheinlichkeit, dass die selben k vielen Fragen falsch beantwortet UND gleiche falsche Antwort genommen
    
    # Vergleiche mit jedem $cheater in %cheaters AUSSER mit sich selbst
    for my $cheater (keys %cheaters) {
        
        # Erstens: Check ob gleiche Master Frage falsch
        for my $wrong_question (keys %{$cheater->{wrong_answers}}) {
            if ("both same master question") { # Bitte hier implementieren

                # Wenn gleich, -> Check ob aehnliche Antwort
                if ($self->has_same_answer(@{$cheater->{wrong_answers}{$wrong_question}})) {
                    
                    # Wenn gleich -> k++
                    $k++;
                }
            }
        }
        
        # $probability fuer Cheat: {1 - (1/(n//k) * (1/y)^k)} * 100
        if ($k > 0) {
            my $probability = $self->calc_probability($n,$y,$k);

            # Alles ueber 50%: $self->{log_cheater}{$cheater} = $log
            if ($probability > 50) {
                my $filename = $self->{filename};
                my $log = "     $filename\nand  $cheater" . ('.' x (80-length("and   $cheater")-length("probability: $probability"))) .  "probability: $probability  ($k out of $n exactly same false)\n";
                $self->{log_cheater}{$cheater} = $log;
            }
        }
    }
    
}

sub has_same_answer($self, @wrong_answers) {
    # With respect to Distanz
}

sub calc_probability($self, $n, $y, $k) {
    # $probability fuer Cheat: {1 - (1/(n//k) * (1/y)^k)} * 100
}

sub cheaters_logged ($self, $cheater) {
    return $self->{log_cheater}{$cheater};
}

1;