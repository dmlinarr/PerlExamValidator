use warnings;
use strict;
use v5.36;
use lib './lib';
use Regex ':regex';
use File_Input_Output ':subs';
use Test::More;

my $sub = File_Input_Output::read();
my $reg = $Regex::REGEX;

is_deeply($sub,"I am a read function\n");
is_deeply($reg,"I am a regex\n");

done_testing();