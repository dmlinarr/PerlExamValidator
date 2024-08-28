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
    my $question_num = Exam_Reader::get_question_total();
    my @num_bucket = shuffle(1 .. $question_num);
    my $count = 1;

    Exam_Writer::write_intro_or_outro(Exam_Reader::get_layout(0));
    
    while (my $num = shift (@num_bucket)) {  
        my $layout = Exam_Reader::get_layout($num);
        my $question = Exam_Reader::get_question($num);
        my @random_answers = shuffle(Exam_Reader::get_answers($num));
        
        $question =~ s{$Regex::QUESTION_PATTERN_REGEX}{$count++}e;
        Exam_Writer::write_one_question($layout, $question, @random_answers);
    }

    Exam_Writer::write_intro_or_outro(Exam_Reader::get_layout($question_num+1));
}

my $exam_name = strftime('%Y%m%d-%H%M%S-', localtime());
if ($ARGV[0] =~ $Regex::FILENAME_PATTERN_REGEX) {
    $exam_name .= "$1";
} 
else {
    warn "No match found for the filename pattern.\n";
}

Exam_Reader::load_file($ARGV[0]);
Exam_Writer::load_file($exam_name);
create_random_exam();