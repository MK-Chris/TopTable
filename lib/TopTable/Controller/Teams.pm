package TopTable::Controller::Teams;
use Moose;
use namespace::autoclean;
use JSON;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Teams - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.teams")});
   
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/teams"),
    label => $c->maketext("menu.text.teams"),
  });
}


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;

  # Retrieve all of the clubs to display
  $c->forward("list");
}

=head2 base_by_id

Chain base for getting the club ID and checking it.

=cut

sub base_by_id :Chained("/") :PathPart("teams") :CaptureArgs(1) {
  my ($self, $c, $team_id) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $team = $c->model("DB::Team")->find_with_prefetches($team_id);
  
  if ( defined( $team ) ) {
    my $encoded_name = encode_entities( sprintf( "%s %s", $team->club->short_name, $team->name ) );
    
    $c->stash({
      team          => $team,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Breadcrumbs
    push(@{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $encoded_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_by_url_key

Chain base for getting the club ID and checking it.

=cut

sub base_by_url_key :Chained("/") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $club = $c->model("DB::Club")->find_url_key( $club_url_key );
  my $team = $c->model("DB::Team")->find_url_key( $club, $team_url_key ) if defined ( $club );
  
  if ( defined($team) ) {
    my $encoded_name = encode_entities( sprintf( "%s %s", $team->club->short_name, $team->name ) );
    
    $c->stash({
      team          => $team,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Breadcrumbs
    push(@{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $encoded_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_no_object_specified

Base URL matcher with no team specified (used in the create routines).  Doesn't actually do anything other than the URL matching and loading status messages.

=cut

sub base_no_object_specified :Chained("/") :PathPart("teams") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list

List the clubs that match the criteria offered in the provided arguments.

=cut

sub list :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( team_create team_edit team_delete ) ], "", 0] );
  
  # Retrieve all of the clubs to display
  $c->stash(teams => [$c->model("DB::Team")->search({}, {
    join      => "club",
    order_by  => {-asc => ["club.full_name", "name"]}
  })]);
  
  # Set up the template to use
  $c->stash({
    template            => "html/teams/list.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/standard/accordion.js"),
    ],
    view_online_display => "Viewing teams",
    view_online_link    => 1,
  });
}

=head2 ajax_search

Handle search requests and return the data in JSON.

=cut

sub ajax_search :Path("ajax-search") :Args(0) {
  my ( $self, $c ) = @_;
  my $season_id_or_url_key = $c->request->parameters->{season} if exists( $c->request->parameters->{season} );
  
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key ) if defined( $season_id_or_url_key );
  $c->detach( "TopTable::Controller::Root", "json_error", [400, "The season specified is invalid."] ) if defined( $season_id_or_url_key ) and !defined( $season );
  
  if ( defined( $c->request->parameters->{q} ) and defined( $season ) ) {
    # Perform the search
    my @teams       = $c->model("DB::Team")->search_by_name( $c->request->parameters->{q}, $season );
    my $json_teams  = [];
    
    # Loop through and concatenate the short club name and team name, then push it on to the $json_teams arrayref
    push( @{$json_teams}, {id => $_->id, name => encode_entities( sprintf( "%s %s", $_->club->short_name, $_->name ) )} ) foreach (@teams);
    
    # Set up the stash
    $c->stash({json_teams => $json_teams});
    
    # Detach to the JSON view
    $c->detach( $c->view("JSON") );
  }
  
  # Don't alter the view who's online activity
  $c->stash->{skip_view_online} = 1;
}

=head2 view_by_id

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_id :Chained("base_by_id") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->forward( "view" );
}

=head2 view_by_url_key

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_url_key :Chained("base_by_url_key") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->forward( "view" );
}

=head2 view

Private function to check we have permissions to view teams (forwarded from the view_by_id and view_by_url_key routines).

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view teams
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( team_create team_edit team_delete person_create ) ], "", 0] );
}

