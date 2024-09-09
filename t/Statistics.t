use warnings;
use strict;
use v5.36;
use lib './lib';
use Test::More;

use Statistics ':subs';

my %result = (
    'Alexander' => [5, 13],
    'Jonas'     => [4, 14],
    'Leon'      => [10, 16],
    'Tom'       => [9, 20],
    'Paul'      => [20, 20],
);
Statistics::add_students(%result);

# Questions
my $total_question = 30;
my @min_question = (13,1);
my @max_question = (20,2);
my $avg_question = 16.6;

my @min_question_test = Statistics::min_question();
my @max_question_test = Statistics::max_question();
my $avg_question_test = Statistics::avg_question();

is_deeply(\@min_question_test, \@min_question, 'Minimum number of questions');
is_deeply(\@max_question_test, \@max_question, 'Maximum number of questions');
is_deeply($avg_question_test, $avg_question, 'Average number of questions');

# Answer 
my @min_answer = (4,1);
my @max_answer = (20,1);
my $avg_answer = 9.6;

my @min_answer_test = Statistics::min_answer();
my @max_answer_test = Statistics::max_answer();
my $avg_answer_test = Statistics::avg_answer();

is_deeply(\@min_answer_test, \@min_answer, 'Minimum number of correct answers');
is_deeply(\@max_answer_test, \@max_answer, 'Maximum number of correct answers');
is_deeply($avg_answer_test, $avg_answer, 'Average number of correct answers');

# Statistics
my %filter_total_question = (
    'Alexander' => [5, 13],
    'Jonas'     => [4, 14],
);

my %filter_correct_answer = (
    'Alexander' => [5, 13],
    'Jonas'     => [4, 14],
    'Tom'       => [9, 20],
);

my %filter_total_question_test = Statistics::less_than_half_the_total_question($total_question);
my %filter_correct_answer_test = Statistics::less_than_half_the_answers_correct();

is_deeply(\%filter_total_question_test, \%filter_total_question, 'Students with less than half the total questions');
is_deeply(\%filter_correct_answer_test, \%filter_correct_answer, 'Students with less than half answers correct');

done_testing();
