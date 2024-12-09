package TopTable::Controller::Matches::Team;
use Moose;
use namespace::autoclean;
use JSON;
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
  $c->stash({subtitle1 => $c->maketext("menu.text.team-match")});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path  => $c->uri_for_action("/fixtures-results/root_current_season"),
    label => $c->maketext("menu.text.team-match-breadcrumbs-nav"),
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
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date = $c->datetime(
      year  => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day   => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  my $match = $c->model("DB::TeamMatch")->get_match_by_ids($match_home_team_id, $match_away_team_id, $scheduled_date);
  
  if ( defined($match) ) {
    $c->stash({match => $match});
    $c->forward("base");
  } else {
    $c->detach(qw( TopTable::Controller::Root default ));
  }
}

=head2 base_by_url_keys

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_url_keys :Chained("/") :PathPart("matches/team") :CaptureArgs(7) {
  my ( $self, $c, $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day ) = @_;
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date =$c->datetime(
      year => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw( TopTable::Controller::Root default ));
  };
  
  my $match = $c->model("DB::TeamMatch")->get_match_by_url_keys($match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $scheduled_date);
  
  if ( defined($match) ) {
    $c->stash({match => $match});
    $c->forward("base");
  } else {
    $c->detach(qw( TopTable::Controller::Root default ));
  }
}

=head2

Private base action forwarded from both base_by_ids and base_by_url_keys to perform actions common to both.

=cut

sub base :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $season = $match->season;
  my ( $home_team, $away_team ) = ( $match->team_season_home_team_season, $match->team_season_away_team_season );
  my $score = ( $match->home_team_match_score or $match->away_team_match_score ) ? sprintf("%d-%d", $match->home_team_match_score, $match->away_team_match_score) : $c->maketext("matches.versus-abbreviation");
  my $encoded_name = encode_entities($match->name);
  my $scoreless_name = encode_entities($match->name({scoreless => 1}));
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys),
    label => $encoded_name,
  });
  
  my $home_players = $match->players({location => "home"});
  my $away_players = $match->players({location => "away"});
  
  my $noindex = $match->noindex_set(1)->count;
  $c->stash->{noindex} = 1 if $noindex;
  
  my ( $subtitle2, $subtitle3, $subtitle4, $subtitle5 );
  my $date = $match->played_date->set_locale($c->locale);
  my $date_str = $c->i18n_datetime_format_date_long->format_datetime($date);
  
  if ( defined($match->division_season) ) {
    $subtitle2 = $c->maketext("matches.field.competition.value.league");
    $subtitle3 = encode_entities($match->division_season->name);
    $subtitle4 = $date_str;
  } else {
    $subtitle2 = encode_entities($match->tournament_round->tournament->event_season->name);
    $subtitle3 = $match->tournament_round->name;
    
    if ( defined($match->tournament_group) ) {
      $subtitle4 = $match->tournament_group->name if defined($match->tournament_group);
      $subtitle5 = $date_str;
    } else {
      $subtitle4 = $date_str;
      
    }
    
    # Add a warning for matches that don't have a division (attached to an event instead)
    $c->add_event_test_msg;
  }
  
  # Get and stash the season / team_season / division_season objects so we don't need to look them up later
  $c->stash({
    encoded_name => $encoded_name,
    scoreless_name => $scoreless_name,
    score => $score,
    subtitle1 => $encoded_name,
    subtitle2 => $subtitle2,
    subtitle3 => $subtitle3,
    subtitle4 => $subtitle4,
    subtitle5 => $subtitle5,
    date => $date,
    team_seasons => $match->get_team_seasons,
    division_season => $match->division_season,
    home_players => $home_players,
    away_players => $away_players,
  });
}

=head2 view_by_ids

=cut

sub view_by_ids :Chained("base_by_ids") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("view");
}

=head2 view_by_url_keys

=cut

sub view_by_url_keys :Chained("base_by_url_keys") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->detach("view");
}

=head2 view

