package TopTable::Controller::FixturesResults;
use Moose;
use namespace::autoclean;
use DateTime;
use Try::Tiny;
use HTML::Entities;
use URI::QueryParam;
use Data::ICal::TimeZone;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered fixtures-results, so the URLs start /fixtures-results.
__PACKAGE__->config(namespace => "fixtures-results");

=head1 NAME

TopTable::Controller::FixturesResults - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for displaying fixtures and results in a variety of ways.  The fixtures are created in TopTable::Controller::FixturesGrids, so this is just a display mechanism.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.fixtures-results")});
}

=head2 base

Chain base for getting the club ID and checking it.  Matches "/fixtures-results/*" (start of chain)

=cut

sub base :Chained("/") :PathPart("fixtures-results") :CaptureArgs(0) {}

=head2 load_current_season

Load the current season (or last completed season if there is no season) for displaying the fixtures / results from.

Matches "/fixtures-results".

=cut

sub load_current_season :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  # The header will just say 'Results' is the season we're looking at is complete
  my $page_header = $season->complete ? $c->maketext("menu.text.results") : $c->maketext("menu.text.fixtures-results");
  
  if ( defined( $season ) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      page_header => $page_header,
      subtitle1 => $page_header,
    });
    
    # Push the fixtures and results options page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for("/fixtures-results"),
      label => $page_header,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 load_specific_season

Load the season specified for displaying the fixtures / results from.

Matches "/fixtures-results/seasons/*".

=cut

sub load_specific_season :Chained("base") :PathPart("seasons") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  my $season = $c->model("DB::Season")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $season ) ) {
    my $enc_season_name = encode_entities($season->name);
    
    # The header will just say 'Results' is the season we're looking at is complete
    my $page_header = $season->complete ? $c->maketext("menu.text.results") : $c->maketext("menu.text.fixtures-results");
    
    $c->stash({
      season => $season,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      specific_season => 1,
      page_header => $page_header,
      subtitle1 => $page_header,
    });
  
    # Push the fixtures and results options page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for("/fixtures-results"),
      label => $page_header,
    }, {
      path => $c->uri_for("/fixtures-results/seasons"),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/fixtures-results/root_specific_season", [$season->url_key]),
      label => $enc_season_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 view_seasons

Retrieve and display a list of seasons to view fixtures and results for.

Matches "/fixtures-results/seasons".

=cut

sub view_seasons :Chained("base") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  
  # Push the fixtures and results options page on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/fixtures-results/seasons"),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the first page of seasons.

Matches "/fixtures-results/seasons" (end of chain).

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $club = $c->stash->{club};
  
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/view_seasons_first_page")});
  $c->detach("retrieve_paged_seasons", [1]);
}

=head2 view_seasons_specific_page

List the seasons on the specified page.

Matches /fixtures-results/seasons/page/* (end of chain).

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/view_seasons_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/view_seasons_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged_seasons", [$page_number]);
}

=head2 retrieve_paged_seasons

Performs the lookups for seasons with the given page number; this is a private routine forwarded from view_seasons_first_page and view_seasons_specific_page with the page number to view.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $seasons = $c->model("DB::Season")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/fixtures-results/view_seasons_first_page",
    specific_page_action => "/fixtures-results/view_seasons_specific_page",
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/list-seasons.ttkt",
    view_online_display => "Viewing fixtures & results",
    view_online_link => 1,
    seasons => $seasons,
    page_info => $page_info,
    page_links => $page_links,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 root_current_season

Display a list of options for the current season (view by team / date / etc.)

Matches "/fixtures-results" (end of chain).

=cut

sub root_current_season :Chained("load_current_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/root_current_season")});
  $c->detach("root");
}

=head2 root_specific_season

Display a list of options for the specified season (view by team / date / etc.)

Matches "/fixtures-results/seasons/*" (end of chain).

=cut

sub root_specific_season :Chained("load_specific_season") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  $c->stash({ canonical_uri => $c->uri_for_action("/fixtures-results/root_specific_season", [$season->url_key]) });
  $c->detach("root");
}

=head2 root

Displays the options for how to view the fixtures (by team / date / etc.).  This is a private routine forwarded from root_current_season and root_specific_season.

=cut

sub root :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/root.ttkt",
    view_online_display => sprintf("Viewing fixtures & results for season %s", $season->name),
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 filter_view_current_season

Display the options for the given viewing mode in the current season.

Matches "/fixtures-results/*" (end of chain) (example: "/fixtures-results/months" displays a list of months in the current season with matches to view).

=cut

sub filter_view_current_season :Chained("load_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $view_method ) = @_;
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/filter_view_current_season", [$view_method])});
  $c->detach( "filter_view", [$view_method] );
}

=head2 filter_view_specific_season

Display the options for the given viewing mode in the specified season.

Matches "/fixtures-results/seasons/*/*" (end of chain) (example: "/fixtures-results/seasons/2014-2015/months" displays a list of months in the 2014-2015 season with matches to view).

=cut

sub filter_view_specific_season :Chained("load_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $view_method ) = @_;
  my $season = $c->stash->{season};
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/filter_view_current_season", [$season->url_key, $view_method])});
  $c->detach("filter_view", [$view_method]);
}

=head2 filter_view

Display the options for the given viewing mode; this is a private routine that is forwarded to from filter_view_current_season and filter_view_specific_season.

=cut

