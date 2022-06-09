package TopTable::Schema::ResultSet::TeamMatchGame;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 games_in_match_with_people

Get the games in a match that have people set in the positions in the team_match_players table (i.e., where the 'person' has been filled out).  This helps us to only set people into games where there is already a person set into the other position, so that when choosing people into their playing positions, you don't set them into a match where there's no opposition player.  For this reason, the optional second parameter to this function is a player position, so you can return all the games featuring player 1 (for example) that have a player set in the opposition position.

=cut

sub games_in_match_with_people {
  my ( $self, $match, $player_number ) = @_;
  my ( $where );
  
  if ( $player_number ) {
    $where = {
      -or => [{
        home_player_number => $player_number,
      }, {
        away_player_number => $player_number,
      }],
      -and =>  [{
        home_team => $match->home_team->id,
        away_team => $match->away_team->id,
        scheduled_date => $match->scheduled_date->ymd,
        home_player => {"!=" => undef},
        away_player => {"!=" => undef},
      }],
    };
  } else {
    $where = {
      home_team => $match->home_team->id,
      away_team => $match->away_team->id,
      scheduled_date => $match->scheduled_date->ymd,
      home_player_number => {"!=" => undef},
      away_player_number => {"!=" => undef},
    };
  }
  
  return $self->search( $where, {
    order_by  => {-asc => qw( scheduled_game_number )},
  });
}

=head2 game_in_match_by_scheduled_game_number_by_ids

Get the specified scheduled game number in a match

=cut

sub game_in_match_by_scheduled_game_number_by_ids {
  my ( $self, $home_team_id, $away_team_id, $scheduled_date, $scheduled_game_number ) = @_;
  
  return $self->find({
    home_team => $home_team_id,
    away_team => $away_team_id,
    scheduled_date => $scheduled_date->ymd,
    scheduled_game_number => $scheduled_game_number,
  }, {
    prefetch => "team_match_legs",
    order_by => {-asc => qw( team_match_legs.leg_number )},
  });
}

=head2 game_in_match_by_scheduled_game_number_by_url_keys

Get the specified scheduled game number in a match

=cut

sub game_in_match_by_scheduled_game_number_by_url_keys {
  my ( $self, $home_club_url_key, $home_team_url_key, $away_club_url_key, $away_team_url_key, $scheduled_date, $scheduled_game_number ) = @_;
  
  return $self->find({
    "club.url_key" => $home_club_url_key,
    "home_team.url_key" => $home_team_url_key,
    "club_2.url_key" => $away_club_url_key,
    "away_team.url_key" => $away_team_url_key,
    scheduled_date => $scheduled_date->ymd,
    scheduled_game_number => $scheduled_game_number,
  }, {
    prefetch => "team_match_legs",
    join => {
      home_team => "club"
    }, {
      away_team => "club"
    },
    order_by => {-asc => qw( team_match_legs.leg_number )},
  });
}

1;