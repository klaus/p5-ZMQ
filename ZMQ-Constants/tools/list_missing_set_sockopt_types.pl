#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;
use ZMQ::Constants qw//;
use List::Util qw(first);
my %LOOKUP = map { $_ => 0 } @{ $ZMQ::Constants::EXPORT_TAGS{all} };

my %not_setters  = map { $_ => 1 }  qw(
    EADDRINUSE
    EADDRNOTAVAIL
    ECONNREFUSED
    EFSM
    EINPROGRESS
    EMTHREAD
    ENETDOWN
    ENOBUFS
    ENOCOMPATPROTO
    ENOTSOCK
    ENOTSUP
    EPROTONOSUPPORT
    ETERM

    ZMQ_HAUSNUMERO

    ZMQ_FAIL_UNROUTABLE
    ZMQ_FORWARDER
    ZMQ_MAX_VSM_SIZE
    ZMQ_MCAST_LOOP
    ZMQ_MSG_MASK
    ZMQ_MSG_SHARED
    ZMQ_PAIR
    ZMQ_POLLOUT
    ZMQ_SNDMORE
    ZMQ_SUB
    ZMQ_XSUB
);

no strict 'refs';
foreach my $k ( sort keys %LOOKUP ) {

    my $val = ZMQ::Constants->$k;
    say "$k => $val,";
    my $type = ZMQ::Constants::get_sockopt_type( ZMQ::Constants->$k );
    next if $type;
    next if $not_setters{$k};

    say $k;
}
