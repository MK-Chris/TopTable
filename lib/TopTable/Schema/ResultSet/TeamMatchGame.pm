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

=head2 noindex_set

Return a subset of the resultset that have players with noindex set.

=cut

sub noindex_set {
  my ( $self, $on ) = @_;
  
  # Sanity check - all true values are 1, all false are 0
  $on = $on ? 1 : 0;
  
  my $where = $on
    ? [
        -or => [
          -and => [doubles_game => 1, [-or => {"person.noindex" => 1, "person_2.noindex" => 1, "person_3.noindex" => 1, "person_4.noindex" => 1,}]]
        ], [
          -and => [doubles_game => 0, [-or => {"home_player.noindex" => 1, "away_player.noindex" => 1}]]
        ]
      ]
    : [
        -or => [
          -and => [doubles_game => 1, [-and => {"person.noindex" => 0, "person_2.noindex" => 0, "person_3.noindex" => 0, "person_4.noindex" => 0,}]]
        ], [
          -and => [doubles_game => 0, [-and => {"home_player.noindex" => 0, "away_player.noindex" => 0}]]
        ]
      ];
  
  return $self->search($where, {
    join => {
      # Join the singles / doubles tables, as we don't know which type of game this is - so we can do a general test for noindex
      # regardless of doubles or singles status of the game
      home_doubles_pair => [{person_season_person1_season_team => "person", person_season_person2_season_team => "person"}],
      away_doubles_pair => [{person_season_person1_season_team => "person", person_season_person2_season_team => "person"}],
      home_player => "person_seasons",
      away_player => "person_seasons",
    },
  });
}

1;