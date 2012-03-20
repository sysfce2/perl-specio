package Type::Declare;

use strict;
use warnings;

use parent 'Exporter';

use Carp qw( croak );
use Params::Util qw( _CODELIKE );
use Type::Constraint::Simple;
use Type::Helpers qw( install_t_sub _STRINGLIKE _INSTANCEDOES );
use Type::Registry qw( internal_types_for_package register );

our @EXPORT = qw( declare anon );

sub import {
    my $package = shift;

    my $caller = caller();

    $package->export_to_level( 1, $package, @_ );

    install_t_sub(
        $caller,
        internal_types_for_package($caller)
    );

    return;
}

sub declare {
    my $name = _STRINGLIKE(shift)
        or croak 'You must provide a name for declared types';
    my %p = @_;

    my $tc = _make_tc( name => $name, %p );

    register( scalar caller(), $name, $tc, 'exportable' );

    return;
}

sub anon {
    return _make_tc(@_);
}

sub _make_tc {
    my %p = @_;

    my $class = delete $p{type_class} || 'Type::Constraint::Simple';

    return $class->new(
        %p,
        declared_at => _declared_at(),
    );
}

our $_CALLER_LEVEL = 2;

sub _declared_at {
    my ( $package, $filename, $line ) = caller($_CALLER_LEVEL);

    # We want to skip the declare() and anon() subs that we exported to the
    # calling package.
    my $sub = ( caller( $_CALLER_LEVEL + 1 ) )[3];

    return {
        package  => $package,
        filename => $filename,
        line     => $line,
        sub      => $sub,
    };
}

1;
