package TopTable::Schema::ResultSet::DoublesPair;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

=head2 get_doubles_pairs_in_division_in_averages_order

Retrieve doubles pairs in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_doubles_pairs_in_division_in_averages_order {
  my ( $self, $parameters ) = @_;
  my $division        = $parameters->{division};
  my $season          = $parameters->{season};
  my $team            = $parameters->{team};
  my $criteria_field  = $parameters->{criteria_field} || undef;
  my $operator        = $parameters->{operator} || undef;
  my $criteria        = $parameters->{criteria} || undef;
  
  my $where = {
    "me.season" => $season->id,
    "division_season.division" => $division->id,
  };
  
  # Set up the team if there is one
  if ( defined( $team ) ) {
    $where->{"team_season.team"} = $team->id;
  }
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{ sprintf( "me.games_%s", $criteria_field ) } = {
      $operator => $criteria,
    };
  }
  
  return $self->search($where, {
    prefetch  => [
      "person_season_person1_season_team",
      "person_season_person2_season_team", {
        team_season => ["division_season", {
          club_season => "club",
      }],
    }],
    order_by  => [{
      -desc => [ qw( me.average_game_wins me.games_played me.games_won ) ],
    }, {
      -asc  => [ qw( person_season_person1_season_team.surname person_season_person1_season_team.first_name person_season_person2_season_team.surname person_season_person2_season_team.first_name ) ],
    }],
  });
}

=head2 get_tables_last_updated_timestamp

For a given season and division, return the last updated date / time.

=cut

sub get_tables_last_updated_timestamp {
  my ( $self, $params ) = @_;
  my $division = delete $params->{division};
  my $season = delete $params->{season};
  my $team = delete $params->{team} || undef;
  
  my $where = {season => $season->id};
  $where->{"me.team"} = $team->id if defined( $team );
  $where->{"team_season.division"} = $division->id if defined( $division );
  
  my $doubles_pair = $self->find($where, {
    rows => 1,
    join => {team_season => "division_season"},
    order_by => {-desc => "last_updated"}
  });
  
  return defined( $doubles_pair ) ? $doubles_pair->last_updated : undef;
}

=head2 find_pair

Finds a doubles pair given two people (in an arrayref), a team and a season.  People can be passed in either order.

=cut

sub find_pair {
  my ( $self, $parameters ) = @_;
  my ( $person1, $person2 ) = ( @{ $parameters->{people} } );
  my $season  = $parameters->{season};
  my $team    = $parameters->{team};
  
  return $self->search([{
    person1 => $person1->id,
    person2 => $person2->id,
    "me.season" => $season->id,
    "me.team" => $team->id,
  }, {
    person1 => $person2->id,
    person2 => $person1->id,
    "me.season" => $season->id,
    "me.team" => $team->id,
  }], {
    prefetch  => ["person_season_person1_season_team", "person_season_person2_season_team", {
      team_season => "club_season",
    }],
  });
}

=head2 pairs_involving_person

Finds doubles pairs involving the given person

=cut

sub pairs_involving_person {
  my ( $self, $parameters ) = @_;
  my $person  = $parameters->{person};
  my $season  = $parameters->{season};
  my $team    = $parameters->{team};
  
  my $where = [{
    person1 => $person->id,
  }, {
    person2 => $person->id,
  }];
  
  # If we have a season, pass that into the where queries
  if ( defined( $season ) ) {
    $where->[0]{"me.season"} = $season->id;
    $where->[1]{"me.season"} = $season->id;
  }
  
  # If we have a team, pass that into the where queries
  if ( defined( $team ) ) {
    $where->[0]{team} = $team->id;
    $where->[1]{team} = $team->id;
  }
  
  return $self->search($where, {
    prefetch  => ["person_season_person1_season_team", "person_season_person2_season_team", "season", {
      team_season  => ["team", {club_season => "club"}]
    }],
  });
}

1;