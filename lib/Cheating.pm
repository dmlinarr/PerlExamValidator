package Cheating;

use v5.36;
use warnings;
use strict;
# use Math::BigInt;
# use Math::BigFloat;

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
    
    for my $cheater_name (sort keys %cheaters) {
        # Vergleiche mit jedem $cheater in %cheaters AUSSER mit sich selbst    
        next if $cheater_name eq $self->{filename};
        
        my $cheater = $cheaters{$cheater_name};
        # Erstens: Check ob gleiche Master Frage falsch
        for my $wrong_question (sort keys %{$cheater->{wrong_answers}}) {
            if (exists $self->{wrong_answers}{$wrong_question}) { 

                # Wenn gleich, -> Check ob gleiche Antwort
                if ($self->{wrong_answers}{$wrong_question} eq $cheater->{wrong_answers}{$wrong_question}) {
                    
                    # Wenn gleich -> k++
                    $k++;
                }
            }
        }
        
        # $probability fuer Cheat: {1 - (1/(n//k) * (1/y)^k)} * 100
        # CANCLED: my $probability = calc_probability($n,$y,$k);
        if ($k > 0) {
            my $probability = int(($k/$n) * 100);

            # Alles ueber 20%: $self->{log_cheater}{$cheater} = $log
            if ($probability >= 20) {
                my $filename = $self->{filename};
                my $log = "     $filename\nand  $cheater_name" . ('.' x (80-length("and   $cheater_name")-length("probability: $probability"))) .  "probability: $probability  ($k out of $n exactly same false)\n";
                $self->{log_cheater}{$cheater_name} = $log;
            }
            $k = 0;
        }
    }
    
}

sub cheaters_logged ($self, $cheater) {
    return $self->{log_cheater}{$cheater};
}

# sub has_same_answer ($self, $wrong_question, @cheater_wrong_answers) {
#    # With respect to Distanz
#    my @my_wrong_answers = @{$self->{wrong_answers}{$wrong_question}};
#
#    if (@my_wrong_answers != @cheater_wrong_answers) {
#        return 0;
#    }
#    else {
#        my @sorted_my_wrong_answers = sort @my_wrong_answers; 
#        my @sorted_cheater_wrong_answers = sort @cheater_wrong_answers;
#
#        for (my $i = 0; $i < @sorted_my_wrong_answers; $i++) {
#            if ($sorted_my_wrong_answers[$i] ne $sorted_cheater_wrong_answers[$i]) {
#                return 0;  # false if any element is different
#            }
#        }
#        return 1;
#    }
# }

# sub binomial ($n, $k) {
#    if ($k > $n) {
#        return 0;
#    }
#    else {
#        my $n_fact = Math::BigInt->new($n)->bfac();
#        my $k_fact = Math::BigInt->new($k)->bfac();
#        my $n_minus_k_fact = Math::BigInt->new($n - $k)->bfac();
#    
#        return $n_fact / ($k_fact * $n_minus_k_fact); 
#    }
# }

# sub calc_probability ($n, $y, $k) {
#    # Berechnung question probability: 1 / binomial(n, k)
#    my $question_probability = Math::BigFloat->new(1)->bdiv(binomial($n, $k));
#
#    # Berechnung answer probability: (1 / y) ^ k
#    my $answer_probability = Math::BigFloat->new(1)->bdiv(Math::BigFloat->new($y))->bpow($k);
#
#    # Berechnung final probability: {1 - (question_probability * answer_probability)} * 100
#    my $probability = (Math::BigFloat->new(1)->bsub($question_probability->bmul($answer_probability)))->bmul(100);
#
#    return $probability->bfloor();
# }

1;