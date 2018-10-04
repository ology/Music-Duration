#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Music::Duration';

my %expected = (
    # 32nd
      yn => '0.1250',
     dyn => '0.1875',
    ddyn => '0.2188',
     tyn => '0.0833',
    # 64th
      xn => '0.0625',
     dxn => '0.0938',
    ddxn => '0.1094',
     txn => '0.0417',
);
for my $d ( keys %expected ) {
    is sprintf( '%.4f', $MIDI::Simple::Length{$d} ), $expected{$d}, $d;
}

Music::Duration::fractional( 'z', 4 );
%expected = (
    zwn => '4.0000',
    zhn => '2.0000',
    zqn => '1.0000',
    zen => '0.5000',
    zsn => '0.2500',
    zyn => '0.1250',
    zxn => '0.0625',
);
for my $d ( keys %expected ) {
    is sprintf( '%.4f', $MIDI::Simple::Length{$d} ), $expected{$d}, $d;
}

#Music::Duration::fractional('z', 5);
#%expected = (
#    zwn => '0.8000',
#    zhn => '0.4000',
#    zqn => '0.2000',
#    zsn => '0.0500',
#    zyn => '0.0250',
#    zxn => '0.0125',
#);
#for my $d (keys %expected) {
#    is sprintf( '%.4f', $MIDI::Simple::Length{$d} ), $expected{$d}, $d;
#}

done_testing();
