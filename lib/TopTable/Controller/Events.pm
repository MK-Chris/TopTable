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
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_view", $c->maketext("user.auth.view-events"), 1]);
  
  # Check the authorisation to edit events we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( event_edit event_delete event_create)], "", 0]);
  
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
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/events/list_first_page",
    specific_page_action => "/events/list_specific_page",
    current_page => $page_number,
  }]);
  
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
    my $enc_event_name = encode_entities($event->name);
    
    # Event found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    $c->stash({
      event => $event,
      event_type => $event->event_type->id,
      is_event => 1,
      subtitle1 => $enc_event_name,
      enc_event_name => $enc_event_name,
    });
    
    # Push the events list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Event view page (current season)
      path => $c->uri_for_action("/events/view_current_season", [$event->url_key]),
      label => $enc_event_name,
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
  my $event_name = $c->stash->{enc_event_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      subtitle2 => $enc_season_name,
    });
    
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
  my $event_name = $c->stash->{enc_event_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id);
    
  if ( defined($season) ) {
    # Stash the season and the fact that we requested it specifically
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      enc_season_name => $enc_season_name,
      subtitle2 => $enc_season_name,
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
  
  my $event_season = $event->get_season($season);
  $c->stash({event_season => $event_season});
  
  if ( defined($event_season) ) {
    $c->stash({event_detail => $event_season->event_detail});
    
    # Add a warning, but not for meetings
    $c->add_event_test_msg unless $event_season->event->event_type->id eq "meeting";
  }
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Check that we are authorised to create events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_create", $c->maketext("user.auth.create-events"), 1]);
  
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
    season => $current_season,
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
  
  my $event_season = $event->get_season($season);
  
  # Stash the form action, this is dependent on the form
  $c->stash({
    form_action => $c->uri_for_action("/events/do_edit", [$event->url_key]),
    view_online_display => sprintf("Editing %s", $enc_event_name),
    subtitle2 => $c->maketext("admin.edit"),
    action => "edit",
    new_season => defined($event_season) ? 0 : 1, # Flag to show first round fields if this is going to be a new season instance
    #subtitle1 => $enc_event_name,
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
      $c->uri_for("/static/script/events/tournaments/rounds/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    create_event => 1,
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_delete", $c->maketext("user.auth.delete-events"), 1]);
  
  unless ( $event->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.delete.error.cannot-delete", $enc_event_name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $enc_event_name,
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
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_create", $c->maketext("user.auth.create-events"), 1]);
  
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
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
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
  my $event_name = $c->stash->{enc_event_name};
  
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
  my $event_name = $c->stash->{enc_event_name};
  
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
  my $event_type = $event->event_type->id;
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $delete_screen = $c->stash->{delete_screen};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( $delete_screen ) {
    # Push edit link if we are authorised
    if ( $c->stash->{authorisation}{event_edit} ) {
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
        text => $c->maketext("admin.edit-object", $enc_event_name),
        link_uri => $c->uri_for_action("/events/edit", [$event->url_key]),
      });
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0037-Notepad-icon-32.png"),
        text => $c->maketext("admin.edit-object-details", $enc_event_name),
        link_uri => $c->uri_for_action("/events/edit_details", [$event->url_key]),
      }) if $event_type eq "meeting" and $event->can_edit_details;
    }
    
    # Push a delete link if we're authorised and the event can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_event_name),
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
    $c->uri_for("/static/script/standard/vertical-table.js"),
  );
  
  my @external_styles = (
    $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
    $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
  );
  
  my $template_path;
  if ( $event_type eq "meeting" ) {
    my $meeting = $event_season->get_meeting;
    $template_path = "events/view-meeting.ttkt";
    
    push(@external_scripts,
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/responsive-tabs.js"),
    );
    
    $c->stash({
      meeting => $meeting,
      attendees => [$meeting->attendees],
      apologies => [$meeting->apologies],
    });
  } elsif ( $event_type eq "single_tournament" ) {
    # Grab the tournament details
    my $tournament = $c->stash->{event_detail};
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
      my $match_template = $rounds[0]->match_template;
  
      # Base JS name - add to it based on whether we have points or not / handicaps or not
      my $table_view_js = "view";
      $table_view_js .= "-points" if $ranking_template->assign_points;
      $table_view_js .= "-hcp" if $match_template->handicapped;
      $table_view_js = $c->uri_for("/static/script/tables/$table_view_js.js", {v => 3});
      
      push(@external_scripts,
        $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
        $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
        $table_view_js,
        $c->uri_for("/static/script/tables/points-adjustments.js"),
        $c->uri_for("/static/script/events/tournaments/view.js"),
      );
      
      push(@external_styles,
        $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
        $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
      );
      
      my @groups = $rounds[0]->groups;
      $c->stash({
        group_round => $rounds[0],
        groups => \@groups,
        ranking_template => $ranking_template,
        match_template => $match_template,
      });
    }
  } elsif ( $event_type eq "multi_tournament" ) {
    $template_path = "events/tournaments/multi-event/view.ttkt";
  }
  
  $c->stash({
    template => "html/$template_path",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_event_name),
    view_online_link => 1,
    external_scripts => \@external_scripts,
    external_styles => \@external_styles,
  });
}

=head2 teams_by_url_key_current_season, teams_by_id_current_season, teams_by_url_key_specific_season, teams_by_id_specific_season

Get a team participant of this event for the current season or a specific season.  Forwards to the private teams routine.

=cut

sub teams_by_url_key_current_season :Chained("base_current_season") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  # Forward to the routine to get the team
  $c->forward("teams_by_url_key", [$club_url_key, $team_url_key]);
}

sub teams_by_url_key_specific_season :Chained("base_specific_season") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  # Forward to the routine to get the team
  $c->forward("teams_by_url_key", [$club_url_key, $team_url_key]);
}

sub teams_by_id_current_season :Chained("base_current_season") :PathPart("teams") :CaptureArgs(1) {
  my ( $self, $c, $team_id ) = @_;
  
  # Forward to the routine to get the team
  $c->forward("teams_by_id", [$team_id]);
}

sub teams_by_id_specific_season :Chained("base_specific_season") :PathPart("teams") :CaptureArgs(1) {
  my ( $self, $c, $team_id ) = @_;
  
  # Forward to the routine to get the team
  $c->forward("teams_by_id", [$team_id]);
}

