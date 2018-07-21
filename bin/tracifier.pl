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

my %dispatch = (
  'halt' => sub { '11111111' },
  '11111111' => sub { {'cmd' => 'halt'} },

  'wait' => sub { '11111110' },
  '11111110' => sub { {'cmd' => 'wait'} },

  'flip' => sub { '11111101' },
  '11111101' => sub { {'cmd' => 'flip'} },

  'smove' => sub { '0100' },
  '0100' => sub { {'cmd' => "smove ", 'lld' => get_linear_coords(@_) } },

  'lmove' => sub { '1100' },
  '1100' => sub { my ($sld1, $sld2) = get_linear_coords(@_);  {'cmd' =>  "lmove ", "sld1" => $sld1, "sld2" => $sld2 } },

  'fusionp' => sub { '111' },
  '111' => sub { "fusionp " . join(',', @_) },

  'fusions' => sub { '110' },
  '110' => sub { "fusions " . join(',', @_) },

  'fission' => sub { '101' },
  '101' => sub { "fission " . join(',', @_) },

  'fill' => sub { '011' },
  '011' => sub { { 'cmd' => "fill ", "nd" => get_near_coord_diff(@_) } },
);

my $out;
if( $file =~ /nbt$/ ) {
  $out = nbt_to_json($file);
}
elsif( $file =~ /json$/ ) {
  $out = json_to_nbt($file)
}
else {
  say "Whatta ya doin'! Either .json file or .nbt file! Bad monkey!";
  exit;
}

my $fh = *STDOUT;
if( $outfile ) {
  open $fh, '>', $outfile or say "Couldn't open file $outfile: $! - printing to stdout instead";
}

print $fh $out;

exit;


sub nbt_to_json {
  my $file = shift;
  open my $fh, "<:raw", $file or die "Couldnt open file $file: $!";

  my $cmd_cnt = 1;
  my @json = ();
  while (my $cmd = read_and_parse_next( $fh ) ) {

#    print  "$cmd_cnt: $cmd => ";
    $cmd_cnt++;

    if( $dispatch{ $cmd } ) {
      push @json, $dispatch{ $cmd }();
    }
    elsif( $cmd =~ /(0100|1100)$/ ) {
      if( $dispatch{ substr($cmd, 4, 4 )} ) {
        my $next_coords = read_and_parse_next( $fh );
#        print "next coords: $next_coords ";
        push @json, $dispatch{ substr($cmd, 4, 4 )}( substr($cmd, 0, 4), $next_coords );
      }
      else {
        warn "ERROR: Unknown command $cmd";
      }
    }
    elsif( $cmd =~ /(111|110|101|011)$/ ) {
      if( $dispatch{ substr($cmd, 5, 3) } ) {
        my $next_coords = undef;
        $next_coords = read_and_parse_next( $fh ) if $cmd =~ /101$/;
        push @json, $dispatch{ substr($cmd, 5, 3) }( substr($cmd, 0, 5), $next_coords );
      }
      else {
        warn "ERROR: Unknown command $cmd";
      }
    }
    else {
      warn "ERROR: Unknown command $cmd"
    }
  }

#say Dumper(\@json);
  encode_json \@json;
}

sub json_to_nbt {
}

sub read_and_parse_next {
  my $fh = shift;

  my $bytes_read = read $fh, my $bytes, 1;
  my ($cmd) = unpack "B8", $bytes;
  return $cmd;
}

sub get_linear_coords {
  my ($a_coords,
      $i_coords,
  ) = @_;

  my ($a2, $a1) = map { oct("0b$_") - 1} $a_coords =~ /(..)(..)/;

  my $vec1 = my $vec2 = [0,0,0];
  # we're working with smove so only build and return one vector
  if( $a2 == -1) {
    $vec2 = undef;
    $vec1->[ $a1 ] = oct("0b$i_coords") - 15;
  }
  # lmove so build and return 2 vectors
  else {
    my ($i2, $i1) = $i_coords =~ /(.{4})(.{4})/;
    $vec1->[ $a1 ] = oct("0b$i1") - 5;
    $vec2->[ $a2 ] = oct("0b$i2") - 5;
  }

  return $vec2 ?  ($vec1, $vec2) : $vec1;
}

sub get_near_coord_diff {
  my $nd = shift;

  my $dec = oct("0b$nd");
  return decimal_to_base3( $dec );
}

sub decimal_to_base3 {
  my $dec = shift;

  my $digit1 = $dec % 3 - 1;
  $dec = int($dec / 3);
  my $digit2 = $dec % 3 - 1;
  my $digit3 = int($dec / 3) - 1;

  return [$digit3, $digit2, $digit1];
}


=head1 SYNOPSIS

  tracifier.pl -f <infile.nbt>
  tracifier.pl -f <infile.nbt> -o <output.json>
  tracifier.pl -f <infile.json>
  tracifier.pl -f <infile.json> -o <output.nbt>

=head1 DESCRIPTION

  The tracifier script can be given a binary nbt file of trace commands or the
  json file of the commands.  Depending on which file is given, the output
  will the other time of file, e.g. given an nbt file, the output will be
  json.  If the output is sent to stdout by default, but using the output
  param -o a filename can be given and the output will be written to that
  file.

  The structure of the json is as follows:

  [
    {'cmd':<command>},
    {
      'cmd':<command>,
      <param1 name>:<param1>
    },
    {
      'cmd':<command>,
      <param1 name>:<param1>,
      <param2 name>:<param2>
    },
    ...
 ]

 Example:

 [
   {'cmd':'flip'},
   {
     'cmd':'smove',
     'lld':[12,0,0]
   },
   {
     'cmd':'smove',
     'lld':[0,10,0]
   },
   {
     'cmd':'fill',
     'nd':[0,-1,0]
   },
   {
     'cmd':'smove',
     'lld':[0,-10,0]
   },
   {
     'cmd':'smove',
     'lld':[-12,0,0]
   },
   {'cmd':'flip'},
   {'cmd':'halt'}
 ]

=cut
