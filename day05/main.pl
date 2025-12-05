my @intervals = ();

while (my $line = <>) {
  if ($line eq "\n") {
    last;
  }
  chomp $line;
  my ($start, $end) = split /-/, $line;
  push @intervals, [$start, $end];
}

# Do the obvious containment checks.
my $found = 0;
while (my $n = <>) {
  chomp $n;
  for my $interval (@intervals) {
    if ($n >= $interval->[0] && $n <= $interval->[1]) {
      $found += 1;
      last;
    }
  }
}
print "Part 1: $found\n";

# List of start/end events.
my @events = ();
for my $interval (@intervals) {
  push @events, [$interval->[0], 'start'];
  push @events, [$interval->[1] + 1, 'end'];
}
@events = sort { $a->[0] <=> $b->[0] } @events;

# Go through and handle 0<=>1 transitions.
my $depth = 0;
my $start = -1;
my $total = 0;
for my $event (@events) {
  my ($pos, $type) = @$event;
  if ($type eq 'start') {
    if ($depth == 0 && $start == -1) {
      $start = $pos;
    }
    $depth += 1;
  } else {
    $depth -= 1;
    if ($depth == 0) {
      $total += $pos - $start;
      $start = -1;
    }
  }
}
print "Part 2: $total\n";
