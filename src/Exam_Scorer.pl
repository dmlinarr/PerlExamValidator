use strict;
use warnings;
use v5.36;
use lib './lib';

use Exam_Reader;
use Regex ':regex';

sub read_in_exams ($master,@students) {
    print "MASTER: $master\n";
    for my $student (@students) {
        print "STUDENT: $student\n";
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

my $master = $ARGV[0];
my @students = read_in_files(@ARGV[1..scalar(@ARGV)-1]);
read_in_exams ($master,@students);