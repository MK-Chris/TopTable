package TopTable::Model::ICal;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';
use DateTime;

__PACKAGE__->config(
  class => "Data::ICal",
  args  => {
    calname     => "Milton Keynes Table Tennis League",
    rfc_strict  => 1,
    audo_uid    => 1,
    product_id  => "TopTable",
  }
);

sub add_events {
  my ( $self, $events, $parameters ) = @_;
  my $timezone = $parameters->{timezone};
  
  # The events must be an arrayref, so make it one if it's not already
  $events = [ $events ] unless ref( $events ) eq "ARRAY";
  
  # Current date / time
  my $now_tz  = DateTime->now( time_zone => $timezone );
  my $now_utc = DateTime->now( time_zone => "UTC" );
  
  # Hold the entries in an array
  my @entries = ();
  
  # Loop through the specified events
  foreach my $event ( @$events ) {
    my $entry = Data::ICal::Entry::Event->new;
    $entry->add_properties(
      summary         => $event->{summary},
      status          => $event->{status},
      description     => $event->{description},
      dtstart         => $event->{date_start_time},
      duration        => DateTime::Format::ICal->format_duration( $event->{duration} ),
      location        => $event->{venue}->address,
      geo             => sprintf( "%s:%s", $event->{venue}->coordinates_latitude, $event->{venue}->coordinates_longitude ),
      url             => $event->{url},
      created         => DateTime::Format::ICal->format_datetime( $now_tz ),
      "last-modified" => DateTime::Format::ICal->format_datetime( $now_utc ),
      dtstamp         => DateTime::Format::ICal->format_datetime( $now_utc ),
    );
    
    push( @entries, $entry );
  }
  
  $self->add_entries( @entries );
}

1;
