#!/usr/bin/env perl

use v5.26;

use Data::Dumper;
use Getopt::Long;
use JSON::XS;

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

my $json = encode_json({ "resolution" => $resolution, "model" => $model});

my $fh = *STDOUT;
if( $outfile ) {
  open $fh, '>', $outfile or warn "Couldn't open file $outfile: $! - printing to stdout instead";
}

print $fh $json;

# print_matrix();

sub print_matrix {
  say "Columns = z Rows = x";
  for my $y (0..$r) {
    say "Y: $y";
    for my $z (reverse 0..$r) {
      for my $x (0..$r) {
        print $model->[$x][$y][$z] . " ";
      }
      print "\n";
    }
    print "\n\n";
  }
}


=head1 SYNOPSIS

  model_to_json.pl -f <infile.mdl>
  model_to_json.pl -f <infile.mdl> -o <output.json>

=head1 DESCRIPTION

  The model_to_json script will, given an mdl file
  pull the first byte off and convert to decimal
  to find the resolution then use that to figure
  out which cells of the model matrix are filled
  or not filled.  The value of the filled cells
  are 1 and the unfilled cells are 0. A json
  structure is returned with two keys, 'resolution'
  which holds resolution of the model and 'model'
  which is an R x R x R matrix of 0's and 1's.