=head2 view_current_season_by_id

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season_by_id :Chained("view_by_id") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real routine
  $c->detach("view_current_season");
}

=head2 view_current_season_by_url_key

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season_by_url_key :Chained("view_by_url_key") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real routine
  $c->forward("view_current_season");
}

=head2 view_current_season

Private function to grab the current (or last complete) season for viewing the team.  Forward from view_current_season_by_id and view_current_season_by_url_key.

=cut

sub view_current_season :Private {
  my ( $self, $c ) = @_;
  
  # No season ID, try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season if !defined($season);
    
  if ( defined( $season ) ) {
    my $encoded_season_name = encode_entities( $season->name );
    
    # Check authorisation to update / cancel matches.  Only do this for 'view current season' (and even then only if it's not complete)
    # because nobody can update or cancel matches once the season is complete.
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0] ) unless $season->complete;
    
    $c->stash({
      season              => $season,
      encoded_season_name => $encoded_season_name,
    });
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
  
  # Get the team's details for the season.
  $c->forward("get_team_season");
  
  # Finalise the view routine
  $c->detach("view_finalise") unless exists( $c->stash->{delete_screen} );
}

=head2 view_specific_season_by_id

View a team with a specific season's details.

=cut

sub view_specific_season_by_id :Chained("view_by_id") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  
  # Forward to the real routine
  $c->forward( "view_specific_season", [$season_id_or_url_key] );
}

=head2 view_specific_season_by_url_key

View a team with a specific season's details.

=cut

sub view_specific_season_by_url_key :Chained("view_by_url_key") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  
  # Forward to the real routine
  $c->forward( "view_specific_season", [$season_id_or_url_key] );
}

=head2 view_specific_season

Private function to retrieve the specific season that for viewing a team.  Forwarded from view_specific_season_by_id and view_specific_season_by_url_key

=cut

