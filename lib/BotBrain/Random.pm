use Moops;

class BotBrain::Random {

  has bot => (is => 'rw');
  has resolution => (is => 'rw');
  has model => (is => 'rw');

  method get_commands {
    my @commands = qw( move_to fill flip halt );
    my $cmd = $commands[rand @commands];
    if($cmd eq 'move_to') {
      return $self->move_to;
    } elsif ($cmd eq 'fill') {
      return $self->fill;
    } elsif ($cmd eq 'flip') {
      return $self->flip;
    } elsif ($cmd eq 'halt') {
      return $self->halt;
    }
  }

  method flip {
    return $self->bot->flip;
  }

  method halt {
    return $self->bot->halt;
  }

  method fill {
    return $self->bot->fill([0, -1, 0]);
  }

  method move_to {
    my $x = int rand $self->resolution;
    my $y = int rand $self->resolution;
    my $z = int rand $self->resolution;
    return $self->bot->move_to([$x, $y, $z]);
  }
}
