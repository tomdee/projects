use Imager;
use strict;
use warnings;


my $lSize = 8;
#my $lText = "Hello, world!!!";
my $lText = "CEAVA CEAVA CEAVA";
my $image = Imager->new(xsize => 100, ysize => $lSize);

my $font = Imager::Font->new(face => "Small Fonts Regular") or die "Cannot load font: ", Imager->errstr;
$image->string(
  x      => 0,
  y      => $lSize,
  string => $lText,
  font   => $font,
  size   => $lSize,
  aa     => 0,
  color  => 'white'
);

$image->write(file => 'tutorial1.png')
  or die 'Cannot save tutorial1.png: ', $image->errstr;

print "The Image\n";
my @values;

for my $x (0..99)
{
  my $lLine = 0;
 for(my $y=($lSize-1);$y>=0;$y--)
 {
  my $color = $image->getpixel(x=>$x, y=>$y);
  my ($red, $green, $blue, $alpha) = $color->rgba();
  
  if ($red > 50)
  {
   print "*";
   $lLine = $lLine | 1; # Set last bit to "1";
  } 
  else
  {
   print " ";
   $lLine = $lLine & 254; # Set last bit to "0";
  }
  
  # and shift
  $lLine = $lLine << 1;
 }
 $lLine = $lLine >> 1;
 push(@values, $lLine);
 print "\n";
}

print "int cols[] = {";
foreach my $lValue (@values)
{
  print "$lValue,";
}

print "};\n";