Private function forwarded from view_by_id and view_by_url_keys

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $scoreless_name = $c->stash->{scoreless_name};
  my $score = $c->stash->{score};
  my $date = $c->stash->{date};
  
  # Check that we are authorised to view matches
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_view", $c->maketext("user.auth.view-matches"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( match_update match_cancel ) ], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push update / cancel links if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.update-object", $scoreless_name),
    link_uri => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
  }) if $c->stash->{authorisation}{match_update};
  
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0006-Cross-icon-32.png"),
    text => $c->maketext("admin.cancel-object", $scoreless_name),
    link_uri => $c->uri_for_action("/matches/team/cancel_by_url_keys", $match->url_keys),
  }) if $c->stash->{authorisation}{match_cancel};
  
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0037-Notepad-icon-32.png"),
    text => $c->maketext("admin.report-object", $scoreless_name),
    link_uri => $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys),
  }) if $match->can_report($c->user);
  
  # Set up the external scripts - if the match has a score, we'll use a different script - the plugin will always be there
  my @external_scripts = (
    $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
    $c->uri_for("/static/script/standard/vertical-table.js"),
  );
  
  if ( $match->started ) {
    # The match has started, we don't specify a tab and it will default to the first one (games)
    push(@external_scripts, $c->uri_for("/static/script/matches/team/view.js", {v => 3}));
  } else {
    # The match has not started, start on the match details tab
    push(@external_scripts, $c->uri_for("/static/script/matches/team/view-not-started.js", {v => 3}));
  }
  
  # Inform that the scorecard is not yet complete if it's started but not complete
  my $page_description = undef;
  if ( $match->started and !$match->complete ) {
    # Match started but not complete
    $c->add_status_messages({info => $c->maketext("matches.message.info.started-not-complete")});
    $page_description = $c->maketext("description.team-matches.view-started", $scoreless_name, $score);
  } elsif ( $match->cancelled ) {
    # Match cancelled
    $c->add_status_messages({info => $c->maketext("matches.message.info.cancelled")});
    $page_description = $c->maketext("description.team-matches.view-cancelled", $scoreless_name, $c->i18n_datetime_format_date->format_datetime($date));
  } elsif ( !$match->started ) {
    # Match not started
    $c->add_status_messages({info => $c->maketext("matches.message.info.not-started")});
    $page_description = $c->maketext("description.team-matches.view-not-started", $scoreless_name, $c->i18n_datetime_format_date->format_datetime($date));
  } else {
    # Match complete
    $page_description = $c->maketext("description.team-matches.view-completed", $scoreless_name, $score, $c->i18n_datetime_format_date->format_datetime($date));
  }
  
  $c->add_status_messages({info => $c->maketext("matches.message.info.handicap-not-set")}) if $match->handicapped and !$match->handicap_set;
  
  # Set up the template to use
  $c->stash({
    template => "html/matches/team/view.ttkt",
    external_scripts => \@external_scripts,
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
    title_links => \@title_links,
    #subtitle2 => sprintf("%s %d %s %d", ucfirst( $date->day_name ), $date->day, $date->month_name, $date->year),
    view_online_display => sprintf("Viewing match %s", $scoreless_name),
    view_online_link => 1,
    reports => $match->get_reports->count,
    latest_report => $match->get_latest_report,
    original_report => $match->get_original_report,
    canonical_uri => $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys),
    page_description => $page_description,
  });
}

=head2 update_by_ids

Update a team using the information given in base_by_ids

=cut

sub update_by_ids :Chained("base_by_ids") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update");
}

=head2 update_by_url_keys

Update a team using the information given in base_by_ids

=cut

sub update_by_url_keys :Chained("base_by_url_keys") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update");
}

=head2 update

Show the form fields for updating a match.

=cut

