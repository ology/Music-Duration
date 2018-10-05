package Music::Duration;

# ABSTRACT: Add 32nd, 64th, fractional and tuple durations to MIDI-Perl

our $VERSION = '0.0504';
use strict;
use warnings;

use MIDI::Simple;

=head1 SYNOPSIS

  # Compare:
  # perl -MMIDI::Simple -MData::Dumper -e'$Data::Dumper::Sortkeys=1; print Dumper \%MIDI::Simple::Length'
  # perl -MMusic::Duration -MData::Dumper -e'$Data::Dumper::Sortkeys=1; print Dumper \%MIDI::Simple::Length'

  # In a program:
  use MIDI::Simple;
  use Music::Duration;
  Music::Duration::fractional('z', 5);
  # Create and set up a new_score, then for example:
  n('zsn', 'n38') for 1 .. 5;
  Music::Duration::tuple( 'qn', 'z', 5 );
  n('zqn', 'n38') for 1 .. 5;

=head1 DESCRIPTION

This module adds thirty-second and sixty-fourth note divisions to
L<MIDI::Simple>.  These are 32nd: yn, dyn, ddyn, tyn and 64th: xn, dxn, ddxn, txn.

Also, this module allows the addition of non-standard note divisions with the
B<fractional()> and B<tuple()> functions, detailed below.

=cut

{
    # Set the initial duration to one below 32nd,
    my $last = 's'; # ..which is a sixteenth.

    # Add 32nd and 64th as y and x.
    for my $duration ( qw( y x ) ) {
        # Create a MIDI::Simple format note identifier.
        my $n = $duration . 'n';

        # Compute the note duration.
        $MIDI::Simple::Length{$n} = $duration eq $last
            ? 4 : $MIDI::Simple::Length{ $last . 'n' } / 2;
        # Compute the dotted duration.
        $MIDI::Simple::Length{ 'd'  . $n } = $MIDI::Simple::Length{$n}
            + $MIDI::Simple::Length{$n} / 2;
        # Compute the double-dotted duration.
        $MIDI::Simple::Length{ 'dd' . $n } = $MIDI::Simple::Length{'d' . $n}
            + $MIDI::Simple::Length{$n} / 4;
        # Compute triplet duration.
        $MIDI::Simple::Length{ 't'  . $n } = $MIDI::Simple::Length{$n} / 3 * 2;

        # Increment the last duration seen.
        $last = $duration;
    }
}

=head1 FUNCTIONS

=head2 fractional()

  Music::Duration::fractional( 'z', 5 )
  # Then: $score->n( 'zqn', ... );

Add a fractional division to the L<MIDI::Simple> C<Length> hash.

For a given name of 'z', this function adds the following durations:

  zwn
  zhn
  zqn
  zen
  zsn
  zyn
  zxn

For the example of 5 divisions, this means that a whole note is 5 beats long.
The duration for each division is "half as long as the last."  So a half note is
2.5 beats long, and a quarter note is, you guessed it - 1.25.  See the
distribution test for the full breakdown.

=cut

sub fractional {
    my ( $name, $factor ) = @_;

    my $divisor = 1;

    for my $d (qw( w h q e s y x )) {
        $MIDI::Simple::Length{ $name . $d . 'n' } = $factor / $divisor;
        $divisor *= 2;
    }
}

=head2 tuple()

  Music::Duration::tuple( 'wn', 'z', 5 );
  # Then: $score->n( 'zwn', ... );

Add a fractional division for a given B<duration> of the L<MIDI::Simple>
C<Length> hash.

Musically, this creates a "cluster" of notes in place of the given B<duration>.

So instead of a whole note of four beats, we instead play 5 beats.  A triplet is
a 3-tuple.

=cut

sub tuple {
    my ( $duration, $name, $factor ) = @_;
    $MIDI::Simple::Length{ $name . $duration } = $MIDI::Simple::Length{$duration} / $factor
}

1;
__END__
=head1 TO DO

Add dot, double-dot and triplet to the fractional durations.

=head1 SEE ALSO

The "Parameters for n/r/noop" section in L<MIDI::Simple>

The code in the C<t/> directory

=cut
