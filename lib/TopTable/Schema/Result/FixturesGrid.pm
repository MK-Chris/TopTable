use utf8;
package TopTable::Schema::Result::FixturesGrid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesGrid

=head1 DESCRIPTION

There is not a lot to put in this table, its just something for other tables (i.e., grid cells) to link back to...

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<fixtures_grids>

=cut

__PACKAGE__->table("fixtures_grids");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 maximum_teams

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_repeated

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "maximum_teams",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "fixtures_repeated",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 division_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->has_many(
  "division_seasons",
  "TopTable::Schema::Result::DivisionSeason",
  { "foreign.fixtures_grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_grid_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesGridWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_grid_weeks",
  "TopTable::Schema::Result::FixturesGridWeek",
  { "foreign.grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_fixtures_grids

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogFixturesGrid>

=cut

__PACKAGE__->has_many(
  "system_event_log_fixtures_grids",
  "TopTable::Schema::Result::SystemEventLogFixturesGrid",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.fixtures_grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OqXSR9xArT9LLH+t1V2YIg

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [ $self->url_key ];
}

=head2 can_delete

Checks to see whether a fixtures grid can be deleted.  A fixtures grid can be deleted if there are no matches and no divisions assigned to it.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # First check the divisions - this is quicker than matches, as there are lots of matches to check
  my $divisions = $self->search_related("division_seasons")->count;
  return 0 if $divisions;
  
  my $matches = $self->search_related("team_matches")->count;
  return 0 if $matches;
  
  # If we get this far, we can delete
  return 1;
}

=head2 check_and_delete

Process the deletion of the grid; checks that we're able to do this first (via can_delete).

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
    
  # Check we can delete
  #seasons.delete.error.matches-exist
  push(@{ $error }, {
    id          => "fixtures-grids.delete.error.cant-delete",
    parameters  => $self->name,
  }) if !$self->can_delete;
  
  # Delete
  my $ok = $self->delete if !$error;
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) if !$ok;
  
  return $error;
}

=head2 can_create_fixtures

Checks that all the requirements are in place to create the fixtures.  (i.e., the grid matches and team position numbers are filled out and there are no fixtures created for this grid already).

=cut

sub can_create_fixtures {
  my ( $self ) = @_;
  
  # First check the matches have been filled out
  my $incomplete_grid_matches = $self->search_related("fixtures_grid_weeks", [{
    "fixtures_grid_matches.home_team" => undef,
    "fixtures_grid_matches.away_team" => undef,
  }], {
    join => "fixtures_grid_matches",
  })->count;
  
  return 0 if $incomplete_grid_matches;
  
  # Next check the team position numbers have been filled out
  my $incomplete_team_positions = $self->search_related("division_seasons", {
    "team_seasons.grid_position"  => undef,
    "season.complete"             => 0,
  }, {
    join => {
      season => "team_seasons",
    },
  })->count;
  
  return 0 if $incomplete_team_positions;
  
  # If we get this far, we need to check if fixtures have been created
  my $matches = $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
  
  return 0 if $matches;
  
  # If we get this far, we can create
  return 1;
}

=head2 can_delete_fixtures

Checks to see whether the fixtures for the current season that have been created by this grid are able to be deleted.  This is basically if there are no scores filled out for any matches.

=cut

sub can_delete_fixtures {
  my ( $self ) = @_;
  
  my $total_matches = $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
  
  # If there are no matches, we will just return false, as there's nothing to delete
  return 0 if !$total_matches;
  
  my $matches = $self->search_related("team_matches", {
    -and => {
      "season.complete" => 0,
    }, -or => [{
      home_team_games_won => {
        ">" => 0,
      }
    }, {
      home_team_games_lost => {
        ">" => 0,
      }
    }, {
      home_team_legs_won => {
        ">" => 0,
      }
    }, {
      home_team_points_won => {
        ">" => 0,
      }
    }, {
      away_team_games_won => {
        ">" => 0,
      }
    }, {
      away_team_games_lost => {
        ">" => 0,
      }
    }, {
      away_team_legs_won => {
        ">" => 0,
      }
    }, {
      away_team_points_won => {
        ">" => 0,
      }
    }, {
      games_drawn => {
        ">" => 0,
      }
    }]
  }, {
    join => "season",
  })->count;
  
  # Return 1 if the number of matches with any scores in is zero, otherwise zero
  return ( $matches == 0 ) ? 1 : 0;
}

=head2 delete_fixtures

Deletes the fixtures for the grid in the current season (so long as they are able to be deleted - this is checked with can_delete_fixtures).

