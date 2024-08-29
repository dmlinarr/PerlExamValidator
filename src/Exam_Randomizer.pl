use strict;
use warnings;
use v5.36;
use List::Util 'shuffle';
use POSIX 'strftime';
use lib './lib';

use Exam_Reader;
use Exam_Writer ':subs';
use Regex ':regex';

sub create_random_exam ($reader){
    my $question_num = $reader->get_question_total();
    my @num_bucket = shuffle(1 .. $question_num);
    my $count = 1;

    my $intro = $reader->get_layout(0);
    Exam_Writer::write_intro_or_outro($intro);
    
    while (my $num = shift (@num_bucket)) {  
        my $layout = $reader->get_layout($num);
        my $question = $reader->get_question_pretty($num);
        my @random_answers = shuffle($reader->get_answers_pretty($num));
        
        $question =~ s{$Regex::QUESTION_PATTERN_REGEX}{$count++}e;
        Exam_Writer::write_one_question($layout, $question, @random_answers);
    }

    my $outro = $reader->get_layout($question_num+1);
    Exam_Writer::write_intro_or_outro($outro);
}

my $exam_name = strftime('%Y%m%d-%H%M%S-', localtime());
if ($ARGV[0] =~ $Regex::FILENAME_PATTERN_REGEX) {
    $exam_name .= "$1";
} 
else {
    warn "No match found for the filename pattern.\n";
}

my $reader = Exam_Reader->new($ARGV[0]);
Exam_Writer::load_file($exam_name);
create_random_exam($reader);