sub view_specific_season :Private {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $team = $c->stash->{team};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined( $season ) ) {
    my $encoded_season_name = encode_entities( $season->name );
    
    $c->stash({
      season              => $season,
      specific_season     => 1,
      encoded_season_name => $encoded_season_name,
    });
    
    # Breadcrumbs
    push(@{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/teams/view_seasons_first_page_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $c->maketext("menu.text.seasons"),
    }, {
      path  => $c->uri_for_action("/teams/view_specific_season_by_url_key", [$team->club->url_key, $team->url_key, $season->url_key]),
      label => $encoded_season_name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg( {error => "seasons.invalid-find-current"} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_team_season");
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_team_season

Obtain a team's details for a given season.

=cut

sub get_team_season :Private {
  my ( $self, $c ) = @_;
  my ( $team, $season ) = ( $c->stash->{team}, $c->stash->{season} );
  my $specific_season = $c->stash->{specific_season};
  
  # If we've found a season, try and find the team's statistics and players from it
  #my $team_season = $c->model("DB::TeamSeason")->find({
  my $team_season = $team->get_season( $season );
  
  # Check if the name has changed since the season we're viewing
  $c->add_status_message( "info", $c->maketext( "teams.club.changed-notice", $team_season->club->short_name, $team_season->name, $c->uri_for_action("/clubs/view_current_season", [$team->club->url_key]), $team->club->full_name ) ) if $specific_season and $team_season->club->id != $team->club->id;
  $c->add_status_message( "info", $c->maketext( "teams.name.changed-notice", $team_season->club->short_name, $team_season->name, $team->club->short_name, $team->name ) ) if $specific_season and $team_season->name ne $team->name;
  
  # Get the team's position - we need to get all teams in the division in an array ordered properly first
  my @teams_in_division = $c->model("DB::TeamSeason")->get_teams_in_division_in_league_table_order( $season, $team_season->division );
  
  # Now we need to loop throug the array, counting up as we go
  my $league_position = 0;
  foreach my $division_team ( @teams_in_division ) {
    # Increment our count
    $league_position++;
    
    # Exit the loop once we find this team
    last if $division_team->team->id == $team->id;
  }
  
  # $team_players is called averages in the stash so we can include the team averages table
  $c->stash({
    team_season                 => $team_season,
    singles_averages            => [ $c->model("DB::PersonSeason")->get_people_in_division_in_singles_averages_order({
      season    => $season,
      division  => $team_season->division,
      team      => $team,
    } ) ],
    doubles_individual_averages => [ $c->model("DB::PersonSeason")->get_people_in_division_in_doubles_individual_averages_order({
      season          => $season,
      division        => $team_season->division,
      team            => $team,
      criteria_field  => "played",
      operator        => ">=",
      criteria        => 1,
    }) ],
    doubles_pair_averages       => [ $c->model("DB::DoublesPair")->get_doubles_pairs_in_division_in_averages_order({
      season          => $season,
      division        => $team_season->division,
      team            => $team,
      criteria_field  => "played",
      operator        => ">=",
      criteria        => 1,
    }) ],
    averages_team_page          => 1,
    season                      => $season,
    league_position             => $league_position,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $team                = $c->stash->{team};
  my $season              = $c->stash->{season};
  my $encoded_season_name = $c->stash->{encoded_season_name};
  my $team_season         = $c->stash->{team_season};
  my $specific_season     = $c->stash->{specific_season};
  my $encoded_name        = $c->stash->{encoded_name};
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/teams/view_specific_season_by_url_key", [$team->club->url_key, $team->url_key, $season->url_key])
    : $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text      => $c->maketext("admin.edit-object", $encoded_name ),
    link_uri  => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
  }) if $c->stash->{authorisation}{team_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text      => $c->maketext("admin.delete-object", $encoded_name ),
    link_uri  => $c->uri_for_action("/teams/delete_by_url_key", [$team->club->url_key, $team->url_key]),
  }) if $c->stash->{authorisation}{team_delete} and $team->can_delete;
  
  # Get the matches for the fixtures tab
  my $matches = $c->model("DB::TeamMatch")->matches_for_team({
    team              => $team,
    season            => $season,
  });
  
  # Set up the template to use
  $c->stash({
    template            => "html/teams/view.ttkt",
    title_links         => \@title_links,
    subtitle2           => $encoded_season_name,
    canonical_uri       => $canonical_uri,
    external_scripts    => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/standard/responsive-tabs.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    ],
    view_online_display => sprintf( "Viewing %s", $encoded_name ),
    view_online_link    => 1,
    no_filter           => 1, # Don't include the averages filter form on a team averages view
    matches             => $matches,
    seasons             => $team->seasons->count,
  });
}

=head2 view_seasons_by_url_key

Display the list of seasons when specifying the URL key in the URL

=cut

sub view_seasons_by_url_key :Chained("view_by_url_key") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real routine
  $c->forward("view_seasons");
}

=head2 view_seasons_by_id

Display the list of seasons when specifying the ID in the URL

=cut

sub view_seasons_by_id :Chained("view_by_id") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real routine
  $c->forward("view_seasons");
}

=head2 view_seasons

Retrieve and display a list of seasons that this team has entered teams into.

=cut

sub view_seasons :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/teams/view_seasons_first_page_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("menu.text.seasons"),
  });
}

=head2 view_seasons_first_page_by_url_key

List the seasons on the first page.

=cut

sub view_seasons_first_page_by_url_key :Chained("view_seasons_by_url_key") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_seasons_first_page");
}

=head2 view_seasons_first_page_by_id

List the seasons on the first page.

=cut

sub view_seasons_first_page_by_id :Chained("view_seasons_by_id") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_seasons_first_page");
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  $c->stash({canonical_uri => $c->uri_for_action("/teams/view_seasons_first_page", [$team->club->url_key, $team->url_key])});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page_by_url_key

List the seasons on the first page.

=cut

sub view_seasons_specific_page_by_url_key :Chained("view_seasons_by_url_key") :PathPart("page") :Args(1) {
  my ( $self, $c ) = @_;
  $c->detach("view_seasons_specific_page");
}

