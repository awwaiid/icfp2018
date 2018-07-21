#!/usr/bin/env perl

use v5.26;

use Data::Dumper;
use Getopt::Long;
use JSON::XS;
use File::Slurp;

my ($file,
    $outfile,
);

GetOptions("file=s", => \$file,
           "out=s", => \$outfile,
);

open my $fh, "<:raw", $file or die "Couldnt open file $file: $!";
my $res_bytes = read $fh, my $bytes, 1;
my ($resolution) = unpack "B8", $bytes;
$resolution = oct("0b$resolution");

#while( my $bytes_read = read $fh, my $bytes, 1 ) {
#  my ($coords) = unpack "B8", $bytes;
#  print "bin: $coords ";
#  $coords = oct("0b$coords");
#  print "dec: $coords ";
#  my $vec_coords = decimal_to_baseR($coords, $resolution);
#  say "vec: " . Dumper($vec_coords);
#}

my $r = $resolution - 1;
my $model = [[[]]];
my @buffer = ();
for my $x (0..$r) {
  for my $y (0..$r) {
    for my $z (0..$r) {
      if( ! scalar @buffer ) {
        my $bytes_read = read $fh, my $bytes, 1;
        my ($b) = unpack "B8", $bytes;
        @buffer = reverse split(//,$b)
      }
      $model->[$x][$y][$z] = shift @buffer;
    }
  }
}


for my $y (0..$r) {
  for my $z (0..$r) {
    for my $x (0..$r) {
      print $model->[$x][$y][$z] . " ";
    }
    print "\n";
  }
  print "\n\n";
}
