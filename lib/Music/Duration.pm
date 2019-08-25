package Music::Duration;

# ABSTRACT: Add 32nd, 64th, 128th and tuplet durations to MIDI-Perl

use strict;
use warnings;

use MIDI::Simple;

our $VERSION = '0.0701';

=head1 SYNOPSIS

  # Compare lengths:
  # perl -MMIDI::Simple -MData::Dumper -e '%x = %MIDI::Simple::Length; print Dumper [ map { "$_ => $x{$_}" } sort { $x{$a} <=> $x{$b} } keys %x ]'
  # perl -MMusic::Duration -MData::Dumper -e '%x = %MIDI::Simple::Length; print Dumper [ map { "$_ => $x{$_}" } sort { $x{$a} <=> $x{$b} } keys %x ]'

  # In a program:
  use Music::Duration;

  Music::Duration::tuplet( 'ten', 'z', 5 ); # 5 divisions in place of an eighth note triplet

  my $black_page = MIDI::Simple->new_score();
  # ...
  $black_page->n( 'zten', 'n38' ) for 1 .. 5;

=head1 DESCRIPTION

This module adds 32nd, 64th, and 128th note divisions to
L<MIDI::Simple> C<%Length>.  It also adds fractional note divisions
with the B<tuplet()> function.

32nd durations added:

  yn:   thirty-second note
  dyn:  dotted thirty-second note
  ddyn: double dotted thirty-second note
  tyn:  thirty-second note triplet

64th durations added:

  xn:   sixty-fourth note
  dxn:  dotted sixty-fourth note
  ddxn: double dotted sixty-fourth note
  txn:  sixty-fourth note triplet

128th durations added:

  on:   128th note
  don:  dotted 128th note
  ddon: double dotted 128th note
  ton:  128th note triplet

=cut

{
    # Set the initial duration to one below 32nd,
    my $last = 's'; # ..which is a sixteenth.

    # Add 32nd, 64th and 128th as y, x, and o respectively.
    for my $duration ( qw( y x o ) ) {
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

=head1 FUNCTION

=head2 tuplet

  Music::Duration::tuplet( 'qn', 'z', 5 );
  # $score->n( 'zqn', ... );

  Music::Duration::tuplet( 'wn', 'z', 7 );
  # $score->n( 'zwn', ... );

Add a fractional division to the L<MIDI::Simple> C<Length> hash for a
given B<name> and B<duration>.

Musically, this creates a series of notes in place of the given
B<duration>.

A triplet is a 3-tuplet.

So in the first example, instead of a quarter note, we instead play 5
beats - a 5-tuple.  In the second, instead of a whole note (of four
beats), we instead play 7 beats.

=cut

sub tuplet {
    my ( $duration, $name, $factor ) = @_;
    $MIDI::Simple::Length{ $name . $duration } = $MIDI::Simple::Length{$duration} / $factor
}

=head2 tuple

Synonym for the B<tuplet> function.

=cut

sub tuple { tuplet(@_) }

1;
__END__

=head1 SEE ALSO

The C<%Length> hash in L<MIDI::Simple>

The code in the F<eg/> and F<t/> directories

L<https://www.scribd.com/doc/26974069/Frank-Zappa-The-Black-Page-1-Melody-Score>

L<https://en.wikipedia.org/wiki/Tuplet>

=cut