sub filter_view :Private {
  my ( $self, $c, $view_method ) = @_;
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  my $enc_season_name = $c->stash->{enc_season_name};
  
  # $display_options will be a list of teams, divisions or dates, depending on our view method, to display on the page as links
  my ( $view_method_display, $display_options );
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  
  my @external_scripts = (
    $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
  );
  
  my @external_styles = (
    $c->uri_for("/static/css/chosen/chosen.min.css"),
    $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
  );
  
  if ( $view_method eq "teams" ) {
    # View by team; display a list of teams
    $display_options = [$c->model("DB::TeamMatchCountsView")->search_by_season($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-team");
    push(@external_scripts,
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/options/teams.js"),
    );
    push(@external_styles, $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"));
  } elsif ( $view_method eq "divisions" ) {
    # View by division; display a list of divisions
    $display_options = [$c->model("DB::TeamMatch")->match_counts_by_division($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-division");
    push(@external_scripts, $c->uri_for("/static/script/fixtures-results/options/standard-sort-column.js"));
  } elsif ( $view_method eq "days" ) {
    # View by day; display a list of dates with matches
    $display_options = [$c->model("DB::TeamMatch")->match_counts_by_day($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-day");
    push(@external_scripts,
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/options/weeks.js"),
    );
    push(@external_styles, $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"));
  } elsif ( $view_method eq "weeks" ) {
    # View by week; display a list of weeks with matches
    $display_options = [$c->model("DB::TeamMatchWeeksView")->search_by_season($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-week");
    push(@external_scripts,
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/options/weeks.js"),
    );
    push(@external_styles, $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"));
  } elsif ( $view_method eq "months" ) {
    # View by month; display a list of months with matches
    $display_options = [$c->model("DB::TeamMatch")->match_counts_by_month($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-month");
    push(@external_scripts, $c->uri_for("/static/script/fixtures-results/options/standard-sort-column.js"));
  } elsif ( $view_method eq "date-range" ) {
    # Fixtures in a date range
    
    #$view_method_display = "By custom date range";
  } elsif ( $view_method eq "venues" ) {
    # Fixtures in a venue
    $display_options = [$c->model("DB::TeamMatch")->match_counts_by_venue($season)];
    $view_method_display = $c->maketext("fixtures-results.title.category.by-venue");
    push(@external_scripts, $c->uri_for("/static/script/fixtures-results/options/standard.js"));
  } else {
    # Detach to the 404 error if we don't recognise the view method.
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  # If we're viewing a specific season, subtitle2 is taken up by the season name
  my $subtitle1 = $season->complete ? $c->maketext("fixtures-results.title.results.by-cat", $view_method_display) : $c->maketext("fixtures-results.title.fixtures-results.by-cat", $view_method_display);
  my $subtitle2 = $enc_season_name unless $specific_season;
  
  # Check that we are authorised to view fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/options/$view_method.ttkt",
    external_scripts => \@external_scripts,
    external_styles => \@external_styles,
    view_online_display => "Viewing fixtures & results for season " . $c->stash->{season}->name,
    view_online_link => 1,
    seasons => [$c->model("DB::Season")->all_seasons],
    subtitle1 => $subtitle1,
    subtitle2 => $subtitle2,
    view_method => $view_method,
    display_options => $display_options,
  });
  
  # Push the fixtures and results options page on to the breadcrumbs
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, $view_method]),
      label => $view_method_display,
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path  => $c->uri_for_action("/fixtures-results/filter_view_current_season", [$view_method]),
      label => $view_method_display,
    });
  }
}

=head2 view_team_by_id_current_season

Display the fixtures for the given team (identified by ID) for the current season.

Matches "/fixtures-results/teams/*".

=cut

sub view_team_by_id_current_season :Chained("load_current_season") :PathPart("teams") :CaptureArgs(1) {
  my ( $self, $c, $team_id ) = @_;
  $c->forward("view_team_by_id", [$team_id]);
}

=head2 view_team_by_id_specific_season

Display the fixtures for the given team (identified by ID) for the current season.

Matches "/fixtures-results/seasons/*/teams/*".

=cut

sub view_team_by_id_specific_season :Chained("load_specific_season") :PathPart("teams") :CaptureArgs(1) {
  my ( $self, $c, $team_id ) = @_;
  $c->forward("view_team_by_id", [$team_id]);
}

=head2 view_team_by_id

Retrieves the team specified by ID in view_team_by_id_current_season and view_team_by_id_specific_season (private routine forwarded from the aforementioned routines).

=cut

sub view_team_by_id :Private {
  my ( $self, $c, $team_id ) = @_;
  my $season = $c->stash->{season};
  my $team = $c->model("DB::Team")->find_with_prefetches($team_id, {season => $season});
  
  $c->detach(qw(TopTable::Controller::Root default)) unless defined( $team );
  
  # Grab the team
  $c->stash({team => $team});
  $c->forward("view_team");
}

=head2 view_team_by_url_key_current_season

Display the fixtures for the given team (identified by URL key) for the current season.

Matches "/fixtures-results/teams/*/*".

=cut

sub view_team_by_url_key_current_season :Chained("load_current_season") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  $c->forward("view_team_by_url_key", [$club_url_key, $team_url_key]);
}

=head2 view_team_by_url_key_specific_season

Display the fixtures for the given team (identified by URL key) for the current season.

Matches "/fixtures-results/seasons/*/teams/*/*".

=cut

sub view_team_by_url_key_specific_season :Chained("load_specific_season") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  $c->forward("view_team_by_url_key", [$club_url_key, $team_url_key]);
}

=head2 view_team_by_url_key

Retrieves the team specified by ID in view_team_by_url_key_current_season and view_team_by_url_key_specific_season (private routine forwarded from the aforementioned routines).

=cut

sub view_team_by_url_key :Private {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  my $season = $c->stash->{season};
  my $team = $c->model("DB::Team")->find_url_keys($club_url_key, $team_url_key);
  $c->detach(qw(TopTable::Controller::Root default)) unless defined($team);
  
  # Grab the team
  $c->stash({team => $team});
  $c->forward("view_team");
}

=head2 view_team

Private function that ALL of the view_team_* functions end up at that retrieves the matches for the stashed team, season with the given page number.

=cut

sub view_team :Private {
  my ( $self, $c ) = @_;
  my $specific_season  = $c->stash->{specific_season};
  my $season = $c->stash->{season};
  my $team = $c->stash->{team};
  
  # $display_options will be a list of teams, divisions or dates, depending on our view method, to display on the page as links
  my ( $matches, $display_options );
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( match_update match_cancel )], "", 0]);
  
  if ( $specific_season ) {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/view_team_by_url_key_specific_season", [$season->url_key, $team->club->url_key, $team->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-results/view_team_by_url_key_current_season_end", [$team->club->url_key, $team->url_key])});
  }
  
  # Team info is in the team season object if we're using a specific season
  my $team_info = $team->find_related("team_seasons", {season => $season->id});
  my $enc_old_club_short_name = encode_entities($team_info->club_season->short_name);
  my $enc_club_short_name = encode_entities($team->club->short_name);
  my $enc_club_full_name = encode_entities($team->club->full_name);
  my $enc_old_team_name = encode_entities($team_info->name);
  my $enc_team_name = encode_entities($team->name);
  my $old_club_and_team = sprintf("%s %s", $enc_old_club_short_name, $enc_old_team_name);
  my $new_club_and_team = sprintf("%s %s", $enc_club_short_name, $enc_team_name);
  
  # New name info message
  $c->add_status_messages({info => $c->maketext("teams.club.changed-notice", $old_club_and_team, $enc_club_full_name, $c->uri_for_action("/clubs/view_current_season", [$team->club->url_key]), $enc_club_full_name)}) if $specific_season and $team_info->club_season->club->id != $team->club->id;
  $c->add_status_messages({info => $c->maketext("teams.name.changed-notice", $old_club_and_team, $new_club_and_team)}) if $team_info->name ne $team->name;
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = sprintf("Viewing fixtures & results for %s %s in %s", $enc_club_short_name, $enc_old_team_name, $season->name);
  } else {
    $online_display = sprintf("Viewing fixtures & results for %s %s", $enc_club_short_name, $enc_old_team_name);
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/no-grouping.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => scalar $c->model("DB::TeamMatch")->matches_for_team({
      team => $team,
      season => $season,
    }),
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $old_club_and_team): $c->maketext("fixtures-results.title.fixtures-results", $old_club_and_team),
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_team_by_url_key_specific_season", [$season->url_key, $team->club->url_key, $team->url_key, "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-no-grouping.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "teams"]),
      label => $c->maketext("menu.text.fixtures-results-by-team"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_team_by_url_key_specific_season", [$season->url_key, $team->club->url_key, $team->url_key]),
      label => sprintf("%s %s", $enc_old_club_short_name, $enc_old_team_name),
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_current_season", ["teams"]),
      label => $c->maketext("menu.text.fixtures-results-by-team"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_team_by_url_key_current_season_end", [$team->club->url_key, $team->url_key]),
      label => sprintf("%s %s", $enc_club_short_name, $enc_team_name),
    });
  }
}

