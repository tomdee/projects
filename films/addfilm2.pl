#TODO Make it search based on the name of the first file
use Getopt::Long;
use IMDB::Film;
use LWP::Simple;
use File::Copy;
use File::Spec;

use lib::routines;
use XML::Simple;
use Data::Dumper;

use Win32;

use strict;
use warnings;

my $gTest = 0;
my $gName = "";
my $gID = 0;
my $gHelp = 0;
#my $cPath = $lib::constants::gLocationOfSortedFilms;
#my $cPath = File::Spec->curdir();

my %gImdbFilmOptions = (
						#debug => 1,
						cache => 1,
						cache_root => 'c:\filmcache'
						);

if (scalar(@ARGV) != 0)
{
  showHelp("No arguments may be passed");
}

my $dirname = "l:\\video\\sorted films2";

my $config = XMLin("L:\\Video\\Film Database\\fullxml.xml", Cache => "storable");


foreach my $lFilm (@{$config->{tblfilms}})
{	
	my $lFilmID = $lFilm->{FilmID} ;
	next unless $lFilmID > "439";
	my $MyDir;
	foreach my $lFile (@{$config->{tblfiles}})
	{
		if ($lFile->{FilmID} eq $lFilmID)
		{
			$MyDir = $lFile->{FilePath};
			last;
		}	
	}

	if ($MyDir)
	{
		#print "Found dir: $MyDir\n";
		#print ".\n";
		my $MyDir = Win32::GetANSIPathName($MyDir);

		if (-d "$dirname\\$MyDir")
		{
		    print "mydir = $MyDir ";
			# Extract the IMDB ID
			#print Dumper($lFilm);
			my $lImdbId = $lFilm->{ImdbID};
			#print "Searching for ID: $lImdbId ";
			#print Dumper($lImdbId);
			#exit();
			
			# Use IMDB ID to fetch the new details
			my $lFilm = new IMDB::Film(crit => $lImdbId, %gImdbFilmOptions);
			
			#print Dumper($lFilm->rating());
			
			my $lDirectory = getFilmDirectory($lFilm);
			
			if (! defined($lDirectory))			
			{
			  print "skipping " . $lFilm->title() . " because I couldn't get some details";
			  next;
			}
			
			
			
			$lDirectory = "l:\\video\\sorted films\\$lDirectory";
			# Rename the directory to the new one.
			print "Renaming $dirname\\$MyDir to $lDirectory\n";
			
#my $lUserInput =  <STDIN>;
#chomp ($lUserInput);

#if ($lUserInput !~ /y/i)
#{
  #exit(1);
#}
			
			rename("$dirname\\$MyDir", "$lDirectory");
			
			#Save off the HTML and cover too.
			my $lCoverFile = File::Spec->catfile($lDirectory, $lFilm->id() . ".jpg");
			
			print "Saving off cover to $lCoverFile ";

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
		}
		else
		{
			print "film directory: $MyDir ";
			print "MISSING";
			print "\n"; 
		}
	}	
}

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
print "This script is for migrating my films from the old structure to the new.
The script takes no arguments.
 
";
exit(0);
}