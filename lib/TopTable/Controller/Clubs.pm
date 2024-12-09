package TopTable::Controller::Clubs;
use Moose;
use namespace::autoclean;
use Regexp::Common qw( URI );
use JSON;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Clubs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for clubs; handles viewing, editing, creating and deleting.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.club") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    # Listing
    path => $c->uri_for("/clubs"),
    label => $c->maketext("menu.text.club"),
  });
}

=head2 base

Chain base for getting the club ID and checking it.

=cut

sub base :Chained("/") :PathPart("clubs") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $club = $c->model("DB::Club")->find_id_or_url_key($id_or_key, {no_prefetch => 1});
  
  if ( defined($club) ) {
    # Club found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    my $enc_full_name = encode_entities($club->full_name);
    $c->stash({
      club => $club,
      enc_full_name => $enc_full_name,
      subtitle1 => $enc_full_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Club view page (current season)
      path => $c->uri_for_action("/clubs/view_current_season", [$club->url_key]),
      label => $enc_full_name,
    });
  } else {
    # 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 base_list

Chain base for the list of clubs.  Matches /clubs

=cut

sub base_list :Chained("/") :PathPart("clubs") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_view", $c->maketext("user.auth.view-clubs"), 1]);
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( club_edit club_delete club_create) ], "", 0]);
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.clubs.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach("retrieve_paged", [1]);
  $c->stash({canonical_uri => $c->uri_for_action("/clubs/list_first_page")});
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/clubs/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/clubs/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $clubs = $c->model("DB::Club")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $clubs->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/clubs/list_first_page",
    specific_page_action => "/clubs/list_specific_page",
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/clubs/list.ttkt",
    view_online_display => "Viewing clubs",
    view_online_link => 1,
    clubs => $clubs,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

Chained to the base class; all this does is check we're authorised to view clubs, then the more relevant funcionality is in methods chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_view", $c->maketext("user.auth.view-clubs"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( club_edit club_delete team_view team_create team_edit team_delete person_edit person_delete venue_edit venue_delete ) ], "", 0]);
}

