#!/usr/bin/perl

our %moviesPresent = (); #key: actor.  Value: movies that the actor appears in
#our %actorsPresent = (); #inverse hash of ^^^

#our %connectedActors = (); #search this in the search algorithm
our @visitedActors = ();
our @pathActors = (); # will be an array of arrays; keep track of all the paths found from KB

while(@ARGV) {
  my $filename = shift(@ARGV);
  open($FH, "zcat $filename |")
    or die "cannot open $filename";
  my $current_actor = "";
  while(<$FH>) {
    if ($_ =~ /^([^\t]+)\t.*/) {  # capture the actor's name (don't come here unless the line starts with the actor's name)
      $current_actor = $1; 
    }
    if ($_ =~ /^[^\t]*\t* ( .*?[)] )/x) {
        $current_movie = $1;
    }
    if ($current_movie =~ /^[^"].*$/ && $_ =~ /^(. (?!\(TV\)) (?!\(V\)) (?!\(VG\)) )*$/x)  {	#regex line 1: consume leading tabs and capture movie & date				        
        #regex line 2: assert there are no instances of "(TV)", "(V)", or "(VG)"
	my @array;        
	if (exists $moviesPresent{$current_actor}) {
    	  @array = @{$moviesPresent{$current_actor}};	
	}
        else {
	  @array = ();
	}
	push @array, $current_movie;
	$moviesPresent{$current_actor} = \@array; 
    }
  } 
}
=pod
foreach $actor (keys %moviesPresent) {
  print "Actor: $actor\n";
}
=cut
findPaths();

=pod
foreach $actor (keys %connectedActors) {
  print "Actor: $actor\n";
}
=cut

print "Actor/Actress? ";
while(<>) {
  $potentials = findMatches(chomp($_));
#  print "@{$potentials} results found\n";
  if (@{$potentials} == 1) {
    $path = search(${$potentials->[0]});
    if ($path) {
      $actOne = pop @{$path};
      print "$actOne\n";
      while (@{$path} > 0) {
        $actTwo = pop @{$path};
        $commonM = commonMovie($actOne, $actTwo);
        print "\t $commonM\n";
        print "$actTwo\n";
        $actOne = $actTwo;
      } 
    }
    else {
      print "Whoops, looks like there's no path from ${$potentials->[0]} to Kevin Bacon :(\n";
    }
  }
  else {
    foreach $actor (@{$potentials}) {
      print "$actor\n";
    }
  }
  print "Actor/Actress? ";
}

# get a common movie between the two given actors.
sub commonMovie {
#  print "Finding common movie\n";
  my $firstAct = shift;
  my $secondAct = shift;
  my %hash = map {$_ => 1} @{$moviesPresent{$secondAct}}; 
  foreach $movie (@{$moviesPresent{$firstAct}}) {
    if (exists $hash{$movie}) {
      return $movie;
    }
  }
  return "";
}

# print all relevant actors, based on the "keywords" typed in by the user
# if a specific actor is specified, call search
sub findMatches {
  my @results = ();
  foreach $actor (keys %moviesPresent) { # don't forget to omit the ,
    my $flag = 1;
    $modActor = $actor;
    $modActor =~ s/,//g;
    foreach $keyword (@_) {
      if ($modActor !~ /\b $keyword \b/xi || $actor !~ /\b $keyword \b/xi) {
        $flag = 0;
        last; # should not get to the push statement below if keywords don't match
      }
    }
    if ($flag) {
      push @results, $actor; # we still want the comma in there 
    }
  }
  return \@results;
}

# borrows from Dijkstra's algorithm to find all of the shortest paths from KB
sub findPaths {
  my @actQueue = ["Bacon, Kevin"];
  my @pathQueue = [["Bacon, Kevin"]]; # these two lists should be synced together, that way we get the correct sub-path for each actor
  while (@actQueue && @pathQueue) {
    my $currentAct = shift @actQueue;
    my $currentPath = shift @pathQueue;
    my $neighbors = findUnvisitedNeighbors($currentAct);
    foreach $neighbor (@{$neighbors}) {
        $copyPath = $currentPath;
        push @{$copyPath}, $neighbor;
        push @pathActors, $copyPath;
        push @actQueue, $neighbor;
        push @pathQueue, $copyPath;
        push @visitedActors, $neighbor;
    }
  }
}
 
sub findUnvisitedNeighbors {
  $main = shift;
  @results = ();
  %visited = map {$_ => 1} @visitedActors;
  @others = grep {$_ ne $main && !(exists $visited{$_})} keys %moviesPresent;
  foreach $other (@others) {
    if (commonMovie($main, $other)) {
      push @results, $other;
    }
  }
  return \@results;  
}


sub search {
  foreach $path (@pathActors) { 
    if (${$path->[-1]} eq shift) {
      return $path;
    }
  }
  return "";
}




















































