package TopTable::Model::ICal;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';
use namespace::autoclean;

=head1 NAME

TopTable::Model::ICal - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

# __PACKAGE__->config(
#   class       => "Data::ICal",
#   args => {
#     calname     => $c->config->{"Model::ICal"}{calname} || "TopTable",
#     rfc_strict  => 1,
#   },
# );

sub mangle_arguments {
  my ( $self, $args ) = @_;
  
  return %$args; # now the args are a plain list
}

# sub ACCEPT_CONTEXT {
#   my ( $self, $c, $calendar_name ) = @_;
#   
#   # Create the geocoder object if we need to
#   $self->{calendar} ||= Data::ICal->new(
#     calname     => $calendar_name || $c->config->{"Model::ICal"}{calname} || "TopTable",
#     rfc_strict  => 1,
#   );
#   
#   # Set an empty hashref for timezones we've seen already
#   $self->{timezones} = {};
#   return $self;
# }

1;