=head2 view_team_by_url_key_current_season_end, view_team_by_url_key_specific_season_end

End point for view_team various functions (current / specific season by id / url_key) without extra options

=cut

sub view_team_by_url_key_current_season_end :Chained("view_team_by_url_key_current_season") :PathPart("") :Args(0) {}
sub view_team_by_url_key_specific_season_end :Chained("view_team_by_url_key_specific_season") :PathPart("") :Args(0) {}
sub view_team_by_id_current_season_end :Chained("view_team_by_id_current_season") :PathPart("") :Args(0) {}
sub view_team_by_id_specific_season_end :Chained("view_team_by_id_specific_season") :PathPart("") :Args(0) {}

=head2 download_team_by_id_current_season

Download the given team's fixtures in the current season where the team has been specified by ID.

Matches "/fixtures-results/teams/*/*" (end of chain).

=cut

sub download_team_by_id_current_season :Chained("view_team_by_id_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $team = $c->stash->{team};
  
  $c->stash({
    download_type => $download_type,
    # Calendar download link is required so we know in the generic function what to replace {cal-uri} with
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_team_by_url_key_current_season", [$team->club->url_key, $team->url_key, $download_type]]),
  });
  
  $c->detach("download_team");
}

=head2 download_team_by_id_specific_season

Download the given team's fixtures in the specified season where the team has been specified by ID.

Matches "/fixtures-results/seasons/*/teams/*/*" (end of chain).

=cut

sub download_team_by_id_specific_season :Chained("view_team_by_id_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $team = $c->stash->{team};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_team_by_url_key_specific_season", [$season->url_key, $team->club->url_key, $team->url_key, $download_type]]),
  });
  
  $c->detach("download_team");
}

=head2 download_team_by_url_key_current_season

Download the given team's fixtures in the current season when the team has been specified by URL key.

Matches "/fixtures-results/teams/*/*/*" (end of chain).

=cut

sub download_team_by_url_key_current_season :Chained("view_team_by_url_key_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $team = $c->stash->{team};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_team_by_url_key_current_season", [$team->club->url_key, $team->url_key, $download_type]]),
  });
  
  $c->detach("download_team");
}

=head2 download_team_by_url_key_specific_season

Download the given team's fixtures in the specified season when the team has been specified by URL key.

Matches "/fixtures-results/seasons/*/teams/*/*/*" (end of chain).

=cut

sub download_team_by_url_key_specific_season :Chained("view_team_by_url_key_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $team = $c->stash->{team};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_team_by_url_key_specific_season", [$season->url_key, $team->club->url_key, $team->url_key, $download_type]]),
  });
  
  $c->detach("download_team");
}

=head2 view_division_current_season

Display the fixtures for the given division in the current season.

Matches "/fixtures-results/divisions/*".

=cut

sub view_division_current_season :Chained("load_current_season") :PathPart("divisions") :CaptureArgs(1) {
  my ( $self, $c, $division_id_or_url_key ) = @_;
  $c->forward("get_division", [$division_id_or_url_key]);
  $c->forward("view_division", [1]);
}

=head2 view_division_specific_season

Display the fixtures for the given division in the specified season.

Matches "/fixtures-results/seasons/*/divisions/*"

=cut

sub view_division_specific_season :Chained("load_specific_season") :PathPart("divisions") :CaptureArgs(1) {
  my ( $self, $c, $division_id_or_url_key ) = @_;
  $c->forward("get_division", [$division_id_or_url_key]);
  $c->forward("view_division", [1]);
}

=head2 download_division_current_season

Download the given division's fixtures in the current season.

Matches "/fixtures-results/divisions/*/*/*" (end of chain).

=cut

sub download_division_current_season :Chained("view_division_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $division = $c->stash->{division};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_division_current_season", [$division->url_key, $download_type]]),
  });
  
  $c->detach("download_division");
}

=head2 download_division_specific_season

Download the given division's fixtures in the specified season.

Matches "/fixtures-results/seasons/*/divisions/*/*/*" (end of chain).

=cut

sub download_division_specific_season :Chained("view_division_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $division = $c->stash->{division};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_division_specific_season", [$season->url_key, $division->url_key, $download_type]]),
  });
  
  $c->detach("download_division");
}

=head2 get_division

Get and stash the division from the given ID or URL key.

=cut

sub get_division :Private {
  my ( $self, $c, $id_or_key ) = @_;
  my $division = $c->model("DB::Division")->find_id_or_url_key( $id_or_key );
  $c->detach(qw(TopTable::Controller::Root default)) unless defined( $division ); # Error, division not found
  $c->stash({division => $division});
}

=head2 view_division

Private function that ALL view_division_* functions end up at; this does the actual lookup of match data and pagination.

=cut

