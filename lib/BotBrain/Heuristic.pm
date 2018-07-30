
use Moops;
  use Simulator;

class BotBrain::Heuristic {
use Data::Dumper;

  use List::Util qw{ any min };

  has bot => (is => 'rw');
  has resolution => (is => 'rw');
  has source_model => (is => 'rw');
  has target_model => (is => 'rw');

  method get_commands {
    my @cmd_array = ();

    #my $res = $sim->send( $bot->flip() );
    #say Dumper($res);

    my $sim = Simulator->new( resolution => $self->resolution );
    my $is_grounded = 1;

    my $forwardz = 0;
    my $print_dir = 1;
    my $forwardx = 0;
    my $r = $self->resolution - 1;

    my @x_indices;
    my $x_jump = 2;
    while ( $x_jump < $r ) {
      push @x_indices, $x_jump;
      $x_jump += 3;
    }
    push @x_indices, $r;

    for my $y (0..$r) {
      push @cmd_array, $self->bot->flip() if $y == 1;

      for my $x (@x_indices) {
        $forwardx = !$forwardx if $x == 2;
        my $new_x = $forwardx ? $x: $r - $x;

        for my $z (0..$r) {
          if( $z == 0 ) {
            $forwardz = !$forwardz;
            $print_dir = -1 * $print_dir;
#            last unless any { $_ } @{$self->target_model->[$new_x][$y]}[0..$r];
          }
          my $new_z = $forwardz ? $z : $r - $z;
          next unless $self->target_model->[$new_x][$y][$new_z + $print_dir];

          my @bot_cmds;
          push @bot_cmds, $self->bot->move_to([$new_x , $y, $new_z]);
          push @bot_cmds, $self->bot->fill([$new_x - 1,$y,$new_z + $print_dir]) if $self->target_model->[$new_x - 1][$y][$new_z + $print_dir];
          push @bot_cmds, $self->bot->fill([$new_x,    $y,$new_z + $print_dir]) if $self->target_model->[$new_x    ][$y][$new_z + $print_dir];
          push @bot_cmds, $self->bot->fill([$new_x + 1,$y,$new_z + $print_dir]) if $self->target_model->[$new_x + 1][$y][$new_z + $print_dir];

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

    # moving to the origin so lets go up one position first to make sure we're clear of obstacles
    my $position = [@{ $self->bot->position }];
    $position->[1] = $position->[1] + 1;
    push @cmd_array, $self->bot->move_to($position);

    push @cmd_array, $self->bot->move_to([0,0,0]);
    push @cmd_array, $self->bot->flip();
    push @cmd_array, $self->bot->halt();

    return @cmd_array;
  }
}
