package TopTable::Controller::Matches::Team::Game;
use Moose;
use namespace::autoclean;
use JSON;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Matches::Team::Game - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for team match games; provides URLs for what will usually be AJAX actions, since users will tend to navigate to entire match pages instead.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach(qw(TopTable::Controller::Root default));
  return;
}

=head2 base_by_ids

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID, date and game number and checking them, stashing the returned game.

=cut

sub base_by_ids :Chained("/") :PathPart("matches/team/game") :CaptureArgs(6) {
  my ( $self, $c, $match_home_team_id, $match_away_team_id, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $game_number ) = @_;
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date = $c->datetime(
      year => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  my $game = $c->model("DB::TeamMatchGame")->game_in_match_by_scheduled_game_number_by_ids($match_home_team_id, $match_away_team_id, $scheduled_date, $game_number);
  
  if ( defined($game) ) {
    $c->stash({game => $game});
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_by_url_keys

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_url_keys :Chained("/") PathPart("matches/team/game") CaptureArgs(8) {
  my ( $self, $c, $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $game_number ) = @_;
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date = $c->datetime(
      year => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw(TopTable::Controller::Root default));
  };
  
  my $game = $c->model("DB::TeamMatchGame")->game_in_match_by_scheduled_game_number_by_url_keys($match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $scheduled_date, $game_number);
  
  if ( defined($game) ) {
    $c->stash({game => $game});
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 doubles_pair_by_ids

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This method chains to base_by_ids in order to do the URI matching, it detaches to doubles_pair, which does the real work.

=cut

sub doubles_pair_by_ids :Chained("base_by_ids") :PathPart("set-doubles") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("doubles_pair");
}

=head2 doubles_pair_by_url_keys

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This method chains to base_by_url_keys in order to do the URI matching, it detaches to doubles_pair, which does the real work.

=cut

sub doubles_pair_by_url_keys :Chained("base_by_url_keys") :PathPart("set-doubles") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("doubles_pair");
}

=head2 doubles_pair

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This private method is detached to from doubles_pair_by_ids or doubles_pair_by_url_keys.

=cut

sub doubles_pair :Private {
  my ( $self, $c ) = @_;
  my $game = $c->stash->{game};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # Get the players
  my $response = $game->update_doubles_pair({
    location => $c->req->params->{location},
    players => [split(",", $c->req->params->{player_ids})],
  });
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  
  if ( $c->is_ajax ) {
    # Stash the messages
    $c->stash({json_data => {messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success}}});
    
    # Change the response code if we didn't complete
    $c->res->status(400) unless $response->{completed};
    
    # Detach to the JSON view
    $c->detach($c->view("JSON"));
    return;
  }
}

=head2 reset_score_by_ids

Reset a game score for the game stashed in base_by_ids.

=cut

sub reset_score_by_ids :Chained("base_by_ids") :PathPart("reset-game-score") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("reset_score");
}

=head2 reset_score_by_url_keys

Reset a game score for the game stashed in base_by_url_keys.

=cut

sub reset_score_by_url_keys :Chained("base_by_url_keys") :PathPart("reset-game-score") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("reset_score");
}

=head2 reset_score

Show the form fields for updating a match.

=cut

sub reset_score :Private {
  my ( $self, $c ) = @_;
  my $game = $c->stash->{game};
  
  # Check that we are authorised to update scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", $c->maketext("user.auth.update-matches"), 1]);
  
  # Reset the score by calling update_score with a delete parameter set to true
  my $response = $game->update_score({
    delete => 1,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); }
  });
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my @match_scores = @{$response->{match_scores}};
  
  if ( $c->is_ajax ) {
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
