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

	# Check the source directory exists - exit if not
	# Check if the target directory exists - create it if not.
	# List all the files in the source directory
	# Foreach file in source (excluding \d*.jpg and \d*.html)
	#   create link from source to dest
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