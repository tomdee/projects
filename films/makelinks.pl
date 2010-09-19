use File::Basename;
use lib::routines;

my @cProcessors = (
					\&rating,
					);

my $cTargetBase = "/mnt/disk1/share/Video";
#Process inputs
#either loop over all directories or just process a single one.
#done

if (scalar(@ARGV) == 1)
{
	processDirectory($ARGV[0]);
}
else
{
	print "bad\n";
	exit(1);
}

sub processDirectory
{
	my ($lSource) = @_;
	$lData = lib::routines::parseFilmDirectory(basename($lSource));
	
	foreach my $lProcessor (@cProcessors)
	{
		my $lTarget = &$lProcessor($lData);
		#Make the target directory
		print "The target directory is: $lTarget";
		#Link all files from within the source directory to the target directory...
		
		makeLink($lSource, $lTarget);
	}
}

sub makeLink()
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
      next if $file =~ /html/;
      
      #link("$lSource/$file", "$lTarget/$file") or die "Couldn't create link from $lSource/$file to $lTarget/$file";
      print "Creating link from $lSource/$file to $lTarget/$file";
    }

    closedir(DIR);
}

sub rating()
{
	my %lData = %{$_[0]};
	my $cRatingDir = "FilmsByRating";
	
	my $lName = sprintf("%s/%s/%.1f - %.100s (%u) - %.3u mins", $cTargetBase, $cRatingDir, $lData{rating}, $lData{title}, $lData{year}, $lData{duration});
    return $lName;
}


#Help
#Command line:
# Take either a single film directory or a directory of film directories
# Allow a "just print what you would do " option
# Specify all processors (default) or just one.