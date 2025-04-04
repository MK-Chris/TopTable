package TopTable::Schema::ResultSet::TeamMatchPlayer;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 player_in_match_by_ids

Prefetch with the player object by IDs.

=cut

sub player_in_match_by_ids {
  my $class = shift;
  my ( $home_team_id, $away_team_id, $scheduled_date, $player_number ) = @_;
  
  return $class->find({
    home_team => $home_team_id,
    away_team => $away_team_id,
    scheduled_date => $scheduled_date->ymd,
    player_number => $player_number,
  }, {
    prefetch => [
      qw( player location ), {
      team_match => "season"
    }],
  });
}

=head2 player_in_match_by_url_keys

Prefetch with the player object by URL keys.

=cut

sub player_in_match_by_url_keys {
  my $class = shift;
  my ( $home_club_url_key, $home_team_url_key, $away_club_url_key, $away_team_url_key, $scheduled_date, $player_number ) = @_;
  
  return $class->find({
    "club.url_key" => $home_club_url_key,
    "home_team.url_key" => $home_team_url_key,
    "club_2.url_key" => $away_club_url_key,
    "away_team.url_key" => $away_team_url_key,
    scheduled_date => $scheduled_date->ymd,
    player_number => $player_number,
  }, {
    prefetch  => [
      "player", "location", {
      team_match => "season"
    }],
    join => {
      home_team => "club"
    }, {
      away_team => "club"
    },
  });
}

=head2 loan_players

Search loan players in a given season.

=cut

sub loan_players {
  my $class = shift;
  my ( $params ) = @_;
  my $season  = $params->{season};
  
  return $class->search({
    loan_team => {"<>" => undef},
    "team_match.season" => $season->id,
    "club_season.season" => $season->id,
    "team_seasons.season" => $season->id,
    "division_season.season" => $season->id,
    "team_season_home_team_season.season" => $season->id,
    "club_season_2.season" => $season->id,
    "team_season_away_team_season.season" => $season->id,
    "club_season_3.season" => $season->id,
    "division_season_2.season" => $season->id,
    "person_seasons.season" => $season->id,
  }, {
    prefetch => [qw( location ), {
      loan_team => {
        team_seasons => [qw( team ), {
          club_season => "club",
          division_season => "division",
        }],
      },
      team_match => [qw( season ), {
        team_season_home_team_season => [qw( team ), {club_season => "club"}],
      }, {
        team_season_away_team_season => [qw( team ), {club_season => "club"}],
      }, {
        division_season => "division",
      }],
    }, {
      player => "person_seasons",
    }],
  });
}

1;