sub teams_by_url_key :Private {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  my $tournament = $c->stash->{event_detail};
  
  # Get the team from the passed parameters
  my $tourn_team = $tournament->get_team_by_url_key($club_url_key, $team_url_key);
  
  if ( defined($tourn_team) ) {
    my $team_season = $tourn_team->team_season;
    my $team = $team_season->team;
    
    $c->stash({
      tourn_team => $tourn_team,
      team_season => $team_season,
      team => $team,
    });
    
    $c->forward("teams");
  } else {
    # 404 - team doesn't exist or isn't in the tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

sub teams_by_id :Private {
  my ( $self, $c, $team_id ) = @_;
  my $tournament = $c->stash->{event_detail};
  
  # Get the team from the passed parameters
  my $tourn_team = $tournament->get_team_by_id($team_id);
  
  if ( defined($tourn_team) ) {
    my $team_season = $tourn_team->team_season;
    my $team = $team_season->team;
    
    $c->stash({
      tourn_team => $tourn_team,
      team_season => $team_season,
      team => $team,
    });
    
    $c->forward("teams");
  } else {
    # 404 - team doesn't exist or isn't in the tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 teams

Do the common stuff we need to do for teams - this is a private routine that's forwarded to from the teams_by_* routines.

=cut

sub teams :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tourn_team = $c->stash->{tourn_team};
  my $team_season = $c->stash->{team_season};
  my $team = $c->stash->{team};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_team_name = encode_entities($tourn_team->object_name);
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  my $event_link = $specific_season
    ? $c->uri_for_action("events/view_specific_season", [$event->url_key, $season->url_key])
    : $c->uri_for_action("/events/view_current_season", [$event->url_key]);
  
  $c->stash({
    subtitle1 => $enc_team_name,
    subtitle2 => $enc_event_name,
    subtitle2_uri => {link => $event_link, title => $c->maketext("title.link.text.view-event", $enc_event_name)},
    enc_team_name => $enc_team_name,
  });
}

=head2 teams_view_by_url_key_current_season, teams_view_by_id_current_season, teams_view_by_url_key_specific_season, teams_view_by_id_specific_season

Chained to the teams_by_* routines, this forwards to the teams_view routine.

=cut

sub teams_view_by_url_key_current_season :Chained("teams_by_url_key_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_view");
}

sub teams_view_by_id_current_season :Chained("teams_by_id_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_view");
}

sub teams_view_by_url_key_specific_season :Chained("teams_by_url_key_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_view");
}

sub teams_view_by_id_specific_season :Chained("teams_by_id_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_view");
}

=head2 teams_view_by_id

Provide a path to view the team just by tournament team ID.  This is basically so we can more easily link to rounds from the event log with just an ID; it performs an HTTP redirect to the round_view_current_season (or round_view_specific_season) routine.

=cut

sub teams_view_by_id :Path("teams") :Args(1) {
  my ( $self, $c, $tourn_team_id ) = @_;
  
  # Get the round
  my $tourn_team = $c->model("DB::TournamentTeam")->find_with_tournament_and_season($tourn_team_id);
  
  # Check it's valid
  if ( defined($tourn_team) ) {
    # Round is valid, check if the season is current or not
    my $season = $tourn_team->tournament->event_season->season;
    my $event = $tourn_team->tournament->event_season->event;
    my $team_season = $tourn_team->team_season;
    my $team = $team_season->team;
    my $club = $team_season->club_season->club;
    my $uri = $season->complete
      ? $c->uri_for_action("/events/teams_view_by_url_key_specific_season", [$event->url_key, $season->url_key, $club->url_key, $team->url_key])
      : $c->uri_for_action("/events/teams_view_by_url_key_current_season", [$event->url_key, $club->url_key, $team->url_key]);
    
    $c->response->redirect($uri);
    $c->detach;
    return;
  } else {
    # Team invalid
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 teams_view

Show the page for viewing a team in the tournament.

=cut

sub teams_view :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $tourn_team = $c->stash->{tourn_team};
  my $team_season = $c->stash->{team_season};
  my $team = $c->stash->{team};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_team_name = $c->stash->{enc_team_name};
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/teams_view_by_url_key_specific_season", [$event->url_key, $season->url_key, $team_season->club_season->club->url_key, $team->url_key])
    : $c->uri_for_action("/events/teams_view_by_url_key_current_season", [$event->url_key, $team_season->club_season->club->url_key, $team->url_key]);
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", undef, 0]);
  
  # Get the matches for the fixtures tab
  my $matches = $tourn_team->matches_for_team;
  
  # Add handicapped flag for template / JS if there are handicapped matches
  my $handicapped = $matches->handicapped_matches->count ? "/hcp" : "";
  
  $c->forward("get_team_stats");
  
  # Set up the title links if we need them
  my $team_link = $specific_season
    ? $c->uri_for_action("/teams/view_specific_season_by_url_key", [$team_season->club_season->club->url_key, $team->url_key, $season->url_key])
    : $c->uri_for_action("/teams/view_current_season_by_url_key", [$team_season->club_season->club->url_key, $team->url_key]);
  
  my @title_links = ({
    image_uri => $c->uri_for("/static/images/icons/league-32.png"),
    text => $c->maketext("title.link.text.view-team-league", $enc_team_name),
    link_uri => $team_link,
  });
  
  my $can_update = $tourn_team->can_update;
  
  if ( $c->stash->{authorisation}{event_edit} ) {
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/plus-minus-32.png"),
      text => $c->maketext("admin.points-adjust-object-tourn", $enc_team_name, $enc_event_name),
      link_uri => $c->uri_for_action("/events/teams_points_adjustment_by_url_key", [$event->url_key, $team->club->url_key, $team->url_key]),
    }) if $can_update->{points};
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/events/tournaments/teams/view.ttkt",
    view_online_display => sprintf("Viewing %s", $enc_event_name),
    canonical_uri => $canonical_uri,
    title_links => \@title_links,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for("/static/script/teams$handicapped/view.js", {v => 5}),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    view_online_display => sprintf("Viewing %s", $enc_event_name),
    view_online_link => 1,
    no_filter => 1, # Don't include the averages filter form on a team averages view
    matches => $matches,
    handicapped => $handicapped,
    points_adjustments => scalar $tourn_team->points_adjustments,
  });
}

=head2 teams_points_adjustment_by_url_key, teams_points_adjustment_by_id

Chained to the teams_by_* routines, this forwards to the teams_view routine.

=cut

sub teams_points_adjustment_by_url_key :Chained("teams_by_url_key_current_season") :PathPart("points-adjustment") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_points_adjustment");
}

sub teams_points_adjustment_by_id :Chained("teams_by_id_current_season") :PathPart("points-adjustment") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_points_adjustment");
}

