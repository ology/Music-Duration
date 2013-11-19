#!perl -T
use strict;
use warnings;
use Test::More;

require_ok('Music::Duration');

my %duration = (
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

for my $d (keys %duration) {
    is sprintf( '%.4f', $MIDI::Simple::Length{$d} ), $duration{$d}, $d;
}

done_testing();

