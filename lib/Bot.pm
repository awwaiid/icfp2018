use Moops;
use Data::Dumper;

class Bot {
  has bid => (is => 'ro' );
  has position => (is => 'rw');
  has seeds => (is => 'rw');

  method move_to($dest) {
    my $diff = $self->position_diff( $dest );
    my $cmd = { cmd => 'smove', lld => $diff };
    $self->position([@{ $dest }]);
    return $cmd;
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
