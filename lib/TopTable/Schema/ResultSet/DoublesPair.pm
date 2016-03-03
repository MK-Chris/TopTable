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

1;