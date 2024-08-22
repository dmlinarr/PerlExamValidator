use v5.36;
use warnings;
use strict;

use Exporter::Attributes 'import';

sub test :Exported () {
    return "Success on import\n";
}

1;