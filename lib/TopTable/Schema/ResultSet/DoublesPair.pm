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
    "me.season"             => $season->id,
    "team_seasons.division" => $division->id,
    "team_seasons.season"   => $season->id,
  };
  
  # Set up the team if there is one
  if ( defined( $team ) ) {
    $where->{"team_seasons.team"} = $team->id;
  }
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{ sprintf( "me.games_%s", $criteria_field ) } = {
      $operator => $criteria,
    };
  }
  
  return $self->search($where, {
    prefetch  => [
      "person1",
      "person2", {
        "team" => "club",
    }],
    join => {
      "team" => "team_seasons"
    },
    order_by  => [{
      -desc => [ qw( average_game_wins games_played games_won ) ],
    }, {
      -asc  => [ qw( person1.surname person1.first_name person2.surname person2.first_name ) ],
    }],
  });
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
    season  => $season->id,
    team    => $team->id,
  }, {
    person1 => $person2->id,
    person2 => $person1->id,
    season  => $season->id,
    team    => $team->id,
  }], {
    prefetch  => ["person1", "person2", "season", {
      team  => "club"
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
    $where->[0]{season} = $season->id;
    $where->[1]{season} = $season->id;
  }
  
  # If we have a team, pass that into the where queries
  if ( defined( $team ) ) {
    $where->[0]{team} = $team->id;
    $where->[1]{team} = $team->id;
  }
  
  return $self->search($where, {
    prefetch  => ["person1", "person2", "season", {
      team  => "club"
    }],
  });
}

1;