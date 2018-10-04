package Music::Duration;

# ABSTRACT: Add 32nd, 64th & odd fractional durations to MIDI-Perl

our $VERSION = '0.0301';
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
  n('zsn', 'n38') for 1 .. 5;   # Add a snare sixteenth quintuplet

=head1 DESCRIPTION

This module adds thirty-second and sixty-fourth note divisions to
L<MIDI::Simple>.  (These are 32nd: y, dy, ddy, ty and 64th: x, dx, ddx, tx.)

Also, this module allows the addition of non-standard note divisions with the
B<fractional> function, detailed below.

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

  $z = Music::Duration::fractional( 'z', 5 )

Add a fractional duration-division (or "tuple") for each note, to the
L<MIDI::Simple> C<Length> hash.

In the example above, we add 5th note divisions called "z-notes" to the existing
lengths.

=cut

sub fractional {
    # Get the new name and the division factor.
    my ( $name, $factor ) = @_;

    # Add a named factor for each note value.
    for my $n ( keys %MIDI::Simple::Length ) {
        # Skip durations longer than a single note.
        next if length $n > 2;
        # Add the fractional note value to the Lengths.
        $MIDI::Simple::Length{$name . $n} = $MIDI::Simple::Length{$n} / $factor;
    }
}

1;
__END__

=head1 SEE ALSO

The "Parameters for n/r/noop" section in L<MIDI::Simple>

Also, the code in the C<t/> directory

=cut
