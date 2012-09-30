package Type::Constraint::Role::CanType;

use strict;
use warnings;

use Lingua::EN::Inflect qw( PL_N WORDLIST );
use Scalar::Util qw( blessed );

use Moose::Role;

with 'Type::Constraint::Role::Interface' =>
    { -excludes => ['_wrap_message_generator'] };

has methods => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

override BUILDARGS => sub {
    my $self = shift;

    my $p = super();

    if ( defined $p->{can} && !ref $p->{can} ) {
        $p->{can} = [ $p->{can} ];
    }

    return $p;
};

sub _wrap_message_generator {
    my $self      = shift;
    my $generator = shift;

    my @methods = @{ $self->methods() };

    $generator //= sub {
        my $description = shift;
        my $value       = shift;

        my $class = blessed $value;
        $class ||= $value;

        my @missing = grep { !$value->can($_) } @methods;

        my $noun = PL_N( 'method', scalar @missing );

        return
              $class
            . ' is missing the '
            . WORDLIST( map { "'$_'" } @missing ) . q{ }
            . $noun;
    };

    my $d = $self->_description();

    return sub { $generator->( $d, @_ ) };
}

1;

# ABSTRACT: Provides a common implementation for Type::Constraint::AnyCan and Type::Constraint::ObjectCan

__END__

=head1 DESCRIPTION

See L<Type::Constraint::AnyCan> and L<Type::Constraint::ObjectCan> for details.
