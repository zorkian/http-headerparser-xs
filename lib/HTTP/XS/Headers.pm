package HTTP::XS::Headers;

use 5.008;
use strict;
use warnings;
use Carp;

require Exporter;
use AutoLoader;

our @ISA = qw( Exporter );

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use HTTPHeaders ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	H_REQUEST
	H_RESPONSE
	M_DELETE
	M_GET
	M_OPTIONS
	M_POST
	M_PUT
    M_HEAD
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	H_REQUEST
	H_RESPONSE
	M_DELETE
	M_GET
	M_OPTIONS
	M_POST
	M_PUT
    M_HEAD
);

our $VERSION = '0.20';

our $HTTPCode = {
    200 => 'OK',
    204 => 'No Content',
    206 => 'Partial Content',
    304 => 'Not Modified',
    400 => 'Bad request',
    403 => 'Forbidden',
    404 => 'Not Found',
    416 => 'Request range not satisfiable',
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    503 => 'Service Unavailable',
};

sub AUTOLOAD {
    # This AUTOLOAD is used to 'autoload' constants from the constant()
    # XS function.

    my $constname;
    our $AUTOLOAD;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "&HTTP::XS::Headers::constant not defined" if $constname eq 'constant';
    my ($error, $val) = constant($constname);
    if ($error) { croak $error; }
    {
	no strict 'refs';
	# Fixed between 5.005_53 and 5.005_61
#XXX	if ($] >= 5.00561) {
#XXX	    *$AUTOLOAD = sub () { $val };
#XXX	}
#XXX	else {
	    *$AUTOLOAD = sub { $val };
#XXX	}
    }
    goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load('HTTP::XS::Headers', $VERSION);

# create a very bare response to send to a user (mostly used internally)
sub new_response {
    my $code = $_[1];

    my $msg = $HTTPCode->{$code} || "";
    my $hdr = HTTP::XS::Headers->new(\"HTTP/1.0 $code $msg\r\n\r\n");
    return $hdr;
}

# do some magic to determine content length
sub content_length {
    my HTTP::XS::Headers $self = $_[0];

    if ($self->isRequest()) {
        return 0 if $self->getMethod() == M_HEAD();
    } else {
        my $code = $self->getStatusCode();
        if ($code == 304 || $code == 204 || ($code >= 100 && $code <= 199)) {
            return 0;
        }
    }

    if (defined (my $clen = $self->getHeader('Content-length'))) {
        return $clen+0;
    }

    return undef;
}

sub set_version {
    my HTTP::XS::Headers $self = $_[0];
    my $ver = $_[1];

    die "Bogus version" unless $ver =~ /^(\d+)\.(\d+)$/;

    my ($ver_ma, $ver_mi) = ($1, $2);
    $self->setVersionNumber($ver_ma * 1000 + $ver_mi);

    return $self;
}

sub clone {
    return HTTP::XS::Headers->new( $_[0]->to_string_ref );
}

sub code {
    my HTTP::XS::Headers $self = shift;

    my ($code, $msg) = @_;
    $msg ||= $self->http_code_english($code);
    $self->setCodeText($code, $msg);
}

# Preloaded methods go here.

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!
# Right, I'm editing it.

=head1 NAME

HTTP::XS::Headers - XS extension for processing HTTP headers.

=head1 SYNOPSIS

  use HTTP::XS::Headers;

  my $hdr = HTTP::XS::Headers->new("GET / HTTP/1.0\r\nConnection: keep-alive\r\n\r\n");
  if ($hdr->getMethod == M_GET()) {
    print "GET: ", $hdr->getURI(), "\n";
    print "Connection: ", $hdr->getHeader('Connection'), "\n";
  }

=head1 DESCRIPTION

This module is used to read HTTP headers from a string and to parse them
into an internal storage format for easy access and modification.  You
can also ask the module to reconstitute the headers into one big string,
useful if you're writing a proxy and need to read and write headers while
maintaining the ability to modify individual parts of the whole.

The goal is to be fast.  This is a lot faster than doing all of the text
processing in Perl directly, and a lot of the flexibility of Perl is
maintained by implementing higher level logic in the Perl library and
leaving the parsing down to the C++ side.

=head2 Exportable constants

  H_REQUEST
  H_RESPONSE
  M_GET
  M_POST
  M_HEAD
  M_OPTIONS
  M_PUT
  M_DELETE

=head1 KNOWN BUGS

There are no known bugs at this time.  Please report any you find!

=head1 SEE ALSO

Perlbal, and by extension this module, can be discussed by joining the
Perlbal mailing list on http://lists.danga.com/.

Please see the original Perlbal::HTTPHeaders module implemented entirely in
Perl in the Perlbal source tree available at http://code.sixapart.com/svn/perlbal/.

Feel free to contact the author as well.

=head1 AUTHOR

Mark Smith, E<lt>mark@xb95.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2008 by Mark Smith.

Copyright (C) 2004 by Danga Interactive, Inc.

Copyright (C) 2005-2007 by Six Apart, Ltd.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
