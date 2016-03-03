package TopTable::Schema::ResultSet::PersonSeason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper;

=head2 get_active_person_season_and_team

A find() wrapper that also prefetches the team.

=cut

sub get_active_person_season_and_team {
  my ( $self, $person, $season ) = @_;
  
  return $self->find({
    person                => $person->id,
    season                => $season->id,
    team_membership_type  => "active",
  }, {
    prefetch => {
      team => "club"
    },
  });
}

=head2 get_person_season_and_teams_and_divisions

A find() wrapper that also prefetches the teams and divisions; the 'active' membership is shown first.

=cut

sub get_person_season_and_teams_and_divisions {
  my ( $self, $person, $season ) = @_;
  
  return $self->search({
    person      => $person->id,
    "me.season" => $season->id,
  }, {
    prefetch => ["team_membership_type", {
      team => [
        "club", {
          "team_seasons" => "division"
        }
      ]
    }],
    order_by => {
      -asc => "team_membership_type.display_order",
    },
  });
}

=head2 get_all_seasons_a_person_played_in

Gets a list of seasons that a person played in; groups by season, as we don't need all team associations for one person in a given season.

=cut

sub get_all_seasons_a_person_played_in {
  my ( $self, $person ) = @_;
  
  return $self->search({
    person   => $person->id
  }, {
    prefetch => "season",
    group_by => [qw/ season /],
  });
}

=head2 get_people_in_division_in_singles_averages_order

Retrieve people in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_people_in_division_in_singles_averages_order {
  my ( $self, $parameters ) = @_;
  my $division        = $parameters->{division};
  my $season          = $parameters->{season};
  my $team            = $parameters->{team};
  my $player_type     = $parameters->{player_type} || undef;
  my $criteria_field  = $parameters->{criteria_field} || undef;
  my $operator        = $parameters->{operator} || undef;
  my $criteria        = $parameters->{criteria} || undef;
  my $criteria_type   = $parameters->{criteria_type} || undef;
  
  my $where = {
    "me.season"             => $season->id,
    "team_seasons.division" => $division->id,
  };
  
  # Set up the team if there is one
  if ( defined( $team ) ) {
    $where->{"team_seasons.team"} = $team->id;
  }
  
  # Set up the player type if there is one
  if ( defined( $player_type ) ) {
    $player_type = [ $player_type ] unless ref( $player_type ) eq "ARRAY";
    $where->{"me.team_membership_type"} = {-in => $player_type};
  }
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and defined( $criteria_type ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{ sprintf( "me.%s_%s", $criteria_type, $criteria_field ) } = {
      $operator => $criteria,
    };
  }
  
  return $self->search( $where, {
    prefetch  => [{
      person => {
        person_seasons => {
          team => "club",
        },
      },
    }],
    join => {
      "team" => "team_seasons"
    },
    order_by  => [{
      -desc =>  [ qw( me.average_game_wins me.games_played me.games_won me.matches_played) ]}, {
      -asc  => [ qw( person.surname person.first_name) ]}
    ],
  });
}

=head2 get_people_in_division_in_doubles_individual_averages_order

Retrieve people in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_people_in_division_in_doubles_individual_averages_order {
  my ( $self, $parameters ) = @_;
  my $division        = $parameters->{division};
  my $season          = $parameters->{season};
  my $team            = $parameters->{team};
  my $player_type     = $parameters->{player_type} || undef;
  my $criteria_field  = $parameters->{criteria_field} || undef;
  my $operator        = $parameters->{operator} || undef;
  my $criteria        = $parameters->{criteria} || undef;
  
  my $where = {
    "me.season"             => $season->id,
    "team_seasons.division" => $division->id,
  };
  
  # Set up the team if there is one
  if ( defined( $team ) ) {
    $where->{"team_seasons.team"} = $team->id;
  }
  
  # Set up the player type if there is one
  if ( defined( $player_type ) ) {
    $player_type = [ $player_type ] unless ref( $player_type ) eq "ARRAY";
    $where->{"me.team_membership_type"} = {-in => $player_type};
  }
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{ sprintf( "me.doubles_games_%s", $criteria_field ) } = {
      $operator => $criteria,
    };
  }
  
  return $self->search($where, {
    prefetch  => [
      "person", {
        "team" => "club",
      }
    ],
    join => {
      "team" => "team_seasons"
    },
    order_by => [{
      -desc => [ qw( doubles_average_game_wins doubles_games_played doubles_games_won ) ],
    }, {
      -asc  => [ qw( person.surname person.first_name ) ],
    }],
  });
}

=head2 get_people_in_team_in_name_order

Retrieve people in a given season / team in order by surname, then first name.

=cut

sub get_people_in_team_in_name_order {
  my ( $self, $season, $team ) = @_;
  
  return $self->search({
    "me.season"           => $season->id,
    team                  => $team->id,
    team_membership_type  => "active",
  }, {
    prefetch  => "person",
    order_by  =>  [{
      -asc  =>  [ qw/ person.surname person.first_name / ],
    }],
  });
}

1;