=head2 teams_points_adjustment

Show the form to adjust table points for a team in a group.  The form is submitted to the do_points_adjustment routine.

=cut

sub teams_points_adjustment :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $tourn_team = $c->stash->{tourn_team};
  my $team_season = $c->stash->{team_season};
  my $team = $c->stash->{team};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_team_name = $c->stash->{enc_team_name};
  my $season = $c->stash->{season};
  
  # Check that we are authorised to adjust points
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.team-points-adjust-tourn"), 1]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Setup the template and stash the values we need to show the points adjustment form
  $c->stash({
    template => "html/teams/points-adjustment.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/teams/points-adjustment.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for_action("/events/teams_do_points_adjustment_by_url_key", [$event->url_key, $team->club->url_key, $team->url_key]),
    view_online_display => "Adjusting league points for $enc_event_name",
    view_online_link => 0,
    subtitle1 => $c->maketext("admin.points-adjustment"),
    subtitle2 => $enc_team_name,
    subtitle3 => $enc_event_name,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/teams_points_adjustment_by_url_key", [$event->url_key, $team->club->url_key, $team->url_key]),
    label => $c->maketext("admin.points-adjustment"),
  });
}

=head2 teams_do_points_adjustment_by_url_key, teams_do_points_adjustment_by_id

Chained to the teams_by_* routines, this forwards to the teams_view routine.

=cut

sub teams_do_points_adjustment_by_url_key :Chained("teams_by_url_key_current_season") :PathPart("do-points-adjustment") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_do_points_adjustment");
}

sub teams_do_points_adjustment_by_id :Chained("teams_by_id_current_season") :PathPart("do-points-adjustment") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("teams_do_points_adjustment");
}

=head2 teams_do_points_adjustment

Show the form to adjust table points for a team in a group.  The form is submitted to the do_points_adjustment routine.

=cut

sub teams_do_points_adjustment :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to adjust points
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.team-points-adjust-tourn"), 1]);
  $c->detach("process_form", [qw( team points-adjustment )]);
}

=head2 get_team_stats

Lookup the team's stats (averages, etc) for this tournament.

=cut

sub get_team_stats :Private {
  my ( $self, $c ) = @_;
  my $tournament = $c->stash->{event_detail};
  my $tourn_team = $c->stash->{tourn_team};
  my $team_season = $c->stash->{team_season};
  my $team = $c->stash->{team};
  my $specific_season = $c->stash->{specific_season};
  
  # Get the club_season too
  my $club_season = $team_season->club_season;
  my $team_season_name = $team_season->full_name;
  my $enc_team_season_name = encode_entities($team_season_name);
  my $team_current_name = $team->full_name;
  
  $c->add_status_messages({info => $c->maketext("teams.club.changed-notice", $enc_team_season_name, encode_entities($team->club->full_name), $c->uri_for_action("/clubs/view_current_season", [$team->club->url_key]))}) unless $club_season->club->id == $team->club->id;
  $c->add_status_messages({info => $c->maketext("teams.name.changed-notice", $enc_team_season_name, encode_entities($team_current_name))}) unless $team_season->name eq $team->name;
  $c->add_status_messages({info => $c->maketext("clubs.name.changed-notice", encode_entities($club_season->full_name), encode_entities($club_season->short_name), encode_entities($club_season->club->full_name), encode_entities($club_season->club->short_name))}) if $club_season->full_name ne $club_season->club->full_name or $club_season->short_name ne $club_season->club->short_name;
  
  # Grab the singles averages and check if anyone is set with the noindex flag
  my $singles_averages = $tourn_team->singles_averages;
  $c->stash->{noindex} = 1 if $singles_averages->noindex_set(1)->count;
  
  # Stash singles averages (already looked up) and doubles individual / pairs averages
  $c->stash({
    singles_averages => $singles_averages,
    doubles_individual_averages => scalar $tourn_team->doubles_individual_averages({
      logger => sub{ my $level = shift; $c->log->$level( @_ ); },
      criteria_field => "played",
      operator => ">",
      criteria => 0,
    }),
    doubles_pair_averages => scalar $tourn_team->doubles_pairs_averages({
      logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    }),
  });
}

=head2 people_current_season, people_specific_season

Get a person participant of this event for the current season or a specific season.  Forwards to the private people routine.

=cut

sub people_current_season :Chained("base_current_season") :PathPart("people") :CaptureArgs(1) {
  my ( $self, $c, $person_url_key ) = @_;
  
  # Forward to the routine to get the person
  $c->forward("get_people", [$person_url_key]);
}

sub people_specific_season :Chained("base_specific_season") :PathPart("people") :CaptureArgs(1) {
  my ( $self, $c, $person_url_key ) = @_;
  
  # Forward to the routine to get the person
  $c->forward("get_people", [$person_url_key]);
}

=head2 get_people

Do the person lookup.

=cut

