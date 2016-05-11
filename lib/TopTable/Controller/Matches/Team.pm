package TopTable::Controller::Matches::Team;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper;
use Try::Tiny;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Matches::Team - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.team-matches")});
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/fixtures-results/root_current_season"),
    label => $c->maketext("menu.text.team-matches-breadcrumbs"),
  });
}


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Redirect to the fixtures lists so the user can choose which fixtures to view / update / whatever
  $c->response->redirect( $c->uri_for_action("/fixtures-results/root_current_season") );
  $c->detach;
  return;
}

=head2 base_by_ids

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_ids :Chained("/") :PathPart("matches/team") :CaptureArgs(5) {
  my ( $self, $c, $match_home_team_id, $match_away_team_id, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date =  $c->datetime(
      year  => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day   => $match_scheduled_date_day,
    );
  } catch {
    $c->detach( qw/TopTable::Controller::Root default/ );
  };
  
  my $match = $c->model("DB::TeamMatch")->get_match_by_ids( $match_home_team_id, $match_away_team_id, $scheduled_date );
  
  if ( defined( $match ) ) {
    $c->stash({match => $match});
    $c->forward("base");
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_by_url_keys

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_url_keys :Chained("/") :PathPart("matches/team") :CaptureArgs(7) {
  my ( $self, $c, $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date =  $c->datetime(
      year  => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day   => $match_scheduled_date_day,
    );
  } catch {
    $c->detach( qw/TopTable::Controller::Root default/ );
  };
  
  my $match = $c->model("DB::TeamMatch")->get_match_by_url_keys( $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $scheduled_date );
  
  if ( defined( $match ) ) {
    $c->stash({match => $match});
    $c->forward("base");
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2

Private base action forwarded from both base_by_ids and base_by_url_keys to perform actions common to both.

=cut

sub base :Private {
  my ( $self, $c ) = @_;
  my $match   = $c->stash->{match};
  my $season  = $match->season;
  my $score = ( $match->home_team_match_score or $match->away_team_match_score ) ? sprintf( "%d-%d", $match->home_team_match_score, $match->away_team_match_score ) : $c->maketext("matches.versus-abbreviation");
  my $encoded_name    = sprintf( "%s %s %s %s %s", encode_entities( $match->home_team->club->short_name ), encode_entities( $match->home_team->name ), $score, encode_entities( $match->away_team->club->short_name ), encode_entities( $match->away_team->name ) );
  my $scoreless_name  = sprintf( "%s %s %s %s %s", encode_entities( $match->home_team->club->short_name ), encode_entities( $match->home_team->name ), $c->maketext("matches.versus-abbreviation"), encode_entities( $match->away_team->club->short_name ), encode_entities( $match->away_team->name ) );
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/matches/team/view_by_url_keys", [$match->home_team->club->url_key, $match->home_team->url_key, $match->away_team->club->url_key, $match->away_team->url_key, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    label => $encoded_name,
  });
  
  my $home_players = $match->players({location => "home"});
  my $away_players = $match->players({location => "away"});
  
  # Get and stash the season / team_season / division_season objects so we don't need to look them up later
  $c->stash({
    encoded_name    => $encoded_name,
    scoreless_name  => $scoreless_name,
    score           => $score,
    subtitle1       => $encoded_name,
    team_seasons    => $match->get_team_seasons,
    division_season => $match->get_division_season,
    home_players    => $home_players,
    away_players    => $away_players,
  });
}

=head2 view_by_ids

=cut

sub view_by_ids :Chained("base_by_ids") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->detach( "view" );
}

=head2 view_by_url_keys

=cut

sub view_by_url_keys :Chained("base_by_url_keys") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->detach( "view" );
}

=head2 view

