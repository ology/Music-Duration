package Music::Duration;
# ABSTRACT: Thirtysecond and sixtyfourth notes

our $VERSION = '0.0201';
use strict;
use warnings;

use MIDI::Simple;

=head1 NAME

Music::Duration - Thirtysecond and sixtyfourth notes

=head1 SYNOPSIS

  perl -MMIDI::Simple -MData::Dumper -e'print Dumper \%MIDI::Simple::Length'

  perl -MMusic::Duration -MData::Dumper -e'print Dumper \%MIDI::Simple::Length'

=head1 DESCRIPTION

This module adds thirtysecond and sixtyfourth note divisions to L<MIDI::Simple>.
These are 32nd: y, dy, ddy, ty and 64th: x, dx, ddx, tx.

=cut

{
    # Set the initial duration to one below 32nd,
    my $last = 's'; # ..which is a sixteenth.

    # Add 32nd and 64th as y and x.
    for my $duration (qw( y x )) {
        # Create a MIDI::Simple format note identifier.
        my $n = $duration . 'n';

        # Compute the note duration.
        $MIDI::Simple::Length{$n} = $duration eq $last
            ? 4 : $MIDI::Simple::Length{$last . 'n'} / 2;
        # Compute the dotted duration.
        $MIDI::Simple::Length{'d'  . $n} = $MIDI::Simple::Length{$n}
            + $MIDI::Simple::Length{$n} / 2;
        # Compute the double-dotted duration.
        $MIDI::Simple::Length{'dd' . $n} = $MIDI::Simple::Length{'d' . $n}
            + $MIDI::Simple::Length{$n} / 4;
        # Compute triplet duration.
        $MIDI::Simple::Length{'t'  . $n} = $MIDI::Simple::Length{$n} / 3 * 2;

        # Increment the last duration seen.
        $last = $duration;
    }
}

=head1 FUNCTIONS

=head2 fractional()

Add a fractional duration-division that is not "by half" to the L<MIDI::Simple>
C<Length> hash.

=cut

sub fractional {
}

1;
__END__

=head1 TO DO

Decouple from L<MIDI> and provide a subroutine of lengths.

Allow addition of any literal or coderef entry to the C<Length> hash.

Only require L<MIDI::Simple> and set the C<Length> hash if present.

=head1 SEE ALSO

L<MIDI> and L<MIDI::Simple>

The code in the C<t/> directory

=cut