sub update :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $updating_locked = 0;
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # Don't cache this page.
  $c->res->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->res->header("Pragma" => "no-cache");
  $c->res->header("Expires" => 0);
  
  
  $c->add_status_messages({warning => $c->maketext("matches.update.warning.handicap-not-set")}) if $match->handicapped and !$match->handicap_set;
  
  my $players = $match->team_match_players;
  my $players_count = $match->team_match_template->singles_players_per_team;
  
  # Ensure the season this match belongs to is not complete
  my $season = $match->season;
  
  if ( $season->complete ) {
    my ( $scheduled_year, $scheduled_month, $scheduled_day ) = split("/", $match->scheduled_date->ymd("/"));
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
      {mid => $c->set_status_msg({error => $c->maketext("matches.update.error.season-complete")})}));
    $c->detach;
    return;
  } elsif ( $match->cancelled ) {
    my ( $scheduled_year, $scheduled_month, $scheduled_day ) = split("/", $match->scheduled_date->ymd("/"));
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
      {mid => $c->set_status_msg({error => $c->maketext("matches.update.error.match-cancelled")})}));
    $c->detach;
    return;
  }
  
  # Set up the page titles
  my $date = $c->stash->{date};
    
  # Get the player lists
  $c->forward("get_player_lists");
  
  # Stash the template values
  $c->stash({
    template => "html/matches/team/update.ttkt",
    form_action => $c->uri_for_action("/matches/team/do_update_by_ids", [$match->team_season_home_team_season->team->id, $match->team_season_away_team_season->team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    scripts => ["tokeninput-standard"],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/standard/button-toggle.js", {v => 2}),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/messages.js"),
      $c->uri_for_action("/matches/team/update_js_by_ids", [$match->team_season_home_team_season->team->id, $match->team_season_away_team_season->team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
    ],
    view_online_display => sprintf("Updating match %s %s v %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name),
    view_online_link => 0,
    total_players => $players_count * 2, # $players_count is the number of players per team
    venues => [$c->model("DB::Venue")->active_venues],
    season => $season,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.update"),
  });
}

=head2 do_update_by_ids

Chained to base_by_ids and provides the path for updating a match.

=cut

sub do_update_by_ids :Chained("base_by_ids") :PathPart("do-update") {
  my ( $self, $c ) = @_;
  $c->detach("do_update");
}

=head2 do_update_by_url_keys

Chained to base_by_url_keys and provides the path for updating a match.

=cut

sub do_update_by_url_keys :Chained("base_by_url_keys") :PathPart("do-update") {
  my ( $self, $c ) = @_;
  $c->detach("do_update");
}

=head2 do_update

Private function forwarded from do_update_by_ids and do_update_by_url_keys.  Updates a match score for all games in the match.

=cut

sub do_update :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $params = $c->req->body_parameters;
  $params->{logger} = sub{ my $level = shift; $c->log->$level( @_ ) };
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  my $update_result = $match->update_scorecard($params);
  
  if ( scalar @{$update_result->{errors}} ) {
    
  } else {
    # Log an update
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "update", {home_team => $match->home_team->id, away_team => $match->away_team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name)]);
  }
}

=head2 update_game_score_by_ids

Provides the URL for update_game_score by chaining to base_by_ids; forwards to the real routine.

=cut

sub update_game_score_by_ids :Chained("base_by_ids") :PathPart("game-score") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_game_score");
}

=head2 update_game_score_by_url_keys

Provides the URL for update_game_score by chaining to base_by_ids; forwards to the real routine.

=cut

sub update_game_score_by_url_keys :Chained("base_by_url_keys") :PathPart("game-score") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_game_score");
}

=head2 update_game_score

Update the score for a game within a match.

=cut

sub update_game_score :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $params = $c->req->body_params;
  $params->{logger} = sub{ my $level = shift; $c->log->$level( @_ ) };
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  my $response = $match->update_scorecard($params);
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my @match_scores = @{$response->{match_scores}};
  
  # Stash the messages
  $c->stash({
    json_data => {
      messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success},
      match_originally_complete => $response->{match_originally_complete},
      match_complete => $response->{match_complete},
      match_scores => \@match_scores,
    }
  });
  
  # Generate the redirect URI and pass it back if the match wasn't complete, but now is.
  # We have to do this because the JS routine either has access to the messages (through the JSON passed back) or the set_status_msg routine (via TT method calling), but can't use both
  if ( $response->{match_complete} and !$response->{match_originally_complete} ) {
    my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
    my $redirect_uri = $c->uri_for_action("/matches/team/view_by_url_keys", [$match->team_season_home_team_season->club_season->club->url_key, $match->team_season_home_team_season->team->url_key, $match->team_season_away_team_season->club_season->club->url_key, $match->team_season_away_team_season->team->url_key, $match->scheduled_date->year, sprintf("%02d", $match->scheduled_date->month), sprintf("%02d", $match->scheduled_date->day)], {mid => $mid});
    $c->stash->{json_data}{redirect_uri} = $redirect_uri->as_string;
  } 
  
  if ( $response->{completed} ) {
    # Completed, log that we updated the match
    my $match_name = $c->maketext("matches.name", $match->team_season_home_team_season->full_name, $match->team_season_away_team_season->full_name);
    $match_name .= " (" . $match->tournament_round->tournament->event_season->name . ")" if defined($match->tournament_round);
    
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "update", {home_team => $match->team_season_home_team_season->team->id, away_team => $match->team_season_away_team_season->team->id, scheduled_date => $match->scheduled_date->ymd}, $match_name]);
  } else {
    # Wasn't completed, return with an error code
    $c->res->status(400);
  }
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
  return;
}

