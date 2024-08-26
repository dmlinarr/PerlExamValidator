use warnings;
use strict;
use v5.36;
use lib './lib';

use File_Input_Output ':subs';

File_Input_Output::load_file($ARGV[0]);