#!/usr/bin/perl
use strict;
my @lala = split(//, join(/ /, @ARGV));

my $i=0;
for my $zap(@lala) {
  $i++;
  print "\033[38;5;$i".'m ', $zap, " \033[0m";
}
