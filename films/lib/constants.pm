use warnings;
use strict;

package lib::constants;



our $gLocationOfSortedFilms = 'L:\\Video\\Sorted Films';


#When passed in all the details required for a film, it returns a string containing the directory name.
sub createFilmDirectory
{
  my ($title, $year, $duration, $rating, $id) = @_;
  print "\n$title, $year, $duration, $rating, $id\n";
  #return $title . "(" . $year . ") - " . $duration . "mins - " . $rating . " [" . $id . "]";
  #255 character max
  #Title    - 100
  #Year     - 4
  #Duration - 3
  #Rating   - 3 (X.Y)
  #ID       - 7 
  #Total    = 100+4+3+3+7+((5*1)-1) = 121 (i.e. lots of space for genres, directors etc...)
  return sprintf("%.100s,%u,%.3u,%.1f,%07u", $title, $year, $duration, $rating, $id);
}


1;