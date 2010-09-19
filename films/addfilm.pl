#TODO Make it search based on the name of the first file
use Getopt::Long;
use IMDB::Film;
use LWP::Simple;
use File::Copy;
use File::Spec;

use lib::routines;

use strict;
use warnings;

my $gTest = 0;
my $gName = "";
my $gID = 0;
my $gHelp = 0;
my $cPath = $lib::routines::gLocationOfSortedFilms;
#my $cPath = File::Spec->curdir();

my %gImdbFilmOptions = (
						#debug => 1,
						cache => 1,
						cache_root => 'c:\filmcache'
						);

GetOptions ('test' => \$gTest,
			'name|n=s' => \$gName,
			'help|h' => \$gHelp,
			'id|i=i' => \$gID); #ID is always an integer
			
			
if ($gHelp)
{
	showHelp();
}

if ($gTest)
{
	print "**********TEST MODE**********\n";
}

if (scalar(@ARGV) == 0)
{
  showHelp("At least one file must be passed in");
}

foreach my $lFile (@ARGV)
{
  if (! -f $lFile)
  {
    showHelp("File $lFile doesn't exist");
  }
}

my $lFilm;

if ($gID)
{
	$lFilm = new IMDB::Film(crit => $gID, %gImdbFilmOptions);
}
elsif ($gName)
{
print "Searching for $gName\n";
	$lFilm = new IMDB::Film(crit => $gName, %gImdbFilmOptions);
}
else
{
  showHelp("A film name or ID must be specified");
}


printFilmDetail($lFilm);

print "\nIs this the right film?\n";
my $lUserInput =  <STDIN>;
chomp ($lUserInput);

if ($lUserInput !~ /y/i)
{
  exit(1);
}

#Construct destination directory
my $lDirectory = getFilmDirectory($lFilm);

if (! defined($lDirectory))			
{
  print "skipping " . $lFilm->title() . " because I couldn't get some details";
  exit(0);
}
			
$lDirectory = File::Spec->catdir(($cPath, $lDirectory));
print $lDirectory . "\n";

if (! -d $lDirectory)
{
	#Directory doesn't exist - create it.
	mkdir($lDirectory);
}
elsif(dirIsEmpty($lDirectory))
{
	#Directory exists but is empty. Do nothing. 
}
else
{
	#Directory exists and contains files.
	#print "\n$lDirectory\n already exists and contains files. Cannot proceed\n";
	
   # exit(1);
   print "\n$lDirectory\n already exists and contains files. Proceeding\n";
}

#Forach file in ARGV move the file to the directory
foreach my $lFile (@ARGV)
{
  print "Moving $lFile\n";
  move($lFile, $lDirectory);  
}

#Save off the HTML and cover too.
my $lCoverFile = File::Spec->catfile($lDirectory, $lFilm->id() . ".jpg");
print "Saving off cover to $lCoverFile\n";

my $lGetResult = "No Cover Available";

if ($lFilm->cover())
{
  $lGetResult = getstore($lFilm->cover(), $lCoverFile);
}
if (is_success($lGetResult))
{
  print "... success\n";
}
else
{
  print "Couldn't get cover from " . $lFilm->cover() . "\n Return code: $lGetResult\n";
}

open (MYFILE, '>' . File::Spec->catfile($lDirectory, $lFilm->id() . ".html"));
print MYFILE ${$lFilm->_content()};
close (MYFILE); 

print "\nALL DONE \n";
exit(0);

sub getFilmDirectory
{
	my ($lFilm) = @_;
	my $lDir = "";
	
    if($lFilm->status) 
	{
	  my $lDuration;
	  if ($lFilm->duration() =~ /(\d+)/)
	  {
	    $lDuration = $1;
	  }
	  
	  my $id = $lFilm->id();
	  my $lRating = $lFilm->rating();	  
	  
	  if (!defined($lRating))
	  {
	    return undef;
	  }
	  
	  $lDir = lib::routines::createFilmDirectory($lFilm->title(),
												 $lFilm->year(),
												 $lDuration,
											     $lRating,
												 $id);		
    } 
	else 
	{
		print "Something wrong: ".$lFilm->error;
		exit(0);
    }
	
	return $lDir;	
}

sub printFilmDetail
{
	my ($lFilm) = @_;
	
    if($lFilm->status) {
                print "Title: " . $lFilm->title() . " (" . $lFilm->rating() . ")\n";
				print "Length: ".$lFilm->duration()."\n";
                print "Year: ".$lFilm->year()."\n";
                print "Plot Symmary: ".$lFilm->plot()."\n";
				print "Genres: @{ $lFilm->genres() } \n";
        } else {
                print "Something wrong: ".$lFilm->error;
				exit(0);
        }
}

sub dirIsEmpty
{
    my ($path) = @_;
    opendir DIR, $path;
    while(my $entry = readdir DIR) {
        next if($entry =~ /^\.\.?$/);
        closedir DIR;
        return 0;
    }
    closedir DIR;
    return 1;
}

sub trim
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

sub showHelp
{
my ($lText) = @_;
print "$lText\n";
print "This script is for organising films into subdirectories.
The script takes the following arguments:
  -i --id   An Imdb ID of the film.
  -n --name The name of the film.
  -h ==help Display help text.
  A list of file names to move.
  
  addfilm.pl [-i|-n]=criteria <files>
";
exit(0);
}