package TopTable::Controller::Events;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Events - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for viewing and administering events.  This is quite a broad umbrella and encompasses tournaments and meetings; the more specific aspects of these are handled in their own controllers.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.event") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    # Events listing
    path => $c->uri_for("/events"),
    label => $c->maketext("menu.text.event"),
  });
}

=head2 base

Chain base for getting the event identifier and checking it.

=cut

sub base :Chained("/") :PathPart("events") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $event = $c->model("DB::Event")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $event ) ) {
    # Encode the name for future use later in the chain (saves encoding multiple times, which is expensive)
    my $encoded_event_name = encode_entities( $event->name );
    
    # Event found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    $c->stash({
      event => $event,
      is_event => 1,
      subtitle1 => $encoded_event_name,
      encoded_event_name => $encoded_event_name,
    });
    
    # Push the events list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Event view page (current season)
      path => $c->uri_for_action("/events/view_current_season", [$event->url_key]),
      label => $encoded_event_name,
    });
  } else {
    # 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 base_list

Chain base for the list of events.  Matches /events

=cut

sub base_list :Chained("/") :PathPart("events") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view events
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1] );
  
  # Check the authorisation to edit events we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( event_edit event_delete event_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.events.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the events on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach("retrieve_paged", [1]);
  $c->stash({canonical_uri => $c->uri_for_action("/events/list_first_page")});
}

=head2 list_specific_page

List the events on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/events/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/events/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for events with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $events = $c->model("DB::Event")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $events->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/events/list_first_page",
    specific_page_action => "/events/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/events/list.ttkt",
    view_online_display => "Viewing events",
    view_online_link => 1,
    events => $events,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

Chained to the base class; all this does is check we're authorised to view events, then the more relevant funcionality is in methods chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( event_edit event_delete )], "", 0]);
}

=head2 view_current_season

