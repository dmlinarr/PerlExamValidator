use warnings;
use strict;
use v5.36;
use lib './lib';
use Test::More;

use Cheating;

my $student_1 = Cheating->new('Alexander');
my $student_2 = Cheating->new('Jonas');
my $cheats_from_1_student = Cheating->new('Tom');

my $question_1 = 'what is green';
my $question_2 = 'what is blue';
my $question_3 = 'what is red';

my $answer_1_1 = 'frog';
my $answer_1_2 = 'water';
my $answer_1_3 = 'blood';

my $answer_2_1 = 'table';
my $answer_2_2 = 'spoon';
my $answer_2_3 = 'fork';

$student_1->add_wrong_answer($question_1,$answer_1_1);
$student_1->add_wrong_answer($question_2,$answer_1_2);
$student_1->add_wrong_answer($question_3,$answer_1_3);

$student_2->add_wrong_answer($question_1,$answer_2_1);
$student_2->add_wrong_answer($question_2,$answer_2_2);
$student_2->add_wrong_answer($question_3,$answer_2_3);

$cheats_from_1_student->add_wrong_answer($question_1,$answer_1_1);
$cheats_from_1_student->add_wrong_answer($question_2,$answer_1_2);
$cheats_from_1_student->add_wrong_answer($question_3,$answer_2_3);

my %cheaters = (
    'Alexander' => $student_1,
    'Jonas'     => $student_2,
    'Tom'       => $cheats_from_1_student,
);

$student_1->check_if_I_am_cheater(3,%cheaters);
$student_2->check_if_I_am_cheater(3,%cheaters);
$cheats_from_1_student->check_if_I_am_cheater(3,%cheaters);

my $log_expected = "     Tom\nand  Alexander..................................................probability: 66  (2 out of 3 exactly same false)\n";
my $log_got = $cheats_from_1_student->{log_cheater}{Alexander};

is($log_got,$log_expected,"Find the cheater");

done_testing();