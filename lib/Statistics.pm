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
    ), 
);

my %data;

sub add_students (%students) {
    %data = %students;
}

sub min_question () {
    if (%data) {
        my $min = 'inf';
        my $amount = 0;
        
        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
                if ($min > $data{$student}[1]) {
                    $min = $data{$student}[1];
                    $amount = 1;
                }
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

sub max_question () {
    if (%data) {
        my $max = '-inf';
        my $amount = 0;

        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
                if ($max < $data{$student}[1]) {
                    $max = $data{$student}[1];
                    $amount = 1;
                }
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

sub avg_question () {
    if (%data) {
        my $sum = 0;
        my $count = 0;

        for my $student (keys %data) {
            if (defined $data{$student}[1]) {
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

sub min_answer () {
    if (%data) {
        my $min = 'inf';
        my $amount = 0;

        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
                if ($min > $data{$student}[0]) {
                    $min = $data{$student}[0];
                    $amount = 1;
                }
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

sub max_answer () {
    if (%data) {
        my $max = '-inf';
        my $amount = 0;

        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
                if ($max < $data{$student}[0]) {
                    $max = $data{$student}[0];
                    $amount = 1;
                }
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

sub avg_answer () {
    if (%data) {
        my $sum = 0;
        my $count = 0;

        for my $student (keys %data) {
            if (defined $data{$student}[0]) {
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

1;