=cut

sub delete_fixtures {
  my ( $self ) = @_;
  my $return_value = {error => []};
  
  if ( $self->can_delete_fixtures ) {
    my @rows_to_delete = $self->search_related("team_matches", {
      "season.complete" => 0,
    }, {
      join => "season",
    })->all;
    
    # These arrays will be used in event log creation
    my ( @match_names, @match_ids );
    
    if ( scalar( @rows_to_delete ) ) {
      foreach my $match ( @rows_to_delete ) {
        push(@match_ids, {
          home_team       => undef,
          away_team       => undef,
          scheduled_date  => undef,
        });
        
        push( @match_names, sprintf( "%s %s v %s %s (%s)", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name, $match->scheduled_date->dmy("/") ) );
      }
      
      my $ok = $self->search_related("team_matches", {
        "season.complete" => 0,
      }, {
        join => "season",
      })->delete;
      
      if ( $ok ) {
        # Deleted ok
        $return_value->{match_names}  = \@match_names;
        $return_value->{match_ids}    = \@match_ids;
        $return_value->{rows}         = $ok;
      } else {
        # Not okay, log an error
        push(@{ $return_value->{error} }, {id => "fixtures-grids.form.delete-fixtures.error.delete-failed"});
      }
    } else {
      $return_value->{rows} = 0;
    }
  } else {
    push(@{ $return_value->{error} }, {
      id          => "fixtures-grids.form.delete-fixtures.error.cant-delete",
      parameters  => [$self->name],
    });
  }
  
  return $return_value;
}

=head2 matches_in_current_season

Returns the number of matches in the current season (defined as the season with a 'complete' value of zero).

=cut

sub matches_in_current_season {
  my ( $self ) = @_;
  
  return $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
}



=head2 set_teams

Set the teams to their grid numbers for the current season.

=cut

