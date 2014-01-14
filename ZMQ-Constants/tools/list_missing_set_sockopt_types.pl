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

__DATA__

# from zmq doc 4.0.4
#
ZMQ_IDENTITY binary
ZMQ_SUBSCRIBE binary
ZMQ_TCP_ACCEPT_FILTER binary
ZMQ_UNSUBSCRIBE binary
ZMQ_CURVE_PUBLICKEY binary|string
ZMQ_CURVE_SECRETKEY binary|string
ZMQ_CURVE_SERVERKEY binary|string

ZMQ_BACKLOG int
ZMQ_CONFLATE int
ZMQ_CURVE_SERVER int
ZMQ_IMMEDIATE int
ZMQ_IPV4ONLY int
ZMQ_IPV6 int
ZMQ_MULTICAST_HOPS int
ZMQ_PLAIN_SERVER int
ZMQ_PROBE_ROUTER int
ZMQ_RATE int
ZMQ_RCVBUF int
ZMQ_RCVHWM int
ZMQ_RCVTIMEO int
ZMQ_RECONNECT_IVL int
ZMQ_RECONNECT_IVL_MAX int
ZMQ_RECOVERY_IVL int
ZMQ_REQ_CORRELATE int
ZMQ_REQ_RELAXED int
ZMQ_ROUTER_MANDATORY int
ZMQ_ROUTER_RAW int
ZMQ_SNDBUF int
ZMQ_SNDHWM int
ZMQ_SNDTIMEO int
ZMQ_TCP_KEEPALIVE int
ZMQ_TCP_KEEPALIVE_CNT int
ZMQ_TCP_KEEPALIVE_IDLE int
ZMQ_TCP_KEEPALIVE_INTVL int
ZMQ_XPUB_VERBOSE int
ZMQ_LINGER int

ZMQ_MAXMSGSIZE int64_t

ZMQ_PLAIN_PASSWORD string
ZMQ_PLAIN_USERNAME string
ZMQ_ZAP_DOMAIN string

ZMQ_AFFINITY uint64_t

EINVAL
ETERM
ENOTSOCK
EINTR

