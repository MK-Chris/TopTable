package TopTable::Controller::SystemEventLog;
use Moose;
use namespace::autoclean;
use Data::Dumper::Concise;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered event-log, so the URLs start /event-log.
__PACKAGE__->config(namespace => "event-log");

=head1 NAME

TopTable::Controller::SystemEventLog - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.system-event-log")});
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/event-log"),
    label => $c->maketext("menu.text.system-event-log"),
  });
}

=head2 base

Base routine for the event log listing.  Checks the authorisation.

=cut

sub base :Chained("/") :PathPart("event-log") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["system_event_log_view_all", "view administrative updates", 0] );
  
  # Page description
  $c->stash({page_description => $c->maketext("description.event-log.list", $site_name)});
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

Set the page number to 1 and forward to the routine that retrieves the events.

=cut

sub list_first_page :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Retrieve the events, specifying page 1
  $c->detach("retrieve_paged", [1]);
}

=head2 list_specific_page

Check the page number, then forward to the routine that retrieves the events.

=cut

sub list_specific_page :Chained("base") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  if ( !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1 ) {
    $page_number = 1;
    
    # Stash a warning
    if ( exists( $c->stash->{status_msg}{warning} ) and $c->stash->{status_msg}{warning} ) {
      $c->stash->{status_msg}{warning} .= "\nInvalid page specified: $page_number.  Defaulting to page 1.";
    } else {
      $c->stash->{status_msg}{warning} = "Invalid page specified: $page_number.  Defaulting to page 1.";
    }
  }
  
  # Retrieve the events, specifying our page number
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

List the events on the specified page.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  # Work out if we can view all events or just public ones
  my $public_events_only = 1;
  $public_events_only = 0 if $c->stash->{authorisation}{system_event_log_view_all} and !exists( $c->request->parameters->{"suppress-private"} );
  
  my $event_logs = $c->model("DB::SystemEventLog")->page_records({
    public_events_only  => $public_events_only,
    page_number         => $page_number,
    results_per_page    => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $event_logs->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/event-log/list_first_page",
    specific_page_action  => "/event-log/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/event-log/list.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/qtip/jquery.qtip.min.js"),
      $c->uri_for("/static/script/standard/qtip.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/event-viewer/view.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/qtip/jquery.qtip.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    view_online_display => "Viewing event log",
    view_online_link    => 1,
    event_logs          => $event_logs,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2

=head2 add_event

Private sub to add events to the event log.

=cut

sub add_event :Private {
  my ( $self, $c ) = @_;
  my ( $object_type, $event_type, $object_ids, $object_name ) = @{ $c->request->arguments };
  
  my $current_datetime = $c->datetime_tz({time_zone => "UTC"});
  
  # Set the event log
  my $details = $c->model("DB::SystemEventLog")->set_event_log({
    object_type   => $object_type,
    event_type    => $event_type,
    object_ids    => $object_ids,
    object_name   => $object_name,
    user          => $c->user,
    ip_address    => $c->request->address,
    current_time  => $current_datetime,
    logger        => sub{ my $level = shift; $c->log->$level( @_ ) },
  });
  
  return $details;
}

=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