Private function forwarded from view_by_id and view_by_url_keys

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  my $match           = $c->stash->{match};
  my $scoreless_name  = $c->stash->{scoreless_name};
  my $score           = $c->stash->{score};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_view", $c->maketext("user.auth.view-matches"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( match_update match_cancel ) ], "", 0] );
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push update / cancel links if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.update-object",  $scoreless_name),
      link_uri  => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    }) if $c->stash->{authorisation}{match_update};
    
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0006-Cross-icon-32.png"),
      text      => $c->maketext("admin.cancel-object",  $scoreless_name),
      link_uri  => $c->uri_for_action("/matches/team/cancel_by_url_keys", $match->url_keys),
    }) if $c->stash->{authorisation}{match_cancel};
    
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0037-Notepad-icon-32.png"),
      text      => $c->maketext("admin.report-object",  $scoreless_name),
      link_uri  => $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys),
    }) if $match->can_report( $c->user );
  }
  
  my $date = $match->actual_date->set_locale( $c->locale );
  
  # Set up the external scripts - if the match has a score, we'll use a different script - the plugin will always be there
  my @external_scripts = ( $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js") );
  
  if ( $match->started ) {
    # The match has started, we don't specify a tab and it will default to the first one (games)
    push( @external_scripts, $c->uri_for("/static/script/standard/responsive-tabs.js") );
  } else {
    # The match has not started, start on the match details tab
    push( @external_scripts, $c->uri_for("/static/script/matches/team/view.js") );
  }
  
  # Inform that the scorecard is not yet complete if it's started but not complete
  my $page_description = undef;
  if ( $match->started and !$match->complete ) {
    # Match started but not complete
    $c->add_status_message("info", $c->maketext("matches.message.info.started-not-complete"));
    $page_description = $c->maketext("description.team-matches.view-started", $scoreless_name, $score);
  } elsif ( $match->cancelled ) {
    # Match cancelled
    $c->add_status_message("info", $c->maketext("matches.message.info.cancelled"));
    $page_description = $c->maketext("description.team-matches.view-cancelled", $scoreless_name, $c->i18n_datetime_format_date->format_datetime($date));
  } elsif ( !$match->started ) {
    # Match not started
    $c->add_status_message("info", $c->maketext("matches.message.info.not-started"));
    $page_description = $c->maketext("description.team-matches.view-not-started", $scoreless_name, $c->i18n_datetime_format_date->format_datetime($date));
  } else {
    # Match complete
    $page_description = $c->maketext("description.team-matches.view-completed", $scoreless_name, $score, $c->i18n_datetime_format_date->format_datetime($date));
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/matches/team/view.ttkt",
    external_scripts    => \@external_scripts,
    external_styles     => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    ],
    title_links         => \@title_links,
    subtitle2           => sprintf( "%s, %d %s %d", ucfirst( $date->day_name ), $date->day, $date->month_name, $date->year ),
    view_online_display => sprintf( "Viewing match %s", $scoreless_name ),
    view_online_link    => 1,
    reports             => $match->get_reports->count,
    latest_report       => $match->get_latest_report,
    original_report     => $match->get_original_report,
    canonical_uri       => $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys),
    page_description    => $page_description,
  });
}

=head2 update_by_ids

Update a team using the information given in base_by_ids

=cut

sub update_by_ids :Chained("base_by_ids") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "update" );
}

=head2 update_by_url_keys

Update a team using the information given in base_by_ids

=cut

sub update_by_url_keys :Chained("base_by_url_keys") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "update" );
}

=head2 update

Show the form fields for updating a match.

=cut

