package TopTable::Model::Geocode;
use Moose;
use namespace::autoclean;
#use Google::GeoCoder::Smart;
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

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use LWP::UserAgent;
use URI;
use TopTable::Maketext;
use JSON;

has ua => (
  is => "rw",
  isa => "LWP::UserAgent",
);

has scheme => (
  is => "ro",
  isa => "Str",
  default => "https",
);

has host => (
  is => "ro",
  isa => "Str",
  default => "maps.googleapis.com",
);

has path => (
  is => "ro",
  isa => "Str",
  default => "/maps/api/geocode/json",
);

has language => (
  is => "rw",
  isa => "Str",
  writer => "_set_locale",
);

has key => (
  is => "ro",
  isa => "Str",
  writer => "_set_key",
);

has lang => (
  is => "rw",
  isa => "TopTable::Maketext",
  writer => "_set_maketext",
);

sub ACCEPT_CONTEXT {
  my ( $self, $c ) = @_;
  
  $self->_set_key($c->config->{Google}{Maps}{api_key});
  $self->_set_locale($c->locale);
  $self->ua(LWP::UserAgent->new("TopTable/" . $c->toptable_version));
  $self->_set_maketext(TopTable::Maketext->get_handle($c->locale));
  
  return $self;
}

sub search {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  $self->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($self->lang);
  my $lang = $self->lang;
  
  # Grab the fields
  my $location = $params->{location};
  my $reverse = $params->{reverse} || 0;
  my $loc_param = $reverse ? "latlng" : "address";
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    results => [],
  };
  
  my $uri = URI->new(sprintf("%s://%s%s", $self->scheme, $self->host, $self->path));
  my %query_params = (
    $loc_param => $location,
    language => $self->language,
    key => $self->key,
  );
  
  $uri->query_form(%query_params);
  my $url = $uri->as_string;
  my $res = $self->ua->get($url);
  
  if ( $res->is_error ) {
    push(@{$response->{error}}, $lang->maketext("google.maps.geocode.errors", $res->status_line, $res->message));
    return $response;
  }
  
  my $json = JSON->new->utf8;
  my $data = $json->decode($res->content);
  $response->{results} = $data->{results};
  $response->{status} = $data->{status};
  
  return $response;
}

__PACKAGE__->meta->make_immutable;

1;