=head2 view_seasons_specific_page_by_id

List the seasons on the first page.

=cut

sub view_seasons_specific_page_by_id :Chained("view_seasons_by_id") :PathPart("page") :Args(1) {
  my ( $self, $c ) = @_;
  $c->detach("view_seasons_specific_page");
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Private {
  my ( $self, $c, $page_number ) = @_;
  my $team = $c->stash->{team};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/teams/view_seasons_first_page", [$team->club->url_key, $team->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/teams/view_seasons_specific_page", [$team->club->url_key, $team->url_key, $page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $team = $c->stash->{team};
  
  my $seasons = $c->model("DB::Season")->page_records({
    team              => $team,
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/teams/view_seasons_first_page",
    page1_action_arguments          => [$team->club->url_key, $team->url_key],
    specific_page_action            => "/teams/view_seasons_specific_page",
    specific_page_action_arguments  => [$team->club->url_key, $team->url_key],
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/teams/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for %s %s", $team->club->short_name, $team->name ),
    view_online_link    => 1,
    seasons             => $seasons,
    subtitle2           => $c->maketext("menu.text.seasons"),
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 create

Display a form to collect information for creating a team.

=cut

sub create :Chained("base_no_object_specified") :PathPart("create") :CaptureArgs(0) {
  my ($self, $c) = @_;
  my ( $current_season, $error, $captain_tokeninput_options );
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_create", $c->maketext("user.auth.create-teams"), 1] );
  
  # Get the current season
  $current_season = $c->model("DB::Season")->get_current;
  
  if ( defined( $current_season ) ) {
    # If there us a current season, we need to check we haven't progressed through
    # the season too much to add teams.
    # Check if we have any matches; if not, allow team creation
    if ( $c->model("DB::TeamMatch")->season_matches($current_season)->count > 0 ) {
      # Redirect and show the error
      $c->response->redirect( $c->uri_for("/",
                                  {mid => $c->set_status_msg( {error => $c->maketext("teams.form.error.matches-exist")} ) }) );
      $c->detach;
      return;
    }
  } else {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("teams.form.error.no-current-season", $c->maketext("admin.message.created"))} ) }) );
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $captain_tokeninput_options = {
      jsonContainer => "json_people",
      tokenLimit    => 1,
      hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add the pre-population if needed
    $captain_tokeninput_options->{prePopulate} = [{id => $c->flash->{captain}->id, name => $c->flash->{captain}->display_name}] if defined( $c->flash->{captain} );
    
    my $players_tokeninput_options = {
      jsonContainer => "json_people",
      hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add pre-population if we need it
    if ( exists( $c->flash->{players} ) and ref( $c->flash->{players} ) eq "ARRAY" ) {
      foreach my $player ( @{ $c->flash->{players} } ) {
        push(@{ $players_tokeninput_options->{prePopulate} }, {
          id    => $player->id,
          name  => $player->display_name,
        });
      }
    }
    
    my $tokeninput_confs = [{
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $captain_tokeninput_options ),
      selector  => "captain",
    }, {
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $players_tokeninput_options ),
      selector  => "players",
    }];
    
    $c->stash({
      tokeninput_confs => $tokeninput_confs,
    });
  }
  
  # Stash the things we need to show the creation form
  $c->stash({
    template            => "html/teams/create-edit.ttkt",
    scripts             =>  [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/teams/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    clubs               => [ $c->model("DB::Club")->all_clubs_by_name ],
    divisions           => [ $current_season->divisions ],
    home_nights         => [ $c->model("DB::LookupWeekday")->all_days ],
    current_season      => $current_season,
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating teams",
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/teams/create_no_club"),
    label => $c->maketext("admin.create"),
  });
}

=head2 create_with_club

Create URL with club specified for pre-selection.

=cut

sub create_with_club :Chained("create") :PathPart("club") :Args(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  # Flash the club with what's provided in the params if needed
  if ( defined ( my $club = $c->model("DB::Club")->find_id_or_url_key( $id_or_url_key ) ) ) {
    $c->flash->{club} = $club->id;
  } else {
    $c->detach( "TopTable::Controller::Root", "default" );
  }
}

=head2 create_no_club

Create URL for create with no club specified.  This doesn't do anything other than specify the end of a chain.

=cut

sub create_no_club :Chained("create") :PathPart("") :Args(0) {}

=head2 edit_by_id

Handles an edit request by ID (forwards to the real edit routine)

=cut

sub edit_by_id :Chained("base_by_id") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "edit" );
}

