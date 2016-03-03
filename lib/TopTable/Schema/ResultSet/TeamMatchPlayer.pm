package TopTable::Schema::ResultSet::TeamMatchPlayer;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 player_in_match_by_ids

Prefetch with the player object by IDs.

=cut

sub player_in_match_by_ids {
  my ( $self, $home_team_id, $away_team_id, $scheduled_date, $player_number ) = @_;
  
  return $self->find({
    home_team       => $home_team_id,
    away_team       => $away_team_id,
    scheduled_date  => $scheduled_date->ymd,
    player_number   => $player_number,
  }, {
    prefetch  => [
      "player", "location", {
      team_match => "season"
    }],
  });
}

=head2 player_in_match_by_url_keys

Prefetch with the player object by URL keys.

=cut

sub player_in_match_by_url_keys {
  my ( $self, $home_club_url_key, $home_team_url_key, $away_club_url_key, $away_team_url_key, $scheduled_date, $player_number ) = @_;
  
  return $self->find({
    "club.url_key"        => $home_club_url_key,
    "home_team.url_key"   => $home_team_url_key,
    "club_2.url_key"      => $away_club_url_key,
    "away_team.url_key"   => $away_team_url_key,
    scheduled_date        => $scheduled_date->ymd,
    player_number         => $player_number,
  }, {
    prefetch  => [
      "player", "location", {
      team_match => "season"
    }],
    join      => {
      home_team => "club"
    }, {
      away_team => "club"
    },
  });
}

1;