sub get_people :Private {
  my ( $self, $c, $person_url_key ) = @_;
  my $tournament = $c->stash->{event_detail};
  
  # Get the team from the passed parameters
  my $tourn_person = $tournament->get_person($person_url_key);
  
  if ( defined($tourn_person) ) {
    my $person_season = $tourn_person->team_season;
    my $person = $person_season->person;
    
    $c->stash({
      tourn_person => $tourn_person,
      person_season => $person_season,
      person => $person,
    });
    
    $c->forward("people");
  } else {
    # 404 - team doesn't exist or isn't in the tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 people

Do the common stuff we need to do for people - this is a private routine that's forwarded to from the people_by_* routines.

=cut

sub people :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tourn_person = $c->stash->{tourn_person};
  my $person_season = $c->stash->{person_season};
  my $person = $c->stash->{person};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_person_name = encode_entities($tourn_person->object_name);
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  my $event_link = $specific_season
    ? $c->uri_for_action("events/view_specific_season", [$event->url_key, $season->url_key])
    : $c->uri_for_action("/events/view_current_season", [$event->url_key]);
  
  $c->stash({
    subtitle1 => $enc_person_name,
    subtitle2 => $enc_event_name,
    subtitle2_uri => {link => $event_link, title => $c->maketext("title.link.text.view-event", $enc_event_name)},
    enc_person_name => $enc_person_name,
  });
}

=head2 people_view_current_season, people_view_specific_season

Chained to the [ep[;e]]_by_* routines, this forwards to the people_view routine.

=cut

sub people_view_current_season :Chained("people_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("people_view");
}

sub people_view_specific_season :Chained("people_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("people_view");
}

=head2 people_view

Show the page for viewing a person in the tournament.

=cut

sub people_view {
  my ( $self, $c ) = @_;
}

=head2 rounds_current_season, rounds_specific_season

Return the rounds for the current season - this obviously only works if the event is a tournament, otherwise it will default to a 404 error.

This just forwards to a get_round function that's common to the specific and current season routines.

=cut

sub rounds_current_season :Chained("base_current_season") :PathPart("rounds") :CaptureArgs(1) {
  my ( $self, $c, $round_id ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  my $enc_event_name = $c->stash->{enc_event_name};
  
  $c->forward("rounds", [$round_id]);
}

sub rounds_specific_season :Chained("base_specific_season") :PathPart("rounds") :CaptureArgs(1) {
  my ( $self, $c, $round_id ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $round = $c->stash->{round};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_season_name = $c->stash->{enc_season_name};
  
  $c->forward("rounds", [$round_id]);
}

sub rounds :Private {
  my ( $self, $c, $round_id ) = @_;
  my $event = $c->stash->{event};
  my $event_type = $c->stash->{event_type};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $specific_season = $c->stash->{specific_season};
  my $season = $c->stash->{season};
  
  if ( $event_type ne "single_tournament" ) {
    # 404 - event is not a tournament
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_cancel", "", 0]);
  
  my $tournament = $c->stash->{event_detail};
  my $round = $tournament->find_round_by_number_or_url_key($round_id);
  
  if ( !defined($round) ) {
    # 404 - round doesn't exist
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  my $event_link = $specific_season
    ? $c->uri_for_action("events/view_specific_season", [$event->url_key, $season->url_key])
    : $c->uri_for_action("/events/view_current_season", [$event->url_key]);
  
  
  $c->stash({
    subtitle1 => $round->name,
    subtitle2 => $enc_event_name,
    subtitle2_uri => {link => $event_link, title => $c->maketext("title.link.text.view-event", $enc_event_name)},
    round => $round,
    match_template => $round->match_template,
    rank_template => $round->rank_template,
  });
}

=head2 round_view_current_season, round_view_specific_season

Page to view the rounds for the given season.

This just forwards to a round_view's private function that's common to the specific and current season routines and shows the page for viewing those rounds.

=cut

sub round_view_current_season :Chained("rounds_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("round_view");
}

sub round_view_specific_season :Chained("rounds_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("round_view");
}

=head2 round_view_by_id

Provide a path to view the round just by ID.  This is basically so we can more easily link to rounds from the event log with just an ID; it performs an HTTP redirect to the round_view_current_season (or round_view_specific_season) routine.

=cut

sub round_view_by_id :Path("rounds") :Args(1) {
  my ( $self, $c, $round_id ) = @_;
  
  # Get the round
  my $round = $c->model("DB::TournamentRound")->find_with_tournament_and_season($round_id);
  
  # Check it's valid
  if ( defined($round) ) {
    # Round is valid, check if the season is current or not
    my $season = $round->tournament->event_season->season;
    my $event = $round->tournament->event_season->event;
    my $uri = $season->complete
      ? $c->uri_for_action("/events/round_view_specific_season", [$event->url_key, $season->url_key, $round->url_key])
      : $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key]);
    
    $c->response->redirect($uri);
    $c->detach;
    return;
  } else {
    # Round invalid
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 round_view

Show a page to view the round.

=cut

sub round_view :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $tournament = $c->stash->{event_detail};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $round = $c->stash->{round};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  if ( $c->stash->{authorisation}{event_edit} ) {
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_event_name),
      link_uri => $c->uri_for_action("/events/edit_round", [$event->url_key, $round->url_key]),
    });
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/round_view_specific_season", [$event->url_key, $season->url_key, $round->url_key])
    : $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  my ( $template, @external_scripts, @external_styles );
  if ( $round->group_round ) {
    
    # Get the ranking template for the table - we need this before we stash because one of the scripts depends
    # on whether or not we're assigning points (as there's an extra column if we are)
    my $ranking_template = $round->rank_template;
    my $match_template = $round->match_template;

    # Base JS name - add to it based on whether we have points or not / handicaps or not
    my $table_view_js = "view";
    $table_view_js .= "-points" if $ranking_template->assign_points;
    $table_view_js .= "-hcp" if $match_template->handicapped;
    $table_view_js = $c->uri_for("/static/script/tables/$table_view_js.js", {v => 3});
    
    @external_scripts = (
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $table_view_js,
      $c->uri_for("/static/script/tables/points-adjustments.js")
    );
    
    @external_styles = (
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    );
    
    $c->stash({
      groups => [$round->groups],
      ranking_template => $ranking_template,
      match_template => $match_template,
    });
    
    $template = "view-groups";
  } else {
    # Grab the matches and check if there are handicapped ones in there
    my $matches = $c->model("DB::TeamMatch")->matches_in_tourn_round({round => $round});
    
    # Add handicapped flag for template / JS if there are handicapped matches
    my $handicapped = $matches->handicapped_matches->count ? "/hcp" : "";
    
    @external_scripts = (
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for("/static/script/events/tournaments/rounds$handicapped/view.js"),
    );
    
    @external_styles = (
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    );
    
    $template = "view";
  }
  
  $c->stash({
    template => "html/events/tournaments/rounds/$template.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_event_name),
    view_online_link => 1,
    external_scripts => \@external_scripts,
    external_styles => \@external_styles,
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
  my $enc_event_name = $c->stash->{enc_event_name};
  my $season = $c->stash->{season};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
    
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
  
  $c->stash({
    form_action => $c->uri_for_action("/events/do_edit_round", [$event->url_key, $round->url_key]),
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/events/edit_round", [$event->url_key, $round->url_key]),
    label => $c->maketext("admin.edit"),
  });
  
  $c->detach("prepare_form_round", [qw( create )]);
}

=head2 do_edit_round

Process the form for editing the round for a tournament.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub do_edit_round :Chained("rounds_current_season") :PathPart("do-edit-round") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( round edit )]);
}

=head2 add_next_round

Show the form to add the next round to this event.

=cut

sub add_next_round :Chained("base_current_season") :PathPart("add-next-round") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $season = $c->stash->{season};
  my $event_type = $c->stash->{event_type};
  my $tournament = $c->stash->{event_detail};
  
  # If this isn't a tournament, there are no rounds to add, so show a 404
  if ( $event_type ne "single_tournament" ) {
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  if ( $season->complete ) {
    # The stashed season is complete (this is chained from the base_current_season routine, which gets the current or last complete season) so we can't edit the event
    $c->response->redirect($c->uri_for_action("/events/view_current_season", [$event->url_key],
      {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  if ( !$tournament->can_add_round ) {
    # We can add a round
    $c->response->redirect($c->uri_for_action("/events/view_current_season", [$event->url_key],
      {mid => $c->set_status_msg({error => $c->maketext("tournaments.form.error.rounds-complete", $enc_event_name)})}));
    $c->detach;
    return;
  }
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  $c->stash({
    form_action => $c->uri_for_action("/events/do_add_next_round", [$event->url_key]),
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/events/add_next_round", [$event->url_key]),
    label => $c->maketext("admin.add-next-round-crumbs"),
  });
  
  $c->detach("prepare_form_round", [qw( create )]);
}

=head2 do_add_next_round

Process the form to add the next round.

=cut

sub do_add_next_round :Chained("base_current_season") :PathPart("do-add-next-round") :Args(0) {
  my ( $self, $c ) = @_;
  my $event_type = $c->stash->{event_type};
  
  # If this isn't a tournament, there are no rounds to add, so show a 404
  if ( $event_type ne "single_tournament" ) {
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", [qw( round create )]);
}

# =head2 round_select_entrants

# Show a form to add the entrants to a round - this is only used for knock-out rounds; if this is the first round, entants can be anyone registered for the season, otherwise they must be from the previous round.  This is a formality in most situations, but sometimes we may need to select qualifiers from a list of best runners up.

# Knock-out rounds that follow knock-out rounds will automatically have the entrants set to the winners of the previous round, or those who had a bye from the round before that, so this is only needed for the first knock-out round.

# =cut

# sub round_select_entrants :Chained("rounds_current_season") :PathPart("select-entrants") :Args(0) {
#   my ( $self, $c ) = @_;
#   my $event = $c->stash->{event};
#   my $enc_event_name = $c->stash->{enc_event_name};
#   my $season = $c->stash->{season};
#   my $event_type = $c->stash->{event_type};
#   my $tournament = $c->stash->{event_detail};
#   my $round = $c->stash->{round};
#   my $prev_round = $round->prev_round;
#   my $match_template = $prev_round->match_template;
#   my $ranking_template = $prev_round->rank_template;
  
#   # Check that we are authorised to edit events
#   $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
#   my %can = $round->can_update("entrants");
  
#   my $js = "select-entrants";
#   $js .= "-points" if $ranking_template->assign_points;
#   $js .= "-hcp" if $match_template->handicapped;
#   $js = $c->uri_for("/static/script/events/tournaments/rounds/$js.js");
  
#   # Setup template and scripts
#   $c->stash({
#     template => "html/events/tournaments/rounds/select-entrants.ttkt",
#     form_action => $c->uri_for_action("/events/do_round_select_entrants", [$event->url_key, $round->url_key]),
#     external_scripts => [
#       $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
#       $c->uri_for("/static/script/standard/chosen.js"),
#       $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
#       $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
#       $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
#       $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
#       $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
#       $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
#       $c->uri_for("/static/script/standard/prettycheckable.js"),
#       $js,
#     ],
#     external_styles => [
#       $c->uri_for("/static/css/chosen/chosen.min.css"),
#       $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
#       $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
#       $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
#       $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
#       $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
#       $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
#     ],
#     view_online_display => "Selecting entrants for $enc_event_name",
#     view_online_link => 0,
#     prev_round => $prev_round,
#     auto_qualifiers => [$prev_round->auto_qualifiers],
#     non_auto_qualifiers => [$prev_round->non_auto_qualifiers],
#     winner_type => $match_template->winner_type->id,
#     match_template => $match_template,
#     ranking_template => $ranking_template,
#   });
# }

# =head2 do_round_select_entrants

# Process the form to add the entrants to a round.

# =cut

# sub do_round_select_entrants :Chained("rounds_current_season") :PathPart("do-select-entrants") :Args(0) {
#   my ( $self, $c ) = @_;
  
#   # Check that we are authorised to edit events
#   $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
#   # Forward to the create / edit routine
#   $c->detach("process_form", [qw( round entrants )]);
# }

=head2 prepare_form_round

Prepare and show the form to create or edit a round.

=cut

sub prepare_form_round :Private {
  my ( $self, $c ) = @_;
  
  $c->stash({
    template => "html/events/tournaments/rounds/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/events/tournaments/rounds/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    team_match_templates => [$c->model("DB::TemplateMatchTeam")->all_templates],
    ind_match_templates => [$c->model("DB::TemplateMatchIndividual")->all_templates],
    rank_templates => [$c->model("DB::TemplateLeagueTableRanking")->all_templates],
    venues => [$c->model("DB::Venue")->active_venues],
    view_online_display => "Editing tournament rounds",
    view_online_link => 0,
  });
}

=head2 groups_current_season, groups_specific_season

Return the groups for the current season in a given tournament round - this obviously only works if the event is a tournament, otherwise it will default to a 404 error.

This just forwards to a groups function that's common to the specific and current season routines.

=cut

sub groups_current_season :Chained("rounds_current_season") :PathPart("groups") :CaptureArgs(1) {
  my ( $self, $c, $group_id ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  my $enc_event_name = $c->stash->{enc_event_name};
  
  # Setup the round view link
  $c->stash({
    subtitle2_uri => {
      link => $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key]),
      title => $c->maketext("title.link.text.view-event-round", $round->name, $enc_event_name),
    },
    subtitle3_uri => {
      link => $c->uri_for_action("/events/view_current_season", [$event->url_key]),
      title => $c->maketext("title.link.text.view-event", $enc_event_name),
    },
  });
  
  $c->forward("groups", [$group_id]);
}

sub groups_specific_season :Chained("rounds_specific_season") :PathPart("groups") :CaptureArgs(1) {
  my ( $self, $c, $group_id ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $round = $c->stash->{round};
  my $enc_event_name = $c->stash->{enc_event_name};
  my $enc_season_name = $c->stash->{enc_season_name};
  
  # Setup the round view link
  $c->stash({
    subtitle2_uri => {
      link => $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key]),
      title => $c->maketext("title.link.text.view-event-round-specific-season", $round->name, $enc_event_name, $enc_season_name),
    },
    subtitle3_uri => {
      link => $c->uri_for_action("/events/view_specific_season", [$event->url_key, $season->url_key]),
      title => $c->maketext("title.link.text.view-event-specific-season", $enc_event_name, $enc_season_name),
    },
  });
  
  $c->forward("groups", [$group_id]);
}

sub groups :Private {
  my ( $self, $c, $group_id ) = @_;
  my $event = $c->stash->{event};
  my $round = $c->stash->{round};
  my $event_type = $c->stash->{event_type};
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
  
  $c->stash({
    group => $group,
    subtitle1 => $group->name,
    subtitle2 => $round->name,
    subtitle3 => $enc_event_name,
  });
}

=head2 group_view_current_season, group_view_specific_season

Page to view the rounds for the given season.

This just forwards to a group_view's private function that's common to the specific and current season routines and shows the page for viewing those rounds.

=cut

sub group_view_current_season :Chained("groups_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("group_view");
}

sub group_view_specific_season :Chained("groups_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("group_view");
}

=head2 group_view_by_id

Provide a path to view the group just by ID.  This is basically so we can more easily link to rounds from the event log with just an ID; it performs an HTTP redirect to the group_view_current_season (or group_view_specific_season) routine.

=cut

sub group_view_by_id :Path("groups") :Args(1) {
  my ( $self, $c, $group_id ) = @_;
  
  # Get the round
  my $group = $c->model("DB::TournamentRoundGroup")->find_with_round_tournament_and_season($group_id);
  
  # Check it's valid
  if ( defined($group) ) {
    # Round is valid, check if the season is current or not
    my $round = $group->tournament_round;
    my $season = $round->tournament->event_season->season;
    my $event = $round->tournament->event_season->event;
    my $uri = $season->complete
      ? $c->uri_for_action("/events/group_view_specific_season", [$event->url_key, $season->url_key, $round->url_key, $group->url_key])
      : $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key]);
    
    $c->response->redirect($uri);
    $c->detach;
    return;
  } else {
    # Round invalid
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

sub group_view :Private {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $season = $c->stash->{season};
  my $event_season = $c->stash->{event_season};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $enc_event_name = $c->stash->{enc_event_name};
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  if ( !$season->complete and !$c->stash->{delete_screen} ) {
    if ( $c->stash->{authorisation}{event_edit} ) {
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
        text => $c->maketext("admin.edit-object", $group->name),
        link_uri => $c->uri_for_action("/events/group_edit", [$event->url_key, $round->url_key, $group->url_key]),
      });
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/reorder-32.png"),
        text => $c->maketext("admin.fixtures-grid.set-positions", $group->name),
        link_uri => $c->uri_for_action("/events/group_grid_positions", [$event->url_key, $round->url_key, $group->url_key]),
      }) if $group->can_set_grid_positions;
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/fixtures-32.png"),
        text => $c->maketext("admin.fixtures-grid.create-fixtures", $group->name),
        link_uri => $c->uri_for_action("/events/group_create_matches", [$event->url_key, $round->url_key, $group->url_key]),
      }) if $group->can_create_matches;
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/fixturesdel-32.png"),
        text => $c->maketext("admin.fixtures-grid.delete-fixtures", $group->name),
        link_uri => $c->uri_for_action("/events/group_delete_matches", [$event->url_key, $round->url_key, $group->url_key]),
      }) if $group->can_delete_matches;
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
        text => $c->maketext("admin.delete-object", $group->name),
        link_uri => $c->uri_for_action("/events/group_delete", [$event->url_key, $round->url_key, $group->url_key]),
      }) if $group->can_delete;
    }
  }
  
  # Set up the canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/events/group_view_specific_season", [$event->url_key, $season->url_key, $round->url_key, $group->url_key])
    : $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key]);
  
  $c->stash({canonical_uri => $canonical_uri});
  
  # Get the ranking template for the table - we need this before we stash because one of the scripts depends
  # on whether or not we're assigning points (as there's an extra column if we are)
  my $ranking_template = $round->rank_template;
  my $match_template = $round->match_template;
  
  # Base JS name - add to it based on whether we have points or not / handicaps or not
  my $table_view_js = "view";
  $table_view_js .= "-points" if $ranking_template->assign_points;
  $table_view_js .= "-hcp" if $match_template->handicapped;
  $table_view_js = $c->uri_for("/static/script/tables/$table_view_js.js", {v => 3});
  
  my $matches = $group->matches;
  
  # Add handicapped flag for template / JS if there are handicapped matches
  my $handicapped = $matches->handicapped_matches->count ? "/hcp" : "";
  
  my @ext_scripts = (
    $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
    $c->uri_for("/static/script/standard/responsive-tabs.js"),
    $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
    $table_view_js,
    $c->uri_for("/static/script/fixtures-results/view$handicapped/group-weeks-ordering-no-comp.js"),
    $c->uri_for("/static/script/tables/points-adjustments.js")
  );
  
  my @ext_styles = (
    $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
    $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    $c->uri_for("/static/css/chosen/chosen.min.css"),
    $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
  );
  
  $c->stash({
    template => "html/events/tournaments/rounds/groups/view.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_event_name),
    view_online_link => 1,
    entrants => [$group->get_entrants_in_table_order],
    last_updated => $group->get_tables_last_updated_timestamp,
    ranking_template => $ranking_template,
    match_template => $match_template,
    matches => $matches,
    handicapped => $handicapped,
    external_scripts => \@ext_scripts,
    external_styles => \@ext_styles,
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
  
  my %can_add = $round->can_update("add-groups");
  if ( !$can_add{allowed} ) {
    # Not allowed to override, get the reason and redirect
    # Redirect with the correct message if we can't override
    $c->response->redirect($c->uri_for_action("/events/view_current_season", [$event->url_key],
      {mid => $c->set_status_msg({$can_add{level} => $can_add{reason}})}));
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

=head2 group_delete

Show the form to delete a group in the first round of a competition.

We only need to chain this to the current season, as we don't allow deletion of groups from previous seasons.

=cut

sub group_delete :Chained("groups_current_season") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  if ( !$group->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.delete.error.cannot-delete", $group->name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("group_view_current_season");
  
  $c->stash({
    subtitle5 => $c->maketext("admin.delete"),
    template => "html/events/tournaments/rounds/groups/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $group->name),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/group_delete", [$event->url_key, $round->url_key, $group->url_key]),
    label => $c->maketext("admin.delete"),
  });
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
      id => $_->url_key,
      name => $_->object_name,
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
      $c->uri_for("/static/script/events/tournaments/rounds/groups/create-edit.js"),
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
  
  if ( !$round->group_round ) {
    # If this is not a group round, we can't create groups
    $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key],
      {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.create.error.not-group-round")})});
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

Show the form to create a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub group_do_edit :Chained("groups_current_season") :PathPart("do-edit") :Args(0) {
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

=head2 group_do_delete

Process the form to create a group in a group stage of a competition.

We only need to chain this to the current season, as we don't allow editing of rounds from previous seasons.

=cut

sub group_do_delete :Chained("groups_current_season") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_season}->event_detail;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  my $name = $group->name;
  my $response = $group->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["event-group", "delete", {id => undef}, $name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
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
    $c->response->redirect($c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.teams.error.matches-already-set")})}));
    $c->detach;
    return;
  }
  
  if ( !defined($group->fixtures_grid) ) {
    # Error, no grid for this group
    $c->response->redirect($c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key],
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
  my $season = $c->stash->{season};
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  # Check we're ready to create fixtures
  if ( !$group->can_create_matches ) {
    # Error, can't create fixtures
    my $msg = defined($group->fixtures_grid)
      ? $c->maketext("events.tournaments.rounds.groups.create-fixtures.error.grid-positions-not-set")
      : $c->maketext("events.tournaments.rounds.groups.create-fixtures.error.matches-already-exist");
    
    $c->response->redirect($c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $msg})}));
    $c->detach;
    return;
  }
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Stash the bits we need that don't care if there's a grid or not
  $c->stash({
    subtitle2 => $round->name,
    subtitle3 => $group->name,
    subtitle4 => $c->maketext("fixtures-grids.create-fixtures"),
    form_action => $c->uri_for_action("/events/group_do_create_matches", [$event->url_key, $round->url_key, $group->url_key]),
  });
  
  if ( defined($group->fixtures_grid) ) {
    # Show the grid form
    $c->stash({
      template => "html/fixtures-grids/create-fixtures.ttkt",
      external_scripts => [
        $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
        $c->uri_for("/static/script/standard/chosen.js"),
        $c->uri_for("/static/script/fixtures-grids/create-fixtures.js"),
        $c->uri_for("/static/script/fixtures-grids/create-fixtures.js"),
      ],
      external_styles => [
        $c->uri_for("/static/css/chosen/chosen.min.css"),
      ],
      view_online_display => "Creating fixtures for " . $group->name,
      view_online_link => 0,
      grid_weeks => [$group->fixtures_grid->rounds],
      season_weeks => [$season->weeks],
    });
  } else {
    # Show the grid form
    $c->stash({
      template => "html/events/tournaments/rounds/groups/create-matches.ttkt",
      external_scripts => [
        $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
        $c->uri_for("/static/script/standard/chosen.js"),
        $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
        $c->uri_for("/static/script/standard/prettycheckable.js"),
        $c->uri_for("/static/script/events/tournaments/rounds/groups/create-matches-manual.js"),
      ],
      external_styles => [
        $c->uri_for("/static/css/chosen/chosen.min.css"),
        $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      ],
      entrants => [$group->get_entrants],
      venues => [$c->model("DB::Venue")->active_venues],
      days => [$c->model("DB::LookupWeekday")->all_days],
      view_online_display => "Creating fixtures for " . $group->name,
      view_online_link => 0,
      season_weeks => [$season->weeks],
    });
  }
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/group_create_matches", [$event->url_key, $round->url_key, $group->url_key]),
    label => $c->maketext("events.tournaments.create-matches"),
  });
}

