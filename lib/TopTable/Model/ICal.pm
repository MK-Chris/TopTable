package TopTable::Model::ICal;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::Format::ICal;
use Data::ICal;
use Data::ICal::Entry::Event;
use Data::ICal::TimeZone;

extends 'Catalyst::Model';

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

sub ACCEPT_CONTEXT {
  my ( $self, $c, $calendar_name ) = @_;
  
  # Create the geocoder object if we need to
  $self->{calendar} ||= Data::ICal->new(
    calname     => $calendar_name || $c->config->{"Model::ICal"}{calname} || "TopTable",
    rfc_strict  => 1,
  );
  
  # Set an empty hashref for timezones we've seen already
  $self->{timezones} = {};
  return $self;
}

sub add_events {
  my ( $self, $events, $parameters ) = @_;
  
  # The events must be an arrayref, so make it one if it's not already
  $events = [ $events ] unless ref( $events ) eq "ARRAY";
  
  # Current date / time in UTC
  my $now_utc = DateTime->now( time_zone => "UTC" );
  
  # Hold the entries in an array
  my @entries = ();
  
  # Loop through the specified events
  foreach my $event ( @$events ) {
    my $timezone  = $event->{timezone};
    my $now_tz    = DateTime->now( time_zone => $timezone );
    #$event->{date_start_time}->set_time_zone( $timezone );
    
    # Create the timezone definition unless it exists already
    unless ( exists( $self->{timezones}{$timezone} ) ) {
      $self->{timezones}{$timezone} = 1;
      my $calendar_zone = Data::ICal::TimeZone->new( timezone => $timezone );
      $self->{calendar}->add_entry( $calendar_zone->definition );
    }
    
    my $entry = Data::ICal::Entry::Event->new;
    $entry->add_properties(
      uid             => $event->{uid},
      summary         => $event->{summary},
      status          => $event->{status},
      description     => $event->{description},
      dtstart         => DateTime::Format::ICal->format_datetime( $event->{date_start_time} ),
      duration        => DateTime::Format::ICal->format_duration( $event->{duration} ),
      location        => $event->{venue}->full_address(", "),
      geo             => sprintf( "%s;%s", $event->{venue}->coordinates_latitude, $event->{venue}->coordinates_longitude ),
      url             => $event->{url},
      created         => DateTime::Format::ICal->format_datetime( $now_utc ),
      "last-modified" => DateTime::Format::ICal->format_datetime( $now_utc ),
      dtstamp         => DateTime::Format::ICal->format_datetime( $now_utc ),
    );
    
    push( @entries, $entry );
  }
  
  $self->{calendar}->add_entries( @entries );
}

1;