sub view_division :Private {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # $display_options will be a list of teams, divisions or dates, depending on our view method, to display on the page as links
  
  # Get the matches to display
  my $matches = $c->model("DB::TeamMatch")->matches_in_division({
    division => $division,
    season => $season,
  });
  
  # Make sure this division has an association with the given season
  my $division_season = $division->get_season($season);
  $c->detach(qw(TopTable::Controller::Root default)) unless defined($division_season);
  
  # Encode the names.  If, in the season we're viewing, the name was different to the current name, we'll display a notice
  my $enc_division_name = encode_entities($division->name);
  my $enc_old_division_name = encode_entities($division_season->name);
  my $enc_season_name = $c->stash->{enc_season_name};
  
  $c->add_status_messages({info => $c->maketext("divisions.name.changed-notice", $enc_old_division_name, $enc_division_name)}) if $division->name ne $division_season->name;
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = sprintf("Viewing fixtures & results in %s in %s", $enc_old_division_name, $enc_season_name);
  } else {
    $online_display = sprintf("Viewing fixtures & results in %s", $enc_division_name);
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-weeks-ordering-no-comp.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => $matches,
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $enc_old_division_name): $c->maketext("fixtures-results.title.fixtures-results", $enc_old_division_name),
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_division_specific_season", [$season->url_key, $division->url_key, "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-weeks-ordering-no-comp.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "divisions"]),
      label => $c->maketext("menu.text.fixtures-results-by-division"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_division_specific_season", [$season->url_key, $division->url_key]),
      label => $division->name,
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_current_season", ["divisions"]),
      label => $c->maketext("menu.text.fixtures-results-by-division"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_division_current_season_end", [$division->url_key]),
      label => $division->name,
    });
  }
}

=head2 view_division_current_season_end, view_division_specific_season_end

Provide an end point for viewing a division without download options.

=cut

sub view_division_current_season_end :Chained("view_division_current_season") :PathPart("") :Args(0) {}
sub view_division_specific_season_end :Chained("view_division_specific_season") :PathPart("") :Args(0) {}

=head2 view_venue_current_season

Display the fixtures for the given venue in the current season.

Matches "/fixtures-results/venues/*".

=cut

sub view_venue_current_season :Chained("load_current_season") :PathPart("venues") :CaptureArgs(1) {
  my ( $self, $c, $venue_id_or_url_key ) = @_;
  $c->forward("get_venue", [$venue_id_or_url_key]);
  $c->detach("view_venue");
}

=head2 view_venue_specific_season

Display the fixtures for the given venue in the current season.

Matches "/fixtures-results/seasons/*/venues/*".

=cut

sub view_venue_specific_season :Chained("load_specific_season") :PathPart("venues") :CaptureArgs(1) {
  my ( $self, $c, $venue_id_or_url_key ) = @_;
  $c->forward("get_venue", [$venue_id_or_url_key]);
  $c->detach("view_venue");
}

=head2 download_venue_current_season

Download the given venue's fixtures in the current season.

Matches "/fixtures-results/venues/*/*/*" (end of chain).

=cut

sub download_venue_current_season :Chained("view_venue_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $venue = $c->stash->{venue};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_venue_current_season", [$venue->url_key, $download_type]]),
  });
  
  $c->detach("download_venue");
}

=head2 download_venue_specific_season

Download the given venue's fixtures in the specified season.

Matches "/fixtures-results/seasons/*/venues/*/*/*" (end of chain).

=cut

sub download_venue_specific_season :Chained("view_venue_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $venue = $c->stash->{venue};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_venue_specific_season", [$season->url_key, $venue->url_key, $download_type]]),
  });
  
  $c->detach("download_venue");
}

=head2 get_venue

Get and stash the venue from the given ID or URL key.

=cut

sub get_venue :Private {
  my ( $self, $c, $id_or_key ) = @_;
  my $venue = $c->model("DB::Venue")->find_id_or_url_key($id_or_key);
  $c->detach(qw(TopTable::Controller::Root default)) unless defined($venue); # Error, division not found
  $c->stash({venue => $venue});
}

=head2 view_venue

Private routine that all of the view_venue_* functions end up at.  This does the lookup for the matches to display and paginates them with links to other pages if required.

=cut

sub view_venue :Private {
  my ( $self, $c ) = @_;
  my $venue = $c->stash->{venue};
  my $specific_season = $c->stash->{specific_season};
  my $season = $c->stash->{season};
  
  # $display_options will be a list of teams, divisions or dates, depending on our view method, to display on the page as links
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # Get the matches for this venue
  my $matches = $c->model("DB::TeamMatch")->matches_at_venue({
    venue => $venue,
    season => $season,
  });
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = sprintf("Viewing fixtures & results taking place at %s in %s", $venue->name, $season->name);
  } else {
    $online_display = sprintf("Viewing fixtures & results taking place at %s", $venue->name);
  }
  
  my $enc_venue_name = encode_entities($venue->name);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-weeks-ordering.ttkt",
    matches => $matches,
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $enc_venue_name): $c->maketext("fixtures-results.title.fixtures-results", $enc_venue_name),
    view_online_display => sprintf( "Viewing fixtures & results taking place at %s in %s", $venue->name, $season->name ),
    view_online_link => 1,
    view_online_display => $online_display,
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_venue_specific_season", [$season->url_key, $venue->url_key, "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-weeks-ordering.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "venues"]),
      label => $c->maketext("menu.text.fixtures-results-by-venue"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_venue_specific_season_end", [$season->url_key, $venue->url_key]),
      label => $enc_venue_name,
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_current_season", ["venues"]),
      label => $c->maketext("menu.text.fixtures-results-by-venue"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_venue_current_season_end", [$venue->url_key]),
      label => $enc_venue_name,
    });
  }
}

=head2 view_venue_current_season_end, view_venue_specific_season_end

End point for venue view without options for downloading, etc.

=cut

sub view_venue_current_season_end :Chained("view_venue_current_season") :PathPart("") :Args(0) {}
sub view_venue_specific_season_end :Chained("view_venue_specific_season") :PathPart("") :Args(0) {}

=head2 view_month_current_season

Display the fixtures for the given month in the current season.

Matches "/fixtures-results/months/*/*" (last */* is [year]/[month]).

=cut

sub view_month_current_season :Chained("load_current_season") :PathPart("months") :CaptureArgs(2) {
  my ( $self, $c, $year, $month ) = @_;
  $c->forward("get_month", [$year, $month]);
  $c->forward("view_month");
}

=head2 view_month_specific_season

Display the fixtures for the given month in the current season.

Matches "/fixtures-results/seasons/*/months/*/*" (last */* is [year]/[month]).

