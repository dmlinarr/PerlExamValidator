use strict;
use warnings;
use v5.36;
use lib './lib';

use Exam_Reader ':subs';
 
Exam_Reader::load_file($ARGV[0]);

print "Total Questions: ", Exam_Reader::get_question_total(), "\n";
print "Question 10: ", Exam_Reader::get_question(10), "\n";
print "Answers 10:", Exam_Reader::get_answers(10), "\n";
print "Right answer 10: ", Exam_Reader::get_right_answer(10), "\n";