
use Moops;

class BotBrain::Heuristic {

  use List::Util qw{ any };

  has bot => (is => 'rw');
  has resolution => (is => 'rw');
  has model => (is => 'rw');

  method get_commands {
    my @cmd_array = ();

    push @cmd_array, $self->bot->flip();
    #my $res = $sim->send( $bot->flip() );
    #say Dumper($res);

    my $forwardz = 0;
    my $forwardx = 0;
    my $r = $self->resolution - 1;
    for my $y (0..$r) {
      for my $x (0..$r) {
        $forwardx = !$forwardx if $x == 0;
        my $new_x = $forwardx ? $x : $r - $x;

        for my $z (0..$r) {
          if( $z == 0 ) {
            $forwardz = !$forwardz;
            last unless any { $_ } @{$self->model->[$x][$y]}[0..$r];
          }
          my $new_z = $forwardz ? $z : $r - $z;

          push @cmd_array, $self->bot->move_to([$new_x, $y+1, $new_z]);
          push @cmd_array, $self->bot->fill([$new_x,$y,$new_z]) if $self->model->[$new_x][$y][$new_z];
          #say Dumper($self->bot->position);
        }
      }
    }

    push @cmd_array, $self->bot->move_to([0,0,0]);
    push @cmd_array, $self->bot->flip();
    push @cmd_array, $self->bot->halt();

    return @cmd_array;
  }
}