=cut

sub view_month_specific_season :Chained("load_specific_season") :PathPart("months") :CaptureArgs(2) {
  my ( $self, $c, $year, $month ) = @_;
  $c->forward("get_month", [$year, $month]);
  $c->forward("view_month");
}

=head2 download_month_current_season

Download the given month's fixtures in the current season.

Matches "/fixtures-results/months/*/*/*" (end of chain).

=cut

sub download_month_current_season :Chained("view_month_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $date = $c->stash->{start_date};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_month_current_season", [$date->year, sprintf("%02d", $date->month), $download_type]]),
  });
  
  $c->detach("download_month");
}

=head2 download_month_specific_season

Download the given month's fixtures in the specified season.

Matches "/fixtures-results/seasons/*/venues/*/*/*" (end of chain).

=cut

sub download_month_specific_season :Chained("view_month_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $date = $c->stash->{start_date};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_month_specific_season", [$season->url_key, $date->year, sprintf("%02d", $date->month), $download_type]]),
  });
  
  $c->detach("download_month");
}

=head2 get_month

Get and stash the month from the given year and month numbers.

=cut

sub get_month :Private {
  my ( $self, $c, $year, $month ) = @_;
  
  # 404 if the year or month is invalid
  $c->detach(qw(TopTable::Controller::Root default)) if $year !~ /^-?\d+$/ or $month !~ /^\d+$/ or $month < 1 or $month > 12;
  
  # Get the start / end date to look for matches; the start date will always be 1 and the end date will always be the last date of that particular month.
  my ( $start_date, $end_date );
  try {
    $start_date = DateTime->new(year => $year, month => $month, day => 1, locale => $c->locale);
    $end_date = DateTime->last_day_of_month(year => $year, month => $month, locale => $c->locale);
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  $c->stash({
    start_date => $start_date,
    end_date => $end_date,
  });
}

=head2 view_month

Private routine that all of the view_month_* functions end up at.  This does the match lookup and paginates the results with links to other pages if necessary.

=cut

sub view_month :Private {
  my ( $self, $c ) = @_;
  my $start_date = $c->stash->{start_date};
  my $end_date = $c->stash->{end_date};
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # Retrieve the matches for display
  my $matches = $c->model("DB::TeamMatch")->matches_in_date_range({
    season => $season,
    start_date => $start_date,
    end_date => $end_date,
  });
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = sprintf("Viewing fixtures & results in %s %d", $start_date->month_name, $start_date->year);
  } else {
    $online_display = sprintf("Viewing fixtures & results in %s %d", $start_date->month_name, $start_date->year);
  }
  
  # We ucfirst the month as some languages (e.g., French) don't capitalise months, so at the start of a heading it looks odd
  my $enc_month = encode_entities(sprintf("%s %s", ucfirst($start_date->month_name), $start_date->year));
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-week-competitions.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => $matches,
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $enc_month): $c->maketext("fixtures-results.title.fixtures-results", $enc_month),
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_month_specific_season", [$season->url_key, $start_date->year, sprintf("%02d", $start_date->month), "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-week-competitions.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "months"]),
      label => $c->maketext("menu.text.fixtures-results-by-month"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_month_specific_season_end", [$season->url_key, $start_date->year, $start_date->month]),
      label => $enc_month,
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", ["months"]),
      label => $c->maketext("menu.text.fixtures-results-by-month"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_month_current_season_end", [$start_date->year, $start_date->month]),
      label => $enc_month,
    });
  }
}

=head2 view_month_current_season_end, view_month_specific_season_end

End point for viewing months without download options.

=cut

sub view_month_current_season_end :Chained("view_month_current_season") :PathPart("") :Args(0) {}
sub view_month_specific_season_end :Chained("view_month_specific_season") :PathPart("") :Args(0) {}

=head2 view_outstanding_current_season

Display the outstanding scorecards in the current season.

Matches "/fixtures-results/outstanding-scorecards".

=cut

sub view_outstanding_current_season :Chained("load_current_season") :PathPart("outstanding-scorecards") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_outstanding");
}

=head2 view_outstanding

Private routine that all of the view_day_* functions end up at.  Does the match lookup and pagination with links to other pages if necessary.

=cut

sub view_outstanding :Private {
  my ( $self, $c, $page_number ) = @_;
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  my $outstanding_scorecard_hours = $c->config->{Matches}{Team}{outstanding_scorecard_hours};
  $outstanding_scorecard_hours = 24 if !defined($outstanding_scorecard_hours) or !$outstanding_scorecard_hours or $outstanding_scorecard_hours !~ /^\d+$/ or $outstanding_scorecard_hours < 1;
  my $date_cutoff = DateTime->now(time_zone => $c->stash->{timezone})->subtract(hours => $outstanding_scorecard_hours);
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # Get the start / end date to look for matches; the start date will always be 1 and the end date will always be the last date of that particular month.
  my $matches = $c->model("DB::TeamMatch")->incomplete_matches({
    season => $season,
    date_cutoff => $date_cutoff,
  });
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = "Viewing outstanding scorecards";
  } else {
    $online_display = "Viewing outstanding scorecards";
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-weeks.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => $matches,
    subtitle1 => $c->maketext("fixtures-results.view.outstanding-scorecards"),
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-weeks.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-results/view_outstanding_current_season"),
    label => $c->maketext("fixtures-results.view.outstanding-scorecards"),
  });
}

=head2 view_week_current_season

Display the fixtures for the given week in the current season.

Matches "/fixtures-results/weeks/*/*/*" (last */*/* is [year]/[month]/[day]).

=cut

sub view_week_current_season :Chained("load_current_season") :PathPart("weeks") :CaptureArgs(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  $c->forward("get_week", [$year, $month, $day]);
  $c->forward("view_week");
}

=head2 view_week_specific_season

Display the fixtures for the given week in the specified season.

Matches "/fixtures-results/seasons/*/weeks/*/*/*" (last */*/* is [year]/[month]/[day]).

=cut

sub view_week_specific_season :Chained("load_specific_season") :PathPart("weeks") :CaptureArgs(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  $c->forward("get_week", [$year, $month, $day]);
  $c->forward("view_week");
}

=head2 download_week_current_season

Download the given week's fixtures in the current season.

Matches "/fixtures-results/weeks/*/*/*" (end of chain).

=cut

sub download_week_current_season :Chained("view_week_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $week_date = $c->stash->{week_date};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_week_current_season", [$week_date->year, sprintf("%02d", $week_date->month), sprintf("%02d", $week_date->day), $download_type]]),
  });
  
  $c->detach("download_week");
}

