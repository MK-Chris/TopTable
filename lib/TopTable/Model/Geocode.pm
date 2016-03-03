package TopTable::Model::Geocode;
use Moose;
use namespace::autoclean;
use Google::GeoCoder::Smart;
#use Geo::Coder::Google;

extends 'Catalyst::Model';

=head1 NAME

TopTable::Model::Geocode - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.


=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub ACCEPT_CONTEXT {
  my ( $self, $c ) = @_;
  # Create the geocoder object if we need to
  $self->{geocoder} ||= Google::GeoCoder::Smart->new(key => $c->config->{Google}{Maps}{api_key});
  return $self;
}

sub search {
  my ( $self, $location ) = @_;
  my ( $result_count, $status, @geocode_results, $return_content ) = $self->{geocoder}->geocode( address => $location );
  
  # Return value will consist of:
  # * $return_value->{result_count}
  # * $return_value->{status}
  # * $return_value->{results} (arrayref)
  return {
    result_count  => $result_count,
    status        => $status,
    results       => \@geocode_results,
  };
}

__PACKAGE__->meta->make_immutable;

1;