=head2 update_js_by_ids

Generate the javascript for updating a scorecard based on the information given in base_by_ids

=cut

sub update_js_by_ids :Chained("base_by_ids") :PathPart("update.js") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_js");
}

=head2 update_js_by_url_keys

Update a team using the information given in base_by_ids

=cut

sub update_js_by_url_keys :Chained("base_by_url_keys") :PathPart("update.js") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_js");
}

=head2 update_js

Generates a javascript include file for the match update page that facilitates updating the scorecard fields. 

=cut

sub update_js :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # This will be a javascript file, not a HTML
  $c->res->header("Content-type" => "text/javascript");
  
  # Stash no wrapper and the template
  $c->stash({
    template => "scripts/matches/team/update.ttjs",
    no_wrapper => 1,
  });
  
  $c->detach($c->view("HTML"));
}

=head2 calculate_running_scores_by_ids

Return the running scores for each game based on the information given in base_by_ids.

=cut

sub calculate_running_scores_by_ids :Chained("base_by_ids") :PathPart("calculate-running-scores") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("calculate_running_scores");
}

=head2 calculate_running_scores_by_url_keys

Return the running scores for each game based on the information given in base_by_ids.

=cut

sub calculate_running_scores_by_url_keys :Chained("base_by_url_keys") :PathPart("calculate-running-scores") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("calculate_running_scores");
}

=head2 calculate_running_scores

Return the running scores for each game.

=cut

sub calculate_running_scores :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  my $match_scores = $match->calculate_match_score;
  $c->stash({json_data => {match_scores => $match_scores}});
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
  return;
}

=head2 change_played_date_by_ids

Provides a URL for change_played_date by chaining to base_by_ids; forwards to the real routine.

=cut

sub change_played_date_by_ids  :Chained("base_by_ids") :PathPart("change-date") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("change_played_date");
}

=head2 change_played_date_by_url_keys

Provides a URL for change_played_date by chaining to base_by_ids; forwards to the real routine.

=cut

sub change_played_date_by_url_keys  :Chained("base_by_url_keys") :PathPart("change-date") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("change_played_date");
}

=head2 change_played_date

Change the match played date.

=cut

sub change_played_date :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $played_date = $c->req->params->{date};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # $c->log->debug(sprintf("played date: %s", $c->req->params->{date}));
  # $c->log->debug(sprintf("parsed date: %s", $c->i18n_datetime_format_date->parse_datetime($c->req->params->{date})->ymd("/")));
  my $cldr = $c->i18n_datetime_format_date;
  $cldr->time_zone("UTC");
  my $response = $match->update_played_date($cldr->parse_datetime($c->req->params->{date}));
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  
  # Stash the messages
  $c->stash({json_data => {messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success}}});
  
  if ( $response->{completed} ) {
    # Completed, log that we updated the match
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "date-change", {home_team => $match->team_season_home_team_season->team->id, away_team => $match->team_season_away_team_season->team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name)]);
  } else {
    # Wasn't completed, return with an error code
    $c->res->status(400);
  }
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
  return;
}

=head2 change_venue_by_ids

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_venue_by_ids :Chained("base_by_ids") :PathPart("change-venue") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("change_venue");
}

=head2 change_venue_by_url_keys

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_venue_by_url_keys :Chained("base_by_url_keys") :PathPart("change-venue") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("change_venue");
}

=head2 change_venue

Change the match venue.

=cut

