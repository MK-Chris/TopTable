package TopTable::Controller::Events;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Events - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for viewing and administering events.  This is quite a broad umbrella and encompasses tournaments and meetings, although meetings can also be handled as non-events in their own controller (intended for committee meetings that don't need to be linked as an event).

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

=head2 base_list

Chain base for the list of events.  Matches /events

=cut

sub base_list :Chained("/") :PathPart("events") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view events
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1] );
  
  # Check the authorisation to edit events we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[qw( event_edit event_delete event_create)], "", 0] );
  
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
  $page_number = 1 if !defined($page_number) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/events/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/events/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
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

=head2 base

Chain base for getting the event identifier and checking it.

=cut

sub base :Chained("/") :PathPart("events") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  my %params = (type => "tournament") if $c->stash->{tournament};
  my $event = $c->model("DB::Event")->find_id_or_url_key($id_or_key, \%params);
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( event_edit event_delete )], "", 0]);
  
  if ( defined($event) ) {
    # Encode the name for future use later in the chain (saves encoding multiple times, which is expensive)
    my $enc_name = encode_entities($event->name);
    
    # Event found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    $c->stash({
      event => $event,
      event_type => $event->event_type->id,
      is_event => 1,
      subtitle1 => $enc_name,
      enc_name => $enc_name,
    });
    
    # Push the events list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Event view page (current season)
      path => $c->uri_for_action("/events/view_current_season", [$event->url_key]),
      label => $enc_name,
    });
  } else {
    # 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 base_current_season

Just get the current season details for this event; we could then be viewing in general, or if it's a tournament we could be viewing specific rounds, so it's not just the view action that needs to chain off this.

=cut

sub base_current_season :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current_or_last;
    
  if ( defined($season) ) {
    $c->stash({season => $season});
    
    # Get the event's details for the season.
    $c->forward("get_event_season");
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_specific_season

Just get the current season details for this event; we could then be viewing in general, or if it's a tournament we could be viewing specific rounds, so it's not just the view action that needs to chain off this.

=cut

sub base_specific_season :Chained("base") :PathPart("seasons") :CaptureArgs(1) {
  my ( $self, $c, $season_id ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id);
    
  if ( defined($season) ) {
    # Stash the season and the fact that we requested it specifically
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      enc_season_name => $enc_season_name,
    });
    
    # Get the event's details for the season.
    $c->forward("get_event_season");
    
    push(@{$c->stash->{breadcrumbs}}, {
      # Event view page (current season)
      path => $c->uri_for_action("/events/view_specific_season", [$event->url_key, $season->url_key]),
      label => $enc_season_name,
    });
  } else {
    # Season doesn't exist
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 get_event_season

Obtain a event's details for a given season; forwarded from both base_current_season and base_specific_season, both of which stash the season we're going to look for.

=cut

sub get_event_season :Private {
  my ( $self, $c ) = @_;
  my ( $event, $season ) = ( $c->stash->{event}, $c->stash->{season} );
  my $event_season = $event->single_season($season);
  $c->stash({event_season => $event_season});
  
  if ( defined($event_season) ) {
    $c->stash({event_detail => $event_season->event_detail});
  }
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Check that we are authorised to create events
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["event_create", $c->maketext("user.auth.create-events"), 1] );
  
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("events.form.error.no-current-season", $c->maketext("admin.message.created"))})}));
    $c->detach;
    return;
  }
  
  # Stash the form action, this is dependent on the form
  $c->stash({
    form_action => $c->uri_for_action("/events/do_create"),
    view_online_display => sprintf("Creating events"),
    subtitle2 => $c->maketext("admin.create"),
    action => "create",
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/events/create"),
    label => $c->maketext("admin.create"),
  });
  
  $c->detach("prepare_form_event", [qw( create )]);
}

=head2 edit

Display the form to edit the event.

=cut

sub edit :Chained("base_current_season") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to edit clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);  # Try to find the current season (or the last completed season if there is no current season)
  
  my $season = $c->stash->{season};
    
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Stash the form action, this is dependent on the form
  $c->stash({
    form_action => $c->uri_for_action("/events/do_edit", [$event->url_key]),
    view_online_display => sprintf("Editing %s", $enc_name),
    subtitle2 => $c->maketext("admin.edit"),
    action => "edit",
    #subtitle1 => $enc_name,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/events/edit"),
    label => $c->maketext("admin.edit"),
  });
  
  $c->detach("prepare_form_event", [qw( edit )]);
}