sub update :Private {
  my ( $self, $c ) = @_;
  my $match           = $c->stash->{match};
  my $updating_locked = 0;
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  my $players = $match->team_match_players;
  my $players_count = $match->team_match_template->singles_players_per_team;
  
  # Ensure the season this match belongs to is not complete
  my $season = $match->season;
  
  if ( $season->complete ) {
    my ( $scheduled_year, $scheduled_month, $scheduled_day ) = split( "/", $match->scheduled_date->ymd( "/" ) );
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", [ $match->home_team->club->url_key, $match->home_team->url_key, $match->away_team->club->url_key, $match->away_team->url_key, $scheduled_year, sprintf("%02d", $scheduled_month), sprintf("%02d", $scheduled_day) ],
      {mid => $c->set_status_msg( {error => $c->maketext("matches.update.error.season-complete")} )}));
    $c->detach;
    return;
  } elsif ( $match->cancelled ) {
    my ( $scheduled_year, $scheduled_month, $scheduled_day ) = split( "/", $match->scheduled_date->ymd( "/" ) );
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", [ $match->home_team->club->url_key, $match->home_team->url_key, $match->away_team->club->url_key, $match->away_team->url_key, $scheduled_year, sprintf("%02d", $scheduled_month), sprintf("%02d", $scheduled_day) ],
      {mid => $c->set_status_msg( {error => $c->maketext("matches.update.error.match-cancelled")} )}));
    $c->detach;
    return;
  }
  
  # Set up the page titles
  my $date = $match->scheduled_date->set_locale( $c->locale );
    
  # Get the player lists
  $c->forward( "get_player_lists" );
  
  # Stash the template values
  $c->stash({
    template            => "html/matches/team/update.ttkt",
    form_action         => $c->uri_for_action("/matches/team/do_update_by_ids", [$match->home_team->id, $match->away_team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/standard/button-toggle.js"),
      $c->uri_for_action("/matches/team/update_js_by_ids", [$match->home_team->id, $match->away_team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
    ],
    subtitle2           => encode_entities( $match->division->name ),
    subtitle3           => sprintf( "%s, %d %s %d", ucfirst( $date->day_name ), $date->day, $date->month_name, $date->year ),
    view_online_display => sprintf( "Updating match %s %s v %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name ),
    view_online_link    => 0,
    total_players       => $players_count * 2, # $players_count is the number of players per team
    venues              => [ $c->model("DB::Venue")->all_venues ],
    season              => $season,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.update"),
  });
}

=head2 do_update_by_ids

Chained to base_by_ids and provides the path for updating a match.

=cut

sub do_update_by_ids :Chained("base_by_ids") :PathPart("do-update") {
  my ( $self, $c ) = @_;
  
  # Forward to the genuine update routine
  $c->detach( "do_update" );
}

=head2 do_update_by_url_keys

Chained to base_by_url_keys and provides the path for updating a match.

=cut

sub do_update_by_url_keys :Chained("base_by_url_keys") :PathPart("do-update") {
  my ( $self, $c ) = @_;
  
  # Forward to the genuine update routine
  $c->detach( "do_update" );
}

=head2 do_update

Private function forwarded from do_update_by_ids and do_update_by_url_keys.  Updates a match score for all games in the match.

=cut

sub do_update :Private {
  my ( $self, $c ) = @_;
  my $match         = $c->stash->{match};
  my $parameters    = $c->request->body_parameters;
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  my $update_result = $match->update_scorecard( $parameters );
  
  if ( scalar( @{ $update_result->{errors} } ) ) {
    
  } else {
    # Log an update
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team-match", "update", {home_team => $match->home_team->id, away_team => $match->away_team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name) ] );
    
  }
}

=head2 update_game_score_by_ids

Provides the URL for update_game_score by chaining to base_by_ids; forwards to the real routine.

=cut

sub update_game_score_by_ids :Chained("base_by_ids") :PathPart("game-score") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "update_game_score" );
}

=head2 update_game_score_by_url_keys

Provides the URL for update_game_score by chaining to base_by_ids; forwards to the real routine.

=cut

sub update_game_score_by_url_keys :Chained("base_by_url_keys") :PathPart("game-score") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "update_game_score" );
}

=head2 update_game_score

Update the score for a game within a match.

=cut

sub update_game_score :Private {
  my ( $self, $c ) = @_;
  my $match         = $c->stash->{match};
  my $parameters    = $c->request->body_parameters;
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  my $update_result = $match->update_scorecard( $parameters );
  
  if ( scalar( @{ $update_result->{error} } ) ) {
    my $error = $c->build_message( $update_result->{error} );
    
    if ( $c->is_ajax ) {
      # AJAX requests get returned with a 400 status code
      $c->log->error($error);
      $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
      return;
    } else {
      # Otherwise, just return the error
      return $error;
    }
  }
  
  # Log an update
  $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team-match", "update", {home_team => $match->home_team->id, away_team => $match->away_team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name) ] );
  
  # Stash something to say the request was okay
  if ( $c->is_ajax ) {
    $c->stash({
      json_status               => "Okay",
      json_originally_complete  => $update_result->{match_originally_complete},
      json_match_complete       => $update_result->{match}->complete,
    });
    
    $c->detach( $c->view("JSON") );
  }
}

=head2 update_js_by_ids

Generate the javascript for updating a scorecard based on the information given in base_by_ids

=cut

sub update_js_by_ids :Chained("base_by_ids") :PathPart("update.js") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "update_js" );
}

=head2 update_js_by_url_keys

