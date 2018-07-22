use Moops;

class Simulator {
  use JSON::XS;
  use IPC::Open2;

  has to_sim => (is => 'rw' );
  has from_sim => (is => 'rw' );

  method BUILD($args) {
    $self->connect( $args->{resolution} || 20 );
  }

  method connect($resolution) {
    my ($to_sim, $from_sim);
    open2($from_sim, $to_sim, "./simulator/simulator.native $resolution");
    $self->to_sim($to_sim);
    $self->from_sim($from_sim);
  }

  method send($data) {
    $self->to_sim->print(encode_json($data));
    my $response = $self->from_sim->getline;
    return decode_json($response);
  }

  method state {
    return $self->send({cmd => "state"});
  }

  method save {
    return $self->send({cmd => "save"});
  }

  method restore {
    return $self->send({cmd => "restore"});
  }
}
