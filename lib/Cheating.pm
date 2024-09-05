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
    };
    
    my $cheater = bless ($self, $class);
    return $cheater;
}

sub add_wrong_answer ($self, $norm_master_question, $norm_wrong_answer) {
    push (@{$self->{wrong_answers}{$norm_master_question}}, $norm_wrong_answer)
}

sub check_if_I_am_cheater (%wrong_answers) {
    # return all over 50% possability that I have cheated with someone else
}


1;