Update a team using the information given in base_by_ids

=cut

sub update_js_by_url_keys :Chained("base_by_url_keys") :PathPart("update.js") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "update_js" );
}

=head2 update_js

Generates a javascript include file for the match update page that facilitates updating the scorecard fields. 

=cut

sub update_js :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  # This will be a javascript file, not a HTML
  $c->response->headers->header("Content-type" => "text/javascript");
  
  # Stash no wrapper and the template
  $c->stash({
    template    => "scripts/matches/team/update.ttjs",
    no_wrapper  => 1,
  });
  
  $c->detach( $c->view("HTML") );
}

=head2 change_played_date_by_ids

Provides a URL for change_played_date by chaining to base_by_ids; forwards to the real routine.

=cut

sub change_played_date_by_ids  :Chained("base_by_ids") :PathPart("change-date") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "change_played_date" );
}

=head2 change_played_date_by_url_keys

Provides a URL for change_played_date by chaining to base_by_ids; forwards to the real routine.

=cut

sub change_played_date_by_url_keys  :Chained("base_by_url_keys") :PathPart("change-date") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "change_played_date" );
}

=head2 change_played_date

Change the match played date

=cut

sub change_played_date :Private {
  my ( $self, $c ) = @_;
  my $match         = $c->stash->{match};
  my $played_date   = $c->request->parameters->{date};
  my $content_type  = $c->request->parameters->{"content-type"} || "html";
  my $error = $match->update_played_date( $played_date );
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  # Check if we got an error
  if ( scalar( @{ $error } ) ) {
    $error = $c->build_message( $error );
    
    if ( $c->is_ajax ) {
      # AJAX requests get returned with a 400 status code
      $c->log->error($error);
      $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
      return;
    } else {
      # Otherwise, just return the error
      return $error;
    }
  }
  
  # Stash something to say the request was okay
  if ( $c->is_ajax ) {
    $c->stash({json_status  => "Okay",});
    $c->detach( $c->view("JSON") );
  }
}

=head2 change_venue_by_ids

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_venue_by_ids :Chained("base_by_ids") :PathPart("change-venue") Args(0) {
  my ( $self, $c )  = @_;
  
  $c->detach( "change_venue" );
}

=head2 change_venue_by_url_keys

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_venue_by_url_keys :Chained("base_by_url_keys") :PathPart("change-venue") Args(0) {
  my ( $self, $c )  = @_;
  
  $c->detach( "change_venue" );
}

=head2 change_venue

Change the match venue.

=cut

sub change_venue :Private {
  my ( $self, $c )  = @_;
  my $content_type  = $c->request->parameters->{"content-type"} || "html";
  my $venue_id      = $c->request->parameters->{venue};
  my $match         = $c->stash->{match};
  my $match_type    = $c->stash->{match_type};
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  my $venue = $c->model("DB::Venue")->find( $venue_id );
  my $error = $match->update_venue( $venue );
  
  if ( scalar( @{ $error } ) ) {
    # Error, couldn't update
    $error = $c->build_message( $error );
    
    if ( $c->is_ajax ) {
      $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
    } else {
      return $error;
    }
  } else {
    # Success
    if ( $c->is_ajax ) {
      $c->stash({json_status  => "Okay",});
      $c->detach( $c->view("JSON") );
    }
  }
}

=head2 get_player_lists_by_ids

Provides the URL for get_playerlists by chaining to base_by_ids.  Forwards to the real routine.

=cut

sub get_player_lists_by_ids :Chained("base_by_ids") :PathPart("player-lists") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "get_player_lists" );
}

=head2 get_player_lists_by_url_keys

Provides the URL for get_playerlists by chaining to base_by_ids.  Forwards to the real routine.

=cut

sub get_player_lists_by_url_keys :Chained("base_by_url_keys") :PathPart("player-lists") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "get_player_lists" );
}

=head2 get_player_lists

Get the list of players for home and away teams, including any players playing as loan players in this particular match.

=cut

