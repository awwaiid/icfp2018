use Moops;

class Bot {
  use Data::Dumper;
  use List::Util qw{ min };

  has bid => (is => 'ro' );
  has position => (is => 'rw');
  has seeds => (is => 'rw');

  method move_to($dest) {
    my $diff = $self->position_diff( $dest );
    my @cmds;

    my @indices = $dest->[0] == 0 && $dest->[1] == 0 && $dest->[2] == 0 ? (0,1,2) : (1,0,2);   # if moving to destination can move in y dir first
    for my $i ( @indices ) {
      my $pos = $diff->[$i];
      my $forward = $pos > 0 ? 1 : -1;
      while ( $pos != 0 ) {
        $pos = abs($pos);
        my $new_loc = [0,0,0];
        $new_loc->[$i] = min($pos, 15) * $forward;
        $pos -= $pos >  15 ? 15 : $pos;
        push @cmds, { cmd => 'smove', lld => $new_loc };
      }
    }
    $self->position([@{ $dest }]);
    return @cmds;
  }

  method fill($voxel) {
    my $diff = $self->position_diff( $voxel );
    my $cmd = { cmd => 'fill', nd => $diff };

    return $cmd;
  }

  method position_diff($pos) {
    my $x_diff = $pos->[0] - $self->position()->[0];
    my $y_diff = $pos->[1] - $self->position()->[1];
    my $z_diff = $pos->[2] - $self->position()->[2];

    return [$x_diff, $y_diff, $z_diff];
  }

  method halt() {
    return { cmd => 'halt'};
  }

  method flip() {
    return { cmd => 'flip'};
  }
}

1;
