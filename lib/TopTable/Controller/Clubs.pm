package TopTable::Controller::Clubs;
use Moose;
use namespace::autoclean;
use Regexp::Common qw/URI/;
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
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.clubs") });
  
  # Breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    # Clubs listing
    path  => $c->uri_for("/clubs"),
    label => $c->maketext("menu.text.clubs"),
  });
}

=head2 base

Chain base for getting the club ID and checking it.

=cut

sub base :Chained("/") :PathPart("clubs") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $club = $c->model("DB::Club")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $club ) ) {
    # Club found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    my $encoded_club_full_name = encode_entities( $club->full_name );
    $c->stash({
      club                    => $club,
      encoded_club_full_name  => $encoded_club_full_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      # Club view page (current season)
      path  => $c->uri_for_action("/clubs/view_current_season", [$club->url_key]),
      label => $encoded_club_full_name,
    });
  } else {
    # 404
    $c->detach( qw/TopTable::Controller::Root default/ );
    return;
  }
}

=head2 base_list

Chain base for the list of clubs.  Matches /clubs

=cut

sub base_list :Chained("/") :PathPart("clubs") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_view", $c->maketext("user.auth.view-clubs"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( club_edit club_delete club_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description  => $c->maketext("description.clubs.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
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
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $clubs = $c->model("DB::Club")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $clubs->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/clubs/list_first_page",
    specific_page_action  => "/clubs/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/clubs/list.ttkt",
    view_online_display => "Viewing clubs",
    view_online_link    => 1,
    clubs               => $clubs,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

Chained to the base class; all this does is check we're authorised to view clubs, then the more relevant funcionality is in methods chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_view", $c->maketext("user.auth.view-clubs"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( club_edit club_delete team_view team_create ) ], "", 0] );
}