sub get_player_lists :Private {
  my ( $self, $c ) = @_;
  my $content_type  = $c->request->parameters->{"content-type"} || "html";
  my $match         = $c->stash->{match};
  my @home_player_list = $c->model("DB::PersonSeason")->get_people_in_team_in_name_order( $match->scheduled_week->season, $match->home_team );
  my @away_player_list = $c->model("DB::PersonSeason")->get_people_in_team_in_name_order( $match->scheduled_week->season, $match->away_team );
  my $home_doubles_list = [];
  my $away_doubles_list = [];
  
  # Push the ID and name on to the value / text attributes for SelectBoxIt.
  foreach my $player ( @home_player_list ) {
    push( @{ $home_doubles_list }, {value => $player->person->id, text => $player->person->display_name,} );
  }
  
  foreach my $player ( @away_player_list ) {
    push( @{ $away_doubles_list }, {value => $player->person->id, text => $player->person->display_name,} );
  }
  
  # Then loop through the match players, adding any that are loan players to the array
  my $players = $match->team_match_players;
  while ( my $player = $players->next ) {
    if ( defined( $player->loan_team ) and defined( $player->player ) and $player->location->location eq "Home" ) {
      # Home loan player
      push( @{ $home_doubles_list }, {value => $player->player->id, text => $player->player->display_name,} );
    } elsif ( defined( $player->loan_team ) and defined( $player->player ) and $player->location->location eq "Away" ) {
      # Away loan player
      push( @{ $away_doubles_list }, {value => $player->player->id, text => $player->player->display_name,} );
    }
  }
  
  # Stash our values
  $c->stash({
    home_player_list        => \@home_player_list,
    away_player_list        => \@away_player_list,
    home_doubles_list       => $home_doubles_list,
    away_doubles_list       => $away_doubles_list,
    
    # No encoding for this, as we're forwarding to a JSON view that will do it for us
    json_home_doubles_list  => $home_doubles_list,
    json_away_doubles_list  => $away_doubles_list,
    # Don't alter the view who's online activity
    skip_view_online        => 1,
  });
  
  # Detach to the JSON view if required
  $c->detach( $c->view("JSON") ) if $c->is_ajax;
  
  return;
}

=head2 update_playing_order_by_ids

Provides the URL for update_playing_order chaining to base_by_ids; forwards to the real routine.

=cut

sub update_playing_order_by_ids :Chained("base_by_ids") :PathPart("playing-order") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "update_playing_order" );
}

=head2 update_playing_order_by_url_keys

Provides the URL for update_playing_order chaining to base_by_ids; forwards to the real routine.

=cut

sub update_playing_order_by_url_keys :Chained("base_by_url_keys") :PathPart("playing-order") Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "update_playing_order" );
}

sub update_playing_order :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  # Check that we are authorised to update scorecards
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1] );
  
  my $details = $match->update_playing_order( $c->request->parameters );
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Detach to the JSON error routine if we're using JSON
    $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
  } else {
    # Detach to the JSON view
    $c->detach( $c->view("JSON") );
  }
}

=head2 cancel_by_ids

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub cancel_by_ids :Chained("base_by_ids") :PathPart("cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "cancel" );
}

=head2 cancel_by_url_keys

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub cancel_by_url_keys :Chained("base_by_url_keys") :PathPart("cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "cancel" );
}

=head2 cancel

Display the form for cancelling the match, allowing the user to enter a points award for one or either team.

=cut