sub change_venue :Private {
  my ( $self, $c )  = @_;
  my $match = $c->stash->{match};
  my $match_type = $c->stash->{match_type};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  my $response = $match->update_venue($c->req->params->{venue});
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  
  # Stash the messages
  $c->stash({json_data => {messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success}}});
  
  if ( $response->{completed} ) {
    # Completed, log that we updated the match
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "venue-change", {home_team => $match->team_season_home_team_season->team->id, away_team => $match->team_season_away_team_season->team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name)]);
  } else {
    # Wasn't completed, return with an error code
    $c->res->status(400);
  }
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
  return;
}

=head2 get_player_lists_by_ids

Provides the URL for get_playerlists by chaining to base_by_ids.  Forwards to the real routine.

=cut

sub get_player_lists_by_ids :Chained("base_by_ids") :PathPart("player-lists") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("get_player_lists");
}

=head2 get_player_lists_by_url_keys

Provides the URL for get_playerlists by chaining to base_by_ids.  Forwards to the real routine.

=cut

sub get_player_lists_by_url_keys :Chained("base_by_url_keys") :PathPart("player-lists") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("get_player_lists");
}

=head2 get_player_lists

Get the list of players for home and away teams, including any players playing as loan players in this particular match.

=cut

sub get_player_lists :Private {
  my ( $self, $c ) = @_;
  my $content_type = $c->req->params->{"content-type"} || "html";
  my $match = $c->stash->{match};
  my @home_player_list = $c->model("DB::PersonSeason")->get_people_in_team_in_name_order($match->season, $match->team_season_home_team_season->team);
  my @away_player_list = $c->model("DB::PersonSeason")->get_people_in_team_in_name_order($match->season, $match->team_season_away_team_season->team);
  my $home_doubles_list = [];
  my $away_doubles_list = [];
  
  # Push the ID and name on to the value / text attributes for SelectBoxIt.
  foreach my $player ( @home_player_list ) {
    push(@{$home_doubles_list}, {value => $player->person->id, text => $player->person->display_name});
  }
  
  foreach my $player ( @away_player_list ) {
    push(@{$away_doubles_list}, {value => $player->person->id, text => $player->person->display_name});
  }
  
  # Then loop through the match players, adding any that are loan players to the array
  my $players = $match->team_match_players;
  while ( my $player = $players->next ) {
    if ( defined($player->loan_team) and defined($player->player) and $player->location->location eq "Home" ) {
      # Home loan player
      push(@{$home_doubles_list}, {value => $player->player->id, text => $player->player->display_name,});
    } elsif ( defined($player->loan_team) and defined($player->player) and $player->location->location eq "Away" ) {
      # Away loan player
      push(@{$away_doubles_list}, {value => $player->player->id, text => $player->player->display_name});
    }
  }
  
  # Stash our values
  $c->stash({
    home_player_list => \@home_player_list,
    away_player_list => \@away_player_list,
    home_doubles_list => $home_doubles_list,
    away_doubles_list => $away_doubles_list,
    skip_view_online => 1, # Don't alter the view who's online activity
    
    # No encoding for this, as we're forwarding to a JSON view that will do it for us
    json_data => {
      json_home_doubles_list => $home_doubles_list,
      json_away_doubles_list => $away_doubles_list,
    }
  });
  
  # Detach to the JSON view if required
  $c->detach($c->view("JSON")) if $c->is_ajax;
  
  return;
}

=head2 update_playing_order_by_ids

Provides the URL for update_playing_order chaining to base_by_ids; forwards to the real routine.

=cut

sub update_playing_order_by_ids :Chained("base_by_ids") :PathPart("playing-order") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_playing_order");
}

=head2 update_playing_order_by_url_keys

Provides the URL for update_playing_order chaining to base_by_ids; forwards to the real routine.

=cut

sub update_playing_order_by_url_keys :Chained("base_by_url_keys") :PathPart("playing-order") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update_playing_order");
}

sub update_playing_order :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  my $response = $match->update_playing_order($c->req->params);
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my @match_scores = @{$response->{match_scores}};
  
  # Stash the messages
  $c->stash({
    json_data => {
      messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success},
      match_scores => \@match_scores,
    }
  });
  
  # Change the response code if we didn't complete
  $c->res->status(400) unless $response->{completed};
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
  return;
}

