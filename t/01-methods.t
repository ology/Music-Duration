#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'Music::Duration';
#use Data::Dumper;$Data::Dumper::Sortkeys=1;warn Dumper\%MIDI::Simple::Length;exit;

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
for my $i ( keys %expected ) {
    is sprintf( '%.4f', $MIDI::Simple::Length{$i} ), $expected{$i}, $i;
}

Music::Duration::fractional( 'z', 4 );
%expected = (
    zwn => $MIDI::Simple::Length{wn},
    zhn => $MIDI::Simple::Length{hn},
    zqn => $MIDI::Simple::Length{qn},
    zen => $MIDI::Simple::Length{en},
    zsn => $MIDI::Simple::Length{sn},
    zyn => $MIDI::Simple::Length{yn},
    zxn => $MIDI::Simple::Length{xn},
);
for my $i ( keys %expected ) {
    is $MIDI::Simple::Length{$i}, $expected{$i}, "$i 4";
}

Music::Duration::fractional( 'z', 5 );
%expected = (
    zwn => 5,
    zhn => 2.5,
    zqn => 1.25,
    zen => 0.625,
    zsn => 0.3125,
    zyn => 0.15625,
    zxn => 0.078125,
);
for my $i ( keys %expected ) {
    is $MIDI::Simple::Length{$i}, $expected{$i}, "$i 5";
}

Music::Duration::tuple( 'qn', 'z', 3 );
is $MIDI::Simple::Length{zqn}, $MIDI::Simple::Length{ten}, 'zqn = ten';

Music::Duration::tuple( 'wn', 'z', 5 );
my $expected = 4 / 5;
is $MIDI::Simple::Length{zwn}, $expected, 'zwn 5-tuple';

done_testing();
