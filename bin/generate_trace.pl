#!/usr/bin/env perl

use v5.26;

use lib 'lib';
use Data::Dumper;
use JSON::XS;
use File::Slurp;
use Bot;

my $model = decode_json( <> );
my $res = $model->{resolution};
my $matrix = $model->{model};
my $bot = Bot->new(bid => 1, position => [0,0,0]);
my @cmd_array = ();

push @cmd_array, $bot->flip();

my $forwardz = 0;
my $forwardx = 0;
my $r = $res - 1;
for my $y (0..$r) {
  for my $x (0..$r) {
    $forwardx = !$forwardx if $x == 0;
    my $new_x = $forwardx ? $x : $r - $x;

    for my $z (0..$r) {
      $forwardz = !$forwardz if $z == 0;
      my $new_z = $forwardz ? $z : $r - $z;

      push @cmd_array, $bot->fill([$new_x,$y,$new_z]) if $matrix->[$new_x][$y][$new_z];

      push @cmd_array, $bot->move_to([$new_x, $y+1, $new_z]);
      #say Dumper($bot->position);
    }
  }
}

push @cmd_array, $bot->move_to([0,0,0]);
push @cmd_array, $bot->flip();
push @cmd_array, $bot->halt();

#say Dumper(\@cmd_array);
my $json_cmds = encode_json( \@cmd_array );

print $json_cmds;
