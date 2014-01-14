#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use ZMQ::Constants qw//;

my ($header_file) = @ARGV;

die "usage: `perl $0 ~/src/zeromq4-x/include/zmq.h` # some header file" unless -f $header_file;


my %LOOKUP = map { $_ => 0 } @{ $ZMQ::Constants::EXPORT_TAGS{all} };
my %header_definitions;

open( my $fh, "<", $header_file );
while ( my $line = <$fh> ) {
    chomp($line);

    if ($line =~ m/#define\s+(\w+)\s+/) {
        $header_definitions{$1}=0;
    }

}
close($fh);

for my $k ( sort keys %LOOKUP ) {
    $LOOKUP{$k}++ if defined $header_definitions{$k};
}
for my $l ( sort keys %header_definitions) {
    $header_definitions{$l}++ unless defined $LOOKUP{$l};
}

say "\n* Missing constants in this header file:";
while ( my ( $k, $v ) = each %LOOKUP ) {
    next if $v;
    say $k;
}

say "\n* Missing constants in ZMQ::Constants:";
while ( my ( $k, $v ) = each %header_definitions ) {
    next unless $v;
    say $k;
}

1;
