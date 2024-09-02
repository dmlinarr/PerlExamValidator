use strict;
use warnings;
use v5.36;
use lib './lib';

use Exam_Reader;
use Regex ':regex';

# use Data::Show;

my $master = undef;
my @students = ();

sub print_score () {
    if ($master && @students) {
        for my $student (@students) {
            my $question_num = $student->get_question_total();
            my $student_score = 0;

            for my $num (1 .. $question_num) {
                my $question_pressed = $student->get_question_pressed($num);
                my @student_answer = $student->get_marked_answer_pressed($question_pressed);
                my @master_answer = $master->get_marked_answer_pressed($question_pressed);
                
                if (scalar(@student_answer) == 1 && scalar(@master_answer) == 1 && $master_answer[0] eq $student_answer[0]) {
                    $student_score++;
                }
            }

            my $filename = $student->get_filename();
            my $final_score = $student_score . "/" . $question_num;
            my $output = $filename . ('.' x (80-length($filename)-length($final_score))) . $final_score;
            print "$output\n";
        }
    }
    else {
        die ("Exams are not loaded");
    }
}

sub read_in_exams ($master_file,@students_files) {
    $master = Exam_Reader->new($master_file);
    
    for my $student_file (@students_files) {
        push (@students,Exam_Reader->new($student_file));
    }
}

sub read_in_files (@inputs) {
    my @files = ();
    
    for my $input (@inputs) {
        
        if (-f $input) {
            push (@files, $input);
        } 
        else {
            my @wild_files = glob ($input);
            push (@files, @wild_files);
       }

    }

    return @files;
}

# $ARGV[0] = 'resource/normal-exam/IntroPerlEntryExam.txt'; 
# $ARGV[1] = 'resource/normal-exam/Wagner_Caro.txt';


my $master_file = $ARGV[0];
my @students_files = read_in_files(@ARGV[1..scalar(@ARGV)-1]);
read_in_exams ($master_file,@students_files);
print_score ();