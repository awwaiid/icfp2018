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

my $models = decode_json( <STDIN> );
my $res = $models->{resolution};
my $bot = Bot->new(bid => 1, position => [0,0,0]);

my $brain_class = "BotBrain::$brain_name";
eval("use $brain_class");
warn $@ if $@;

my $botbrain = $brain_class->new(
  bot => $bot,
  resolution => $res,
  source_model => $models->{source_model},
  target_model => $models->{target_model},
);

my $last_cmd = {};
while ($last_cmd->{cmd} ne 'halt') {
  my (@cmds) = $botbrain->get_commands;
  for my $cmd (@cmds) {
    say encode_json( $cmd );
  }
  $last_cmd = $cmds[-1];
}

