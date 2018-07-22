#!/usr/bin/env perl

use v5.26;

use lib 'lib';
use Data::Dumper;
use JSON::XS;
use File::Slurp;
use Bot;
use Getopt::Long;

my $brain_name;
GetOptions("brain=s", => \$brain_name);

my $model = decode_json( <STDIN> );
my $res = $model->{resolution};
my $matrix = $model->{model};
my $bot = Bot->new(bid => 1, position => [0,0,0]);

my $brain_class = "BotBrain::$brain_name";
eval "use $brain_class";

my $botbrain = $brain_class->new(
  bot => $bot,
  resolution => $res,
  model => $model->{model}
);

my $cmd = {};
while ($cmd->{cmd} ne 'halt') {
  $cmd = $botbrain->get_command;
  say encode_json( $cmd );
}

