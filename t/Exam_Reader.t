use warnings;
use strict;
use v5.36;
use lib './lib';
use Test::More;

use Exam_Reader;

# load_file
my $reader = Exam_Reader->new('./resource/test-exam/Test_Exam.txt');

# question_through_num
is($reader->question_through_num(3),"today date:","question_through_num");
is($reader->question_through_num(4),"cats like:","question_through_num");

# question_through_toleranz
is($reader->question_through_toleranz("today date#:"),"today date:","question_through_toleranz");
is($reader->question_through_toleranz("cats like#:"),"cats like:","question_through_toleranz");

# pretty_question_through_norm
is($reader->pretty_question_through_norm("today date:"),"Today is the date:","pretty_question_through_norm");
is($reader->pretty_question_through_norm("cats like:"),"Cats like:","pretty_question_through_norm");

# printed_question_through_norm
is($reader->printed_question_through_norm("today date:"),"3. Today is the date:\n","printed_question_through_norm");
is($reader->printed_question_through_norm("cats like:"),"4. Cats like:\n","printed_question_through_norm");

# all_answers_through_norm_question
my @answer_expected = ("jump water", "eat sandwich", "put glasses", "delete computer", "throw away computer");
my @answers_got = $reader->all_answers_through_norm_question("today date:");

is_deeply(\@answers_got,\@answer_expected,"all_answers_through_norm_question");

# marked_answers_through_norm_question
my @first_answer = $reader->marked_answers_through_norm_question("today date:");
my @second_answer = $reader->marked_answers_through_norm_question("cats like:");

is($first_answer[0],"throw away computer","marked_answers_through_norm_question");
is($second_answer[0],"humans feed","marked_answers_through_norm_question");

# pretty_answer_through_norm
is($reader->pretty_answer_through_norm("throw away computer"),"To throw away my computer","pretty_answer_through_norm");
is($reader->pretty_answer_through_norm("humans feed"),"humans who feed them","pretty_answer_through_norm");

# printed_answer_through_norm
is($reader->printed_answer_through_norm("throw away computer"),"    [ ] To throw away my computer\n","printed_answer_through_norm");
is($reader->printed_answer_through_norm("humans feed"),"    [ ] humans who feed them \n","printed_answer_through_norm");

done_testing();