Get and stash the current season (or last complete one if it doesn't exist) for the event view page.  End of chain for /events/*

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{encoded_event_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined($season);
    
  if ( defined( $season ) ) {
    $c->stash({
      season => $season,
      page_description => $c->maketext("description.events.view-current", $event_name, $site_name),
    });
    
    # Get the team's details for the season.
    $c->forward("get_event_season");
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Finalise the view routine - if there is no season to display, we'll just display the details without a season.
  # We only do this if we're actually showing a view page, not a delete page
  $c->detach("view_finalise") unless exists( $c->stash->{delete_screen} );
}

=head2 view_specific_season

View an event in a specific season.  Matches /events/*/seasons/* (End of chain)

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{encoded_event_name};
  
  # Validate the passed season ID
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key );
  my $encoded_season_name = encode_entities( $season->name );
  
  if ( defined($season) ) {
    # Stash the season and the fact that we requested it specifically
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $encoded_season_name,
      page_description => $c->maketext("description.events.view-specific", $event_name, $site_name, $encoded_season_name),
    });
  
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/events/view_seasons_first_page", [$event->url_key]),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/events/view_specific_season", [$event->url_key, $season->url_key]),
      label => $encoded_season_name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg( {error => "seasons.invalid-find-current"} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_event_season");
  
  # Finalise the view routine - if it's a meeting, we fire off to that routine
  if ( $event->event_type->id eq "meeting" ) {
    $c->detach(qw(TopTable::Controller::Root default));
  } else {
    $c->detach("view_finalise");
  }
}

=head2 get_event_season

Obtain a event's details for a given season.

=cut

sub get_event_season :Private {
  my ( $self, $c ) = @_;
  my ( $event, $season ) = ( $c->stash->{event}, $c->stash->{season} );
  $c->stash({event_season => $event->single_season( $season ) });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $encoded_event_name = $c->stash->{encoded_event_name};
  my $delete_screen = $c->stash->{delete_screen};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( $delete_screen ) {
    # Push edit link if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $encoded_event_name),
      link_uri => $c->uri_for_action("/events/edit", [$event->url_key]),
    }) if $c->stash->{authorisation}{event_edit};
    
    # Push a delete link if we're authorised and the event can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $encoded_event_name),
      link_uri => $c->uri_for_action("/events/delete", [$event->url_key]),
    }) if $c->stash->{authorisation}{event_delete} and $event->can_delete;
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/view_specific_season", [$event->url_key, $season->url_key])
    : $c->uri_for_action("/events/view_current_season", [$event->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  # Set up the template to use
  if ( $event->event_type->id eq "meeting" ) {
    $c->detach(qw(TopTable::Controller::Root default));
  } else {
    $c->stash({
      template => "html/events/view.ttkt",
      title_links => \@title_links,
      view_online_display => sprintf( "Viewing %s", $encoded_event_name ),
      view_online_link => 1,
    });
  }
}

=head2 view_seasons

Retrieve and display a list of seasons that this event has been run in.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{encoded_event_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template => "html/events/list-seasons.ttkt",
    page_description => $c->maketext("description.events.list-seasons", $event_name, $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/view_seasons_first_page", [$event->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the seasons on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  
  $c->stash({canonical_uri => $c->uri_for_action("/events/view_seasons_first_page", [$event->url_key])});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page

List the seasons on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $event = $c->stash->{event};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/events/view_seasons_first_page", [$event->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/events/view_seasons_specific_page", [$event->url_key, $page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for events with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $event = $c->stash->{event};
  
  my $seasons = $c->model("DB::Season")->page_records({
    event => $event,
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/events/view_seasons_first_page",
    page1_action_arguments => [$event->url_key],
    specific_page_action => "/events/view_seasons_specific_page",
    specific_page_action_arguments => [$event->url_key],
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/events/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $event->name ),
    view_online_link => 1,
    seasons => $seasons,
    subtitle2 => $c->maketext("menu.text.season"),
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Check that we are authorised to create events
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_create", $c->maketext("user.auth.create-events"), 1] );
  
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined( $current_season ) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("events.form.error.no-current-season", $c->maketext("admin.message.created"))} ) }) );
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add the pre-population if needed
    $tokeninput_options->{prePopulate} = [{id => $c->flash->{organiser}->id, name => $c->flash->{organiser}->display_name}] if defined( $c->flash->{organiser} );
    
    my $tokeninput_confs = [{
      script    => $c->uri_for("/people/search"),
      options   => encode_json( $tokeninput_options ),
      selector  => "organiser",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/events/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/events/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    venues => [$c->model("DB::Venue")->active_venues],
    event_types => [$c->model("DB::LookupEventType")->all_types],
    tournament_types => [$c->model("DB::LookupTournamentType")->all_types],
    current_season => $current_season,
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating events",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/events/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display the form to edit the event.

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $event = $c->stash->{event};
  my $encoded_event_name = $c->stash->{encoded_event_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to edit clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current;
    
  if ( defined( $season ) ) {
    $c->stash({season => $season});
    
    # Forward to the routine that stashes the team's season
    $c->forward("get_event_season");
  } else {
    # There is no current season, so we can't edit
    $c->response->redirect( $c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("events.edit.error.no-current-season") } ) }) );
    $c->detach;
    return;
  }
  
  # Set up the template to use
  if ( $event->event_type->id eq "meeting" ) {
    $c->detach(qw(TopTable::Controller::Root default));
  } else {
    $c->stash({
      template => "html/events/create-edit.ttkt",
      subtitle1 => $encoded_event_name,
      view_online_display => sprintf( "Viewing %s", $encoded_event_name ),
      view_online_link => 1,
    });
  }
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/edit", [$event->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form asking if the user really wants to delete the event.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $encoded_name = $c->stash->{encoded_event_name};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_delete", $c->maketext("user.auth.delete-events"), 1] );
  
  unless ( $event->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg( {error => sprintf( "You cannot delete %s, as it has teams assigned either in this season or in historical seasons.", $event->name )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $encoded_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/events/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $event->name ),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/delete", [$event->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating an event. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_create", $c->maketext("user.auth.create-events"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1] );
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion form and delete a club (if possible).

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $name = $event->name;
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_delete", $c->maketext("user.auth.delete-events"), 1]);
  
  my $response = $event->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/events", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["event", "delete", {id => undef}, $name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/events/view", [$event->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect( $redirect_uri );
  $c->detach;
  return;
}

=head2 process_form

Forwarded from docreate and doedit to do the event creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $event = $c->stash->{event};
  my @field_names = qw( name event_type tournament_type venue organiser date start_hour start_minute all_day finish_hour finish_minute );
  
  my $season = $c->model("DB::Season")->get_current;
  
  unless ( defined($season) ) {
    # Error, no current season so can't create or edit events
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("events.form.error.no-current-season", $c->maketext("admin.message.created"))} ) }) );
    $c->detach;
    return;
  }
  
  # The rest of the error checking is done in the Club model
  my $response = $c->model("DB::Event")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    event => $event,
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
  });
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $event = $response->{event};
    $redirect_uri = $c->uri_for_action("/events/view_current_season", [$event->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["event", $action, {id => $event->id}, $event->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/events/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/events/edit", [$event->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    map {$c->flash->{$_} = $response->{fields}{$_}} @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
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
