#!/usr/bin/env perl

use v5.26;

use Data::Dumper;
use Getopt::Long;

my ($file,
    $out,
);

GetOptions("file=s", => \$file,
           "out=s", => \$out,
);

my %dispatch = (
  'halt' => sub { '11111111' },
  '11111111' => sub { 'halt' },

  'wait' => sub { '11111110' },
  '11111110' => sub { 'wait' },

  'flip' => sub { '11111101' },
  '11111101' => sub { 'flip' },

  'smove' => sub { '0100' },
  '0100' => sub { "smove " . join(',', @_) },

  'lmove' => sub { '1100' },
  '1100' => sub { "lmove " . join(',', @_) },

  'fusionp' => sub { '111' },
  '111' => sub { "fusionp " . join(',', @_) },

  'fusions' => sub { '110' },
  '110' => sub { "fusions " . join(',', @_) },

  'fission' => sub { '101' },
  '101' => sub { "fission " . join(',', @_) },

  'fill' => sub { '011' },
  '011' => sub { "fill " . join(',', @_) },
);

open my $fh, "<:raw", $file or die "Couldnt open file $file: $!";

my $cmd_cnt = 1;
while (my $cmd = read_and_parse_next( $fh ) ) {

  print  "$cmd_cnt: $cmd => ";
  $cmd_cnt++;

  if( $dispatch{ $cmd } ) {
    say $dispatch{ $cmd }();
  }
  elsif( $cmd =~ /(0100|1100)$/ ) {
    if( $dispatch{ substr($cmd, 4, 4 )} ) {
      my $next_coords = read_and_parse_next( $fh );
      print "next coords: $next_coords ";
      say $dispatch{ substr($cmd, 4, 4 )}( substr($cmd, 0, 4), substr($next_coords, 3, 5) );
    }
    else {
      say "blah Unknown command $cmd";
    }
  }
  elsif( $cmd =~ /(111|110|101|011)$/ ) {
    if( $dispatch{ substr($cmd, 5, 3) } ) {
      my $next_coords = undef;
      $next_coords = read_and_parse_next( $fh ) if $cmd =~ /101$/;
      say $dispatch{ substr($cmd, 5, 3) }( substr($cmd, 0, 5), substr($next_coords, 0, 5) );
    }
    else {
      say "foo Unknown command $cmd";
    }
  }
  else {
    say "Unknown command $cmd"
  }
}


sub read_and_parse_next {
  my $fh = shift;

  my $bytes_read = read $fh, my $bytes, 1;
  my ($cmd) = unpack "B8", $bytes;
  return $cmd;
}
