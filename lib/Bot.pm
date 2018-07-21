use Moops;
use Data::Dumper;

class Bot {
  use JSON::XS;
  has bid => (is => 'ro' );
  has position => (is => 'rw');
  has seeds => (is => 'rw');

  method move_to($dest) {
    my $diff = $self->position_diff( $dest );
    my $json = { cmd => 'smove', lld => $diff };
    $self->position([@{ $dest }]);
    return encode_json($json);
  }

  method fill($voxel) {
    my $diff = $self->position_diff( $voxel );
    my $json = { cmd => 'fill', nd => $diff };
    return encode_json($json);
  }

  method position_diff($pos) {
    my $x_diff = $pos->[0] - $self->position()->[0];
    my $y_diff = $pos->[1] - $self->position()->[1];
    my $z_diff = $pos->[2] - $self->position()->[2];

    return [$x_diff, $y_diff, $z_diff];
  }

  method halt() {
    return encode_json({ cmd => 'halt'});
  }

  method flip() {
    return encode_json({ cmd => 'flip'});
  }
}

1;