=head2 download_week_specific_season

Download the given week's fixtures in the specified season.

Matches "/fixtures-results/seasons/*/weeks/*/*/*" (end of chain).

=cut

sub download_week_specific_season :Chained("view_week_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $week_date = $c->stash->{week_date};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_week_specific_season", [$season->url_key, $week_date->year, sprintf("%02d", $week_date->month), sprintf("%02d", $week_date->day), $download_type]]),
  });
  
  $c->detach("download_week");
}

=head2 get_week

Get and stash the day from the given year and month numbers.

=cut

sub get_week :Private {
  my ( $self, $c, $year, $month, $day ) = @_;
  
  # Get the start / end date to look for matches; the start date will always be 1 and the end date will always be the last date of that particular month.
  my $week_start_date;
  try { 
    $week_start_date = DateTime->new(year => $year, month => $month, day => $day, locale => $c->locale);
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  # 404 if the day isn't a Monday
  $c->detach(qw(TopTable::Controller::Root default)) if $week_start_date->day_of_week != 1;
  
  $c->stash({
    week_start_date => $week_start_date,
    week_end_date => $week_start_date->clone->add(days => 6), # Add 6 days to get the week end date (today and the following 6 days make up the week)
  });
}

=head2 view_week

Private routine that all of the view_week_* functions end up at.  This does the match lookups and paginates them with links to other pages if necessary.

=cut

sub view_week :Private {
  my ( $self, $c ) = @_;
  my $week_start_date = $c->stash->{week_start_date};
  my $week_end_date = $c->stash->{week_end_date};
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  $c->log->debug(sprintf("start date: %s, end date: %s", $week_start_date, $week_end_date));
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # Get the matches
  my $matches = $c->model("DB::TeamMatch")->matches_in_date_range({
    season => $season,
    start_date => $week_start_date,
    end_date => $week_end_date,
  });
  
  my $week_text = $c->i18n_datetime_format_date_long->format_datetime($week_start_date);
  my $online_display = "Viewing fixtures & reults in week beginning $week_text";
  my $enc_week_text = $c->maketext("fixtures-results.view-week.week-beginning", $week_text);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-competitions.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => $matches,
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $enc_week_text): $c->maketext("fixtures-results.title.fixtures-results", $enc_week_text),
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_week_specific_season", [$season->url_key, $week_start_date->year, sprintf("%02d", $week_start_date->month), sprintf("%02d", $week_start_date->day), "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-competitions.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "weeks"]),
      label => $c->maketext("menu.text.fixtures-results-by-week"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_week_specific_season", [$season->url_key, $week_start_date->year, $week_start_date->month, $week_start_date->day]),
      label => sprintf( "Week beginning %s, %d %s %d", $week_start_date->day_name, $week_start_date->day, $week_start_date->month_name, $week_start_date->year ),
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", ["weeks"]),
      label => $c->maketext("menu.text.fixtures-results-by-week"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_week_current_season_end", [$week_start_date->year, $week_start_date->month, $week_start_date->day]),
      label => sprintf("Week beginning %s, %d %s %d", $week_start_date->day_name, $week_start_date->day, $week_start_date->month_name, $week_start_date->year),
    });
  }
}

=head2 view_week_current_season_end, view_week_specific_season_end

End points for view_week_current_season and view_week_specific_season without using download / calendar options.

=cut

sub view_week_current_season_end :Chained("view_week_current_season") :PathPart("") :Args(0) {}
sub view_week_specific_season_end :Chained("view_week_specific_season") :PathPart("") :Args(0) {}

=head2 view_day_current_season

Display the fixtures for the given day in the current season.

Matches "/fixtures-results/days/*/*/*" (last */*/* is [year]/[month]/[day]).

=cut

sub view_day_current_season :Chained("load_current_season") :PathPart("days") :CaptureArgs(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  $c->forward("get_day", [$year, $month, $day]);
  $c->forward("view_day");
}

=head2 view_day_specific_season

Display the fixtures for the given day in the current season.

Matches "/fixtures-results/seasons/*/days/*/*/*" (last */*/* is [year]/[month]/[day]).

=cut

sub view_day_specific_season :Chained("load_specific_season") :PathPart("days") :CaptureArgs(3) {
  my ( $self, $c, $year, $month, $day ) = @_;
  $c->forward("get_day", [$year, $month, $day]);
  $c->forward("view_day");
}

=head2 download_day_current_season

Download the given week's fixtures in the current season.

Matches "/fixtures-results/days/*/*/*" (end of chain).

=cut

sub download_day_current_season :Chained("view_day_current_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $date = $c->stash->{date};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_day_current_season", [$date->year, sprintf("%02d", $date->month), sprintf("%02d", $date->day), $download_type]]),
  });
  
  $c->detach("download_day");
}

=head2 download_day_specific_season

Download the given day's fixtures in the specified season.

Matches "/fixtures-results/seasons/*/days/*/*/*" (end of chain).

=cut

sub download_day_specific_season :Chained("view_day_specific_season") :PathPart("") :Args(1) {
  my ( $self, $c, $download_type ) = @_;
  my $date = $c->stash->{date};
  my $season = $c->stash->{season};
  
  $c->stash({
    download_type => $download_type,
    calendar_download_uri => $c->forward("generate_calendar_download_uri", ["/fixtures-results/download_day_specific_season", [$season->url_key, $date->year, sprintf("%02d", $date->month), sprintf("%02d", $date->day), $download_type]]),
  });
  
  $c->detach("download_day");
}

=head2 get_day

Get and stash the day from the given year and month numbers.

=cut