=head2 prepare_form_event

Process the event creation / edit form.  Private, forwarded to from the create / edit actions.

=cut

sub prepare_form_event :Private {
  my ( $self, $c, $action ) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Add the pre-population if needed
  my $organiser;
  if ( $c->flash->{show_flashed} ) {
    $organiser = $c->flash->{organiser};
  } else {
    if ( defined(my $event_season = $c->stash->{event_season}) ) {
      # If there's a currently defined team season, use the captain from that
      $organiser = $event_season->organiser;
    }
  }
  
  # First setup the function arguments
  my $tokeninput_options = {
    jsonContainer => "json_search",
    tokenLimit => 1,
    hintText => $c->maketext("person.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  $tokeninput_options->{prePopulate} = [{id => $organiser->url_key, name => $organiser->display_name}] if defined($organiser);
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/people/search"),
    options => encode_json($tokeninput_options),
    selector => "organiser",
  }];
  
  # Set up the template to use
  $c->stash({
    template => "html/events/create-edit.ttkt",
    view_online_link => 0,
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
    tokeninput_confs => $tokeninput_confs,
    venues => [$c->model("DB::Venue")->active_venues],
    event_types => [$c->model("DB::LookupEventType")->all_types],
    tournament_types => [$c->model("DB::LookupTournamentType")->all_types],
    team_match_templates => [$c->model("DB::TemplateMatchTeam")->all_templates],
    ind_match_templates => [$c->model("DB::TemplateMatchIndividual")->all_templates],
    rank_templates => [$c->model("DB::TemplateLeagueTableRanking")->all_templates],
  });
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( event edit )]);
}

=head2 delete