=head2 edit_by_url_key

Handles an edit request by URL key (forwards to the real edit routine)

=cut

sub edit_by_url_key :Chained("base_by_url_key") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "edit" );
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Private {
  my ( $self, $c ) = @_;
  my ( $current_season, $mid_season, $team_season, $divisions, $last_team_season, $last_team_season_changes );
  my $team = $c->stash->{team};
  my $encoded_name = $c->stash->{encoded_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_edit", $c->maketext("user.auth.edit-teams"), 1] );
  
  # Get the current season
  $current_season = $c->model("DB::Season")->get_current;
  
  if ( defined( $current_season ) ) {
    # If there us a current season, we need to check we haven't progressed through
    # the season too much to edit some fields.
    my $league_matches = $c->model("DB::TeamMatch")->season_matches($current_season)->count;
    
    # Check if we have any rows; if so, we will disable some fields
    $mid_season = 1 if $league_matches > 0;
    
    # Get the team's season
    $team_season = $team->get_season( $current_season );
    
    # Get divisions based on which divisions have an association with the current season.
    $divisions = [ $current_season->divisions ],
  } else {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg( {error => $c->maketext("teams.form.error.no-current-season", $c->maketext("admin.message.edited"))} ) }) );
    $c->detach;
    return;
  }
  
  # Get the last team season
  $last_team_season = $c->model("DB::Season")->last_complete_season( $team );
  
  my $home_night;
  if ( defined( $team_season ) ) {
    $home_night = $team_season->home_night->weekday_number;
  } elsif ( defined( $last_team_season ) ) {
    $home_night = $last_team_season->home_night->weekday_number;
  }
  
  # Get the number of people - if there are none, then we need to display a message
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $captain_tokeninput_options = {
      jsonContainer => "json_people",
      tokenLimit    => 1,
      hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add the pre-population if needed - prioritise flashed values
    my $captain;
    if ( defined( $c->flash->{captain} ) ) {
      $captain = $c->flash->{captain};
    } else {
      if ( defined( $team_season ) ) {
        # If there's a currently defined team season, use the captain from that
        $captain = $team_season->captain;
      } else {
        # If not, use the captain from the last completed season this team entered
        $captain = $last_team_season->team_seasons->first->captain if defined( $last_team_season->team_seasons );
      }
    }
    
    $captain_tokeninput_options->{prePopulate} = [{id => $captain->id, name => $captain->display_name}] if defined( $captain );
    
    # Players
    my $players_tokeninput_options = {
      jsonContainer => "json_people",
      hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    my $players = [];
    if ( defined( $c->flash->{players} ) and ref( $c->flash->{players} ) eq "ARRAY" ) {
      @{ $players } = map({
        id    => $_->id,
        name  => encode_entities( $_->display_name ),
      }, @{ $c->flash->{players} });
    } else {
      my $team_players = $team->get_players({season => $current_season});
      while ( my $player = $team_players->next ) {
        push(@{ $players }, {
          id    => $player->person->id,
          name  => encode_entities( $player->person->display_name ),
        });
      }
    }
    
    $players_tokeninput_options->{prePopulate} = $players if scalar( @{ $players } );
    
    my $tokeninput_confs = [{
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $captain_tokeninput_options ),
      selector  => "captain",
    }, {
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $players_tokeninput_options ),
      selector  => "players",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues to list
  $c->stash({
    template            => "html/teams/create-edit.ttkt",
    scripts             =>  [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/teams/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    clubs               => [ $c->model("DB::Club")->search({}, {order_by => {-asc => "full_name"}}) ],
    divisions           => $divisions,
    home_nights         => [ $c->model("DB::LookupWeekday")->all_days ],
    current_season      => $current_season,
    team_season         => $team_season,
    last_team_season    => $last_team_season,
    form_action         => $c->uri_for_action("/teams/do_edit_by_url_key", [$team->club->url_key, $team->url_key]),
    view_online_display => "Editing $encoded_name",
    view_online_link    => 0,
    subtitle2           => $c->maketext("admin.edit"),
    mid_season          => $mid_season,
  });
  
  # Flash the current club's data to display
  # Split the time up.
  my @time_bits = split ":", $c->stash->{team}->default_match_start if defined($c->stash->{team}->default_match_start);
  
  $c->flash->{club}             = $c->stash->{team}->club->id   if !$c->flash->{club};
  $c->flash->{division}         = $team_season->division->id    if !$c->flash->{division} and defined( $team_season );
  $c->flash->{captain}          = $team_season->captain         if !$c->flash->{captain} and defined($team_season->captain);
  $c->flash->{home_night}       = $home_night                   if !$c->flash->{home_night};
  $c->flash->{start_hour}       = $time_bits[0]                 if !$c->flash->{start_hour};
  $c->flash->{start_minute}     = $time_bits[1]                 if !$c->flash->{start_minute};
  $c->flash->{log_old_details}  = $c->stash->{log_old_details}  if !$c->flash->{log_old_details};
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete_by_id

Display the form to delete a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub delete_by_id :Chained("base_by_id") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete_by_url_key

Display the form to delete a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub delete_by_url_key :Chained("base_by_url_key") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete

Forwarded from delete_by_id and delete_by_url_key.

=cut

sub delete :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  my $encoded_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_delete", $c->maketext("user.auth.delete-teams"), 1] );
  
  unless ( $team->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "teams.delete.error.cannot-delete", $team->club->short_name, $team->name )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1           => sprintf( "%s %s", $team->club->short_name, $team->name ),
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/teams/delete.ttkt",
    view_online_display => "Deleting $encoded_name",
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("admin.delete"),
  });
}


