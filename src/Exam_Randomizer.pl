use strict;
use warnings;
use v5.36;
use List::Util 'shuffle';
use POSIX 'strftime';
use lib './lib';

use Exam_Reader ':subs';
use Exam_Writer ':subs';
use Regex ':regex';


 
sub create_random_exam {
    Exam_Writer::write_other(Exam_Reader::get_other());
    
    my @num_bucket = shuffle(1 .. Exam_Reader::get_question_total());
    my $count = 1; 
    
    while (my $num = shift (@num_bucket)) {  
        my $question = Exam_Reader::get_question($num);
        my @random_answers = shuffle(Exam_Reader::get_answers($num));
        
        $question =~ s{$Regex::QUESTION_PATTERN_REGEX}{$count++}e;
        $question .= Exam_Reader::get_other();
        Exam_Writer::write_one_question($question, @random_answers);
        for (1..4) {Exam_Writer::write_other(Exam_Reader::get_other());}
    }
}

my $exam_name = strftime('%Y%m%d-%H%M%S-', localtime());
if ($ARGV[0] =~ $Regex::FILENAME_PATTERN_REGEX) {
    $exam_name .= "$1";
} 
else {
    warn "No match found for the filename pattern.\n";
}

Exam_Reader::load_file($ARGV[0]);
Exam_Writer::load_file("hello.txt");
create_random_exam();