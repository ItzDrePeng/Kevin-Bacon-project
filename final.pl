#!/usr/bin/perl

our %moviesPresent = (); #key: actor.  Value: movies that the actor appears in
#our %visitedActors = ("Bacon, Kevin" => 1);
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
print "b\n";
findPaths();
$blah = $#pathActors + 1;
print "$blah actors are connected to KB\n";

print "Actor/Actress? ";
while(<>) {
  chomp;
  @keyWords = /([^\s]+)/ig; # whitespace is the delimiter
  $potentials = findMatches(\@keyWords);
  @potentList = @{$potentials};
  $var = $#potentList + 1;
  print "$var results found\n";
  if (@potentList == 1) {
    $path = search($potentList[0]);
    if ($path) {
      $actOne = pop @{$path};
      print "$actOne\n";
      while (@{$path} > 0) {
        $actTwo = pop @{$path};
        $commonM = commonMovie($actOne, $actTwo);
        print "\t$commonM\n";
        print "$actTwo\n";
        $actOne = $actTwo;
      } 
    }
    else {
      print "Whoops, looks like there's no path from $potentList[0] to Kevin Bacon :(\n";
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
#  my $hash = shift;
#  my %tempTable = %{$hash};
  my %hash2 = map {$_ => 1} @{$moviesPresent{$secondAct}}; 
  foreach $movie (@{$moviesPresent{$firstAct}}) {
    if (exists $hash2{$movie}) {
      return $movie;
    }
  }
  return "";
}

# print all relevant actors, based on the "keywords" typed in by the user
# if a specific actor is specified, call search
sub findMatches {
  my $ref = shift;
  my @keyWords = @{$ref};
  my @results = ();
  foreach $actor (keys %moviesPresent) { # don't forget to omit the ,
    my $flag = 1;
    $modActor = $actor;
    $modActor =~ s/,//g;
    foreach $keyword (@keyWords) {
      if ($modActor !~ /\b $keyword \b/xi || $actor !~ /\b $keyword \b/xi) {
        $flag = 0;
        last;
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
#  my %mpCopy = %moviesPresent;
  my @actQueue = ("Bacon, Kevin");
 # print "$actQueue[0]\n";
  my @pathQueue = (("Bacon, Kevin")); # these two lists should be synced together, that way we get the correct sub-path for each actor
  while (@actQueue) {
#    print "a\n";
    my $currentAct = shift @actQueue;
    my $currentPath = shift @pathQueue;
    my $neighbors = findUnvisitedNeighbors($currentAct);
    foreach $neighbor (@{$neighbors}) {
        $copyPath = $currentPath;
        push @{$copyPath}, $neighbor;
        push @pathActors, $copyPath;
        push @actQueue, $neighbor;
        push @pathQueue, $copyPath;
        $visitedActors{$neighbor} = 1;
    }
 #   delete($mpCopy{$currentAct});
  }
}
 
sub findUnvisitedNeighbors {
  $main = shift;
 # $hash = shift;
  @results = grep {!(exists $visitedActors{$_}) && commonMovie($main, $_)} keys %moviesPresent;
 # print "$#others neighbors of $main\n";
  return \@results;  
}


sub search {
  $target = shift;
  foreach $pathRef (@pathActors) {
    @path = @{$pathRef};  
    if ($path[-1] eq $target) {
      return $pathRef;
    }
  }
  return "";
}