=head2 view_current_season

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.  End of chain for /clubs/*

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $club      = $c->stash->{club};
  my $site_name = $c->stash->{encoded_site_name};
  my $club_name = $c->stash->{encoded_club_full_name};
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined($season);
    
  if ( defined( $season ) ) {
    $c->stash({
      season            => $season,
      page_description  => $c->maketext("description.clubs.view-current", $club_name, $site_name),
    });
    
    # Get the team's details for the season.
    $c->forward("get_club_season");
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
  
  # Finalise the view routine - if there is no season to display, we'll just display the details without a season.
  # We only do this if we're actually showing a view page, not a delete page
  $c->detach("view_finalise") unless exists( $c->stash->{delete_screen} );
}

=head2 view_specific_season

View a club only with teams for a specific season.  Matches /clubs/*/seasons/* (End of chain)

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $club      = $c->stash->{club};
  my $site_name = $c->stash->{encoded_site_name};
  my $club_name = $c->stash->{encoded_club_full_name};
  
  # Validate the passed season ID
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key );
  
  if ( defined($season) ) {
    # Stash the season and the fact that we requested it specifically
    my $encoded_season_name = encode_entities( $season->name );
    $c->stash({
      season              => $season,
      encoded_season_name => $encoded_season_name,
      specific_season     => 1,
      subtitle2           => $encoded_season_name,
      page_description    => $c->maketext("description.clubs.view-specific", $club_name, $encoded_season_name, $site_name),
    });
  
    # Push the season list URI and the current URI on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/clubs/view_seasons_first_page", [$club->url_key]),
      label => $c->maketext("menu.text.seasons"),
    }, {
      path  => $c->uri_for_action("/clubs/view_specific_season", [$club->url_key, $season->url_key]),
      label => $season->name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [$club->url_key],
                                {mid => $c->set_status_msg( {error => "seasons.invalid-find-current"} ) }) );
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
  my ( $club, $season ) = ( $c->stash->{club}, $c->stash->{season} );
  my $sort_column = $c->request->parameters->{sort};
  my $order       = $c->request->parameters->{order};
  $sort_column    = "name" unless defined( $sort_column ) and ( $sort_column eq "name" or $sort_column eq "captain" or $sort_column eq "division" or $sort_column eq "home-night" );
  $order          = "asc" unless defined( $order ) and ( $order eq "asc" or $order eq "desc" );
  
  my $club_seasons = $club->get_seasons;
  $c->log->debug( sprintf( "Seasons: %s, ref %s, count: %s", $club_seasons, ref( $club_seasons ), $club_seasons->count ) );
  
  # If we've found a season, try and find the team's statistics and players from it
  my $teams = [ $c->model("DB::Team")->teams_in_club({
    club    => $club,
    season  => $season,
    sort    => $sort_column,
    order   => $order,
  }) ];
  
  $c->stash({
    teams         => $teams,
    season        => $season,
    sort          => $sort_column,
    order         => $order,
    club_season   => $club->get_season({season => $season}),
    club_seasons  => $club_seasons,
    seasons_count => $club_seasons->count,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $club        = $c->stash->{club};
  my $season      = $c->stash->{season};
  my $club_season = $c->stash->{club_season};
  my $encoded_club_full_name = $c->stash->{encoded_club_full_name};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text      => $c->maketext("admin.edit-object", $encoded_club_full_name),
    link_uri  => $c->uri_for_action("/clubs/edit", [$club->url_key]),
  }) if $c->stash->{authorisation}{club_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text      => $c->maketext("admin.delete-object", $encoded_club_full_name),
    link_uri  => $c->uri_for_action("/clubs/delete", [$club->url_key]),
  }) if $c->stash->{authorisation}{club_delete} and $club->can_delete;
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/clubs/view_specific_season", [$club->url_key, $season->url_key])
    : $c->uri_for_action("/clubs/view_current_season", [$club->url_key]);
  
  # Set up the template to use
  $c->stash({
    template            => "html/clubs/view.ttkt",
    title_links         => \@title_links,
    subtitle1           => $encoded_club_full_name,
    view_online_display => sprintf( "Viewing %s", $club->full_name ),
    view_online_link    => 1,
    canonical_uri       => $canonical_uri,
    external_scripts    => [
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/clubs/view.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $club      = $c->stash->{club};
  my $site_name = $c->stash->{encoded_site_name};
  my $club_name = $c->stash->{encoded_club_full_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template          => "html/clubs/list-seasons.ttkt",
    page_description  => $c->maketext("description.clubs.list-seasons", $club_name, $site_name),
    external_scripts      => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/clubs/view_seasons_first_page", [$club->url_key]),
    label => $c->maketext("menu.text.seasons"),
  });
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  
  $c->stash({canonical_uri => $c->uri_for_action("/clubs/view_seasons_first_page", [$club->url_key])});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $club = $c->stash->{club};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/clubs/view_seasons_first_page", [$club->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/clubs/view_seasons_specific_page", [$club->url_key, $page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $club = $c->stash->{club};
  my $encoded_club_full_name = $c->stash->{encoded_club_full_name};
  
  my $seasons = $c->model("DB::Season")->page_records({
    club              => $club,
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/clubs/view_seasons_first_page",
    page1_action_arguments          => [$club->url_key],
    specific_page_action            => "/clubs/view_seasons_specific_page",
    specific_page_action_arguments  => [$club->url_key],
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/clubs/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $club->full_name ),
    view_online_link    => 1,
    seasons             => $seasons,
    subtitle1           => $encoded_club_full_name,
    subtitle2           => $c->maketext("menu.text.seasons"),
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 ajax_search

Handle search requests and return the data in JSON.

=cut

sub ajax_search :Path('ajax-search') :Args(0) {
  my ( $self, $c ) = @_;
  
  if (defined($c->request->parameters->{q})) {
    # Perform the search
    my @clubs       = $c->model("DB::Club")->search_by_name( $c->request->parameters->{q} );
    my $json_clubs  = [];
    
    # Loop through and concatenate the short club name and team name, then push it on to the $json_teams arrayref
    foreach my $club (@clubs) {
      push( @{$json_clubs}, {id => $club->id, name => $club->full_name} );
    }
    
    # Set up the stash
    $c->stash({json_clubs => $json_clubs});
    
    # Detach to the JSON view
    $c->detach( $c->view("JSON") );
  }
  
  # Don't alter the view who's online activity
  $c->stash->{skip_view_online} = 1;
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_create", $c->maketext("user.auth.create-clubs"), 1] );
  
  my $venues = [ $c->model("DB::Venue")->all_venues ];
  
  # If we have no venues to select, we must create them first
  unless ( scalar( @{$venues} ) ) {
    # Check we can create venues - if not, we'll have to redirect ot the home page
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["venue_create", "", 0] );
    
    if ( $c->stash->{authorisation}{venue_create} ) {
      $c->response->redirect( $c->uri_for("/venues/create",
                                  {mid => $c->set_status_msg( {error => "clubs.create.error.no-venues"} ) }) );
    } else {
      $c->response->redirect( $c->uri_for("/",
                                  {mid => $c->set_status_msg( {error => "clubs.create.error.no-venues"} ) }) );
    }
    
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_people",
      tokenLimit    => 1,
      hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add the pre-population if needed
    $tokeninput_options->{prePopulate} = [{id => $c->flash->{secretary}->id, name => $c->flash->{secretary}->display_name}] if defined( $c->flash->{secretary} );
    
    my $tokeninput_confs = [{
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $tokeninput_options ),
      selector  => "secretary",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template            => "html/clubs/create-edit.ttkt",
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/clubs/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    venues              => $venues,
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating clubs",
    view_online_link    => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/clubs/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $club = $c->stash->{club};
  my $encoded_club_full_name = $c->stash->{encoded_club_full_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to edit clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_edit", $c->maketext("user.auth.edit-clubs"), 1] );
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_people",
      tokenLimit    => 1,
      hintText      => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed - prioritise flashed values
    my $secretary;
    if ( defined( $c->flash->{secretary} ) and ref( $c->flash->{secretary} ) eq "TopTable::Model::DB::Person" ) {
      $secretary = $c->flash->{secretary};
    } else {
      $secretary = $club->secretary;
    }
    
    $tokeninput_options->{prePopulate} = [{id => $secretary->id, name => $secretary->display_name}] if defined( $secretary );
    
    my $tokeninput_confs = [{
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $tokeninput_options ),
      selector  => "secretary",
    }];
    
    $c->stash({
      tokeninput_confs => $tokeninput_confs,
    });
  }
  
  # Get venues to list
  $c->stash({
    template            => "html/clubs/create-edit.ttkt",
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/clubs/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    venues              => [$c->model("DB::Venue")->all_venues],
    form_action         => $c->uri_for_action("/clubs/do_edit", [$club->url_key]),
    view_online_display => "Editing " . $club->full_name,
    view_online_link    => 0,
    subtitle1           => $encoded_club_full_name,
    subtitle2           => $c->maketext("admin.edit"),
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/clubs/edit", [$club->url_key]),
    label => $c->maketext("admin.edit"),
  });
  
  # Flash the current club's data to display
  # Split the time up.
  my @time_bits = split( ":", $club->default_match_start ) if defined( $club->default_match_start );
  
  $c->flash->{secretary}    = $club->secretary  if !$c->flash->{secretary} and defined( $club->secretary );
  $c->flash->{venue}        = $club->venue->id  if !$c->flash->{venue} and defined( $club->venue );
  $c->flash->{start_hour}   = $time_bits[0]     if !$c->flash->{start_hour};
  $c->flash->{start_minute} = $time_bits[1]     if !$c->flash->{start_minute};
}

=head2 delete

Display the form asking if the user really wants to delete the club.  Note the club can't be deleted if it has teams attached either in the current or in any historical seasons.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  my $encoded_club_full_name = $c->stash->{encoded_club_full_name};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_delete", $c->maketext("user.auth.delete-clubs"), 1] );
  
  unless ( $club->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [$club->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "clubs.delete.error.cannot-delete", encode_entities( $club->full_name ) )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1           => $encoded_club_full_name,
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/clubs/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $club->full_name ),
    view_online_link    => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/clubs/delete", [$club->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a club. 

=cut

sub do_create :Path("do-create") {
  my ($self, $c, $club_id) = @_;
  my ( $club );
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_create", $c->maketext("user.auth.create-clubs"), 1] );
  
  # Forward to the create / edit routine
  $c->detach( "setup_club", ["create"] );
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_edit", $c->maketext("user.auth.edit-clubs"), 1] );
  
  # Forward to the create / edit routine
  $c->detach( "setup_club", ["edit"] );
}

=head2 do_delete

Process the deletion form and delete a club (if possible).

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $club      = $c->stash->{club};
  my $club_name = $club->full_name;
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_delete", $c->maketext("user.auth.delete-clubs"), 1] );
  
  my $error = $club->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/clubs/view", [ $club->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["club", "delete", {id => undef}, $club_name] );
    $c->response->redirect( $c->uri_for("/clubs",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $club_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_club

Forwarded from docreate and doedit to do the club creation / edit.

=cut

sub setup_club :Private {
  my ( $self, $c ) = @_;
  my $action  = $c->request->arguments->[0];
  my $club    = $c->stash->{club};
  
  # Validate the venue / secretary
  my $venue     = $c->model("DB::Venue")->find( $c->request->parameters->{venue} ) if $c->request->parameters->{venue};
  my $secretary = $c->model("DB::Person")->find( $c->request->parameters->{secretary} ) if $c->request->parameters->{secretary};
  
  # The rest of the error checking is done in the Club model
  my $actioned = $c->model("DB::Club")->create_or_edit($action, {
    club              => $club,
    full_name         => $c->request->parameters->{full_name},
    short_name        => $c->request->parameters->{short_name},
    abbreviated_name  => $c->request->parameters->{abbreviated_name},
    email_address     => $c->request->parameters->{email_address},
    website           => $c->request->parameters->{website},
    start_hour        => $c->request->parameters->{start_hour},
    start_minute      => $c->request->parameters->{start_minute},
    venue             => $venue,
    secretary         => $secretary,
  });
  
  if ( scalar( @{ $actioned->{error} } ) > 0 ) {
    my $error = $c->build_message( $actioned->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{full_name}        = $c->request->parameters->{full_name};
    $c->flash->{short_name}       = $c->request->parameters->{short_name};
    $c->flash->{abbreviated_name} = $c->request->parameters->{abbreviated_name};
    $c->flash->{address1}         = $c->request->parameters->{address1};
    $c->flash->{address2}         = $c->request->parameters->{address2};
    $c->flash->{address3}         = $c->request->parameters->{address3};
    $c->flash->{address4}         = $c->request->parameters->{address4};
    $c->flash->{address5}         = $c->request->parameters->{address5};
    $c->flash->{postcode}         = $c->request->parameters->{postcode};
    $c->flash->{telephone}        = $c->request->parameters->{telephone};
    $c->flash->{email_address}    = $c->request->parameters->{email_address};
    $c->flash->{secretary}        = $secretary;
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      # If we're creating, we'll just redirect straight back to the create form
      $redirect_uri = $c->uri_for("/clubs/create",
                            {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      # If we're editing and we found an object to edit, we'll redirect to the edit form for that object
      $redirect_uri = $c->uri_for_action("/clubs/edit", [ $club->url_key ],
                          {mid => $c->set_status_msg( {error => $error} ) });
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $action_description;
    if ( $action eq "create" ) {
      $club = $actioned->{club};
      $action_description = $c->maketext("admin.message.created");
    } else {
      $action_description = $c->maketext("admin.message.edited");
    }
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["club", $action, {id => $club->id}, $club->full_name] );
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [$club->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", encode_entities( $club->full_name ), $action_description )} ) }) );
    $c->detach;
    return;
  }
}

=head2 history

Create historical club_seasons records for clubs if they don't exist.

=cut

sub history :Chained("base") :PathPart("history") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  
  # Check that we are authorised to edit clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["club_edit", $c->maketext("user.auth.edit-clubs"), 1] );
  
  # Create history if the club needs it
  my $error = $club->create_history;
  
  if ( defined( $error ) and $error ) {
    # Errored
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [ $club->url_key ],
      {mid => $c->set_status_msg({error => $c->maketext($error)})} ) );
  } else {
    
    $c->response->redirect( $c->uri_for_action("/clubs/view_current_season", [ $club->url_key ],
      {mid => $c->set_status_msg({success => $c->maketext("clubs.history.success")})} ) );
  }
  
  # Detach / return here, as we are definitely redirecting
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
