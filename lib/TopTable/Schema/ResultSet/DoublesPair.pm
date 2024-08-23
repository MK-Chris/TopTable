package TopTable::Schema::ResultSet::DoublesPair;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

__PACKAGE__->load_components(qw(Helper::ResultSet::SetOperations));

=head2 get_doubles_pairs_in_division_in_averages_order

Retrieve doubles pairs in a given season / division in averages order.  If the $criteria hashref is given, these will be added to the query.

=cut

sub get_doubles_pairs_in_division_in_averages_order {
  my $class = shift;
  my ( $params ) = @_;
  my $division = $params->{division};
  my $season = $params->{season};
  my $team = $params->{team};
  my $criteria_field = $params->{criteria_field} || undef;
  my $operator = $params->{operator} || undef;
  my $criteria = $params->{criteria};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $where = {
    "me.season" => $season->id,
    "division_season.division" => $division->id,
  };
  
  # Set up the team if there is one
  if ( defined($team) ) {
    $where->{"team_season.team"} = $team->id;
  }
  
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where->{sprintf("me.games_%s", $criteria_field)} = {
      $operator => $criteria,
    };
  }
  
  return $class->search($where, {
    prefetch  => [
      "person_season_person1_season_team",
      "person_season_person2_season_team", {
        team_season => ["division_season", {
          club_season => "club",
      }],
    }],
    order_by  => [{
      -desc => [qw( me.average_game_wins me.games_played me.games_won )],
    }, {
      -asc  => [qw( person_season_person1_season_team.surname person_season_person1_season_team.first_name person_season_person2_season_team.surname person_season_person2_season_team.first_name )],
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
  my $team = $params->{team} || undef;
  
  my $where = {season => $season->id};
  $where->{"me.team"} = $team->id if defined( $team );
  $where->{"team_season.division"} = $division->id if defined( $division );
  
  my $doubles_pair = $class->find($where, {
    rows => 1,
    join => {team_season => "division_season"},
    order_by => {-desc => "last_updated"}
  });
  
  return defined($doubles_pair) ? $doubles_pair->last_updated : undef;
}

=head2 find_pair

Finds a doubles pair given two people (in an arrayref), a team and a season.  People can be passed in either order.

=cut

sub find_pair {
  my $class = shift;
  my ( $params ) = @_;
  my ( $person1, $person2 ) = ( @{$params->{people}} );
  my $season = $params->{season};
  my $team = $params->{team};
  
  # Return undef if we don't have two people defined
  return undef unless defined($person1) and defined($person2);
  
  # Do the lookups if they are not passed in as objects
  my $schema = $class->result_source->schema;
  $person1 = $schema->resultset("Person")->find_id_or_url_key($person1) unless ref($person1);
  $person2 = $schema->resultset("Person")->find_id_or_url_key($person2) unless ref($person2);
  $season = $schema->resultset("Season")->find_id_or_url_key($season) if defined($season) and !ref($season);
  $team = $schema->resultset("Team")->find_id_or_url_key($team) if defined($team) and !ref($team);
  
  my @where = ({
    person1 => $person1->id,
    person2 => $person2->id,
  }, {
    person1 => $person2->id,
    person2 => $person1->id,
  });
  
  if ( defined($season) ) {
    $where[0]{"me.season"} = $season->id;
    $where[1]{"me.season"} = $season->id;
  }
  
  if ( defined($team) ) {
    $where[0]{"me.team"} = $team->id;
    $where[1]{"me.team"} = $team->id;
  }
  
  return $class->search(\@where, {
    prefetch  => [qw( season ), {
      person_season_person1_season_team => "person",
    }, {
      person_season_person2_season_team => "person",
    }, {
      team_season => "club_season",
    }],
    order_by => {-desc => [qw( season.start_date season.end_date )]}
  });
}

=head2 get_season

Search a resultset for a specific season.

=cut

sub get_season {
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  
  return $class->search({"me.season" => $season->id}, {
    join => [qw( season ), {
      person_season_person1_season_team => [qw( person team_membership_type )],
    }, {
      person_season_person2_season_team => [qw( person team_membership_type )],
    }, {
      team_season => [qw( club_season ), {division_season => "division"}],
    }],
    order_by => {-asc => [qw( team_membership_type.display_order team_membership_type_2.display_order division.rank )]},
  });
}

=head2 get_games

Return the games for this resultset (normally this would be an already looked up resultset involving a specific pair).

=cut

sub get_games {
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season} if defined($params);
  my $schema = $class->result_source->schema;
  
  # Grab the IDs in this resultset
  my @rs = $class->all;
  my @ids = map($_->id, @rs);
  
  # Build our initial where
  my @where = ({
    home_doubles_pair => {-in => \@ids},
    doubles_game => 1,
  }, {
    away_doubles_pair => {-in => \@ids},
    doubles_game => 1,
  });
  
  if ( defined($season) ) {
    # Add the season if supplied
    $where[0]{"team_match.season"} = $season->id;
    $where[1]{"team_match.season"} = $season->id;
  }
  
  # We can't search related because this pair may be a home or away player, so do a direct search on the table
  return $schema->resultset("TeamMatchGame")->search(\@where, {
    prefetch  => [qw( winner ), {
      home_doubles_pair => [{person_season_person1_season_team => "person", person_season_person2_season_team => "person"}],
      away_doubles_pair => [{person_season_person1_season_team => "person", person_season_person2_season_team => "person"}],
      team_match => [{
        team_season_home_team_season => [qw( team ), {club_season => "club"}],
      }, {
        team_season_away_team_season => [qw( team ), {club_season => "club"}],
      }],
    }],
    order_by => {
      -asc => [qw( me.scheduled_date me.home_team me.away_team me.actual_game_number me.scheduled_game_number )],
    },
  });
}

=head2 pairs_involving_person

Finds doubles pairs involving the given person

=cut

sub pairs_involving_person {
  my $class = shift;
  my ( $params ) = @_;
  my $person = $params->{person};
  my $season = $params->{season};
  my $team = $params->{team};
  
  my $where = [{
    person1 => $person->id,
  }, {
    person2 => $person->id,
  }];
  
  # If we have a season, pass that into the where queries
  if ( defined($season) ) {
    $where->[0]{"me.season"} = $season->id;
    $where->[1]{"me.season"} = $season->id;
  }
  
  # If we have a team, pass that into the where queries
  if ( defined($team) ) {
    $where->[0]{team} = $team->id;
    $where->[1]{team} = $team->id;
  }
  
  return $class->search($where, {
    prefetch => ["person_season_person1_season_team", "person_season_person2_season_team", "season", {
      team_season  => ["team", {club_season => "club"}]
    }],
  });
}

=head2 get_all_seasons

A list of seasons involving the doubles pairs in this set - essentially just grouping by season.

=cut

sub get_all_seasons {
  my $class = shift;
  
  return $class->search(undef, {
    group_by => [qw( me.season )],
  });
}

=head2 noindex_set

Determine if the current resultset has anybody set to noindex (if $on is true, otherwise determine if anyone *doesn't* have it set).

=cut

sub noindex_set {
  my $class = shift;
  my ( $on ) = @_;
  
  # Sanity check - all true values are 1, all false are 0
  $on = $on ? 1 : 0;
  
  return $class->search([-or => {"person.noindex" => $on, "person_2.noindex" => $on}], {
    join => {
      person_season_person1_season_team => "person",
      person_season_person2_season_team => "person"
    }
  });
}

1;