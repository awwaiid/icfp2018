
use Moops;
  use Simulator;

class BotBrain::Heuristic {

  use List::Util qw{ any };

  has bot => (is => 'rw');
  has resolution => (is => 'rw');
  has model => (is => 'rw');

  method get_commands {
    my @cmd_array = ();

    #my $res = $sim->send( $bot->flip() );
    #say Dumper($res);

    my $sim = Simulator->new( resolution => $self->resolution );
    my $is_grounded = 1;

    my $forwardz = 0;
    my $forwardx = 0;
    my $r = $self->resolution - 1;
    for my $y (0..$r) {
      # push @cmd_array, $self->bot->flip() if $y == 1;

      for my $x (0..$r) {
        $forwardx = !$forwardx if $x == 0;
        my $new_x = $forwardx ? $x : $r - $x;

        for my $z (0..$r) {
          if( $z == 0 ) {
            $forwardz = !$forwardz;
#            last unless any { $_ } @{$self->model->[$new_x][$y]}[0..$r];
          }
          my $new_z = $forwardz ? $z : $r - $z;
          next unless $self->model->[$new_x][$y][$new_z];

          my @bot_cmds;
          push @bot_cmds, $self->bot->move_to([$new_x, $y+1, $new_z]);
          push @bot_cmds, $self->bot->fill([$new_x,$y,$new_z]) if $self->model->[$new_x][$y][$new_z];

          for my $cmd (@bot_cmds) {
            $sim->send($cmd);
          }

          my $new_grounded = $sim->is_grounded;
          if($is_grounded && !$new_grounded) {
            # Go from grounded to ungrounded ... FLIP before
            unshift @bot_cmds, $self->bot->flip();
          } elsif(!$is_grounded && $new_grounded) {
            # Go from ungrounded to grounded ... FLIP after
            push @bot_cmds, $self->bot->flip();
          }
          $is_grounded = $new_grounded;

          push @cmd_array, @bot_cmds;

          #say Dumper($self->bot->position);
        }
      }
    }

    push @cmd_array, $self->bot->move_to([0,0,0]);
    # push @cmd_array, $self->bot->flip();
    push @cmd_array, $self->bot->halt();

    return @cmd_array;
  }
}