sub get_day :Private {
  my ( $self, $c, $year, $month, $day ) = @_;
  
  # Get the start / end date to look for matches; the start date will always be 1 and the end date will always be the last date of that particular month.
  my $date;
  try { 
    $date = DateTime->new(year => $year, month => $month, day => $day, locale => $c->locale);
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  $c->stash({date => $date});
}

=head2 view_day

Private routine that all of the view_day_* functions end up at.  Does the match lookup and pagination with links to other pages if necessary.

=cut

sub view_day :Private {
  my ( $self, $c ) = @_;
  my $date = $c->stash->{date};
  my $season = $c->stash->{season};
  my $specific_season = $c->stash->{specific_season};
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( match_update match_cancel ) ], "", 0]);
  
  # Get the start / end date to look for matches; the start date will always be 1 and the end date will always be the last date of that particular month.
  my $matches = $c->model("DB::TeamMatch")->matches_on_date({
    season => $season,
    date => $date,
  });
  
  my $online_display;
  if ( $specific_season ) {
    $online_display = sprintf("Viewing fixtures & reults on week beginning %s, %d %s %d", $date->day_name, $date->day, $date->month_name, $date->year);
  } else {
    $online_display = sprintf("Viewing fixtures & reults on week beginning %s, %d %s %d", $date->day_name, $date->day, $date->month_name, $date->year);
  }
  
  # ucfirst on the day because some languages (e.g., French) don't capitalise day names and it looks odd at the start of a heading
  my $enc_date = encode_entities(sprintf("%s %d %s %d", ucfirst($date->day_name), $date->day, $date->month_name, $date->year));
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-results/view/group-competitions-no-date.ttkt",
    view_online_display => $online_display,
    view_online_link => 1,
    matches => $matches,
    subtitle1 => $season->complete ? $c->maketext("fixtures-results.title.results", $enc_date): $c->maketext("fixtures-results.title.fixtures-results", $enc_date),
    title_links => [{
      image_uri => $c->uri_for("/static/images/icons/0038-Calender-icon-32.png"),
      text => $c->maketext("calendar.download"),
      link_uri => $c->uri_for_action("/fixtures-results/download_day_specific_season", [$season->url_key, $date->year, sprintf("%02d", $date->month), sprintf("%02d", $date->day), "calendar"]),
    }],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-results/view-group-competitions-no-date.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs links
  if ( $specific_season ) {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_specific_season", [$season->url_key, "days"]),
      label => $c->maketext("menu.text.fixtures-results-by-day"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_day_specific_season_end", [$season->url_key, $date->year, $date->month, $date->day]),
      label => sprintf( "%s, %d %s %d", $date->day_name, $date->day, $date->month_name, $date->year ),
    });
  } else {
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-results/filter_view_current_season", ["days"]),
      label => $c->maketext("menu.text.fixtures-results-by-day"),
    }, {
      path => $c->uri_for_action("/fixtures-results/view_day_current_season_end", [$date->year, $date->month, $date->day]),
      label => $enc_date,
    });
  }
}

=head2 view_day_current_season_end, view_day_specific_season_end

End points for view_day_current_season and view_day_specific_season without using calendar / download options.

=cut

sub view_day_current_season_end :Chained("view_day_current_season") :PathPart("") :Args(0) {}
sub view_day_specific_season_end :Chained("view_day_specific_season") :PathPart("") :Args(0) {}

=head2 download_team

Download the given team's fixtures.

=cut

sub download_team :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $team = $c->stash->{team};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find( $calendar_type ) unless !defined( $calendar_type ) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      my $matches = $c->model("DB::TeamMatch")->matches_for_team({
        team => $team,
        season => $season,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf( "fixtures_team_%s-%s_%s", $team->club->url_key, $team->url_key, $season->url_key ),
        calendar_name => sprintf("%s | %s %s | %s", $c->config->{"Model::ICal"}{args}{calname}, $team->club->short_name, $team->name, $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => encode_entities( sprintf( "%s %s", $team->club->short_name, $team->name ) ),
  });
  
  $c->detach("download");
}

=head2 download_division

Download the given division's fixtures.

=cut

sub download_division :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $division = $c->stash->{division};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find( $calendar_type ) unless !defined( $calendar_type ) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      my $matches = $c->model("DB::TeamMatch")->matches_in_division({
        division => $division,
        season => $season,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf("fixtures_division_%s_%s", $division->url_key, $season->url_key),
        calendar_name => sprintf("%s | %s | %s", $c->config->{"Model::ICal"}{args}{calname}, $division->name, $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => encode_entities($division->name),
  });
  
  $c->detach("download");
}

=head2 download_venue

Download the given venue's fixtures.

=cut

sub download_venue :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $venue = $c->stash->{venue};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find( $calendar_type ) unless !defined( $calendar_type ) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      my $matches = $c->model("DB::TeamMatch")->matches_at_venue({
        venue => $venue,
        season => $season,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf("fixtures_venue_%s_%s", $venue->url_key, $season->url_key),
        calendar_name => sprintf("%s | %s | %s", $c->config->{"Model::ICal"}{args}{calname}, $venue->name, $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => encode_entities( $venue->name ),
  });
  
  $c->detach("download");
}

=head2 download_month

Download the given month's fixtures.

=cut

