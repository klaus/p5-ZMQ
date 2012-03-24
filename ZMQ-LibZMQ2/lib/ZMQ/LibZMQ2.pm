package ZMQ::LibZMQ2;
use strict;
use base qw(Exporter);
use XSLoader;

BEGIN {
    our $VERSION = '0.20';
    XSLoader::load(__PACKAGE__, $VERSION);
}

our @EXPORT = qw(
    zmq_init
    zmq_term

    zmq_msg_close
    zmq_msg_data
    zmq_msg_init
    zmq_msg_init_data
    zmq_msg_init_size
    zmq_msg_size
    zmq_msg_copy
    zmq_msg_move

    zmq_bind
    zmq_close
    zmq_connect
    zmq_getsockopt
    zmq_recv
    zmq_send
    zmq_setsockopt
    zmq_socket

    zmq_poll

    zmq_device
);

1;

__END__

=head1 NAME

ZMQ::LibZMQ2 - A libzmq 2.x wrapper for Perl

=head1 SYNOPSIS

    use ZMQ::LibZMQ;

    my $ctxt = zmq_init($threads);
    my $rv   = zmq_term($ctxt);

    my $msg  = zmq_msg_init();
    my $msg  = zmq_msg_init_size( $size );
    my $msg  = zmq_msg_init_data( $data );
    my $rv   = zmq_msg_close( $msg );
    my $rv   = zmq_msg_move( $dest, $src );
    my $rv   = zmq_msg_copy( $dest, $src );
    my $data = zmq_msg_data( $msg );
    my $size = zmq_msg_size( $msg);

    my $sock = zmq_socket( $ctxt, $type );
    my $rv   = zmq_close( $sock );
    my $rv   = zmq_setsockopt( $socket, $option, $value );
    my $val  = zmq_getsockopt( $socket, $option );
    my $rv   = zmq_bind( $sock, $addr );
    my $rv   = zmq_send( $sock, $msg, $flags );
    my $msg  = zmq_recv( $sock, $flags );

=head1 INSTALLATION

If you have libzmq registered with pkg-config:

    perl Makefile.PL
    make 
    make test
    make install

If you don't have pkg-config, and libzmq is installed under /usr/local/libzmq:

    ZMQ_HOME=/usr/local/libzmq \
        perl Makefile.PL
    make
    make test
    make install

If you want to customize include directories and such:

    ZMQ_INCLUDES=/path/to/libzmq/include \
    ZMQ_LIBS=/path/to/libzmq/lib \
    ZMQ_H=/path/to/libzmq/include/zmq.h \
        perl Makefile.PL
    make
    make test
    make install

If you want to compile with debugging on:

    perl Makefile.PL -g

=head1 DESCRIPTION

The C<ZMQ::LibZMQ2> module is a wrapper of the 0MQ message passing library for Perl. 
It's a thin wrapper around the C API. Please read L<http://zeromq.org> for
more details on 0MQ.

Note that this is a wrapper for libzmq 2.x. For 3.x, you need to check L<ZMQ::LibZMQ3>

=head1 BASIC USAGE

To start using ZMQ::LibZMQ2, you need to create a context object, then as many ZMQ::LibZMQ2::Socket obects as you need:

    my $ctxt = zmq_init;
    my $socket = zmq_socket( $ctxt, ... options );

You need to call C<zmq_bind()> or C<zmq_connect()> on the socket, depending on your usage. For example on a typical server-client model you would write on the server side:

    zmq_bind( $socket, "tcp://127.0.0.1:9999" );

and on the client side:

    zmq_connect( $socket, "tcp://127.0.0.1:9999" );

The underlying zeromq library offers TCP, multicast, in-process, and ipc connection patterns. Read the zeromq manual for more details on other ways to setup the socket.

When sending data, you can either pass a ZMQ::LibZMQ2::Message object or a Perl string. 

    # the following two send() calls are equivalent
    my $msg = zmq_msg_init_data( "a simple message" );
    zmq_send( $socket, $msg );
    
    zmq_send( $socket, "a simple message" ); 

In most cases using ZMQ::LibZMQ2::Message is redundunt, so you will most likely use the string version.

To receive, simply call C<zmq_recv()> on the socket

    my $msg = zmq_recv( $socket );

The received message is an instance of ZMQ::LibZMQ2::Message object, and you can access the content held in the message via the C<data()> method:

    my $data = zmq_msg_data( $msg );

=head1 ASYNCHRONOUS I/O WITH ZEROMQ

By default 0MQ comes with its own zmq_poll() mechanism that can handle
non-blocking sockets. You can use this by calling zmq_poll with a list of
hashrefs:

    zmq_poll([
        {
            fd => fileno(STDOUT),
            events => ZMQ_POLLOUT,
            callback => \&callback,
        },
        {
            socket => $zmq_socket,
            events => ZMQ_POLLIN,
            callback => \&callback
        },
    ], $timeout );

Unfortunately this custom polling scheme doesn't play too well with AnyEvent.

As of zeromq2-2.1.0, you can use getsockopt to retrieve the underlying file
descriptor, so use that to integrate ZMQ::LibZMQ2 and AnyEvent:

    my $socket = zmq_socket( $ctxt, ZMQ_REP );
    my $fh = zmq_getsockopt( $socket, ZMQ_FD );
    my $w; $w = AE::io $fh, 0, sub {
        while ( my $msg = zmq_recv( $socket, ZMQ_RCVMORE ) ) {
            # do something with $msg;
        }
        undef $w;
    };

=head1 NOTES ON MULTI-PROCESS and MULTI-THREADED USAGE

0MQ works on both multi-process and multi-threaded use cases, but you need
to be careful bout sharing ZMQ::LibZMQ2 objects.

For multi-process environments, you should not be sharing the context object.
Create separate contexts for each process, and therefore you shouldn't
be sharing the socket objects either.

For multi-thread environemnts, you can share the same context object. However
you cannot share sockets.

=head1 FUNCTIONS

=head2 zmq_version()

Returns the version of the underlying zeromq library that is being linked.
In scalar context, returns a dotted version string. In list context,
returns a 3-element list of the version numbers:

    my $version_string = ZMQ::LibZMQ2::zmq_version();
    my ($major, $minor, $patch) = ZMQ::LibZMQ2::zmq_version();

=head2 zmq_device($type, $sock1, $sock2)

=head1 DEBUGGING XS

If you see segmentation faults, and such, you need to figure out where the error is occuring in order for the maintainers to figure out what happened. Here's a very very brief explanation of steps involved.

First, make sure to compile C<ZMQ::LibZMQ2> with debugging on by specifying -g:

    perl Makefile.PL -g
    make

Then fire gdb:

    gdb perl
    (gdb) R -Mblib /path/to/your/script.pl

When you see the crash, get a backtrace:

    (gdb) bt

=head1 CAVEATS

This is an early release. Proceed with caution, please report
(or better yet: fix) bugs you encounter.

This module has been tested againt B<zeromq 2.1.11>. Semantics of this
module rely heavily on the underlying zeromq version. Make sure
you know which version of zeromq you're working with.

=head1 SEE ALSO

L<http://zeromq.org>

L<http://github.com/lestrrat/p5-ZMQ>

=head1 AUTHOR

Daisuke Maki C<< <daisuke@endeworks.jp> >>

Steffen Mueller, C<< <smueller@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

The ZMQ::LibZMQ2 module is

Copyright (C) 2010 by Daisuke Maki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.0 or,
at your option, any later version of Perl 5 you may have available.

=cut