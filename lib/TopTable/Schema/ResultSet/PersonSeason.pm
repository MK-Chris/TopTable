package TopTable::Schema::ResultSet::PersonSeason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper::Concise;

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
      team_season => ["team", {
        club_season => "club",
      }],
    },
  });
}

=head2 get_person_season_and_teams_and_divisions

A find() wrapper that also prefetches the teams and divisions; the 'active' membership is shown first.

=cut

sub get_person_season_and_teams_and_divisions {
  my ( $self, $parameters ) = @_;
  my $person                    = $parameters->{person};
  my $season                    = $parameters->{season};
  my $separate_membership_types = $parameters->{separate_membership_types} || 0;
  
  if ( $separate_membership_types ) {
    my %teams = (
      # Get ACTIVE team
      active  => $self->find({
        person                    => $person->id,
        "me.season"               => $season->id,
        "team_seasons.season"     => $season->id,
        "me.team_membership_type" => "active",
      }, {
        prefetch => {
          team => {
            team_seasons => [ qw( division club ) ],
          },
        },
      }),
      
      # Get LOAN teams
      loan  => $self->search({
        person                    => $person->id,
        "me.season"               => $season->id,
        "team_seasons.season"     => $season->id,
        "me.team_membership_type" => "loan",
      }, {
        prefetch => {
          team => {
            team_seasons => [ qw( division club ) ],
          },
        },
        order_by => {
          -asc => [ qw( division.rank club.short_name team.name ) ],
        },
      }),
      
      inactive  => $self->search({
        person                    => $person->id,
        "me.season"               => $season->id,
        "team_seasons.season"     => $season->id,
        "me.team_membership_type" => "inactive",
      }, {
        prefetch => {
          team => {
            team_seasons => [ qw( division club ) ],
          },
        },
        order_by => {
          -asc => [ qw( division.rank club.short_name team.name ) ],
        },
      }),
    );
    
    return \%teams;
  } else {
    # We're not separating, just return as called.
    return $self->search({
      person                => $person->id,
      "me.season"           => $season->id,
      "team_season.season"  => $season->id,
    }, {
      prefetch => ["team_membership_type", {
        team_season => ["team", {division_season => "division", club_season => "club"}],
      }],
      order_by => {
        -asc => [ qw( team_membership_type.display_order division.rank club_season.short_name team_season.name ) ],
      },
    });
  }
}

=head2 get_team_membership_types_for_person_in_season

Get a list of all team membership types that a person is using in the season

=cut

sub get_team_membership_types_for_person_in_season {
  my ( $self, $parameters ) = @_;
  my $person  = $parameters->{person};
  my $season  = $parameters->{season};
  
  return $self->search({
      person      => $person->id,
      "me.season" => $season->id,
  }, {
    columns   => [ qw( team_membership_type.id ) ],
    distinct  => 1,
    join      => "team_membership_type",
    order_by  => {
      -asc    => [ qw( team_membership_type.display_order ) ]
    }
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
  my $log             = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $where = {
    "me.season"             => $season->id,
    "team_season.division"  => $division->id,
    "team_season.season"    => $season->id,
  };
  
  # Set up the team if there is one
  $where->{"team_season.team"} = $team->id if defined( $team );
  
  # Set up the player type if there is one
  if ( defined( $player_type ) ) {
    $player_type = [ $player_type ] unless ref( $player_type ) eq "ARRAY";
    $where->{"me.team_membership_type"} = {-in => $player_type};
  }
  
  if ( defined( $criteria_field ) and defined( $operator ) and defined( $criteria ) and defined( $criteria_type ) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    if ( $criteria_type eq "matches-pc" ) {
      # We need to work out a percentage of the available matches, which means we need to work out the percentage from the criteria, rather than use it directly
      $where->{ sprintf( "me.matches_played" ) } = {
        $operator => \sprintf( "(team_season.matches_played / 100) * %d", $criteria ),
      };
    } else {
      $where->{ sprintf( "me.%s_%s", $criteria_type, $criteria_field ) } = {
        $operator => $criteria,
      };
    }
  }
  
  return $self->search( $where, {
    prefetch  => ["person", {
      team_season => ["team", {club_season => "club"}],
    }],
    order_by  => [{
      -desc =>  [ qw( me.average_game_wins me.games_played me.games_won me.matches_played) ]}, {
      -asc  => [ qw( me.surname me.first_name) ]}
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
    "team_season.division"  => $division->id,
    "team_season.season"    => $season->id,
  };
  
  # Set up the team if there is one
  $where->{"team_season.team"} = $team->id if defined( $team );
  
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
    prefetch  => ["person", {
      team_season => ["team", {club_season => "club"}],
    }],
    order_by => [{
      -desc => [ qw( me.doubles_average_game_wins me.doubles_games_played me.doubles_games_won ) ],
    }, {
      -asc  => [ qw( me.surname me.first_name ) ],
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