=head2 group_do_create_matches

Process the form to create the matches for a group.

=cut

sub group_do_create_matches :Chained("groups_current_season") :PathPart("do-create-matches") {
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
  $c->detach("process_form", [qw( group matches )]);
}

=head2 group_delete_matches

Show the form to delete the matches for a group.

=cut

sub group_delete_matches :Chained("groups_current_season") :PathPart("delete-matches") {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $tournament = $c->stash->{event_detail};
  my $entry_type = $tournament->entry_type->id;
  my $round = $c->stash->{round};
  my $group = $c->stash->{group};
  
  # Check that we are authorised to edit events
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);
  
  unless ( $group->can_delete_matches ) {
    $c->response->redirect($c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.tournaments.rounds.groups.delete-fixtures.error.cant-delete", $group->name)})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/events/tournaments/rounds/delete-matches.ttkt",
    subtitle2 => $round->name,
    subtitle3 => $group->name,
    subtitle4 => $c->maketext("fixtures-grids.delete-fixtures"),
    form_action => $c->uri_for_action("/events/group_do_delete_matches", [$event->url_key, $round->url_key, $group->url_key]),
    view_online_display => sprintf("Deleting fixtures for grid %s", $group->name),
    view_online_link => 0,
    matches => scalar $group->matches,
    obj_name => $group->name,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/events/group_delete_matches", [$event->url_key, $round->url_key, $group->url_key]),
    label => $c->maketext("events.tournaments.delete-matches"),
  });
}