=head2 view_current_season

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.  End of chain for /clubs/*

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current_or_last;
    
  if ( defined($season) ) {
    $c->stash({
      season => $season,
      page_description => $c->maketext("description.clubs.view-current", $enc_full_name, $site_name),
    });
    
    # Get the team's details for the season.
    $c->forward("get_club_season");
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Finalise the view routine - if there is no season to display, we'll just display the details without a season.
  # We only do this if we're actually showing a view page, not a delete page
  $c->detach("view_finalise") unless exists($c->stash->{delete_screen});
}

=head2 view_specific_season

View a club only with teams for a specific season.  Matches /clubs/*/seasons/* (End of chain)

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $club = $c->stash->{club};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Validate the passed season ID
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
  
  if ( defined($season) ) {
    # Stash the season and the fact that we requested it specifically
    my $enc_season_name = encode_entities($season->name);
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      page_description => $c->maketext("description.clubs.view-specific", $enc_full_name, $enc_season_name, $site_name),
    });
  
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/clubs/view_seasons", [$club->url_key]),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/clubs/view_specific_season", [$club->url_key, $season->url_key]),
      label => $season->name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [$club->url_key],
                                {mid => $c->set_status_msg({error => "seasons.invalid-find-current"})}));
    $c->detach;
    return;
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_club_season");
  
  # Set the canonical URI for search engines to index
  $c->stash({canonical_uri => $c->uri_for_action("/clubs/view_specific_season", [$club->url_key, $season->url_key])});
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_club_season

Obtain a club's details for a given season.

=cut

sub get_club_season :Private {
  my ( $self, $c ) = @_;
  my ( $club, $season, $specific_season ) = ( $c->stash->{club}, $c->stash->{season}, $c->stash->{specific_season} );
  my $sort_column = $c->req->params->{sort};
  my $order = $c->req->params->{order};
  $sort_column = "name" unless defined( $sort_column ) and ( $sort_column eq "name" or $sort_column eq "captain" or $sort_column eq "division" or $sort_column eq "home-night" );
  $order = "asc" unless defined( $order ) and ( $order eq "asc" or $order eq "desc" );
  
  my $club_seasons = $club->get_seasons;
  my $club_season = $club->get_season($season);
  
  # Check if the name has changed since the season we're viewing
  if ( $specific_season and defined($club_season) ) {
    $c->add_status_messages({info => $c->maketext("clubs.name.changed-notice", $club_season->full_name, $club_season->short_name, $club->full_name, $club->short_name)}) if $club_season->full_name ne $club->full_name or $club_season->short_name ne $club->short_name;
    
    # Restash the club name with the season
    $c->stash({enc_full_name => encode_entities($club_season->full_name)});
  }
  
  # If we've found a season, try and find the team's statistics and players from it
  my $teams = [$c->model("DB::Team")->teams_in_club({
    club => $club,
    season => $season,
    sort => $sort_column,
    order => $order,
  })];
  
  $c->stash({
    teams => $teams,
    season => $season,
    sort => $sort_column,
    order => $order,
    club_season => $club_season,
    club_seasons => $club_seasons,
    seasons_count => $club_seasons->count,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $season = $c->stash->{season};
  my $club_season = $c->stash->{club_season};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.edit-object", $enc_full_name),
    link_uri => $c->uri_for_action("/clubs/edit", [$club->url_key]),
  }) if $c->stash->{authorisation}{club_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text => $c->maketext("admin.delete-object", $enc_full_name),
    link_uri => $c->uri_for_action("/clubs/delete", [$club->url_key]),
  }) if $c->stash->{authorisation}{club_delete} and $club->can_delete;
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("/clubs/view_specific_season", [$club->url_key, $season->url_key])
    : $c->uri_for_action("/clubs/view_current_season", [$club->url_key]);
  
  # Set up the template to use
  $c->stash({
    template => "html/clubs/view.ttkt",
    title_links => \@title_links,
    subtitle1 => $enc_full_name,
    view_online_display => sprintf( "Viewing %s", $club->full_name ),
    view_online_link => 1,
    canonical_uri => $canonical_uri,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/clubs/view.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Get the seasons this club has entered
  my $seasons = $club->get_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/clubs/seasons.js"),
    ];
    $ext_styles = [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ];
  } else {
    $ext_scripts = [$c->uri_for("/static/script/standard/option-list.js")];
    $ext_styles = [];
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/clubs/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.season"),
    page_description => $c->maketext("description.clubs.list-seasons", $enc_full_name, $site_name),
    view_online_display => sprintf( "Viewing seasons for %s", $club->full_name ),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/clubs/view_seasons", [$club->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 create

Display a form to collect information for creating a club.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_create", $c->maketext("user.auth.create-clubs"), 1]);
  
  my $venues = [$c->model("DB::Venue")->active_venues];
  
  # If we have no venues to select, we must create them first
  unless ( scalar(@{$venues}) ) {
    # Check we can create venues - if not, we'll have to redirect ot the home page
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_create", "", 0]);
    
    if ( $c->stash->{authorisation}{venue_create} ) {
      $c->response->redirect($c->uri_for("/venues/create",
                                  {mid => $c->set_status_msg({error => $c->maketext("clubs.create.error.no-venues")})}));
    } else {
      $c->response->redirect($c->uri_for("/",
                                  {mid => $c->set_status_msg({error => $c->maketext("clubs.create.error.no-venues")})}));
    }
    
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
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed
    $tokeninput_options->{prePopulate} = [{id => $c->flash->{secretary}->id, name => $c->flash->{secretary}->display_name}] if defined($c->flash->{secretary});
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json( $tokeninput_options ),
      selector => "secretary",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/clubs/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/clubs/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    venues => $venues,
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating clubs",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/clubs/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to edit clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_edit", $c->maketext("user.auth.edit-clubs"), 1]);
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed - prioritise flashed values
    my $secretary;
    if ( defined($c->flash->{secretary}) and ref($c->flash->{secretary}) eq "TopTable::Model::DB::Person" ) {
      $secretary = $c->flash->{secretary};
    } else {
      $secretary = $club->secretary;
    }
    
    $tokeninput_options->{prePopulate} = [{id => $secretary->id, name => $secretary->display_name}] if defined( $secretary );
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json( $tokeninput_options ),
      selector => "secretary",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues to list
  $c->stash({
    template => "html/clubs/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/clubs/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    venues => [$c->model("DB::Venue")->active_venues],
    form_action => $c->uri_for_action("/clubs/do_edit", [$club->url_key]),
    view_online_display => "Editing " . $club->full_name,
    view_online_link => 0,
    subtitle1 => $enc_full_name,
    subtitle2 => $c->maketext("admin.edit"),
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/clubs/edit", [$club->url_key]),
    label => $c->maketext("admin.edit"),
  });
  
  # Flash the current club's data to display
  # Split the time up.
  my @time_bits = split(":", $club->default_match_start) if defined($club->default_match_start);
  
  $c->flash->{secretary} = $club->secretary if !$c->flash->{secretary} and defined( $club->secretary );
  $c->flash->{venue} = $club->venue->id if !$c->flash->{venue} and defined( $club->venue );
  $c->flash->{start_hour} = $time_bits[0] if !$c->flash->{start_hour};
  $c->flash->{start_minute} = $time_bits[1] if !$c->flash->{start_minute};
}

=head2 delete

Display the form asking if the user really wants to delete the club.  Note the club can't be deleted if it has teams attached either in the current or in any historical seasons.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_delete", $c->maketext("user.auth.delete-clubs"), 1]);
  
  unless ( $club->can_delete ) {
    $c->response->redirect($c->uri_for_action("/clubs/view_current_season", [$club->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("clubs.delete.error.cannot-delete", $enc_full_name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $enc_full_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/clubs/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $club->full_name),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/clubs/delete", [$club->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a club. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_create", $c->maketext("user.auth.create-clubs"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_edit", $c->maketext("user.auth.edit-clubs"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion form and delete a club (if possible).

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $enc_full_name = $c->stash->{enc_full_name};
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_delete", $c->maketext("user.auth.delete-clubs"), 1]);
  
  my $response = $club->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/clubs/list_first_page", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["club", "delete", {id => undef}, $enc_full_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/clubs/view_current_season", [$club->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Forwarded from docreate and doedit to do the club creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $club = $c->stash->{club};
  my @field_names = qw( full_name short_name abbreviated_name email_address website start_hour start_minute venue secretary );
  
  # The rest of the error checking is done in the Club model
  my $response = $c->model("DB::Club")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    club => $club, # This will be undef if we're creating.
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
    $club = $response->{club};
    $redirect_uri = $c->uri_for_action("/clubs/view_current_season", [$club->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["club", $action, {id => $club->id}, $club->full_name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/clubs/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/clubs/edit", [$club->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    $c->flash->{$_} = $response->{fields}{$_} foreach @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["club_view", $c->maketext("user.auth.view-clubs"), 1]);
  
  $c->stash({
    db_resultset => "Club",
    query_params => {q => $c->req->params->{q}},
    view_action => "/clubs/view_current_season",
    search_action => "/clubs/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.clubs") ),
  });
  
  # Do the search
  $c->forward("TopTable::Controller::Search", "do_search");
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
