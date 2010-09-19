use File::Basename;
use lib::routines;
use Getopt::Long;

my @cProcessors = (
					\&rating,
					);

my $cTargetBase = "/mnt/disk1/share/Video";
#Process inputs
#either loop over all directories or just process a single one.
#donl
my $gTest = 0;
my $gHelp = 0;
my $gAll = 0;
my $gSingle = 0;

GetOptions ('test' => \$gTest,
			'all|a' => \$gAll, 
			'help|h' => \$gHelp,
			'single|s=s' => \$gSingle);
$gHelp and showHelp();			
$gAll or $gSingle or die "Must specifiy one of -a or -s\n";

if ($gSingle)
{
	processDirectory($gSingle);
}
else
{
    my $lSortedFilms = "$cTargetBase/Sorted Films"; 
    opendir(SORTEDDIR, $lSortedFilms) or die "can't opendir $lSortedFilms: $!";
    while (defined($file = readdir(SORTEDDIR))) 
    {
      next if $file =~ /^.$/;
      next if $file =~ /^..$/;
      print "Processing $lSortedFilms/$file\n";
	processDirectory("$lSortedFilms/$file");
    }

    closedir(SORTEDDIR);
}

sub processDirectory
{
	my ($lSource) = @_;
	$lData = lib::routines::parseFilmDirectory(basename($lSource));
	
	foreach my $lProcessor (@cProcessors)
	{
		my $lTarget = &$lProcessor($lData);
		#Make the target directory
		print "The target directory is: $lTarget\n";
		#Link all files from within the source directory to the target directory...
		
		makeLink($lSource, $lTarget);
	}
}

sub makeLink
{
	my ($lSource, $lTarget) = @_;

  if (! -d $lSource)
  {
    die "Missing source directory";
  }
  
  if (! -d $lTarget)
  {
    mkdir $lTarget or die "Couldn't make directory $lTarget";
  }

    opendir(DIR, $lSource) or die "can't opendir $lSource: $!";
    while (defined($file = readdir(DIR))) 
    {
      next if $file =~ /jpg$/;
      next if $file =~ /html$/;
      next if $file =~ /^.$/;
      next if $file =~ /^..$/;
      
      link("$lSource/$file", "$lTarget/$file") or print "Couldn't create link from $lSource/$file to $lTarget/$file\n";
      #print "Creating link from $lSource/$file to $lTarget/$file\n";
    }

    closedir(DIR);
}

sub rating
{
	my %lData = %{$_[0]};
	my $cRatingDir = "FilmsByRating";
	
	my $lName = sprintf("%s/%s/%.1f - %.100s (%u) - %.3u mins", $cTargetBase, $cRatingDir, $lData{rating}, $lData{title}, $lData{year}, $lData{duration});
    return $lName;
}

sub showHelp
{
print "GetOptions ('test' => \$gTest,
			'all|a' => \$gAll, 
			'help|h' => \$gHelp,
			'single|s=s' => \$gSingle);\n";
}
#Help
#Command line:
# Take either a single film directory or a directory of film directories
# Allow a "just print what you would do " option
# Specify all processors (default) or just one.