sub cancel :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  # Check that we are authorised to cancel matches
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.cancel-matches"), 1] );
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Ensure the season this match belongs to is not complete
  my $season = $match->season;
  
  if ( $season->complete ) {
    my ( $scheduled_year, $scheduled_month, $scheduled_day ) = split( "/", $match->scheduled_date->ymd( "/" ) );
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", [ $match->home_team->club->url_key, $match->home_team->url_key, $match->away_team->club->url_key, $match->away_team->url_key, $scheduled_year, $scheduled_month, $scheduled_day ],
      {mid => $c->set_status_msg( {error => $c->maketext("matches.cancel.error.season-complete")} )}));
    $c->detach;
    return;
  }
  
  # Add a warning about the match having a score if we've already started
  $c->add_status_message("warning", $c->maketext("matches.cancel.warning.has-score")) if $match->started;
  
  # Set up the page titles
  my $date = $match->scheduled_date->set_locale( $c->locale );
  
  # Stash the template values
  $c->stash({
    template            => "html/matches/team/cancel.ttkt",
    form_action         => $c->uri_for_action("/matches/team/do_cancel_by_ids", [$match->home_team->id, $match->away_team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/matches/team/cancel.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    subtitle2           => encode_entities( $match->division->name ),
    subtitle3           => sprintf( "%s, %d %s %d", ucfirst( $date->day_name ), $date->day, $date->month_name, $date->year ),
    view_online_display => sprintf( "Cancelling match %s %s v %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.cancel"),
  });
}

=head2 do_cancel_by_ids

Provides the URL for do_cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub do_cancel_by_ids :Chained("base_by_ids") :PathPart("do-cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "do_cancel" );
}

=head2 do_cancel_by_url_keys

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub do_cancel_by_url_keys :Chained("base_by_url_keys") :PathPart("do-cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "do_cancel" );
}

=head2 do_cancel

Process the cancellation form; cancels (or uncancels) the match.  If the match is cancelled, all previous scores / players / statistics calculated from those are removed.

=cut

sub do_cancel :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $home_points_awarded = $c->request->parameters->{home_points_awarded};
  my $away_points_awarded = $c->request->parameters->{away_points_awarded};
  
  # Check that we are authorised to cancel matches
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.cancel-matches"), 1] );
  
  my $cancel = $c->request->parameters->{cancel} || 0;
  
  # Now forward to the match cancellation routine, which does all the error checking
  my $actioned;
  
  if ( $cancel ) {
    $actioned = $match->cancel({
      home_points_awarded => $home_points_awarded,
      away_points_awarded => $away_points_awarded,
    });
  } else {
    $actioned = $match->uncancel;
  }
  
  if ( scalar( @{ $actioned->{error} } ) ) {
    # Errors, return them to the user
    my $errors = $c->build_message( $actioned->{error} );
    
    if ( $actioned->{cancellation_allowed} ) {
      # Flash submitted values and redirect to the cancellation page with the errors
      $c->flash->{form_errored}         = 1;
      $c->flash->{cancel}               = $cancel;
      $c->flash->{home_points_awarded}  = $home_points_awarded;
      $c->flash->{away_points_awarded}  = $away_points_awarded;
      
      $c->response->redirect( $c->uri_for_action("/matches/team/cancel_by_url_keys", $match->url_keys,
                                  {mid => $c->set_status_msg( {success => $errors} ) }) );
    } else {
      # Redirect to the view screen, as we can't cancel
      $c->response->redirect( $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                  {mid => $c->set_status_msg( {success => $errors} ) }) );
    }
    
    $c->detach;
    return;
  } else {
    # No errors, log the cancellation / uncancellation and return to the view the screen
    my $action = ( $cancel ) ? "cancel" : "uncancel";
    my $message = sprintf( "matches.%s.success", $action );
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team-match", $action, {home_team => $match->home_team->id, away_team => $match->away_team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name)] );
    $c->response->redirect( $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg( {success => $c->maketext( $message )} ) }) );
    $c->detach;
    return;
  }
}

=head2 report_by_ids

Report on a match using the information given in base_by_ids

=cut

sub report_by_ids :Chained("base_by_ids") :PathPart("report") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "report" );
}

=head2 report_by_url_keys

Report on a match using the information given in base_by_ids

=cut

sub report_by_url_keys :Chained("base_by_url_keys") :PathPart("report") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "report" );
}

=head2 report

Show the form fields for updating a match.

=cut

sub report :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  $c->forward( "check_report_create_edit_authorisation" );
  
  # Stash the template values
  $c->stash({
    template            => "html/matches/team/report.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/standard/ckeditor.js"),
    ],
    form_action         => $c->uri_for_action("/matches/team/publish_report_by_url_keys", $match->url_keys),
    subtitle2           => $c->maketext("matches.report.heading"),
    latest_report       => $match->get_latest_report,
    view_online_display => "Writing a match report",
    view_online_link    => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.report"),
  });
}

=head2 publish_report_by_ids

Report on a match using the information given in base_by_ids

=cut

sub publish_report_by_ids :Chained("base_by_ids") :PathPart("publish-report") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "publish_report" );
}

=head2 publish_report_by_url_keys

Report on a match using the information given in base_by_ids

=cut

sub publish_report_by_url_keys :Chained("base_by_url_keys") :PathPart("publish-report") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real update routine
  $c->detach( "publish_report" );
}