=head2 do_create

Process the form for creating a club. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_create", $c->maketext("user.auth.create-teams"), 1] );
  
  # Forward to the setup routine
  $c->detach( "setup_team", ["create"] );
}

=head2 do_edit_by_id

Process the form to edit the team.  This just does the URI matching, then forwards to do_edit.

=cut

sub do_edit_by_id :Chained("base_by_id") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit_by_url_key

Process the form to edit the team.  This just does the URI matching, then forwards to do_edit.

=cut

sub do_edit_by_url_key :Chained("base_by_url_key") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit

Forwarded from do_edit_by_id and do_edit_by_url_key. 

=cut

sub do_edit :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_edit", $c->maketext("user.auth.edit-teams"), 1] );
  $c->detach( "setup_team", ["edit"] );
}

=head2 do_delete_by_id

Process the form for deleting a team.  This actually does the URI matching, then forwards to the do_delete routine.

=cut

sub do_delete_by_id :Chained("base_by_id") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete_by_url_key

Process the form for deleting a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub do_delete_by_url_key :Chained("base_by_url_key") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete

Process the deletion of the team.

=cut

sub do_delete :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  # Save the team name so we can display it in a message after the deletion
  my $team_name = sprintf( "%s %s", $team->club->short_name, $team->name );
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_delete", $c->maketext("user.auth.delete-teams"), 1] );
  
  my $error = $team->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [ $team->club->url_key, $team->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Successfully deleted
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team", "delete", {id => undef}, $team_name] );
    $c->response->redirect( $c->uri_for("/teams",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $team_name, $c->maketext("admin.message.deleted"))} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_team

A private routine forwarded from the docreate and doedit routines to set up the team.

=cut

sub setup_team :Private {
  my ( $self, $c, $action ) = @_;
  my $team = $c->stash->{team};
  
  # Foreign key checks
  my $club        = $c->model("DB::Club")->find( $c->request->parameters->{club} ) if $c->request->parameters->{club};
  my $division    = $c->model("DB::Division")->find( $c->request->parameters->{division} ) if $c->request->parameters->{division};
  my $captain     = $c->model("DB::Person")->find( $c->request->parameters->{captain} ) if $c->request->parameters->{captain};
  my $home_night  = $c->model("DB::LookupWeekday")->find( $c->request->parameters->{home_night} ) if $c->request->parameters->{home_night};
  
  # Look up all the players first; these are submitted in a single field, comma separated
  my @player_ids = split( ",", $c->request->parameters->{players} );
  
  # Set up the arrayref that will hold the DB object for each player, then push the result of a find() on to it for each ID
  my $players = [];
  push( @{ $players }, $c->model("DB::Person")->find( $_ ) ) foreach ( @player_ids );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Forward to the model to do the rest of the error checking
  my $details = $c->model("DB::Team")->create_or_edit($action, {
    team                    => $team,
    name                    => $c->request->parameters->{name},
    club                    => $club,
    division                => $division,
    start_hour              => $c->request->parameters->{start_hour},
    start_minute            => $c->request->parameters->{start_minute},
    captain                 => $captain,
    home_night              => $home_night,
    players                 => $players,
    season                  => $current_season,
    reassign_active_players => $c->config->{Players}{reassign_active_on_team_season_create},
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    # Flash the entered values we've got so we can set them into the form
    # Stash the values we've got so we can set them
    $c->flash->{name}         = $c->request->parameters->{name};
    $c->flash->{club}         = $c->request->parameters->{club};
    $c->flash->{division}     = $c->request->parameters->{division};
    $c->flash->{start_hour}   = $c->request->parameters->{start_hour};
    $c->flash->{start_minute} = $c->request->parameters->{start_minute};
    $c->flash->{home_night}   = $c->request->parameters->{home_night};
    $c->flash->{captain}      = $captain;
    $c->flash->{players}      = $players;
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      # If we're creating, we'll just redirect straight back to the create form
      $redirect_uri = $c->uri_for_action("/teams/create_no_club",
                            {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined( $details->{team} ) ) {
        # If we're editing and we found an object to edit, we'll redirect to the edit form for that object
        $redirect_uri = $c->uri_for_action("/teams/edit_by_url_key", [ $details->{team}->club->url_key, $details->{team}->url_key ],
                            {mid => $c->set_status_msg( {error => $error} ) });
      } else {
        # If we're editing and we didn't an object to edit, we'll redirect to the list of objects
        $redirect_uri = $c->uri_for("/teams",
                            {mid => $c->set_status_msg( {error => $error} ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $team = $details->{team};
    my $encoded_name = encode_entities( sprintf( "%s %s", $team->club->short_name, $team->name ) );
    my $action_description;
    
    if ( $action eq "create" ) {
      $action_description = $c->maketext("admin.message.created");
    } else {
      $action_description = $c->maketext("admin.message.edited");
    }
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team", $action, {id => $team->id}, $encoded_name ] );
    
    # Log the home night's changed if necessary
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team", "update-home-night", {id => $team->id}, $encoded_name ] ) if exists( $details->{home_night_changed} );
    
    # Check if we have warnings to support
    if ( scalar( @{ $details->{warning} } ) ) {
      my $warning = $c->build_message( $details->{warning} );
      $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg( { success => $c->maketext( "admin.forms.success-with-warnings", $encoded_name, $action_description ),
                                                              warning => $warning} ) }) );
    } else {
      $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $action_description )} ) }) );
    }
    
    $c->detach;
    return;
  }
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
