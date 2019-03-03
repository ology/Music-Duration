package Music::Duration;

# ABSTRACT: Add 32nd, 64th and tuple durations to MIDI-Perl

our $VERSION = '0.0604';
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

  Music::Duration::tuplet( 'ten', 'z', 5 ); # 5 notes in place of an eighth note triplet

  my $black_page = MIDI::Simple->new_score();
  # ...
  $black_page->n( 'zten', 'n38' ) for 1 .. 5;

=head1 DESCRIPTION

This module adds thirty-second and sixty-fourth note divisions to
L<MIDI::Simple>.  It also adds fractional note divisions with the B<tuplet()>
function.

32nd durations added:

  yn dyn ddyn tyn

64th durations added:

  xn dxn ddxn txn

=cut

{
    # Set the initial duration to one below 32nd,
    my $last = 's'; # ..which is a sixteenth.

    # Add 32nd and 64th as y and x.
    for my $duration ( qw( y x ) ) {
        # Create a MIDI::Simple format note identifier.
        my $n = $duration . 'n';

        # Compute the note duration, which is half of the previous.
        $MIDI::Simple::Length{$n} = $MIDI::Simple::Length{ $last . 'n' } / 2;

        # Compute the dotted duration.
        $MIDI::Simple::Length{ 'd'  . $n } = $MIDI::Simple::Length{$n}
            + $MIDI::Simple::Length{$n} / 2;

        # Compute the double-dotted duration.
        $MIDI::Simple::Length{ 'dd' . $n } = $MIDI::Simple::Length{ 'd' . $n }
            + $MIDI::Simple::Length{$n} / 4;

        # Compute the triplet duration.
        $MIDI::Simple::Length{ 't'  . $n } = $MIDI::Simple::Length{$n} / 3 * 2;

        # Increment the last duration seen.
        $last = $duration;
    }
}

=head1 FUNCTION

=head2 tuplet()

  Music::Duration::tuplet( 'qn', 'z', 5 );
  # $score->n( 'zqn', ... );
  Music::Duration::tuplet( 'wn', 'z', 5 );
  # $score->n( 'zwn', ... );

Add a fractional division to the L<MIDI::Simple> C<Length> hash for a given
B<name> and B<duration>.

Musically, this creates a series of notes in place of the given B<duration>.

A triplet is a 3-tuplet.

So in the first example, instead of a quarter note, we instead play 5 beats - a
5-tuple.  In the second, instead of a whole note (of four beats), we instead
play 5 beats.

=cut

sub tuplet {
    my ( $duration, $name, $factor ) = @_;
    $MIDI::Simple::Length{ $name . $duration } = $MIDI::Simple::Length{$duration} / $factor
}

=head2 tuple()

Synonym for the B<tuplet> function.

=cut

sub tuple { tuplet(@_) }

1;
__END__

=head1 SEE ALSO

The C<Length> hash in L<MIDI::Simple>

The code in the C<t/> directory

L<https://www.scribd.com/doc/26974069/Frank-Zappa-The-Black-Page-1-Melody-Score>

=cut