=head2 publish_report

Process the form for publishing a match report.

=cut

sub publish_report :Private {
  my ( $self, $c ) = @_;
  my $match   = $c->stash->{match};
  my $report  = $c->request->body_parameters->{report};
  
  # Check we're authorised
  $c->forward( "check_report_create_edit_authorisation" );
  
  my $actioned = $match->add_report({
    user  => $c->user,
    report  => $report
  });
  
  if ( scalar( @{ $actioned->{errors} } ) ) {
    # Errors - build them into something we can show the user and redirect back to the form
    $c->flash->{report} = $report;
    my $errors = $c->build_message( $actioned->{errors} );
    
    $c->response->redirect( $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys,
                              {mid => $c->set_status_msg( {success => $errors} ) }) );
    $c->detach;
    return;
  } else {
    my $action = $actioned->{action};
    
    my $action_description = ( $action eq "create" ) ? "created" : "edited";
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["team-match", "report-$action", {home_team => $match->home_team->id, away_team => $match->away_team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name)] );
    $c->response->redirect( $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                              {mid => $c->set_status_msg( {success =>  $c->maketext("matches.report.success", $c->maketext("admin.message.$action_description"))} ) }) );
    $c->detach;
    return;
  }
}

=head2 check_report_create_edit_authorisation

Checks we're authorised to create or edit a report (whichever is necessary) for the stashed match.

=cut

sub check_report_create_edit_authorisation :Private {
  my ( $self, $c ) = @_;
  my $match     = $c->stash->{match};
  my $season    = $match->season;
  my $home_team = $match->home_team;
  my $away_team = $match->away_team;
  my $home_club = $match->home_team->club;
  my $away_club = $match->away_team->club;
  
  if ( $season->complete ) {
    # Season is not current, so we can't submit or edit a match report
    $c->response->redirect( $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg( {error => $c->maketext( "matches.report.error.season-not-current" )} ) }) );
    $c->detach;
    return;
  }
  
  # Before we can auth this, we need to know if a reports exists - if it does, we'll be editing; if not, we'll be creating
  my $reports                 = $match->get_reports;
  my $original_report_number  = ( $reports->count > 0 ) ? $reports->count - 1 : 0;
  
  # The live report will always be the first one - and the original will always be the last one (report count - 1 in a zero-based list).
  my ( $live_report )     = $reports->slice( 0, 0 );
  my ( $original_report ) = $reports->slice( $original_report_number, $original_report_number );
  
  # If we have a live report, we're editing, otherwise we're creating.
  my $action  = ( defined( $live_report ) ) ? "edit" : "create";
  
  if ( $action eq "create" ) {
    # Creating - check we can create match reports
    # Redirect on fail if:
    #  * We're not logged in
    #  * We are logged in and not associated with either the home club, home team, away club or away team in any way (by playing for or captaining the team or being secretary for the club)
    my $redirect_on_fail = (
      $c->user_exists and (
        $c->user->plays_for({team => $home_team, season => $season}) or
        $c->user->captain_for({team => $home_team, season => $season}) or
        $c->user->plays_for({team => $away_team, season => $season}) or
        $c->user->captain_for({team => $away_team, season => $season}) or
        $c->user->secretary_for({club => $home_club}) or
        $c->user->secretary_for({club => $away_club})
      ) ) ? 0 : 1;
    
    # Now do the authorisation
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_report_create", $c->maketext("user.auth.create-match-reports"), $redirect_on_fail] );
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_report_create_associated", $c->maketext("user.auth.create-match-reports"), 1] ) unless $c->stash->{authorisation}{match_report_create};
  } else {
    # Editing - check we can edit the report for this match.
    my $redirect_on_fail = ( $c->user_exists and ( $c->user->id == $original_report->author->id ) ) ? 0 : 1;
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_report_edit_all", $c->maketext("user.auth.edit-match-reports"), $redirect_on_fail] );
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["match_report_edit_own", $c->maketext("user.auth.edit-match-reports"), 1] ) if !$c->stash->{authorisation}{match_report_edit_all} and $c->user_exists and $c->user->id == $original_report->author->id;
  }
  
  # Stash some values for the routines we're returning to
  $c->stash({
    reports         => $reports,
    live_report     => $live_report,
    original_report => $original_report,
  });
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