=head2 cancel_by_ids

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub cancel_by_ids :Chained("base_by_ids") :PathPart("cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("cancel");
}

=head2 cancel_by_url_keys

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub cancel_by_url_keys :Chained("base_by_url_keys") :PathPart("cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("cancel");
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
  $c->res->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->res->header("Pragma" => "no-cache");
  $c->res->header("Expires" => 0);
  
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
  $c->add_status_messages({warning => $c->maketext("matches.cancel.warning.has-score")}) if $match->started;
  
  # Set up the page titles
  my $date = $c->stash->{date};
  
  # Stash the template values
  $c->stash({
    template => "html/matches/team/cancel.ttkt",
    form_action => $c->uri_for_action("/matches/team/do_cancel_by_ids", [$match->team_season_home_team_season->team->id, $match->team_season_away_team_season->team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/matches/team/cancel.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    #subtitle2 => encode_entities($match->division_season->name),
    #subtitle3 => sprintf("%s, %d %s %d", ucfirst($date->day_name), $date->day, $date->month_name, $date->year),
    view_online_display => sprintf("Cancelling match %s %s v %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.cancel"),
  });
}

=head2 do_cancel_by_ids

Provides the URL for do_cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub do_cancel_by_ids :Chained("base_by_ids") :PathPart("do-cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_cancel");
}

=head2 do_cancel_by_url_keys

Provides the URL for cancel chaining to base_by_ids; forwards to the real routine.

=cut

sub do_cancel_by_url_keys :Chained("base_by_url_keys") :PathPart("do-cancel") Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_cancel");
}

=head2 do_cancel

Process the cancellation form; cancels (or uncancels) the match.  If the match is cancelled, all previous scores / players / statistics calculated from those are removed.

=cut

sub do_cancel :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $home_points_awarded = $c->req->params->{home_points_awarded};
  my $away_points_awarded = $c->req->params->{away_points_awarded};
  
  # Check that we are authorised to cancel matches
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.cancel-matches"), 1]);
  
  my $cancel = $c->req->params->{cancel} || 0;
  
  # Now forward to the match cancellation routine, which does all the error checking
  my $response = $cancel
    ? $match->cancel({home_points_awarded => $home_points_awarded, away_points_awarded => $away_points_awarded})
    : $match->uncancel;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  my $action = $cancel ? "cancel" : "uncancel";
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $redirect_uri = $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys, {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", $action, {home_team => $match->team_season_home_team_season->team->id, away_team => $match->team_season_away_team_season->team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name)]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $response->{can_complete} ) {
      $redirect_uri = $c->uri_for_action("/matches/team/cancel_by_url_keys", $match->url_keys, {mid => $mid});
      
      $c->flash({
        show_flashed => 1,
        cancel => $cancel,
        home_points_awarded => $home_points_awarded,
        away_points_awarded => $away_points_awarded,
      });
    } else {
      $redirect_uri = $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys, {mid => $mid});
    }
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 report_by_ids

Report on a match using the information given in base_by_ids

=cut

sub report_by_ids :Chained("base_by_ids") :PathPart("report") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("report");
}

=head2 report_by_url_keys

Report on a match using the information given in base_by_ids

=cut

sub report_by_url_keys :Chained("base_by_url_keys") :PathPart("report") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("report");
}

=head2 report

Show the form fields for updating a match.

=cut

sub report :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  
  $c->forward("check_report_create_edit_authorisation");
  
  # Stash the template values
  $c->stash({
    template => "html/matches/team/report.ttkt",
    scripts => [qw( ckeditor-iframely-standard )],
    ckeditor_selectors => [qw( report )],
    external_scripts => [
      $c->uri_for("/static/script/plugins/ckeditor5/ckeditor.js"),
    ],
    form_action => $c->uri_for_action("/matches/team/publish_report_by_url_keys", $match->url_keys),
    subtitle2 => $c->maketext("matches.report.heading"),
    latest_report => $match->get_latest_report,
    view_online_display => "Writing a match report",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.report"),
  });
}

=head2 publish_report_by_ids

Report on a match using the information given in base_by_ids

=cut

