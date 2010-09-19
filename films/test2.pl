use lib::routines;
use Data::Dumper;

use strict;
use warnings;

my $dirname = "l:\\video\\sorted films";


foreach my $lFile (@ARGV)
{
  print "Processing $lFile\n";
  print Dumper(lib::routines::parseFilmDirectory($lFile));
}