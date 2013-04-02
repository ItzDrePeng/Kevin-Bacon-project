#!/usr/bin/perl


%actors_to_movies;
%actors_to_actors;

while(@ARGV) {
  my $filename = shift(@ARGV);
	open(FH, "<", "zcat $filename")
		or die "cannot open $filename";
	my $current_actor = "";
	while(<FH>) {
		if ($_ =~ /([^\t]*)\t.*/) {
			$current_actor = $1;
		}

		if ($_ =~ /\t* ( .*[)] )
			((      ?!\(TV\))       (?!\(V\))       (?!\(VG\))      .)*$/x) {	#regex line 1: consume leading tabs and capture movie & date
												#regex line 2: assert there are no instances of "(TV)", "(V)", or "(VG)"
			
			#Movie name is in $1, stuff into the array in %actors_to_movies

		}
	}

}