sub publish_report_by_ids :Chained("base_by_ids") :PathPart("publish-report") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("publish_report");
}

=head2 publish_report_by_url_keys

Report on a match using the information given in base_by_ids

=cut

sub publish_report_by_url_keys :Chained("base_by_url_keys") :PathPart("publish-report") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("publish_report");
}

=head2 publish_report

Process the form for publishing a match report.

=cut

sub publish_report :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my ( $home_team, $away_team ) = ( $match->team_season_home_team_season, $match->team_season_away_team_season );
  my $report  = $c->req->body_parameters->{report};
  
  # Check we're authorised
  $c->forward("check_report_create_edit_authorisation");
  
  my $response = $match->add_report({
    user => $c->user,
    report => $report,
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
    my $action = $response->{action};
    $redirect_uri = $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys, {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "report-$action", {home_team => $home_team->team->id, away_team => $away_team->team->id, scheduled_date => $match->scheduled_date->ymd}, sprintf("%s %s %s %s", $home_team->club_season->short_name, $home_team->name, $away_team->club_season->short_name, $away_team->name)]);
  } else {
    $redirect_uri = $c->uri_for_action("/matches/team/report_by_url_keys", $match->url_keys, {mid => $mid});
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{report} = $report;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 check_report_create_edit_authorisation

Checks we're authorised to create or edit a report (whichever is necessary) for the stashed match.

=cut

sub check_report_create_edit_authorisation :Private {
  my ( $self, $c ) = @_;
  my $match = $c->stash->{match};
  my $season = $match->season;
  my $home_team = $match->team_season_home_team_season;
  my $away_team = $match->team_season_away_team_season;
  my $home_club = $match->team_season_home_team_season->club_season;
  my $away_club = $match->team_season_away_team_season->club_season;
  
  if ( $season->complete ) {
    # Season is not current, so we can't submit or edit a match report
    $c->response->redirect( $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg({error => $c->maketext("matches.report.error.season-not-current")})}));
    $c->detach;
    return;
  }
  
  # Before we can auth this, we need to know if a reports exists - if it does, we'll be editing; if not, we'll be creating
  my $reports = $match->get_reports;
  my $original_report_number = $reports->count > 0 ? $reports->count - 1 : 0;
  
  # The live report will always be the first one - and the original will always be the last one (report count - 1 in a zero-based list).
  my ( $live_report ) = $reports->slice(0, 0);
  my ( $original_report ) = $reports->slice($original_report_number, $original_report_number);
  
  # If we have a live report, we're editing, otherwise we're creating.
  my $action  = defined($live_report) ? "edit" : "create";
  
  if ( $action eq "create" ) {
    # Creating - check we can create match reports
    # Redirect on fail if:
    #  * We're not logged in
    #  * We are logged in and not associated with either the home club, home team, away club or away team in any way (by playing for or captaining the team or being secretary for the club)
    my $redirect_on_fail = (
      $c->user_exists and (
        $c->user->plays_for({team => $home_team, season => $season}) or
        $c->user->captain_for({team => $home_team}) or
        $c->user->plays_for({team => $away_team, season => $season}) or
        $c->user->captain_for({team => $away_team, season => $season}) or
        $c->user->secretary_for({club => $home_club}) or
        $c->user->secretary_for({club => $away_club})
      ) ) ? 0 : 1;
    
    # Now do the authorisation
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["matchreport_create", $c->maketext("user.auth.create-match-reports"), $redirect_on_fail]);
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["matchreport_create_associated", $c->maketext("user.auth.create-match-reports"), 1]) unless $c->stash->{authorisation}{matchreport_create};
  } else {
    # Editing - check we can edit the report for this match.
    my $redirect_on_fail = ($c->user_exists and $c->user->id == $original_report->author->id) ? 0 : 1;
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["matchreport_edit_all", $c->maketext("user.auth.edit-match-reports"), $redirect_on_fail]);
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["matchreport_edit_own", $c->maketext("user.auth.edit-match-reports"), 1]) if !$c->stash->{authorisation}{matchreport_edit_all} and $c->user_exists and $c->user->id == $original_report->author->id;
  }
  
  # Stash some values for the routines we're returning to
  $c->stash({
    reports => $reports,
    live_report => $live_report,
    original_report => $original_report,
  });
}

