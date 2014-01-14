#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use ZMQ::Constants qw//;
use List::Util qw/max/;

my ($header_file) = @ARGV;

die "usage: `perl $0 ~/src/zeromq4-x/include/zmq.h` # some header file" unless -f $header_file;


my %LOOKUP = map { $_ => 0 } @{ $ZMQ::Constants::EXPORT_TAGS{all} };
my %header_definitions;
my %lines;

open( my $fh, "<", $header_file );
while ( my $line = <$fh> ) {
    chomp($line);

    if ($line =~ m/#define\s+(\w+)\s+/) {
        $header_definitions{$1}=0;
        $lines{$1} = $line;
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

my $max_width = max(  map { length $_ } values %lines );  
say "\n* My suggestion to add";
for my $k ( sort keys %header_definitions ) {
    my $v = $header_definitions{$k};
    next unless $v;

    my ($def, $val) = $lines{$k} =~ m/#define\s+(\w+)\s+(.+)$/;
    say sprintf("%-${max_width}s,\t# %s", "$def => $val",$lines{$k});
}

1;
