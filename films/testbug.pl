use IMDB::Film;
use Data::Dumper;
my $lFilm = new IMDB::Film(crit => "83658");
#my $lFilm = new IMDB::Film(crit => "0181875");
	
print "got " . $lFilm->title() . "\n";
print Dumper($lFilm->rating());
print "Scale: " . scalar($lFilm->rating());