=head2 change_handicaps_by_ids

Provides the change_handicap URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_handicaps_by_ids :Chained("base_by_ids") :PathPart("handicaps") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("change_handicaps");
}

=head2 change_handicap_by_url_keys

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub change_handicaps_by_url_keys :Chained("base_by_url_keys") :PathPart("handicaps") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("change_handicaps");
}

=head2 change_handicaps

Change the match handicaps.

=cut

sub change_handicaps :Private {
  my ( $self, $c )  = @_;
  my $match = $c->stash->{match};
  my $match_type = $c->stash->{match_type};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # First check if this is a handicapped match
  if ( !$match->handicapped ) {
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg({error => $c->maketext("matches.handicaps.error.not-a-handicapped-match")})}));
    $c->detach;
    return;
  }
  
  if ( $match->started ) {
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg({error => $c->maketext("matches.handicaps.error.match-started")})}));
    $c->detach;
    return;
  }
  
  # Stash the template values
  $c->stash({
    template => "html/matches/team/change-handicaps.ttkt",
    form_action => $c->uri_for_action("/matches/team/set_handicaps_by_ids", [$match->team_season_home_team_season->team->id, $match->team_season_away_team_season->team->id, $match->scheduled_date->year, $match->scheduled_date->month, $match->scheduled_date->day]),
    external_scripts => [
      $c->uri_for("/static/script/matches/team/change-handicaps.js"),
    ],
    view_online_display => sprintf("Changing handicaps for match %s %s v %s %s", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/matches/team/update_by_url_keys", $match->url_keys),
    label => $c->maketext("admin.update"),
  });
}

=head2 set_handicaps_by_ids

Provides the set_handicap URL chaining to base_by_ids, then forwards to the real routine

=cut

sub set_handicaps_by_ids :Chained("base_by_ids") :PathPart("set-handicaps") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("set_handicaps");
}

=head2 set_handicap_by_url_keys

Provides the change_venue URL chaining to base_by_ids, then forwards to the real routine

=cut

sub set_handicaps_by_url_keys :Chained("base_by_url_keys") :PathPart("set-handicaps") Args(0) {
  my ( $self, $c )  = @_;
  $c->detach("set_handicaps");
}

=head2 set_handicaps

Change the match handicaps.

=cut

sub set_handicaps :Private {
  my ( $self, $c )  = @_;
  my $match = $c->stash->{match};
  my $match_type = $c->stash->{match_type};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # First check if this is a handicapped match
  if ( !$match->handicapped ) {
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg({error => $c->maketext("matches.handicaps.error.not-a-handicapped-match")})}));
    $c->detach;
    return;
  }
  
  if ( $match->started ) {
    $c->response->redirect($c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys,
                                {mid => $c->set_status_msg({error => $c->maketext("matches.handicaps.error.match-started")})}));
    $c->detach;
    return;
  }
  
  my @field_names = qw( home_team_handicap away_team_handicap );
  my $response = $match->update_handicaps({
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form
  });
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $redirect_uri = $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys, {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "handicap-change", {home_team => $match->team_season_home_team_season->team->id, away_team => $match->team_season_away_team_season->team->id, scheduled_date => $match->scheduled_date->ymd}, $c->maketext("matches.name", $match->team_season_home_team_season->full_name, $match->team_season_away_team_season->full_name)]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    $redirect_uri = $c->uri_for_action("/matches/team/change_handicaps_by_url_keys", $match->url_keys, {mid => $mid});
    
    # Flash the entered values we've got so we can set them into the form
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
  
  # Check that we are authorised to view matches
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_view", $c->maketext("user.auth.view-matches"), 1]);
  
  $c->stash({
    db_resultset => "TeamMatchView",
    query_params => {
      q => $c->req->params->{q},
      include_complete => $c->req->params->{complete},
      include_incomplete => $c->req->params->{incomplete},
      include_cancelled => $c->req->params->{cancelled},
    },
    view_action => "/matches/team/view_by_url_keys",
    search_action => "/matches/team/search",
    search_form_include => "team-match",
    placeholder => $c->maketext("search.form.placeholder", $c->maketext("object.plural.matches")),
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
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
