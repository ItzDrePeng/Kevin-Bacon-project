#!/usr/bin/perl

our %moviesPresent = (); 
our %connectedActors = (); #search this in the search algorithm
our @pathActors = (); # will be an array of arrays; keep track of all the paths found

# builds %moviesPresent
sub readData {
}

# if two actors have at least one movie in common, put an edge between them (by adding to %connectedActors), then search another distinct pair (next) to see if they share a common movie
# builds %connectedActors
# helper: commonMovie
sub buildGraph {
}

# get a common movie between the two given actors.
sub commonMovie {
}

# print all relevant actors, based on the "keywords" typed in by the user
sub printNames {
}

# recursive boolean routine (will iterate though a list in each call, ugh...)
# keep track of the path length via global array as you go. Pop the array if backtracking (list should end up empty if there's no path to KB)
# mark each explored actor via concatenating '#' at the end of his name (check for this in the beginning of the routine)
sub search {
}

















































}