sub set_teams {
  my ( $self, $parameters ) = @_;
  my $divisions = delete $parameters->{divisions};
  my $lang      = delete $parameters->{language};
  
  my $return          = {
    grid              => $self,
    fatal             => [],
    error             => [],
    warning           => [],
    sanitised_fields  => {},
  };
  
  # Get the current season, as we can only change this for the current season
  my $season = $self->result_source->schema->resultset("Season")->get_current;
  
  unless ( defined( $season ) ) {
    # No current season, fatal error
    push( @{ $return->{error} }, $lang->("fixtures-grids.teams.error.no-current-season") );
    return $return;
  }
    
  # If we have a grid and a season, we need to see if matches have already been set for that grid
  my $matches_set_already = $self->search_related("team_matches", {
    season => $season->id,
  })->count;
  
  if ( $matches_set_already > 0 ) {
    push( @{ $return->{error} }, $lang->("fixtures-grids.teams.error.matches-set") );
    return $return;
  }
  
  # Get the list of teams who've entered in divisions assigned to the grid
  my $division_seasons = $self->search_related("division_seasons", {
    "me.season"           => $season->id,
    "team_seasons.season" => $season->id,
  }, {
    prefetch  => [ qw( division ), { 
      team_seasons => [ qw( team ), {
        club_season => "club",
      }],
    }],
    order_by  => {
      -asc => [ qw( division.rank team_seasons.grid_position ) ]
    },
  });
  
  # This hash will hold divisions and their teams and their positions as well as
  # some other name data so that we can use it in error messages.
  my %submitted_data = ();
  
  # This will hold the values we've seen for each division so we can make sure we've not seen any
  # position more than once for any divisioon
  my %used_values = ();
  
  # The error message to build up
  my $error;
  
  while ( my $division_season = $division_seasons->next ) {
    # Store the name for purposes of error messages
    $submitted_data{ $division_season->division->url_key } = {
      id      => $division_season->division->id,
      rank    => $division_season->division->rank,
      name    => $division_season->name,
      object  => $division_season,
      teams   => {},
    };
    
    # Get the submitted value for this division
    my @team_ids = split( ",", $divisions->{"division-positions-" . $division_season->division->id} );
    
    # Loop through the team IDs; make sure each team belongs to this division and is only itemised once and that no teams are missing.
    my $position = 1;
    foreach my $id ( @team_ids ) {
      if ( $id ) {
        # If we have an ID, make sure it's in the resultset for this division
        my $team_season = $division_season->team_seasons->find({
          team    => $id,
          season  => $season->id,
        }, {
          prefetch => [ qw( team ), {
            club_season => "club",
          }],
        });
        
        if ( defined( $team_season ) ) {
          $submitted_data{ $division_season->division->url_key }{teams}{$team_season->team->id} = {
            name      => sprintf( "%s %s", $team_season->club_season->short_name, $team_season->name ),
            position  => $position,
          };
          
          if ( defined( $used_values{ $division_season->name }{$position} ) ) {
            # Already exists, push it on to the arrayref
            push( @{ $used_values{ $division_season->name }{$position} } , sprintf( "%s %s", $team_season->club_season->short_name, $team_season->name ) );
          } else {
            # Doesn't exist, create a new arrayref
            $used_values{ $division_season->name }{$position} = [sprintf( "%s %s", $team_season->club_season->short_name, $team_season->name )];
          }
        } else {
          push( @{ $return->{error} }, $lang->("fixtures-grids.teams.error.wrong-team-id", $id) );
        }
      } else {
        # No ID, push undefined values for the bye
        $submitted_data{ $division_season->division->url_key }{teams}{0} = {
          id        => 0,
          name      => "[Bye]",
          position  => $position,
        };
      }
      $position++;
    }
    
    # After we loop through the IDs, make sure we have each team in there
    my $team_seasons = $division_season->team_seasons;
    while ( my $team_season = $team_seasons->next ) {
      push( @{ $return->{error} }, $lang->("fixtures-grids.teams.error.no-position-for-team", $team_season->club_season->short_name, $team_season->name, $submitted_data{ $division_season->division->url_key }{name}) )  if !exists( $submitted_data{ $division_season->division->url_key }{teams}{ $team_season->team->id } );
    }
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $division ( keys(%used_values) ) {
    foreach my $position ( keys( %{ $used_values{$division} } ) ) {
      push( @{ $return->{error} }, $lang->("fixtures-grids.teams.error.position-used-more-than-once", $division, $position, join(", ", @{ $used_values{$division}{$position} } ) ) ) if scalar(@{ $used_values{$division}{$position} }) > 1;
    }
  }
  
  # Check for errors
  if ( @{ $return->{error} } ) {
    $return->{submitted_data} = \%submitted_data;
  } else {
    # Finally we need to loop through again updating the home / away teams for each match
    foreach my $division_key ( keys %submitted_data ) {
      # Get the division DB object, then the team seasons object
      my $division_season = $submitted_data{ $division_key }{object};
      my $team_seasons    = $division_season->team_seasons;
      foreach my $team_id ( keys %{ $submitted_data{ $division_key }{teams} } ) {
        $team_seasons->find({
          team    => $team_id,
          season  => $season->id
        })->update({
          grid_position => $submitted_data{ $division_key }{teams}{ $team_id }{position},
        }) if $team_id;
      }
    }
  }
  
  return $return;
}

=head2 set_matches

Performs error checking and updates the grid matches for each week.

=cut

sub set_matches {
  my ( $self, $parameters ) = @_;
  my $repeat_fixtures = delete $parameters->{repeat_fixtures};
  my %match_teams     = %{ delete $parameters->{match_teams} };
  my $lang            = delete $parameters->{language};
  
  my $return          = {
    grid              => $self,
    fatal             => [],
    error             => [],
    warning           => [],
    sanitised_fields  => {},
  };
  
  # Get the grid settings
  my $maximum_teams_per_division = $self->maximum_teams;
  my $fixtures_repeated_count    = $self->fixtures_repeated;
  
  # The number of weeks required to complete a set of fixtures (i.e., everybody playing everybody) will always be the number of teams minus 1 (as everybody plays everybody but themselves)
  my $first_pass_fixtures_weeks  = $maximum_teams_per_division - 1;
  
  my $weeks = $self->fixtures_grid_weeks;
  
  # This array will hold the match number / week number information from the database as well as the submitted form information (home / away teams for each match) 
  my @fixtures_grid_weeks = ();
  # Loop through all weeks
  while ( my $week = $weeks->next ) {
    # Push this week on to the array, with an empty arrayref for matches
    push(@fixtures_grid_weeks, {week => $week->week, matches => []});
    
    my $matches = $week->fixtures_grid_matches;
    while ( my $match = $matches->next ) {
      # Create the arrayref of matches within this week
      push ( @ { $fixtures_grid_weeks[$#fixtures_grid_weeks]{matches} }, {
        match_number  => $match->match_number,
        home_team     => $match_teams{$week->week}{$match->match_number}{home},
        away_team     => $match_teams{$week->week}{$match->match_number}{away},
      });
    }
    
    # Break out of the loop if we are repeating and we have reached the end of the first pass of fixtures
    last if $repeat_fixtures and $week->week == $first_pass_fixtures_weeks;
  }
  
  # These will hold the details of any selects that are blank / invalid in a text form so that they can be 'join'ed in a final error message
  my (@blank_teams, @invalid_teams);
  
  # This hash will hold a hashref of weeks and the keys to each week will be a team number; keys will be added as teams are used so that we can check
  # if a key exists when validating the teams selected
  my %used_teams = ();
  
  # Now loop through the data structure we've created and make sure everything is valid.
  foreach my $week ( @fixtures_grid_weeks ) {
    foreach my $match ( @{ $week->{matches} } ) {
      if ( !$match->{home_team} ) {
        push( @{ $return->{error} }, $lang->("fixtures-grids.form.matches.home-team-blank", $week->{week}, $match->{match_number}) );
      } elsif ( $match->{home_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push( @{ $return->{error} }, $lang->("fixtures-grids.form.matches.home-number-invalid", $week->{week}, $match->{match_number}, $maximum_teams_per_division) );
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref( $used_teams{$week->{week}}{$match->{home_team}} ) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push( @{ $used_teams{$week->{week}}{$match->{home_team}} } , "match " . $match->{match_number} . " (home)");
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{home_team}} = ["match " . $match->{match_number} . " (home)"];
        }
      }
      
      if ( !$match->{away_team} ) {
        push(@{ $return->{error} }, $lang->("fixtures-grids.form.matches.away-team-blank", $week->{week}, $match->{match_number}) );
      } elsif ( $match->{away_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push(@{ $return->{error} }, $lang->("fixtures-grids.form.matches.away-number-invalid", $week->{week}, $match->{match_number}, $maximum_teams_per_division) );
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref( $used_teams{$week->{week}}{$match->{away_team}} ) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push( @{ $used_teams{$week->{week}}{$match->{away_team}} } , "match " . $match->{match_number} . " (away)");
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{away_team}} = ["match " . $match->{match_number} . " (away)"];
        }
      }
    }
  }
  
  # Now loop through our %used_teams hash and make sure we haven't used any team more than once.
  foreach my $week ( keys(%used_teams) ) {
    foreach my $team ( keys( %{ $used_teams{$week} } ) ) {
      push(@{ $return->{error} }, $lang->("fixtures-grids.form.matches.team-overused", $week, $team, join(", ", @{ $used_teams{$week}{$team} } )) ) if scalar(@{ $used_teams{$week}{$team} }) > 1;
    }
  }
  
  # If we've errored, we need to return all the values so - for example - a web application can set them back into the form - we didn't do this originally, as we didn't know if there was an error or not.
  if ( scalar( @{ $return->{error} } ) ) {
    $return->{weeks}            = \@fixtures_grid_weeks;
    $return->{repeat_fixtures}  = $repeat_fixtures;
  } else {
    # Finally we need to loop through again updating the home / away teams for each match
    # If we're repeating, we need to do multiple loops through
    my $loop_end;
    if ( $repeat_fixtures ) {
      # Loop through as many times as fixtures are repeated
      $loop_end = $fixtures_repeated_count;
    } else {
      # Loop through just once (this saves an if statement deciding whether to create a loop within a loop or not, which would duplicate code)
      $loop_end = 1;
    }
    
    # Loop through as many times as we need to repeat the fixtures
    # The week number is counted manually, as we only have the first pass of fixtures in the array, so we need to keep our own count
    my $week_number;
    foreach my $i ( 1 .. $loop_end ) {
      # Now loop through the array we build up
      foreach my $week ( @fixtures_grid_weeks ) {
        # Increment the week number
        $week_number++;
        
        # ... and within that, loop through the matches in that array
        foreach my $match ( @{ $week->{matches} } ) {
          # The home / away teams will be swapped if the first loop counter ($1) is an EVEN number.
          my ( $home_team, $away_team );
          
          if ( $i % 2 ) {
            # Odd number (no remainder), don't swap home and away teams
            $home_team = $match->{home_team};
            $away_team = $match->{away_team};
          } else {
            # Even number (remainder 1), swap home and away teams
            $home_team = $match->{away_team};
            $away_team = $match->{home_team};
          }
          
          $weeks->find({
            grid          => $self->id,
            week          => $week_number,
          })->fixtures_grid_matches->find({
            match_number  => $match->{match_number},
          })->update({
            home_team => $home_team,
            away_team => $away_team,
          });
        }
      }
    }
  }
  
  return $return;
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name,
    url_keys => $self->url_keys,
    type => "fixtures-grid"
  };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
