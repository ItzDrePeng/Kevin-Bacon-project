#!/usr/bin/perl

our %moviesPresent = (); #key: actor.  Value: movies that the actor appears in
our %connectedActors = (); #search this in the search algorithm
our @pathActors = (); # will be an array of arrays; keep track of all the paths found from KB

while(@ARGV) {
  my $filename = shift(@ARGV);
  open($FH, "zcat $filename |")
    or die "cannot open $filename";
  my $current_actor = "";
  while(<$FH>) {
    my @movies = ();
    if ($_ =~ /^([^\t]+)\t.*/) {  # capture the actor's name (don't come here unless the line starts with the actor's name)
      $current_actor = $1; 
    }
    if ($_ =~ /^[^\t]*\t* ( .*?[)] )/x) {
        $current_movie = $1;
    }
    if ($current_movie =~ /^[^"].*$/ && $_ =~ /^( ?!\(TV\)) (?!\(V\)) (?!\(VG\)) .)*$/x)  {	#regex line 1: consume leading tabs and capture movie & date				        
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
  $lastRef = \@movies;
  $moviesPresent{$current_actor} = $lastRef; 
}

buildGraph;

while(<>) {
  print "Actor/Actress? ";
  $potentials = printNames(chomp($_));
  if (@{$potentials} == 1) {
    $path = search(${$potentials->[0]});
    if ($path) {
      $actOne = shift @{$path};
      print "$actOne\n";
      while (@{$path} > 0) {
        $actTwo = shift @{$path};
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
}

# if two actors have at least one movie in common, put an edge between them (by adding to %connectedActors), then search another distinct pair (next) to see if they share a common movie
# builds %connectedActors
# helper: commonMovie
sub buildGraph {
  my @actors = keys %moviesPresent;
  my $offset = 1;
  for ($i = 0; $i < $#actors; $i++) {
    my $firstAct = $actors[$i];
    my @connected = ();
    my @others = splice(@actors, $offset);
    foreach $secondAct (@others) {
      if (commonMovie($firstAct, $secondAct) {
        push @connect, $secondAct;
      }   	
    }
    $connectedActors{$firstAct} = \@connected;
    $offset++;
  } 
}

# get a common movie between the two given actors.
sub commonMovie {
  my $firstAct = shift;
  my $secondAct = shift;
  my %hash = map {$_ -> 1} @{$moviesPresent{$secondAct}}; 
  foreach $movie (@{$moviesPresent{$firstAct}}) {
    if exists $hash{$movie} {
      return $movie;
    }
  }
  return "";
}

# print all relevant actors, based on the "keywords" typed in by the user
# if a specific actor is specified, call search
sub printNames {
}

# borrows from Dijkstra's algorithm to find all of the shortest paths from KB
sub findPaths {
  my @actQueue = ["Bacon, Kevin"];
  my @pathQueue = [["Bacon, Kevin"]]; # these two lists should be synced together, that way we get the correct sub-path for each actor
  while (@actQueue && @pathQueue) {
    my $currentAct = shift @actQueue;
    my $currentPath = shift @pathQueue;
    foreach $neighbor (@{$connectActors{$currentAct}}) {
      if (!($neighbor =~ /#$/) { # have we explored this actor yet?
        $copyPath = $currentPath;
        push @{$copyPath}, $neighbor;
        push @pathActors, $copyPath;
        push @actQueue, $neighbor;
        push @pathQueue, $copyPath;
        markVisited($neighbor); # must mark every instance of $neighbor within the values of %connectedActors
      }
    }
  }
}
 
sub markVisited {
  my $target = shift;
  my $i = 0;
  foreach $key (%connectedActors) {
    my %hash = map ($_ => $i++) @{$connectedActors{$key}}; # ehh, trying to make it so that each value is its position in the list...
    if exists $hash{$target} {
      splice(@{$connectedActors{$key}, $hash{$target}, 1, $target + "#"); 
    }
  }
}

sub search {
  foreach $path (@pathActors) { 
    if (${$path->[-1]} eq shift)
      return $path;
  }
  return "";
}

















































}


