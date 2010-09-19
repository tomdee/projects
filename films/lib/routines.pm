use warnings;
use strict;
use File::Basename;

package lib::routines;



our $gLocationOfSortedFilms = 'L:\\Video\\Sorted Films';


#When passed in all the details required for a film, it returns a string containing the directory name.
sub createFilmDirectory
{
  my ($title, $year, $duration, $rating, $id, $ids) = @_;
  #print "\n$title, $year, $duration, $rating, $id\n";
  #return $title . "(" . $year . ") - " . $duration . "mins - " . $rating . " [" . $id . "]";
  #255 character max
  #Title    - 100
  #Year     - 4
  #Duration - 3
  #Rating   - 3 (X.Y)
  #ID       - 7 
  #Total    = 100+4+3+3+7+((5*1)-1) = 121 (i.e. lots of space for genres, directors etc...)

  
  my $lName = sprintf("%.100s,%u,%.3u,%.1f,%07u", $title, $year, $duration, $rating, $id);
 # print "OLD: $lName ";
  $lName =~ s/[\\\/:\*\?\"\<\>\|]//g;
#  print "NEW: $lName \n";

  return $lName;
}

#Returns a hash of the information stored in the film directory.
sub parseFilmDirectory
{
  my ($lDir) = @_;
  $lDir = File::Basename::basename($lDir);
  
  #255 character max
  #Title    - 100
  #Year     - 4
  #Duration - 3
  #Rating   - 3 (X.Y)
  #ID       - 7 
  #Total    = 100+4+3+3+7+((5*1)-1) = 121 (i.e. lots of space for genres, directors etc...)

  my @lData = split(/,/, $lDir);
  
  my %lResult;
  $lResult{title} = $lData[0];
  $lResult{title} =~ /^.{1,100}$/ or die ("Invalid title from directory: $lDir"); #Just check length - must be present.
  
  $lResult{year} = $lData[1];
  $lResult{year} and $lResult{year} =~ /^\d{4}$/ or die ("Invalid year from directory: $lDir"); # EIther four digits or nothing
  
  $lResult{duration} = $lData[2];
  $lResult{duration} and $lResult{duration} =~ /^\d{1,3}$/ or die ("Invalid duration from directory: $lDir"); #Can only be 1 - 3 digits
  
  $lResult{rating} = $lData[3];
  $lResult{rating} and $lResult{rating} =~ /^\d\.\d$/ or die ("Invalid rating from directory: $lDir"); #digit.digit
  
  $lResult{id} = $lData[4];
  $lResult{id} =~ /^\d{4,8}$/ or die ("Invalid id from directory: $lDir"); #Must be present - 4-8 digits
  
  return \%lResult;
}


1;