sub download_month :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $start_date = $c->stash->{start_date};
  my $end_date = $c->stash->{end_date};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find($calendar_type) unless !defined($calendar_type) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined($calendar_type) and $calendar_type eq "download" ) {
      my $matches = $c->model("DB::TeamMatch")->matches_in_date_range({
        season => $season,
        start_date => $start_date,
        end_date => $end_date,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf("fixtures_month_%s-%s", $start_date->year, sprintf("%02d", $start_date->month)),
        calendar_name => sprintf("%s | %s | %s", $c->config->{"Model::ICal"}{args}{calname}, ucfirst( $start_date->month_name ), $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  $start_date->set_locale( $c->locale );
  
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => encode_entities( sprintf("%s %s", ucfirst( $start_date->month_name ), $start_date->year) ),
  });
  
  $c->detach("download");
}

=head2 download_week

Download the given week's fixtures.

=cut

sub download_week :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $week_start_date = $c->stash->{week_start_date};
  my $week_end_date = $c->stash->{week_end_date};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find($calendar_type) unless !defined($calendar_type) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      # Get the matches
      my $matches = $c->model("DB::TeamMatch")->matches_in_date_range({
        season => $season,
        start_date => $week_start_date,
        end_date => $week_end_date,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf("fixtures_week_%s-%s-%s", $week_start_date->year, sprintf("%02d", $week_start_date->month), sprintf("%02d", $week_start_date->day)),
        calendar_name => sprintf("%s | %s %d %s %d | %s", $c->config->{"Model::ICal"}{args}{calname}, $week_start_date->day_name, $week_start_date->day, $week_start_date->month_name, $week_start_date->year, $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  #$week_start_date->set_locale($c->locale);
  my $enc_day_name = encode_entities($week_start_date->day_name);
  my $enc_month_name = encode_entities($week_start_date->month_name);
  
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => $c->maketext("fixtures-results.view-week.week-beginning", sprintf("%s %d %s %d", $week_start_date->day_name, $week_start_date->day, $week_start_date->month_name, $week_start_date->year)),
  });
  
  $c->detach("download");
}

=head2 download_day

Download the given month's fixtures.

=cut

sub download_day :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $date = $c->stash->{date};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->req->params->{type} || undef;
  
  if ( $download_type eq "calendar" ) {
    # Look up the calendar type, unless it's "download", which is a special case to tell us to actually download the file
    $calendar_type = $c->model("DB::CalendarType")->find( $calendar_type ) unless !defined( $calendar_type ) or $calendar_type eq "download" or $calendar_type == -1;
    
    # If we're downloading, stash the matches for the generic download routine to loop through.  Stash the download file name as well,
    # which is generated without an extension (the download routine will add this on to the end, depending on the download type).
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      my $matches = $c->model("DB::TeamMatch")->matches_on_date({
        season => $season,
        date => $date,
      });
      
      $c->stash({
        matches => $matches,
        file_name => sprintf("fixtures_day_%s-%s-%s", $date->year, sprintf("%02d", $date->month), sprintf("%02d", $date->day)),
        calendar_name => sprintf("%s | %s, %d %s %d | %s", $c->config->{"Model::ICal"}{args}{calname}, ucfirst($date->day_name), $date->day, $date->month_name, $date->year, $season->name),
      });
    }
  }
  
  # Stash the calendar type and detach to the download routine
  $date->set_locale($c->locale);
  
  $c->stash({
    calendar_type => $calendar_type,
    subtitle2 => encode_entities(sprintf("%s, %d %s %d", ucfirst( $date->day_name ), $date->day, $date->month_name, $date->year)),
  });
  
  $c->detach("download");
}

=head2 download

Private action that handles the downloading of fixtures after the file format has been specified / matches chosen

=cut

sub download :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  my $team = $c->stash->{team};
  my $download_type = $c->stash->{download_type};
  my $calendar_type = $c->stash->{calendar_type};
  my $matches = $c->stash->{matches};
  my $file_name = $c->stash->{file_name};
  my $calendar_name = $c->stash->{calendar_name};
  my $abbreviated_club_names = $c->stash->{abbreviated_club_names};
  my $summary_prefix = $c->stash->{summary_prefix};
  
  if ( $download_type eq "calendar" ) {
    my $zone = Data::ICal::TimeZone->new(timezone => $season->timezone);
    
    if ( defined( $calendar_type ) and $calendar_type eq "download" ) {
      # Valid calendar type
      my @events = ();
      
      # Loop through matches
      while ( my $match = $matches->next ) {
        my $event = $match->generate_ical_data({
          get_host => sub{ $c->req->uri->host },
          get_uri => sub{ $c->uri_for_action("/matches/team/view_by_url_keys", $_[0]) },
          get_duration => sub{ $c->config->{Matches}{Team}{duration} },
          abbreviated_club_names => $abbreviated_club_names,
          summary_prefix => $summary_prefix,
          logger => sub{ my $level = shift; $c->log->$level( @_ ); },
          timezone => $zone,
        });
        
        push(@events, $event);
      }
      
      # Now push the events into a calendar
      my $calendar = $c->model("ICal", {calname => $calendar_name});
      $calendar->add_entry($zone->definition);
      $calendar->add_entries(@events);
      
      # Content type is text/calendar
      $c->res->header("Content-type" => "text/calendar");
      
      $c->res->header("Content-Disposition" => 'attachment; filename="' . $file_name . '.ics"');
      $c->res->body($calendar->as_string);
      $c->detach;
    } elsif ( ref($calendar_type) eq "TopTable::Model::DB::CalendarType" ) {
      # Calendar type exists, redirect to the URI
      my $uri = $calendar_type->generate_uri({
        download_uri => $c->stash->{calendar_download_uri},
        calendar_name => $calendar_name,
      });
      
      # Finally, redirect to the URI
      $c->response->redirect($uri);
      $c->detach;
      return;
    } else {
      if ( defined($calendar_type) and $calendar_type == -1 ) {
        # Special calendar type "0" - form was submitted, so display links for manual import / subscription
        # Invalid calendar type or none specified, or not chosen yet - display the form
        my $webcal_uri = $c->stash->{calendar_download_uri}->clone;
        $webcal_uri->scheme("webcal");
        
        $c->stash({
          template => "html/fixtures-results/calendar/type-other.ttkt",
          external_scripts => [
            $c->uri_for("/static/script/fixtures-results/calendar-type-other.js"),
          ],
          webcal_uri => $webcal_uri,
          form_action => $c->uri_for_action($c->action, $c->req->captures, $download_type),
        });
      } else {
        $c->stash({
          template => "html/fixtures-results/calendar/types.ttkt",
          external_scripts => [
            $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
            $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
            $c->uri_for("/static/script/standard/chosen.js"),
            $c->uri_for("/static/script/standard/prettycheckable.js"),
            $c->uri_for("/static/script/fixtures-results/calendar-types.js", {v => "1.1"}),
          ],
          external_styles => [
            $c->uri_for("/static/css/chosen/chosen.min.css"),
            $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
          ],
          calendar_types => [$c->model("DB::CalendarType")->all_types],
          form_action => $c->uri_for_action($c->action, $c->req->captures, $download_type),
        });
      }
    }
  } else {
    # Unknown download type, 404
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 generate_calendar_download_uri

Generate the calendar download URI with the correct parameters for description prefixes and using abbreviated club names.

=cut

sub generate_calendar_download_uri :Private {
  my ( $self, $c, $action, $arguments ) = @_;
  my $summary_prefix = $c->req->params->{"summary-prefix"} || undef;
  my $abbreviated_club_names = $c->req->params->{"abbreviated-club-names"} || 0;
  
  # Stash the values for later on
  $c->stash({
    summary_prefix => $summary_prefix,
    abbreviated_club_names => $abbreviated_club_names,
  });
  
  # Always set abbreviated-club-names and type (type is always "download" and abbreviated-club-names is boolean)
  my $query_params = {
    type => "download",
    "abbreviated-club-names" => $abbreviated_club_names,
  };
  
  # Set summary prefix if it's set
  $query_params->{"summary-prefix"} = $summary_prefix;
  
  # Return the URI we need
  return $c->uri_for_action($action, $arguments, $query_params);
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