=head2 group_do_delete_matches

Process the form to create the matches for a group.

=cut

sub group_do_delete_matches :Chained("groups_current_season") :PathPart("do-delete-matches") {
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
  
  my $response = $group->delete_matches;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri = $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
  
  
  # If it was completed, we log an event
  $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "delete", $response->{match_ids}, $response->{match_names}]) if $response->{completed};
  
  # Redirect
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 view_seasons

Retrieve and display a list of seasons that this event has been run in.

=cut

sub view_seasons :Chained("base") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $site_name = $c->stash->{enc_site_name};
  my $event_name = $c->stash->{enc_event_name};
  
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
  my $tourn_team = $c->stash->{tourn_team};
  my $log_obj;
  my ( @field_names, @processed_field_names ) = ();
  my $response = {}; # Store the response from the form processing
  
  if ( $type eq "event" ) {
    my @field_names = qw( name event_type tournament_type venue organiser start_hour start_minute all_day end_hour end_minute default_team_match_template default_individual_match_template allow_loan_players allow_loan_players_above allow_loan_players_below allow_loan_players_across allow_loan_players_same_club_only allow_loan_players_multiple_teams loan_players_limit_per_player loan_players_limit_per_player_per_team loan_players_limit_per_player_per_opposition loan_players_limit_per_team void_unplayed_games_if_both_teams_incomplete forefeit_count_averages_if_game_not_started missing_player_count_win_in_averages rules round_name round_group round_group_rank_template round_team_match_template round_individual_match_template round_week_commencing round_venue round_of );
    @processed_field_names = ( @field_names, qw( start_date end_date round_date ) );
    
    $response = $c->model("DB::Event")->create_or_edit($action, {
      logger => sub{ my $level = shift; $c->log->$level( @_ ); },
      event => $event,
      start_date => defined($c->req->params->{start_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{start_date}) : undef,
      end_date => defined($c->req->params->{end_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{end_date}) : undef,
      round_date => defined($c->req->params->{round_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{round_date}) : undef,
      map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
    });
  } elsif ( $type eq "round" ) {
    @field_names =  qw( round_name round_team_match_template round_individual_match_template round_week_commencing round_venue round_of );
    @processed_field_names = ( @field_names, qw( round_date ) );
    my $round_number = defined($round) ? $round->round_number : undef;
    
    $response = $tournament->create_or_edit_round($round_number, {
      logger => sub{ my $level = shift; $c->log->$level( @_ ); },
      round_date => defined($c->req->params->{round_date}) ? $c->i18n_datetime_format_date->parse_datetime($c->req->params->{round_date}) : undef,
      map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
    });
  } elsif ( $type eq "group" ) {
    # Group forms to process
    @field_names = qw( name manual_fixtures fixtures_grid automatic_qualifiers );
    
    my @members = ();
    foreach my $key ( keys %{$c->req->params} ) {
      push(@members, [split(",", $c->req->params->{$key})]) if $key =~ /^members\d+$/;
    }
    
    if ( $action eq "create" or $action eq "edit" ) {
      # Create or edit group
      @field_names = qw( name manual_fixtures fixtures_grid automatic_qualifiers );
      @processed_field_names = ( @field_names, qw( members ) );
      
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
    } elsif ( $action eq "matches" ) {
      # Create matches
      @processed_field_names = qw( rounds );
      my %rounds = ();
      foreach ( keys %{$c->req->params } ) {
        # Pass in anything that starts with 'round_' - the rest will be dealt with in the model.
        $rounds{$_} = $c->req->params->{$_} if m/^round_/;
      }
      
      $response = $group->create_matches({
        rounds => \%rounds,
        logger => sub{ my $level = shift; $c->log->$level( @_ ); }
      });
    }
  } elsif ( $type eq "team" ) {
    if ( $action eq "points-adjustment" ) {
      @field_names = qw( action points_adjustment reason );
      @processed_field_names = @field_names;
      
      $response = $tourn_team->adjust_points({
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
      });
    }
  }
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  # Work out redirection URLs - this can only be done after we have the response
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    my %log_ids = ();
    my ( $obj_type, $obj_name );
    if ( $type eq "event" ) {
      $event = $response->{event};
      $obj_type = "event";
      $log_obj = $event;
      $obj_name = $event->name;
      %log_ids = (id => $event->id);
      $redirect_uri = $c->uri_for_action("/events/view_current_season", [$event->url_key], {mid => $mid});
    } elsif ( $type eq "round" ) {
      $round = $response->{round};
      $obj_type = "event-round";
      $log_obj = $round;
      $obj_name = sprintf("%s: %s", $event->name, $round->name);
      %log_ids = (id => $round->id);
      $redirect_uri = $c->uri_for_action("/events/round_view_current_season", [$event->url_key, $round->url_key], {mid => $mid});
    } elsif ( $type eq "group" ) {
      $group = $response->{group} if $action eq "create";
      $obj_type = "event-group";
      $log_obj = $group;
      $obj_name = sprintf("%s: %s", $event->name, $group->name);
      %log_ids = (id => $group->id);
      $redirect_uri = $c->uri_for_action("/events/group_view_current_season", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
    } elsif ( $type eq "team" ) {
      $obj_type = "tourn-team";
      $log_obj = $tourn_team;
      $obj_name = sprintf("%s (%s)", $tourn_team->object_name, $event->name);
      %log_ids = (id => $tourn_team->id);
      my $team_season = $tourn_team->team_season;
      my $team = $team_season->team;
      my $club = $team->club;
      $redirect_uri = $c->uri_for_action("/events/teams_view_by_url_key_current_season", [$event->url_key, $club->url_key, $team->url_key], {mid => $mid});
    }
    
    # Completed, so we log an event
    if ( $action eq "matches" ) {
      # Matches have a match event to log
      $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "create", $response->{match_ids}, $response->{match_names}]);
    } else {
      # Everything else is related to the event, group or round
      $c->forward("TopTable::Controller::SystemEventLog", "add_event", [$obj_type, $action, \%log_ids, $obj_name]);
    }
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $type eq "event" ) {
      if ( $action eq "create" ) {
        $redirect_uri = $c->uri_for("/events/create", {mid => $mid});
      } else {
        $redirect_uri = $c->uri_for_action("/events/edit", [$event->url_key], {mid => $mid});
      }
    } elsif ( $type eq "round" ) {
      if ( $action eq "create" ) {
        $redirect_uri = $c->uri_for_action("/events/add_next_round", [$event->url_key], {mid => $mid});
      } elsif ( $action eq "edit" ) {
        $redirect_uri = $c->uri_for_action("/events/edit_round", [$event->url_key, $round->url_key], {mid => $mid});
      }
    } elsif ( $type eq "group" ) {
      if ( $action eq "create" ) {
        $redirect_uri = $c->uri_for_action("/events/group_create", [$event->url_key, $round->url_key], {mid => $mid});
      } elsif ( $action eq "edit" ) {
        $redirect_uri = $c->uri_for_action("/events/group_edit", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
      } elsif ( $action eq "positions" ) {
        $redirect_uri = $c->uri_for_action("/events/group_grid_positions", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
      } elsif ( $action eq "matches" ) {
        $redirect_uri = $c->uri_for_action("/events/group_create_matches", [$event->url_key, $round->url_key, $group->url_key], {mid => $mid});
      }
    } elsif ( $type eq "team" ) {
      if ( $action eq "points-adjustment" ) {
        my $team_season = $tourn_team->team_season;
        my $team = $team_season->team;
        my $club = $team->club;
        if ( $response->{can_complete} ) {
          $redirect_uri = $c->uri_for_action("/events/teams_points_adjustment_by_url_key", [$event->url_key, $club->url_key, $team->url_key], {mid => $mid});
        } else {
          $redirect_uri = $c->uri_for_action("/events/teams_view_by_url_key_current_season", [$event->url_key, $club->url_key, $team->url_key], {mid => $mid});
        }
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit-details.error.no-event-this-season", $enc_event_name, encode_entities($current_season->name))})}));
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
    view_online_display => sprintf("Editing details for %s", $enc_event_name),
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
  $c->stash({
    view_online_display => sprintf("Editing details for %s", $enc_event_name),
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
  my $enc_event_name = $c->stash->{enc_event_name};
  
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
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit-details.error.no-event-this-season", $enc_event_name, encode_entities($current_season->name))})}));
    $c->detach;
    return;
  }
  
  my $response = $c->forward(sprintf("do_edit_%s", $event->event_type->id));
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
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
