use warnings;
use strict;
use v5.36;
use lib './lib';
use Regex ':regex';
use File_Input_Output ':subs';

print File_Input_Output::read();
print $Regex::REGEX; 