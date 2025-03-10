package TopTable::Schema::ResultSet::TeamSeason;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;

=head2 get_teams_in_division_in_league_table_order

Retrieve people in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_teams_in_division_in_league_table_order {
  my $class = shift;
  my ( $params ) = @_;
  my $season = delete $params->{season};
  my $division = delete $params->{division};
  
  return $class->search({
    "me.season" => $season->id,
    division    => $division->id,
  }, {
    prefetch  => ["team", {
      club_season => "club",
    }],
    order_by  => [{
      -desc => [ qw( games_won matches_won matches_drawn matches_played ) ]
    }, {
      -asc  => [ qw( games_lost matches_lost ) ]
    }, {
      -desc => [ qw( games_won ) ]
    }, {
      -asc  => [ qw( club.short_name team.name ) ]
    }],
  });
}

=head2 get_doubles_teams_in_division_in_averages_order

Retrieve doubles teams in a given season / division in averages order.

=cut

sub get_doubles_teams_in_division_in_averages_order {
  my $class = shift;
  my ( $params ) = @_;
  my $division = $params->{division};
  my $season = $params->{season};
  my $criteria_field = $params->{criteria_field} || undef;
  my $operator = $params->{operator} || undef;
  my $criteria = $params->{criteria} || undef;
  
  my $where = {
    "me.season"   => $season->id,
    "me.division" => $division->id,
  };
  
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and ($operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">") and $criteria =~ /^\d+$/ ) {
    $where->{sprintf("me.doubles_games_%s", $criteria_field)} = {
      $operator => $criteria,
    };
  }
  
  return $class->search($where, {
    prefetch  => ["team", {
      club_season => "club",
    }],
    order_by  => [{
      -desc => [qw( doubles_average_game_wins games_played doubles_games_won )],
    }, {
      -asc  => [qw( club.short_name team.name )],
    }],
  });
}

=head2 get_tables_last_updated_timestamp

For a given season and division, return the last updated date / time.

=cut

sub get_tables_last_updated_timestamp {
  my $class = shift;
  my ( $params ) = @_;
  my $division = $params->{division};
  my $season = $params->{season};
  
  my $last_updated_team = $class->find({
    season => $season->id,
    division => $division->id,
  }, {
    rows => 1,
    order_by => {-desc => "last_updated"}
  });
  
  return $last_updated_team->last_updated if defined($last_updated_team);
}

=head2 grid_positions_set

Loop through a resultset and if any positions are filled with a number, return 1, else return 0.

=cut

sub grid_positions_set {
  my $class = shift;
  my $count = $class->search({
    grid_position => {
      "!=" => undef,
    }
  })->count;
  
  if ( $count ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 grid_positions_empty

Loop through a resultset and if any positions are NOT filled with a number, return 1, else return 0.

=cut

sub grid_positions_empty {
  my $class = shift;
  my $count = $class->search({
    grid_position => undef,
  })->count;
  
  if ( $count ) {
    return 1;
  } else {
    return 0;
  }
}

1;