package Music::Duration;

# ABSTRACT: Add 32nd, 64th and tuple durations to MIDI-Perl

our $VERSION = '0.0600';
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

  # Create and set up a new_score...

  Music::Duration::tuple( 'qn', 'z', 5 );
  n('zqn', 'n38') for 1 .. 5; # 5 snares in place of a standard quarter note

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

=head1 FUNCTION

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

=head1 SEE ALSO

The "Parameters for n/r/noop" section in L<MIDI::Simple>

The code in the C<t/> directory

=cut
