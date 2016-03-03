package TopTable::Controller::Matches::Team::Game;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper;
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
  $c->detach( qw/TopTable::Controller::Root default/ );
  return;
}

=head2 base_by_ids

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID, date and game number and checking them, stashing the returned game.

=cut

sub base_by_ids :Chained("/") :PathPart("matches/team/game") :CaptureArgs(6) {
  my ( $self, $c, $match_home_team_id, $match_away_team_id, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $game_number ) = @_;
  
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
  
  my $game = $c->model("DB::TeamMatchGame")->game_in_match_by_scheduled_game_number_by_ids( $match_home_team_id, $match_away_team_id, $scheduled_date, $game_number );
  
  if ( defined( $game ) ) {
    $c->stash({game => $game});
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_by_url_keys

Chain base for getting the type of team match (league or tournament), the home team ID, away team ID and date and checking them, stashing the returned match.

=cut

sub base_by_url_keys :Chained("/") PathPart("matches/team/game") CaptureArgs(8) {
  my ( $self, $c, $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $match_scheduled_date_year, $match_scheduled_date_month, $match_scheduled_date_day, $game_number ) = @_;
  
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
  
  my $game = $c->model("DB::TeamMatchGame")->game_in_match_by_scheduled_game_number_by_url_keys( $match_home_club_url_key, $match_home_team_url_key, $match_away_club_url_key, $match_away_team_url_key, $scheduled_date, $game_number );
  
  if ( defined( $game ) ) {
    $c->stash({game => $game});
  } else {
    $c->detach( "TopTable::Controller::Root", "default" );
    return;
  }
}

=head2 update_umpire_by_ids

Provides the URL for update_umpire chaining to base_by_ids; forward to the real routine.

=cut

sub update_umpire_by_ids :Chained("base_by_ids") :PathPart("umpire") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "update_umpire" );
}

=head2 update_umpire_by_url_keys

Provides the URL for update_umpire chaining to base_by_ids; forward to the real routine.

=cut

sub update_umpire_by_url_keys :Chained("base_by_url_keys") :PathPart("umpire") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "update_umpire" );
}

=head2 update_umpire

Update the umpire; either add or remove the umpire, depending on whether anyone is specified or not.

=cut

sub update_umpire :Private {
  my ( $self, $c ) = @_;
  my $game          = $c->stash->{game};
  my $content_type  = $c->request->parameters->{"content-type"} || "html";
  my $person_id = $c->request->parameters->{person} || undef;
  my ( $person, $action );
  
  if ( defined( $person_id ) ) {
    # We have a person, look them up and ensure the action is 'add'
    $action = "add";
    $person = $c->model("DB::Person")->find( $person_id );
  } else {
    # Nobody specified; remove.
    $action = "remove";
  }
  
  my $details = $game->update_umpire({
    action => $action,
    person => $person,
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    if ( $c->is_ajax ) {
      # Stash the original player so any select lists or inputs can be reset to their old values
      $c->stash({json_umpire => $details->{original_umpire}});
      $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
    } else {
      $c->log->error( $error );
    }
  } else {
    # Set the success message to pass back based on whether we're adding or removing an umpire
    my $message;
    if ( $action eq "add" ) {
      # Adding an umpire
      $message = $c->maketext("matches.umpire.add.success", $person->display_name, $game->scheduled_game_number);
    } else {
      # Removing an umpire
      $message = $c->maketext("matches.umpire.remove.success", $game->scheduled_game_number);
    }
    
    $c->stash({json_message => $message});
  }
  
  # Detach to the JSON view
  $c->detach( $c->view("JSON") ) if $c->is_ajax;
  return;
}

=head2 doubles_pair_by_ids

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This method chains to base_by_ids in order to do the URI matching, it detaches to set_doubles, which does the real work.

=cut

sub doubles_pair_by_ids :Chained("base_by_ids") :PathPart("set-doubles") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "doubles_pair" );
}

=head2 doubles_pair_by_url_keys

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This method chains to base_by_url_keys in order to do the URI matching, it detaches to set_doubles, which does the real work.

=cut

sub doubles_pair_by_url_keys :Chained("base_by_url_keys") :PathPart("set-doubles") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "doubles_pair" );
}

=head2 doubles_pair

Sets or removes a doubles pairing from a given game (obviously checking that the game specified is a doubles game first).

This private method is detached to from doubles_pair_by_ids or doubles_pair_by_url_keys.

=cut

sub doubles_pair :Private {
  my ( $self, $c ) = @_;
  my $game        = $c->stash->{game};
  my $location    = $c->request->parameters->{location};
  my @player_ids  = split(",", $c->request->parameters->{player_ids});
  
  # Get the players
  my @players = map{ $c->model("DB::Person")->find( $_ ); } @player_ids;
  
  my $actioned = $game->update_doubles_pair({
    location  => $location,
    players   => \@players,
  });
  
  if ( scalar( @{ $actioned->{error} } ) ) {
    my $error = $c->build_message( $actioned->{error} );
    
    if ( $c->is_ajax ) {
      # Stash the original player so any select lists or inputs can be reset to their old values
      $c->stash({json_player => $actioned->{original_player}});
      $c->detach( "TopTable::Controller::Root", "json_error", [400, $error] );
    } else {
      $c->log->error( $error );
    }
  } else {
    # Set the success message to pass back based on whether we're adding or removing the pair
    my $message;
    if ( scalar( @players )  ) {
      # Adding a doubles pair
      $message = $c->maketext("matches.game.update-doubles.add.success", $players[0]->display_name, $players[1]->display_name, $location, $game->scheduled_game_number);
    } else {
      # Removing a doubles pair
      $message = $c->maketext("matches.game.update-doubles.remove.success", $location);
    }
    
    $c->stash({
      json_message  => $message, # Stash the message to display, so we can provide it in the correct language to the client script
    });
  }
  
  # Detach to the JSON view
  $c->detach( $c->view("JSON") ) if $c->is_ajax;
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
