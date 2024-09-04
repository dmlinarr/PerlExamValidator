use strict;
use warnings;
use v5.36;
use lib './lib';

use Exam_Reader;
use Regex ':regex';
use Statistics ':subs';

my $master = undef;
my @students = ();

sub print_score () {
    if ($master && @students) {
        (my $assessment, my %missing_questions, my %missing_answers, my %result);
         my $question_num = $master->get_question_total();

        for my $student (@students) {
            my $student_questions = 0;
            my $student_score = 0;

            for my $num (1 .. $question_num) {
                my $question_pressed = $master->get_question_pressed($num);
                
                my @student_answers_marked = $student->get_marked_answer_pressed($question_pressed);
                my @master_answers_marked = $master->get_marked_answer_pressed($question_pressed);
                
                if (scalar(@student_answers_marked) == 1) {
                    $student_questions++;
                    if ($master_answers_marked[0] eq $student_answers_marked[0]) {
                        $student_score++;
                    }
                }
                
                
                if (my @student_answers_pressed = $student->has_question($question_pressed)) {
                    my @master_answers_pressed = $master->get_answers_pressed($num);
                    
                    for my $answer (@master_answers_pressed) {
                        unless (grep { $_ eq $answer } @student_answers_pressed) {
                            my $filename = $student->get_filename();
                            my $answer_pretty = $master->reverse_answer_to_pretty($answer);            
                            push (@{$missing_answers{$filename}}, $answer_pretty);
                        }
                    }
                }
                else {
                    my $filename = $student->get_filename();        
                    my $question = $master->get_question_pretty($num);
                    push (@{$missing_questions{$filename}}, $question);
                }
            }

            my $filename = $student->get_filename();
            my $final_score = $student_score . "/" . $student_questions;
            my $output = $filename . ('.' x (80-length($filename)-length($final_score))) . $final_score;
            
            $assessment .= "$output\n";
            $result{$filename} = [$student_score, $student_questions];
        }
        print_assessment ($assessment);
        print_missing_questions (%missing_questions);
        print_missing_answers (%missing_answers);
        print_statistics (%result);
    }
    else {
        die ("Exams are not loaded");
    }
}

sub print_assessment ($assessment) {
    print $assessment;
    print '#' x 80 . "\n";
}

sub print_missing_questions (%missing_questions) {
    for my $filename (sort keys %missing_questions) {
        print "$filename:\n";
        for my $question (@{ $missing_questions{$filename} }) {
            print "     Missing question: $question";
        }
    }
    print '#' x 80 . "\n";
}

sub print_missing_answers (%missing_answers) {
    for my $filename (sort keys %missing_answers) {
        print "$filename:\n";
        for my $answer (@{ $missing_answers{$filename} }) {
            print "     Missing answer: $answer";
        }
    }
    print '#' x 80 . "\n";
}

sub print_statistics (%students) {
    Statistics::add_students (%students);
    
    my $avg_question = Statistics::avg_question();
    my @min_question_stats = Statistics::min_question();
    my @max_question_stats = Statistics::max_question();

    my $avg_answer = Statistics::avg_answer();
    my @min_answer_stats = Statistics::min_answer();
    my @max_answer_stats = Statistics::max_answer();
    
    my %less_half_total_question = Statistics::less_than_half_the_total_question($master->get_question_total());
    my %less_half_answers_correct = Statistics::less_than_half_the_answers_correct();
    
    if (scalar(@min_question_stats) == 2 && scalar(@max_question_stats) == 2) {
        my $min_question = $min_question_stats[0];
        my $min_question_amount = $min_question_stats[1];
        my $max_question = $max_question_stats[0];
        my $max_question_amount = $max_question_stats[1];

        print "Average number of questions answered:" . ('.' x (80-length("Average number of questions answered:")-length($avg_question))) . "$avg_question\n";
        print "     Minimum:" . ('.' x (80-length("     Minimum:")-length($min_question))) . "$min_question  (So many: $min_question_amount)\n";
        print "     Maximum:" . ('.' x (80-length("     Maximum:")-length($max_question))) . "$max_question  (So many: $max_question_amount)\n";
    }
    
    if (scalar(@min_answer_stats) == 2 && scalar(@max_answer_stats) == 2) {
        my $min_answer = $min_answer_stats[0];
        my $min_answer_amount = $min_answer_stats[1];
        my $max_answer = $max_answer_stats[0];
        my $max_answer_amount = $max_answer_stats[1];
        
        print "Average number of correct answers:" . ('.' x (80-length("Average number of correct answers:")-length($avg_answer))) . "$avg_answer\n";
        print "     Minimum:" . ('.' x (80-length("     Minimum:")-length($min_answer))) . "$min_answer  (So many: $min_answer_amount)\n";
        print "     Maximum:" . ('.' x (80-length("     Maximum:")-length($max_answer))) . "$max_answer  (So many: $max_answer_amount)\n";
    }

    my $header;

    if (%less_half_total_question) {
        $header = "Results below expectation:\n";
        print $header;
        
        for my $less_half_tot (keys %less_half_total_question) {
            my $score = $less_half_total_question{$less_half_tot}[0];
            my $tot_question = $less_half_total_question{$less_half_tot}[1];
            my $final_score = $score . "/" . $tot_question;
            print "     $less_half_tot" . ('.' x (80-length("     $less_half_tot")-length($final_score))) . "$final_score  (Question answered < 50%)\n";
        }
    }

    if (%less_half_answers_correct) {
        if(not defined($header)) {
            $header = "Results below expectation:\n";
            print $header;
        }

        for my $less_half_answer (keys %less_half_answers_correct) {
            my $score = $less_half_answers_correct{$less_half_answer }[0];
            my $tot_question = $less_half_answers_correct{$less_half_answer }[1];
            my $final_score = $score . "/" . $tot_question;
            print "     $less_half_answer" . ('.' x (80-length("     $less_half_answer")-length($final_score))) . "$final_score  (Answers correct < 50%)\n";
        }
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
# $ARGV[1] = 'resource/normal-exam/*';

my $master_file = $ARGV[0];
my @students_files = read_in_files(@ARGV[1..scalar(@ARGV)-1]);
read_in_exams ($master_file,@students_files);
print_score ();