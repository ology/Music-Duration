package Music::Duration;

# ABSTRACT: Add 32nd, 64th, 128th and tuplet durations to MIDI-Perl

use strict;
use warnings;

use MIDI::Simple ();

our $VERSION = '0.0900';

=head1 SYNOPSIS

  use Music::Duration;

  # 5 divisions in place of an eighth note triplet:
  Music::Duration::tuplet( 'ten', 'Z', 5 );

  # Add an arbitrary duration:
  Music::Duration::add_duration( phi => 1.618 );

  # Now inspect the known lengths:
  my %x = %MIDI::Simple::Length;
  print Dumper [ map { "$_ => $x{$_}" } sort { $x{$a} <=> $x{$b} } keys %x ];

  # Use the new durations in a composition:
  my $black_page = MIDI::Simple->new_score();
  $black_page->Channel(9);
  # ...
  $black_page->n( 'Zten', 38 ) for 1 .. 5;
  $black_page->n( 'phi', 38 ) for 1 .. 4;

=head1 DESCRIPTION

This module adds 32nd, 64th, and 128th notes, triplet and dotted
divisions to C<%MIDI::Simple::Length>.  It also computes and inserts a
fractional note division of an existing duration.  Additionally, this
module will insert any named note duration to the length hash.

32nd durations added:

    xn: thirty-second note
   dxn: dotted thirty-second note
  ddxn: double dotted thirty-second note
   txn: thirty-second note triplet

64th durations added:

    yn: sixty-fourth note
   dyn: dotted sixty-fourth note
  ddyn: double dotted sixty-fourth note
   tyn: sixty-fourth note triplet

128th durations added:

    zn: 128th note
   dzn: dotted 128th note
  ddzn: double dotted 128th note
   tzn: 128th note triplet

=cut

{
    # Set the initial duration to one below 32nd,
    my $last = 's'; # ..which is a sixteenth.

    # Add 32nd, 64th and 128th as x, y, and z respectively.
    for my $duration ( qw( x y z ) ) {
        # Create a MIDI::Simple format note identifier.
        my $n = $duration . 'n';

        # Compute the note duration, which is half of the previous.
        $MIDI::Simple::Length{$n} = $MIDI::Simple::Length{ $last . 'n' } / 2;

        # Compute the dotted duration.
        $MIDI::Simple::Length{ 'd' . $n } = $MIDI::Simple::Length{$n}
            + $MIDI::Simple::Length{$n} / 2;

        # Compute the double-dotted duration.
        $MIDI::Simple::Length{ 'dd' . $n } = $MIDI::Simple::Length{ 'd' . $n }
            + $MIDI::Simple::Length{$n} / 4;

        # Compute the triplet duration.
        $MIDI::Simple::Length{ 't' . $n } = $MIDI::Simple::Length{$n} / 3 * 2;

        # Increment the last duration seen.
        $last = $duration;
    }
}

=head1 FUNCTIONS

=head2 tuple, tuplet

  Music::Duration::tuplet( 'qn', 'z', 5 );
  # $score->n( 'zqn', ... );

  Music::Duration::tuplet( 'wn', 'z', 7 );
  # $score->n( 'zwn', ... );

Add a fractional division to the L<MIDI::Simple> C<Length> hash for a
given B<name> and B<duration>.

Musically, this creates a series of notes in place of the given
B<duration>.

A triplet is a "3-tuplet."

So in the first example, instead of a quarter note, we instead play 5
beats - a 5-tuple.  In the second, instead of a whole note (of four
beats), we instead play 7 beats.

=cut

sub tuplet {
    my ( $duration, $name, $factor ) = @_;
    $MIDI::Simple::Length{ $name . $duration } = $MIDI::Simple::Length{$duration} / $factor
}

sub tuple { tuplet(@_) }

=head2 add_duration

  Music::Duration::add_duration( $name => $duration );

This function just adds a B<name>d B<duration> length to
C<%MIDI::Simple::Length> so that it can be used to add notes or rests
to the score.

=cut

sub add_duration {
    my ( $name, $duration ) = @_;
    $MIDI::Simple::Length{ $name } = $duration;
}

1;
__END__

=head1 SEE ALSO

The code in F<t/01-functions.t> and F<eg/*> in this distribution

The C<%Length> hash in L<MIDI::Simple>

L<https://www.scribd.com/doc/26974069/Frank-Zappa-The-Black-Page-1-Melody-Score>

L<https://en.wikipedia.org/wiki/Tuplet>

=cut
