use YAML::XS 'LoadFile';
use warnings;
use strict;
use v5.36;

BEGIN {
    my $config = LoadFile('config.yaml');
    push @INC, $config->{lib_path};
}

use Export;


print test;