Display the form asking if the user really wants to delete the event.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_delete", $c->maketext("user.auth.delete-events"), 1]);
  
  unless ( $event->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.delete.error.cannot-delete", $enc_name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/events/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $event->name),
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
  $c->detach("process_form", [qw( event create )]);
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

=head2 view_current_season

Get and stash the current season (or last complete one if it doesn't exist) for the event view page.  End of chain for /events/*

=cut

sub view_current_season :Chained("base_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_name};
  
  # Check we can view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1]);
  
  $c->stash({page_description => $c->maketext("description.events.view-current", $event_name, $site_name)});
  
  # Finalise the view routine - if there is no season to display, we'll just display the details without a season.
  # We only do this if we're actually showing a view page, not a delete page
  $c->detach("view_finalise") unless $c->stash->{delete_screen};
}

=head2 view_specific_season

View an event in a specific season.  Matches /events/*/seasons/* (End of chain)

=cut

sub view_specific_season :Chained("base_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_name};
  
  # Check we can view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1]);
  
  # Finalise the view routine - if there is no season to display, we'll just display the details without a season.
  # We only do this if we're actually showing a view page, not a delete page
  $c->detach("view_finalise") unless $c->stash->{delete_screen};
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $enc_name = $c->stash->{enc_name};
  my $delete_screen = $c->stash->{delete_screen};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( $delete_screen ) {
    # Push edit link if we are authorised
    if ( $c->stash->{authorisation}{event_edit} ) {
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
        text => $c->maketext("admin.edit-object", $enc_name),
        link_uri => $c->uri_for_action("/events/edit", [$event->url_key]),
      });
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0037-Notepad-icon-32.png"),
        text => $c->maketext("admin.edit-object-details", $enc_name),
        link_uri => $c->uri_for_action("/events/edit_details", [$event->url_key]),
      }) if $event->event_type->id eq "meeting" and $event->can_edit_details;
    }
    
    # Push a delete link if we're authorised and the event can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/events/delete", [$event->url_key]),
    }) if $c->stash->{authorisation}{event_delete} and $event->can_delete;
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/view_specific_season", [$event->url_key, $season->url_key])
    : $c->uri_for_action("/events/view_current_season", [$event->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  # Set up the template to use - meetings have their own viewing template
  my @external_scripts = (
    $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
    $c->uri_for("/static/script/standard/responsive-tabs.js"),
    $c->uri_for("/static/script/standard/vertical-table.js"),
    $c->uri_for("/static/script/standard/option-list.js"),
  );
  
  my @external_styles = (
    $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
    $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
  );
  
  my $template_path;
  if ( $event->event_type->id eq "meeting" ) {
    my $meeting = $event_season->get_meeting;
    $template_path = "events/view-meeting.ttkt";
    
    $c->stash({
      meeting => $meeting,
      attendees => [$meeting->attendees],
      apologies => [$meeting->apologies],
    });
  } elsif ( $event->event_type->id eq "single_tournament" ) {
    # Grab the tournament details
    my $tournament = $event_season->event_detail;
    $template_path = "events/tournaments/view.ttkt";
    my @rounds = $tournament->rounds;
    
    $c->stash({
      tournament => $tournament,
      rounds => \@rounds,
    });
    
    if ( $tournament->has_group_round ) {
      # Get the ranking template for the table - we need this before we stash because one of the scripts depends
      # on whether or not we're assigning points (as there's an extra column if we are)
      my $ranking_template = $rounds[0]->rank_template;
      
      my $table_view_js = $ranking_template->assign_points
        ? $c->uri_for("/static/script/tables/view-points.js")
        : $c->uri_for("/static/script/tables/view-no-points.js");
      
      push(@external_scripts,
        $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
        $table_view_js,
      );
      
      push(@external_styles,
        $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      );
      
      $c->stash({
        group_round => $rounds[0],
        groups => [$tournament->find_round_by_number_or_url_key(1)->groups],
        ranking_template => $ranking_template,
      });
    }
  }
  
  $c->stash({
    template => "html/$template_path",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_name),
    view_online_link => 1,
    external_scripts => \@external_scripts,
    external_styles => \@external_styles,
  });
}

=head2 rounds_current_season, rounds_specific_season

Return the rounds for the current season - this obviously only works if the event is a tournament, otherwise it will default to a 404 error.

This just forwards to a get_round function that's common to the specific and current season routines.

=cut

sub rounds_current_season :Chained("base_current_season") :PathPart("rounds") :CaptureArgs(1) {
  my ( $self, $c, $round_id ) = @_;
  $c->forward("rounds", [$round_id]);
}

sub rounds_specific_season :Chained("base_specific_season") :PathPart("rounds") :CaptureArgs(1) {
  my ( $self, $c, $round_id ) = @_;
  $c->forward("rounds", [$round_id]);
}

sub rounds :Private {
  my ( $self, $c, $round_id ) = @_;
  my $event = $c->stash->{event};
  my $event_type = $c->stash->{event_type};
  
  if ( $event_type ne "single_tournament" ) {
    # 404 - event is not a tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $tournament->find_round_by_number_or_url_key($round_id);
  
  if ( !defined($round) ) {
    # 404 - round doesn't exist
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  $c->stash({round => $round});
}

=head2 view_round_current_season, view_round_specific_season

Page to view the rounds for the given season.

This just forwards to a view_rounds private function that's common to the specific and current season routines and shows the page for viewing those rounds.

=cut

sub view_round_current_season :Chained("rounds_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $enc_name = $c->stash->{enc_name};
  my $round = $c->stash->{round};
  
  $c->stash({
    subtitle1 => $round->name,
    subtitle2 => $enc_name,
  });
  
  $c->forward("view_round");
}

sub view_round_specific_season :Chained("rounds_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $enc_name = $c->stash->{enc_name};
  my $round = $c->stash->{round};
  my $enc_season_name = $c->stash->{enc_season_name};
  
  $c->stash({
    subtitle1 => $round->name,
    subtitle2 => $enc_name,
    subtitle3 => $enc_season_name,
  });
  
  $c->forward("view_round");
}

=head2 view_round

Show a page to view the round.

=cut

sub view_round :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $tournament = $c->stash->{event_detail};
  my $enc_name = $c->stash->{enc_name};
  my $round = $c->stash->{round};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  if ( $c->stash->{authorisation}{event_edit} ) {
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_name),
      link_uri => $c->uri_for_action("/events/edit_round", [$event->url_key, $round->url_key]),
    });
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/view_round_current_season", [$event->url_key, $season->url_key, $round->url_key])
    : $c->uri_for_action("/events/view_round_current_season", [$event->url_key, $round->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  my $template;
  if ( $round->group_round ) {
    $c->stash({groups => [$round->groups]});
    $template = "view-groups";
  } else {
    $template = "view";
  }
  
  $c->stash({
    template => "html/events/tournaments/rounds/$template.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_name),
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/standard/responsive-tabs.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    ],
  });
}

=head2 edit_round

Display the form to edit a round.  Rounds are auto-created, but can be edited.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub edit_round :Chained("rounds_current_season") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  my $enc_name = $c->stash->{enc_name};
  my $season = $c->stash->{season};
    
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  $c->stash({
    template => "html/events/tournaments/rounds/edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/templates/match/individual/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for_action("/events/do_edit_round", [$event->url_key, $round->url_key]),
    team_match_templates => [$c->model("DB::TemplateMatchTeam")->all_templates],
    ind_match_templates => [$c->model("DB::TemplateMatchIndividual")->all_templates],
    rank_templates => [$c->model("DB::TemplateLeagueTableRanking")->all_templates],
    venues => [$c->model("DB::Venue")->active_venues],
    view_online_display => "Editing tournament rounds",
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/templates/match/individual/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 do_edit_round

Process the form for editing the round for a tournament.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub do_edit_round :Chained("rounds_current_season") :PathPart("do-edit-round") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( round edit )]);
}

=head2 groups_current_season, groups_specific_season

Return the groups for the current season in a given tournament round - this obviously only works if the event is a tournament, otherwise it will default to a 404 error.

This just forwards to a groups function that's common to the specific and current season routines.

=cut

sub groups_current_season :Chained("rounds_current_season") :PathPart("groups") :CaptureArgs(1) {
  my ( $self, $c, $group_id ) = @_;
  $c->forward("groups", [$group_id]);
}

sub groups_specific_season :Chained("rounds_specific_season") :PathPart("groups") :CaptureArgs(1) {
  my ( $self, $c, $group_id ) = @_;
  $c->forward("groups", [$group_id]);
}

sub groups :Private {
  my ( $self, $c, $group_id ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  my $event_type = $c->stash->{event_type};
  
  if ( $event_type ne "single_tournament" ) {
    # 404 - event is not a tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  my $tournament = $c->stash->{event_season}->event_detail;
  my $group = $round->find_group_by_id_or_url_key($group_id);
  
  if ( !defined($group) ) {
    # 404 - round doesn't exist
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  $c->stash({group => $group});
}

=head2 view_group_current_season, view_group_specific_season

Page to view the rounds for the given season.

This just forwards to a view_rounds private function that's common to the specific and current season routines and shows the page for viewing those rounds.

=cut

sub view_group_current_season :Chained("groups_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_group");
}

sub view_group_specific_season :Chained("groups_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_group");
}

sub view_group :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $enc_name = $c->stash->{enc_name};
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  if ( $c->stash->{authorisation}{event_edit} ) {
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_name),
      link_uri => $c->uri_for_action("/events/group_edit", [$event->url_key, $round->url_key, $group->url_key]),
    });
    
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/reorder-32.png"),
      text => $c->maketext("admin.fixtures-grid.set-positions", $enc_name),
      link_uri => $c->uri_for_action("/events/group_grid_positions", [$event->url_key, $round->url_key, $group->url_key]),
    }) if $group->can_set_grid_positions;
    
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/fixtures-32.png"),
      text => $c->maketext("admin.fixtures-grid.create-fixtures", $enc_name),
      link_uri => $c->uri_for_action("/events/group_create_matches", [$event->url_key, $round->url_key, $group->url_key]),
    }) if $group->can_create_fixtures;
    
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/fixturesdel-32.png"),
      text => $c->maketext("admin.fixtures-grid.delete-fixtures", $enc_name),
      link_uri => $c->uri_for_action("/events/group_delete_matches", [$event->url_key, $round->url_key, $group->url_key]),
    }) if $group->can_delete_fixtures;
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/view_group_specific_season", [$event->url_key, $season->url_key, $round->url_key, $group->url_key])
    : $c->uri_for_action("/events/view_group_current_season", [$event->url_key, $round->url_key, $group->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  # Get the ranking template for the table - we need this before we stash because one of the scripts depends
  # on whether or not we're assigning points (as there's an extra column if we are)
  my $ranking_template = $round->rank_template;
  
  my $table_view_js = $ranking_template->assign_points
    ? $c->uri_for("/static/script/tables/view-points.js")
    : $c->uri_for("/static/script/tables/view-no-points.js");
  
  $c->stash({
    template => "html/events/tournaments/rounds/groups/view.ttkt",
    subtitle2 => $round->name,
    subtitle3 => $group->name,
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_name),
    view_online_link => 1,
    entrants => [$group->get_entrants_in_table_order],
    last_updated => $group->get_tables_last_updated_timestamp,
    ranking_template => $ranking_template,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/standard/responsive-tabs.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $table_view_js,
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
}

=head2 group_create

Show the form to create a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow creation of groups from previous seasons.

=cut

sub group_create :Chained("rounds_current_season") :PathPart("groups/create") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  my $season = $c->stash->{season};
    
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  $c->detach("prepare_form_group", [qw( create )]);
}

=head2 group_edit

Show the form to edit a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow editing of groups from previous seasons.

=cut

sub group_edit :Chained("groups_current_season") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  my $season = $c->stash->{season};
    
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  $c->detach("prepare_form_group", [qw( edit )]);
}

=head2 prepare_form_group

Prepare the group create / edit form.  Forwarded from both the create and edit actions.

=cut

sub prepare_form_group :Private {
  my ( $self, $c, $action ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  my $flashed = $c->flash->{show_flashed} || 0;
  
  # Setup group members tokeninput
  my ( $tokeninput_hint, $token_search_url );
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  if ( $tournament->entry_type->id eq "team" ) {
    $tokeninput_hint = $c->maketext("teams.tokeninput.type");
    $token_search_url = $c->uri_for("/teams/search");
  } elsif ( $tournament->entry_type->id eq "singles" ) {
    $tokeninput_hint = $c->maketext("person.tokeninput.type");
    $token_search_url = $c->uri_for("/people/search");
  }
  
  my $members_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => $tokeninput_hint,
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  my ( $members, $form_action );
  if ( $action eq "create" ) {
    # If we're creating, the members could be flashed
    $members = $flashed ? $c->flash->{members} : undef;
    $form_action = $c->uri_for_action("/events/group_do_create", [$event->url_key, $round->url_key]);
  } else {
    # Editing, so we will either have flashed members or members from the group
    $members = $flashed ? $c->flash->{members} : [$group->members];
    $form_action = $c->uri_for_action("/events/group_do_edit", [$event->url_key, $round->url_key, $group->url_key]);
  }
  
  if ( $entry_type eq "doubles" ) {
    # Doubles population is more complex
    ## TODO
  } else {
    $members_tokeninput_options->{prePopulate} = [map({
      id => $_->id,
      name => $entry_type eq "team" ? encode_entities($_->display_name) : encode_entities($_->full_name),
    }, @{$members})] if ref($members) eq "ARRAY" and scalar @{$members};
  }
  
  my $tokeninput_confs = [{
    script => $token_search_url,
    options => encode_json($members_tokeninput_options),
    selector => "members1",
  }];
  
  $c->stash({tokeninput_confs => $tokeninput_confs});
  
  # Stash the details for the form
  $c->stash({
    template => "html/events/tournaments/rounds/groups/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/tournaments/create-edit-group.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    form_action => $form_action,
    tournament => $tournament,
    view_online_display => "Editing tournament rounds",
    view_online_link => 0,
    fixtures_grids => [$c->model("DB::FixturesGrid")->all_grids],
  });
}

=head2 group_do_create

Process the form to create a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub group_do_create :Chained("rounds_current_season") :PathPart("groups/do-create") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  my $season = $c->stash->{season};
    
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( group create )]);
}

=head2 group_do_edit

Process the form to create a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub group_do_edit :Chained("rounds_current_season") :PathPart("groups/do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( group edit )]);
}

=head2 group_grid_positions

Set participants of a group into their grid positions.

=cut

sub group_grid_positions :Chained("groups_current_season") :PathPart("grid-positions") {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check the season hasn't had matches created already
  if ( $group->matches->count ) {
    # Error, matches set already
    $c->response->redirect($c->uri_for_action("/events/view_group_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.teams.error.matches-already-set")})}));
    $c->detach;
    return;
  }
  
  if ( !defined($group->fixtures_grid) ) {
    # Error, no grid for this group
    $c->response->redirect($c->uri_for_action("/events/view_group_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.teams.error.no-grid-assigned")})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/events/tournaments/rounds/groups/grid-positions.ttkt",
    subtitle3 => $c->maketext("fixtures-grids.allocate-teams"),
    external_scripts => [
      $c->uri_for("/static/script/events/tournaments/rounds/groups/grid-positions.js"),
    ],
    form_action => $c->uri_for_action("/events/group_set_grid_positions", [$event->url_key, $round->url_key, $group->url_key]),
    view_online_display => "Allocating teams for group " . $group->name,
    view_online_link => 0,
    entrants => [$group->get_entrants_in_grid_position_order],
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/group_grid_positions", [$event->url_key, $round->url_key, $group->url_key]),
    label => $c->maketext("fixtures-grids.allocate-teams"),
  });
}

=head2 group_set_grid_positions

Process the form to set participants of a group into their grid positions.

=cut

sub group_set_grid_positions :Chained("groups_current_season") :PathPart("set-grid-positions") {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( group positions )]);
}

=head2 group_create_matches

Show the form to create the matches for a group.

=cut

sub group_create_matches :Chained("groups_current_season") :PathPart("create-matches") {
  my ( $self, $c ) = @_;
}

=head2 group_do_create_matches

Process the form to create the matches for a group.

=cut

sub group_do_create_matches :Chained("groups_current_season") :PathPart("do-create-matches") {
  my ( $self, $c ) = @_;
}

=head2 group_delete_matches

Show the form to delete the matches for a group.

=cut

sub group_delete_matches :Chained("groups_current_season") :PathPart("delete-matches") {
  my ( $self, $c ) = @_;
}

=head2 group_do_delete_matches

Process the form to create the matches for a group.

=cut

sub group_do_delete_matches :Chained("groups_current_season") :PathPart("do-delete-matches") {
  my ( $self, $c ) = @_;
}

=head2 view_seasons

Retrieve and display a list of seasons that this event has been run in.

=cut

sub view_seasons :Chained("base") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_name};
  
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
  $c->detach("retrieve_paged_seasons", [1]);
}

=head2 view_seasons_specific_page

List the seasons on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $event = $c->stash->{event};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/events/view_seasons_first_page", [$event->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/events/view_seasons_specific_page", [$event->url_key, $page_number])});
  }
  
  $c->detach("retrieve_paged_seasons", [$page_number]);
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
    view_online_display => sprintf("Viewing seasons for ", $event->name),
    view_online_link => 1,
    seasons => $seasons,
    subtitle2 => $c->maketext("menu.text.season"),
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 process_form

Forwarded from docreate and doedit to do the event creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $type, $action ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  my $log_obj;
  my ( @field_names, @processed_field_names ) = ();
  my $response = {}; # Store the response from the form processing
  
  if ( $type eq "event" ) {
    my @field_names = qw( name event_type tournament_type venue organiser start_hour start_minute all_day end_hour end_minute default_team_match_template default_individual_match_template round_name round_group round_group_rank_template round_team_match_template round_individual_match_template round_venue );
    my @processed_field_names = qw( name event_type tournament_type venue organiser start_date start_hour start_minute all_day end_date end_hour end_minute default_team_match_template default_individual_match_template round_name round_group round_group_rank_template round_team_match_template round_individual_match_template round_venue );
    
    # The rest of the error checking is done in the Club model
    $response = $c->model("DB::Event")->create_or_edit($action, {
      logger => sub{ my $level = shift; $c->log->$level( @_ ); },
      event => $event,
      start_date => defined($c->req->params->{start_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{start_date}) : undef,
      end_date => defined($c->req->params->{end_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{end_date}) : undef,
      round_date => defined($c->req->params->{round_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{round_date}) : undef,
      map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
    });
  } elsif ( $type eq "group" ) {
    # Group forms to process
    @field_names = qw( name manual_fixtures fixtures_grid automatic_qualifiers );
    @processed_field_names = @field_names;
    
    my @members = ();
    foreach my $key ( keys %{$c->req->params} ) {
      push(@members, [split(",", $c->req->params->{$key})]) if $key =~ /^members\d+$/;
    }
    
    if ( $action eq "create" or $action eq "edit" ) {
      # Create or edit group
      @field_names = qw( name manual_fixtures fixtures_grid automatic_qualifiers );
      @processed_field_names = @field_names;
      
      my @members = ();
      foreach my $key ( keys %{$c->req->params} ) {
        push(@members, [split(",", $c->req->params->{$key})]) if $key =~ /^members\d+$/;
      }
      
      $response = $round->create_or_edit_group($group, {
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        members => \@members,
        map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
      });
    } elsif ( $action eq "positions" ) {
      # Set grid positions for group
      @field_names = qw( );
      @processed_field_names = ( @field_names, qw( grid_positions ) );
      
      $response = $group->set_grid_positions({
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        grid_positions => [split(",", $c->req->params->{grid_positions})],
        map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
      });
    }
  }
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  # Work out redirection URLs - this can only be done after we have the response
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    my %log_ids = ();
    if ( $type eq "event" ) {
      $event = $response->{event};
      $log_obj = $event;
      
      %log_ids = (id => $event->id);
      $redirect_uri = $c->uri_for_action("/events/view_current_season", [$event->url_key], {mid => $mid});
    } elsif ( $type eq "group" ) {
      $group = $response->{group} if $action eq "create";
      $log_obj = $group;
      %log_ids = (id => $event->id, round => $group->tournament_round->id, group => $group->id);
      
      # Set the action with a suffix, for event logging
      $action = "group-$action";
      $redirect_uri = $c->uri_for_action("/events/view_group_current_season", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
    }
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["event", $action, \%log_ids, $event->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    $c->log->debug("action: $action");
    if ( $type eq "event" ) {
      if ( $action eq "create" ) {
        $redirect_uri = $c->uri_for("/events/create", {mid => $mid});
      } else {
        $redirect_uri = $c->uri_for_action("/events/edit", [$event->url_key], {mid => $mid});
      }
    } elsif ( $type eq "group" ) {
      if ( $action eq "create" ) {
        $redirect_uri = $c->uri_for_action("/events/group_create", [$event->url_key, $round->url_key], {mid => $mid});
      } elsif ( $action eq "edit" ) {
        $redirect_uri = $c->uri_for_action("/events/group_edit", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
      } elsif ( $action eq "positions" ) {
        $redirect_uri = $c->uri_for_action("/events/group_grid_positions", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
      }
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    map {$c->flash->{$_} = $response->{fields}{$_}} @processed_field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 edit_details

Show a form to edit the details of a 

=cut

sub edit_details :Chained("base") :PathPart("edit-details") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Check we can edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);  # Try to find the current season (or the last completed season if there is no current season)
  
  # Check we have a current season to edit (we can't edit archived seasons' events)
  my $current_season = $c->model("DB::Season")->get_current;
    
  if ( defined($current_season) ) {
    # Forward to the routine that stashes the event's season details
    $c->stash({season => $current_season});
    $c->forward("get_event_season");
  } else {
    # There is no current season, so we can't edit
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  my $event_season = $c->stash->{event_season};
  
  if ( !defined($event_season) ) {
    # No season created for this event
    $c->response->redirect($c->uri_for("/events/edit", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit-details.error.no-event-this-season", $enc_name, encode_entities($current_season->name))})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => sprintf("html/events/edit-details-%s.ttkt", $event->event_type->id),
    form_action => $c->uri_for_action("/events/do_edit_details", [$event->url_key]),
  });
  
  $c->detach(sprintf("edit_%s", $event->event_type->id));
}

=head2 edit_meeting

Forwarded from the details routine when the event is a meeting.

=cut


sub edit_meeting :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $event_season = $c->stash->{event_season};
  my $enc_name = $c->stash->{enc_name};
  
  # Attendees / apologies
  my $attendees_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("person.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  my $apologies_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("person.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Pre-population
  my ( $attendees, $apologies );
  if ( $c->flash->{show_flashed} ) {
    $attendees = $c->flash->{attendees};
    $apologies = $c->flash->{apologies};
  } else {
    $attendees = [$event_season->attendees];
    $apologies = [$event_season->apologies];
  }
  
  $attendees = [$attendees] unless ref($attendees) eq "ARRAY";
  $apologies = [$apologies] unless ref($apologies) eq "ARRAY";
  
  if ( scalar( @{$attendees} ) ) {
    foreach my $attendee ( @{$attendees} ) {
      # Depending whether we've flashed the value or taken it from the database, this will be the person object directly
      # or the meeting attendee object, in which case we need to retrieve the person object.
      my $attendee_person = ref( $attendee ) eq "TopTable::DB::Model::Person" ? $attendee : $attendee->person;
      
      push(@{$attendees_tokeninput_options->{prePopulate}}, {
        id => $attendee_person->id,
        name => encode_entities($attendee_person->display_name),
      });
    }
  }
  
  if ( scalar @{$apologies} ) {
    foreach my $apology ( @{$apologies} ) {
      # Depending whether we've flashed the value or taken it from the database, this will be the person object directly
      # or the meeting attendee object, in which case we need to retrieve the person object.
      my $apology_person = ref($apology) eq "TopTable::DB::Model::Person" ? $apology : $apology->person;
      
      push(@{$apologies_tokeninput_options->{prePopulate}}, {
        id => $apology_person->id,
        name => encode_entities($apology_person->display_name),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/people/search"),
    options => encode_json($attendees_tokeninput_options),
    selector => "attendees",
  }, {
    script => $c->uri_for("/people/search"),
    options => encode_json($apologies_tokeninput_options),
    selector => "apologies",
  }];
  
  $c->stash({
    view_online_display => sprintf("Editing details for %s", $enc_name),
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/ckeditor5/ckeditor.js"),
      #$c->uri_for("/static/script/events/edit-details-meeting.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    scripts => [qw( tokeninput-standard ckeditor-iframely-standard )],
    ckeditor_selectors => [qw( minutes agenda )],
    tokeninput_confs => $tokeninput_confs,
  });
}

=head2 edit_single_tournament

Forwarded from the details routine when the event is a single (not multi) tournament.

=cut

sub edit_single_tournament :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $event_season = $c->stash->{event_season};
  my $enc_name = $c->stash->{enc_name};
  
  $c->stash({
    view_online_display => sprintf("Editing details for %s", $enc_name),
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/ckeditor5/ckeditor.js"),
      #$c->uri_for("/static/script/events/edit-details-meeting.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
  });
}

sub do_edit_details :Chained("base") :PathPart("do-edit-details") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Check we can edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);  # Try to find the current season (or the last completed season if there is no current season)
  
  # Check we have a current season to edit (we can't edit archived seasons' events)
  my $current_season = $c->model("DB::Season")->get_current;
    
  if ( defined($current_season) ) {
    # Forward to the routine that stashes the event's season details
    $c->stash({season => $current_season});
    $c->forward("get_event_season");
  } else {
    # There is no current season, so we can't edit
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  my $event_season = $c->stash->{event_season};
  
  if ( !defined($event_season) ) {
    # No season created for this event
    $c->response->redirect($c->uri_for("/events/edit", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit-details.error.no-event-this-season", $enc_name, encode_entities($current_season->name))})}));
    $c->detach;
    return;
  }
  
  my $response = $c->forward(sprintf("do_edit_%s", $event->event_type->id));
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $redirect_uri = $c->uri_for_action("/events/view_current_season", [$event->url_key], {mid => $mid});
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["event", "edit", {id => $event->id}, $event->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    $redirect_uri = $redirect_uri = $c->uri_for("/events/details", [$event->urlkey], {mid => $mid});
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{$_} = $response->{fields}{$_} foreach @{$c->stash->{processed_field_names}};
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

sub do_edit_meeting :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $event_season = $c->stash->{event_season};
  my @field_names = qw( agenda minutes );
  $c->stash({processed_field_names => [qw( attendees apologies agenda minutes )]});
  
  # Call the DB routine to do the error checking and creation
  my $response = $event_season->set_details({
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    attendees => [split(",", $c->req->params->{attendees})],
    apologies => [split(",", $c->req->params->{apologies})],
    map {$_ => $c->req->params->{$_}} @field_names, # All the rest of the fields from the form - put this last because otherwise the following elements are seen as part of the map
  });
  
  return $response;
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
