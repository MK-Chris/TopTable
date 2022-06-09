package TopTable::Controller::Matches::Team::Player;
use Moose;
use namespace::autoclean;
use JSON;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Matches::Team::Player - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for team match players; provides URLs for what will usually be AJAX actions, since users will tend to navigate to entire match pages instead.

=head1 METHODS

=cut




=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach(qw( TopTable::Controller::Root default ));
  return;
}

=head2 base_by_ids

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID, date and player number and checking them, stashing the returned game.

=cut

sub base_by_ids :Chained("/") :PathPart("matches/team/player") :CaptureArgs(6) {
  my ( $self, $c, $match_home_team_id, $match_away_team_id, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $player_number ) = @_;
  my ( $db_class );
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date = $c->datetime(
      year => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw( TopTable::Controller::Root default ));
  };
  
  my $player = $c->model("DB::TeamMatchPlayer")->player_in_match_by_ids($match_home_team_id, $match_away_team_id, $scheduled_date, $player_number);
  
  if ( defined($player) ) {
    $c->stash({player => $player});
  } else {
    $c->detach(qw( TopTable::Controller::Root default ));
  }
}

=head2 base_by_url_keys

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_url_keys :Chained("/") PathPart("matches/team/player") CaptureArgs(8) {
  my ( $self, $c, $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $player_number ) = @_;
  my ( $db_class );
  
  # Do the date checking; eval it to trap DateTime errors and pass them into $error
  my $scheduled_date;
  try {
    $scheduled_date = $c->datetime(
      year => $match_scheduled_date_year,
      month => $match_scheduled_date_month,
      day => $match_scheduled_date_day,
    );
  } catch {
    $c->detach(qw( TopTable::Controller::Root default ));
  };
  
  my $player = $c->model("DB::TeamMatchPlayer")->player_in_match_by_url_keys($match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $scheduled_date, $player_number);
  
  if ( defined( $player ) ) {
    $c->stash({player => $player});
  } else {
    $c->detach(qw( TopTable::Controller::Root default ));
    return;
  }
}

=head2 update_by_ids

Provides the update_player URL attaching to base_by_ids, then forwards to the real routine.

=cut

sub update_by_ids :Chained("base_by_ids") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update");
}

=head2 update_by_url_keys

Provides the update_player URL attaching to base_by_url_keys, then forwards to the real routine.

=cut

sub update_by_url_keys :Chained("base_by_url_keys") :PathPart("update") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("update");
}

=head2 update

Add a person ID to the team_match_players table.  Called by an AJAX request, takes four arguments in the query string; the player number and person ID, whether the player is a loan or not and the location (home or away).  The match should already be stashed.  If the person ID is omitted, any person in that player position will be removed and the spot will be vacant.  Returns a list of game numbers in this match featuring the player number specified that have both players added in the DB.

=cut

sub update :Private {
  my ( $self, $c ) = @_;
  my $player = $c->stash->{player};
  my $match_type = $c->stash->{match_type};
  my $loan_player = $c->req->params->{loan_player} || 0;
  my $location = $c->req->params->{location};
  my $person = $c->req->params->{person} || undef;
  my $error;
  
  # Check we're authorised to update match scorecards
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["match_update", "update matches", 1]);
  
  # Try and find this person's season
  # We need the action, as if the person is 'undef', the DB class won't know whether it's because the person is invalid or they're being removed,
  # so in this instance, the action will tell it whether to raise an error or not.
  my $action;
  if ( defined($person) and $person ne "PLAYER-MISSING" and $person ) {
    # Add a player
    $action = "add";
  } elsif ( defined($person) and $person eq "PLAYER-MISSING" ) {
    # Remove any players and set them as 'missing'
    $action = "set-missing";
    $loan_player = 0;
  } else {
    # Remove players (but don't set as 'missing')
    $action = "remove";
  }
  
  # Pass through to the validation routine
  my $response = $player->update_person($action, {
    loan_player => $loan_player,
    location => $location,
    person => $person,
    logger => sub{ my $level = shift; $c->log->$level( @_ ) },
  });
  
  # Set the status messages we need to show back to the user
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my @match_scores = @{$response->{match_scores}};
  
  # Stash the messages and the games for this player
  $c->stash({
    json_data => {
      messages => {error => \@errors, warning => \@warnings, info => \@info, success => \@success},
      player_games => $response->{player_games},
      match_scores => \@match_scores,
    }
  });
  
  # Change the response code if we didn't complete
  $c->res->status(400) unless $response->{completed};
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
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
