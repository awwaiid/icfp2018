#!/usr/bin/env perl

use v5.26;

use Data::Dumper;
use Getopt::Long;
use JSON::XS;

my ($source,
    $target,
    $outfile,
);

GetOptions("source=s", => \$source,
           "target=s", => \$target,
           "out=s", => \$outfile,
);

my $resolution = undef;
my ($src_fh, $tgt_fh);

if($source) {
  open $src_fh, "<:raw", $source or die "Couldnt open source $source: $!";
  my $res_bytes = read $src_fh, my $bytes, 1;
  ($resolution) = unpack "B8", $bytes;
say "raw res: $resolution";
  $resolution = oct("0b$resolution");
}

if($target) {
  open $tgt_fh, "<:raw", $target or die "Couldnt open target $target: $!";
  my $res_bytes = read $tgt_fh, my $bytes, 1;
  ($resolution) = unpack "B8", $bytes;
  $resolution = oct("0b$resolution");
}

if( !$source && !$target) {
  warn "You haven't entered in a file at all. Exiting.";
  exit;
}

#while( my $bytes_read = read $fh, my $bytes, 1 ) {
#  my ($coords) = unpack "B8", $bytes;
#  print "bin: $coords ";
#  $coords = oct("0b$coords");
#  print "dec: $coords ";
#  my $vec_coords = decimal_to_baseR($coords, $resolution);
#  say "vec: " . Dumper($vec_coords);
#}

my $json_hash = {
  "resolution" => $resolution,
  "source_model" => build_model_matrix($src_fh),
  "target_model" => build_model_matrix($tgt_fh),
};

my $json = encode_json($json_hash);

my $fh = *STDOUT;
if( $outfile ) {
  open $fh, '>', $outfile or warn "Couldn't open file $outfile: $! - printing to stdout instead";
}

print $fh $json;

#print_matrix($json_hash->{source_model});
#print_matrix($json_hash->{target_model});



##### Subs #####


sub build_model_matrix {
  my $fh = shift;
  return undef unless $fh;

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

  return $model;
}

sub print_matrix {
  my $model = shift;
  my $r = $resolution -1;
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

  model_to_json.pl -s <source_file.mdl> -t <target_file.mdl>
  model_to_json.pl -t <target_file.mdl>
  model_to_json.pl -s <source_file.mdl>
  model_to_json.pl -s <source_file.mdl> -t <target_file.mdl> -o <output.json>
  model_to_json.pl -t <target_file.mdl> -o <output.json>
  model_to_json.pl -s <source_file.mdl> -o <output.json>

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
