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

use HTML::Entities;

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my $self = shift;
  return [$self->url_key];
}

=head2 can_delete

Checks to see whether a fixtures grid can be deleted.  A fixtures grid can be deleted if there are no matches and no divisions assigned to it.

=cut

sub can_delete {
  my $self = shift;
  
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
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the name for messaging
  my $name = encode_entities($self->full_name);
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.delete.error.cant-delete", $name));
    return $response;
  }
  
  # Delete
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

=head2 can_create_fixtures

Checks that all the requirements are in place to create the fixtures.  (i.e., the grid matches and team position numbers are filled out and there are no fixtures created for this grid already).

=cut

sub can_create_fixtures {
  my $self = shift;
  
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
    "team_seasons.grid_position" => undef,
    "season.complete" => 0,
  }, {
    join => {season => "team_seasons"},
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
  my $self = shift;
  
  my $total_matches = $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
  
  # If there are no matches, we will just return false, as there's nothing to delete
  return 0 if !$total_matches;
  
  my $matches = $self->search_related("team_matches", {
    -and => {"season.complete" => 0},
    -or => [{
      home_team_games_won => {">" => 0}
    }, {
      home_team_games_lost => {">" => 0}
    }, {
      home_team_legs_won => {">" => 0}
    }, {
      home_team_points_won => {">" => 0}
    }, {
      away_team_games_won => {">" => 0}
    }, {
      away_team_games_lost => {">" => 0}
    }, {
      away_team_legs_won => {">" => 0}
    }, {
      away_team_points_won => {">" => 0}
    }, {
      games_drawn => {">" => 0}
    }]
  }, {
    join => "season",
  })->count;
  
  # Return 1 if the number of matches with any scores in is zero, otherwise zero
  return ( $matches == 0 ) ? 1 : 0;
}

=head2 matches_in_current_season

Returns the number of matches in the current season (defined as the season with a 'complete' value of zero).

=cut

sub matches_in_current_season {
  my $self = shift;
  
  return $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
}

=head2 get_divisions

Return the DivisionSeason objects that relate to this grid for the given season.

=cut

sub get_divisions {
  my $self = shift;
  my ( $season ) = @_;
  
  return $self->search_related("division_seasons", {
    "me.season" => $season->id,
    "team_seasons.season" => $season->id,
    "club_season.season" => $season->id,
  }, {
    prefetch => [qw( division ), {
        team_seasons => [qw( team ), {
        club_season => "club",
      }]
    }],
    order_by  => {
      -asc => [qw( division.rank team_seasons.grid_position )],
    }
  });
}

=head2 get_match_templates

Get the matches setup for the grid.

=cut

sub get_match_templates {
  my $self = shift;
  
  return $self->search_related("fixtures_grid_weeks", undef, {
    prefetch => [qw( fixtures_grid_matches )],
    order_by => {
      -asc => [qw( fixtures_grid_matches.week fixtures_grid_matches.match_number )]
    },
  });
}

=head2 set_matches

Performs error checking and updates the grid matches for each week.

=cut

sub set_matches {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $repeat_fixtures = $params->{repeat_fixtures};
  my %match_teams = %{$params->{match_teams}};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {repeat_fixtures => $repeat_fixtures},
    completed => 0,
  };
  
  # Check the matches for this grid can be set
  push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.cannot-edit")) unless $self->can_edit_matches;
  
  # Get the grid settings
  my $maximum_teams_per_division = $self->maximum_teams;
  my $fixtures_repeated_count = $self->fixtures_repeated;
  
  # The number of weeks required to complete a set of fixtures (i.e., everybody playing everybody) will always be the number of teams minus 1 (as everybody plays everybody but themselves)
  my $first_pass_fixtures_weeks = $maximum_teams_per_division - 1;
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
      push ( @{$fixtures_grid_weeks[$#fixtures_grid_weeks]{matches}}, {
        match_number => $match->match_number,
        home_team => $match_teams{$week->week}{$match->match_number}{home},
        away_team => $match_teams{$week->week}{$match->match_number}{away},
      });
    }
    
    # Break out of the loop if we are repeating and we have reached the end of the first pass of fixtures
    last if $repeat_fixtures and $week->week == $first_pass_fixtures_weeks;
  }
  
  $response->{fields}{weeks} = \@fixtures_grid_weeks;
  
  # These will hold the details of any teams submitted that are blank / invalid in a text form so that they can be 'join'ed in a final error message
  my (@blank_teams, @invalid_teams);
  
  # This hash will hold a hashref of weeks and the keys to each week will be a team number; keys will be added as teams are used so that we can check
  # if a key exists when validating the teams selected
  my %used_teams = ();
  
  # Now loop through the data structure we've created and make sure everything is valid.
  foreach my $week ( @fixtures_grid_weeks ) {
    foreach my $match ( @{ $week->{matches} } ) {
      if ( !$match->{home_team} ) {
        push( @{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.home-team-blank", $week->{week}, $match->{match_number}) );
      } elsif ( $match->{home_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push( @{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.home-number-invalid", $week->{week}, $match->{match_number}, $maximum_teams_per_division) );
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref($used_teams{$week->{week}}{$match->{home_team}}) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push(@{$used_teams{$week->{week}}{$match->{home_team}}} , sprintf("match %s (home)", $match->{match_number}));
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{home_team}} = [sprintf("match %s (home)", $match->{match_number})];
        }
      }
      
      if ( !$match->{away_team} ) {
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.away-team-blank", $week->{week}, $match->{match_number}) );
      } elsif ( $match->{away_team} !~ m/^\d{1,2}$/ or $match->{home_team} > $maximum_teams_per_division ) {
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.away-number-invalid", $week->{week}, $match->{match_number}, $maximum_teams_per_division) );
      } else {
        # The value is valid, but has it been entered in a previous match for this week?
        if ( ref($used_teams{$week->{week}}{$match->{away_team}}) eq "ARRAY" ) {
          # Already exists, push it on to the arrayref
          push(@{$used_teams{$week->{week}}{$match->{away_team}}} , sprintf("match %s (away)", $match->{match_number}));
        } else {
          # Doesn't exist, create a new arrayref
          $used_teams{$week->{week}}{$match->{away_team}} = [sprintf("match %s (away)", $match->{match_number})];
        }
      }
    }
  }
  
  # Now loop through our %used_teams hash and make sure we haven't used any team more than once.
  foreach my $week ( keys(%used_teams) ) {
    foreach my $team ( keys( %{$used_teams{$week}} ) ) {
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.team-overused", $week, $team, join(", ", @{ $used_teams{$week}{$team} } )) ) if scalar(@{ $used_teams{$week}{$team} }) > 1;
    }
  }
  
  # If we've errored, we need to return all the values so - for example - a web application can set them back into the form - we didn't do this originally, as we didn't know if there was an error or not.
  if ( scalar @{$response->{errors}} == 0 ) {
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
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Loop through as many times as we need to repeat the fixtures
    # The week number is counted manually, as we only have the first pass of fixtures in the array, so we need to keep our own count
    my $week_number;
    foreach my $i ( 1 .. $loop_end ) {
      # Now loop through the array we build up
      foreach my $week ( @fixtures_grid_weeks ) {
        # Increment the week number
        $week_number++;
        
        # ... and within that, loop through the matches in that array
        foreach my $match ( @{$week->{matches}} ) {
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
          
          my $ok = $weeks->find({
            grid => $self->id,
            week => $week_number,
          })->fixtures_grid_matches->find({
            match_number => $match->{match_number},
          })->update({
            home_team => $home_team,
            away_team => $away_team,
          });
        }
      }
    }
    
    $transaction->commit;
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("fixtures-grids.form.matches.success"));
  }
  
  return $response;
}

=head2 set_teams

Set the teams to their grid numbers for the current season.

=cut

sub set_teams {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $divisions = $params->{divisions};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
    can_complete => 1, # Default to 1, set to 0 if we hit certain errors.  This is so the application calling this routine knows not to return back to the form if we can't actually do it anyway
  };
  
  # Get the current season, as we can only change this for the current season
  my $season = $self->result_source->schema->resultset("Season")->get_current;
  
  unless ( defined( $season ) ) {
    # No current season, fatal error
    push( @{$response->{errors}}, $lang->maketext("fixtures-grids.teams.error.no-current-season") );
    $response->{can_complete} = 0;
    return $response;
  }
    
  # If we have a grid and a season, we need to see if matches have already been set for that grid
  if ( $self->search_related("team_matches", {season => $season->id})->count > 0 ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.teams.error.matches-set") );
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Get the list of teams who've entered in divisions assigned to the grid
  my $division_seasons = $self->search_related("division_seasons", {
    "me.season" => $season->id,
    "team_seasons.season" => $season->id,
  }, {
    prefetch  => [qw( division ), { 
      team_seasons => [qw( team ), {club_season => "club"}],
    }],
    order_by => {-asc => [qw( division.rank team_seasons.grid_position )]},
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
      id => $division_season->division->id,
      rank => $division_season->division->rank,
      name  => $division_season->name,
      object => $division_season,
      teams => {},
    };
    
    # Get the submitted value for this division
    my $team_ids = $divisions->{"division-positions-" . $division_season->division->id};
    $team_ids = [$team_ids] unless ref($team_ids) eq "ARRAY";
    
    # Loop through the team IDs; make sure each team belongs to this division and is only itemised once and that no teams are missing.
    my $position = 1;
    foreach my $id ( @{$team_ids} ) {
      if ( $id ) {
        # If we have an ID, make sure it's in the resultset for this division
        my $team_season = $division_season->team_seasons->find({
          team => $id,
          season => $season->id,
        }, {
          prefetch => [qw( team ), {club_season => "club"}],
        });
        
        if ( defined($team_season) ) {
          $submitted_data{$division_season->division->url_key}{teams}{$team_season->team->id} = {
            name => sprintf("%s %s", $team_season->club_season->short_name, $team_season->name),
            position => $position,
          };
          
          if ( defined( $used_values{$division_season->name}{$position} ) ) {
            # Already exists, push it on to the arrayref
            push(@{$used_values{$division_season->name}{$position}} , sprintf("%s %s", $team_season->club_season->short_name, $team_season->name));
          } else {
            # Doesn't exist, create a new arrayref
            $used_values{$division_season->name}{$position} = [sprintf( "%s %s", $team_season->club_season->short_name, $team_season->name )];
          }
        } else {
          push(@{$response->{errors}}, $lang->maketext("fixtures-grids.teams.error.wrong-team-id", $id));
        }
      } else {
        # No ID, push undefined values for the bye
        $submitted_data{$division_season->division->url_key}{teams}{0} = {
          id => 0,
          name => "[Bye]",
          position => $position,
        };
      }
      $position++;
    }
    
    # After we loop through the IDs, make sure we have each team in there
    my $team_seasons = $division_season->team_seasons;
    while ( my $team_season = $team_seasons->next ) {
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.teams.error.no-position-for-team", $team_season->club_season->short_name, $team_season->name, $submitted_data{ $division_season->division->url_key }{name}) )  if !exists( $submitted_data{ $division_season->division->url_key }{teams}{ $team_season->team->id } );
    }
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $division ( keys(%used_values) ) {
    foreach my $position ( keys( %{$used_values{$division}} ) ) {
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.teams.error.position-used-more-than-once", $division, $position, join(", ", @{ $used_values{$division}{$position} } ) )) if scalar(@{ $used_values{$division}{$position} }) > 1;
    }
  }
  
  $response->{fields} = \%submitted_data;
  
  # Check for errors
  if ( scalar @{$response->{errors}} == 0 ) {
    # Finally we need to loop through again updating the home / away teams for each match
    foreach my $division_key ( keys %submitted_data ) {
      # Get the division DB object, then the team seasons object
      my $division_season = $submitted_data{ $division_key }{object};
      my $team_seasons = $division_season->team_seasons;
      foreach my $team_id ( keys %{$submitted_data{ $division_key }{teams}} ) {
        $team_seasons->find({
          team => $team_id,
          season => $season->id
        })->update({
          grid_position => $submitted_data{ $division_key }{teams}{$team_id}{position},
        }) if $team_id;
      }
    }
    
    push(@{$response->{success}}, $lang->maketext("fixtures-grids.form.teams.success", encode_entities($self->name)));
    $response->{completed} = 1;
  }
  
  return $response;
}



=head2 create_matches

Checks the given parameters and if everything is okay, populates the league matches for the current season for any division using the given grid.

=cut

sub create_matches {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $weeks = $params->{weeks};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
    can_complete => 1, # Default to 1, set to 0 if we hit certain errors.  This is so the application calling this routine knows not to return back to the form if we can't actually do it anyway
  };
  
  # Get the current season
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.no-current-season"));
    $response->{can_complete} = 0;
  }
  
  # Check the season hasn't had matches created already.
  if ( $self->result_source->schema->resultset("TeamMatch")->season_matches($season, {grid => $self})->count > 0 ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.matches-exist", $season->name));
    $response->{can_complete} = 0;
  }
  
  # Check if we have some incomplete matches set up for this grid
  my $grid_weeks = $self->search_related("fixtures_grid_weeks", undef, {prefetch => "fixtures_grid_matches"});
  
  # This will store home / away team information for each match of each week; team numbers are 1-[maximum_teams_per_division].
  # Format:
  # $grid_matches{$week_id}[$array_index]{home_team} = $home_team_number;
  # $grid_matches{$week_id}[$array_index]{away_team} = $away_team_number;
  my ( %grid_matches, $incomplete_grid_matches );
  
  # Loop through all weeks
  WEEKS: while ( my $week = $grid_weeks->next ) {
    # Now loop through matches within those weeks
    my $matches = $week->fixtures_grid_matches;
    while ( my $match = $matches->next ) {
      # Check that the matches have been completely filled out
      if ( $match->home_team and $match->away_team ) {
        # Store this match in the %grid_matches hash - first check if it's an arrayref
        if ( ref( $grid_matches{$week->week} ) eq "ARRAY" ) {
          # It's already an arrayref, push the values on to it
          push(@{$grid_matches{$week->week}}, {home_team => $match->home_team, away_team => $match->away_team});
        } else {
          # It's not an arrayref, so these must the first values; create an arrayref with these values
          $grid_matches{$week->week} = [{home_team => $match->home_team, away_team => $match->away_team}];
        }
      } else {
        $incomplete_grid_matches++;
        last WEEKS;
      }
    }
  }
  
  if ( $incomplete_grid_matches ) {
    # If not all the grid matches are filled out, we have to prompt to do that first
    push(@{ $response->{error} }, $lang->maketext("fixtures-grids.form.create-fixtures.error.matches-incomplete"));
    $response->{can_complete} = 0;
  }
  
  # Check if we have incomplete grid positions for any teams involved in divisions that use this fixtures grid for the current season
  my $team_grid_positions = $self->search_related("division_seasons", {
    "team_seasons.season" => $season->id,
    "me.season" => $season->id,
  }, {
    prefetch => [qw( division ), {
      league_match_template => {
        template_match_team_games => "individual_match_template",
      },
      team_seasons => [qw( home_night team ), {club_season => [qw( club venue )]}]
    }],
    order_by => {
      -asc => [ qw( division.rank template_match_team_games.match_game_number )],
    },
  });
  
  # %division_positions will hold the positions for each division like so:
  # $division_positions{$division_id}{$position} = $team (value is a team object).
  # $incomplete_team_grid_positions will hold a count of the team grid positions that aren't yet completed.
  my ( %division_positions, $incomplete_team_grid_positions, %division_templates );
  
  # Loop through our divisions and within them the team season objects, saving away the grid position / team for each
  while ( my $division_season = $team_grid_positions->next ) {
    my $team_seasons = $division_season->team_seasons;
    
    # Loop through and store each team's grid position
    while( my $team_season = $team_seasons->next ) {
      if ( defined($team_season->grid_position) ) {
        # The grid position is set; use it as a hashref key so we can easily access it when creating matches
        $division_positions{$division_season->division->id}{$team_season->grid_position} = $team_season;
      } else {
        $incomplete_team_grid_positions++;
      }
    }
    
    # Store this division's template information in a hashref.  This is better than a resultset that we need to keep resetting,
    # as we'd be doing this a lot and it would slow us down.
    $division_templates{$division_season->division->id} = {
      id => $division_season->league_match_template->id,
      singles_players_per_team => $division_season->league_match_template->singles_players_per_team,
      games => [],
    };
    
    # Loop through and add the games rules
    my $template_games = $division_season->league_match_template->template_match_team_games;
    while ( my $game = $template_games->next ) {
      push(@{$division_templates{ $division_season->division->id }{games}}, {
        singles_home_player_number => $game->singles_home_player_number,
        singles_away_player_number => $game->singles_away_player_number,
        doubles_game => $game->doubles_game,
        match_template => $game->individual_match_template->id,
        match_game_number => $game->match_game_number,
        legs_per_game => $game->individual_match_template->legs_per_game,
      });
    }
  }
  
  # Check if we have any incomplete grid positions
  if ( $incomplete_team_grid_positions ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.teams-incomplete"));
    $response->{can_complete} = 1;
  }
  
  # Return at this point if we have any errors so far
  return $response if scalar( @{$response->{errors}} );
  
  # Now we've done our fatal error checks, we need to loop through the values we've been given and check them for errors
  # We store the last season week's date that we processed, so we can ensure this one does not occur before the last one. 
  my $last_season_week;
  
  # This hash will hold the values we can use to repopulate the form if we need to
  my %week_allocations = ();
  
  # Now loop through the weeks ensuring that we have a valid season week ID for each and that they are in order.
  # Go back to the first record
  $grid_weeks->reset;
  while ( my $week = $grid_weeks->next ) {
    $week_allocations{"week_" . $week->week }{id} = $week->week;
    
    if ( $weeks->{"week_" . $week->week} ) {
      # Find this week in the fixtures_weeks table
      my $season_week = $season->find_related("fixtures_weeks", {id => $weeks->{"week_" . $week->week}});
      
      if ( defined( $season_week ) ) {
        # Set the week beginning date for that week ID so we can refer to it later without going back to the DB
        $week_allocations{"week_" . $week->week }{week_beginning_id} = $season_week->id;
        $week_allocations{"week_" . $week->week }{week_beginning_date} = $season_week->week_beginning_date;
        
        # The week is valid; ensure it doesn't occur prior to the last one.
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.date-occurs-before-previous-date", $week->week))
            if defined($last_season_week) and $season_week->week_beginning_date->ymd("") <= $last_season_week->week_beginning_date->ymd("");
        
        # Set the last season week so that we can check the next one occurs at a later date on the next iteration.
        $last_season_week = $season_week;
      } else {
        # Error, season week not found
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.week-invalid", $week->week));
      }
    } else {
      # Error, season week not specified.
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.week-blank", $week->week));
    }
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    $response->{week_allocations} = \%week_allocations;
    
    ############## CREATE MATCHES #############
    # Loop through our week allocations and in each loop, loop through the divisions.
    # This will be the MASSIVE arrayref that will hold all the matches (plus their contained players, games and legs)
    my ( @matches, @match_ids, @match_names, $team_match_template );
    my $matches = 0;
    
    # Loop through each week for the grid
    foreach my $week_allocation ( sort { $week_allocations{$a}{id} <=> $week_allocations{$b}{id} } keys %week_allocations ) {
      # Store the ID in a more easily readable variable
      my $scheduled_week = $week_allocations{$week_allocation}{week_beginning_id};
      my $league_week_number = $week_allocations{$week_allocation}{id};
      my $week_beginning_date = $week_allocations{$week_allocation}{week_beginning_date};
      
      # Loop through the divisions, getting each match for each division
      foreach my $division ( sort keys( %division_positions ) ) {
        # Store the template for this division
        my $team_match_template = $division_templates{$division};
        my $singles_players_per_team = $team_match_template->{singles_players_per_team};
        my @team_match_games_templates = @{ $division_templates{$division}{games} };
        
        foreach my $match ( @{$grid_matches{$league_week_number}} ) {
          # Store the home and away team for easy access
          my $home_team = $division_positions{$division}{$match->{home_team}}->team if defined($division_positions{$division}{$match->{home_team}});
          my $away_team = $division_positions{$division}{$match->{away_team}}->team if defined($division_positions{$division}{$match->{away_team}});
          
          # This defined() check protects against teams that have a bye.
          if ( defined($home_team) and defined($away_team) ) {
            my $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_beginning_date, $division_positions{$division}{$match->{home_team}}->home_night->weekday_number);
            my $start_time = $home_team->default_match_start // $home_team->club->default_match_start // $season->default_match_start;
            
            # Empty arrayref for the games - these will be populated in the next loop
            my @match_games = ();
            
            # Set up the league team match games / legs
            foreach my $game_template ( @team_match_games_templates ) {
              # Loop through creating legs for each game
              # Empty arrayref for the legs - this will be populated on the next loop
              my @match_legs = ();
              foreach my $i ( 1 .. $game_template->{legs_per_game} ) {
                push(@match_legs, {
                  home_team => $home_team->id,
                  away_team => $away_team->id,
                  scheduled_date => $scheduled_date->ymd,
                  scheduled_game_number => $game_template->{match_game_number},
                  leg_number => $i,
                });
              }
              
              # What we populate will be different, depending on whether it's a doubles game or not
              my $populate;
              if ( $game_template->{doubles_game} ) {
                $populate = {
                  home_team => $home_team->id,
                  away_team => $away_team->id,
                  scheduled_date => $scheduled_date->ymd,
                  scheduled_game_number => $game_template->{match_game_number},
                  individual_match_template => $game_template->{match_template},
                  actual_game_number => $game_template->{match_game_number},
                  doubles_game => $game_template->{doubles_game},
                  team_match_legs => \@match_legs,
                };
              } else {
                $populate = {
                  home_team => $home_team->id,
                  away_team => $away_team->id,
                  scheduled_date => $scheduled_date->ymd,
                  scheduled_game_number => $game_template->{match_game_number},
                  individual_match_template => $game_template->{match_template},
                  actual_game_number => $game_template->{match_game_number},
                  home_player_number => $game_template->{singles_home_player_number},
                  away_player_number => $game_template->{singles_away_player_number},
                  doubles_game => $game_template->{doubles_game},
                  team_match_legs => \@match_legs,
                }
              }
              
              push(@match_games, $populate);
            }
            
            # Now loop through and build the players.  We loop through twice for the number of players per team,
            # so that we do it for both teams
            # Empty arrayref to start off with
            my @match_players = ();
            foreach my $i ( 1 .. ( $singles_players_per_team * 2 ) ) {
              # Is it home or away?  If our loop counter is greater than the number of players in a team, we must have moved on to the away team
              my $location = $i > $singles_players_per_team ? "away" : "home";
              
              push(@match_players, {
                home_team => $home_team->id,
                away_team => $away_team->id,
                player_number => $i,
                location => $location,
              });
            }
            
            # Push on to the array that will populate the DB
            push(@matches, {
              home_team => $home_team->id,
              away_team => $away_team->id,
              scheduled_date => $scheduled_date->ymd,
              played_date => $scheduled_date->ymd,
              scheduled_start_time => $start_time,
              season => $season->id,
              division => $division, # This is an ID, not an object, as we've used it as the key of this hash
              tournament_round => undef,
              venue => $home_team->club->venue->id,
              scheduled_week => $scheduled_week,
              team_match_template => $team_match_template->{id},
              fixtures_grid => $self->id,
              team_match_games => \@match_games,
              team_match_players => \@match_players,
            });
            
            # Increase the number of matches we are creating
            $matches++;
            
            # Push on to the IDs / names arrays that we'll use for the event log
            push(@match_ids, {
              home_team => $home_team->id,
              away_team => $away_team->id,
              scheduled_date => $scheduled_date->ymd,
            });
            
            push(@match_names, sprintf("%s %s-%s %s (%s)", $home_team->club->short_name, $home_team->name, $away_team->club->short_name, $away_team->name, $scheduled_date->dmy("/")));
          }
        }
      }
    }
    
    $schema->resultset("TeamMatch")->populate(\@matches);
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("fixtures-grids.form.create-fixtures.success", scalar(@match_ids), $self->name, $season->name));
    
    # Return the matches so we can log their creation... lucky this is a reference, as this is a huge array!
    $response->{match_ids} = \@match_ids;
    $response->{match_names} = \@match_names;
    $response->{matches} = \@matches;
  }
  
  return $response;
}

=head2 delete_matches

Deletes the fixtures for the grid in the current season (so long as they are able to be deleted - this is checked with can_delete_fixtures).

=cut

sub delete_matches {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
    can_complete => 1, # Default to 1, set to 0 if we hit certain errors.  This is so the application calling this routine knows not to return back to the form if we can't actually do it anyway
  };
  
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
          home_team => undef,
          away_team => undef,
          scheduled_date => undef,
        });
        
        push(@match_names, sprintf("%s %s v %s %s (%s)", $match->team_season_home_team_season->club_season->short_name, $match->team_season_home_team_season->name, $match->team_season_away_team_season->club_season->short_name, $match->team_season_away_team_season->name, $match->scheduled_date->dmy("/")));
      }
      
      my $ok = $self->search_related("team_matches", {
        "season.complete" => 0,
      }, {
        join => "season",
      })->delete;
      
      if ( $ok ) {
        # Deleted ok
        $response->{match_names} = \@match_names;
        $response->{match_ids} = \@match_ids;
        $response->{rows} = $ok;
        $response->{completed} = 1;
        push(@{$response->{success}}, $lang->maketext("fixture-grids.form.delete-fixtures.success", $ok, encode_entities($self->name)));
      } else {
        # Not okay, log an error
        push(@{$response->{errors}}, $lang->maktext("fixtures-grids.form.delete-fixtures.error.delete-failed"));
      }
    } else {
      $response->{rows} = 0;
    }
  } else {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.delete-fixtures.error.cant-delete", encode_entities($self->name)));
  }
  
  return $response;
}

=head2 get_matches



=cut

sub get_matches {
  my $self = shift;
  return $self->search_related("team_matches");
}

=head2 can_edit_matches

Determine whether we can edit the matches for this grid by checking if matches have been created from it yet.

=cut

sub can_edit_matches {
  my $self = shift;
  return $self->get_matches->count ? 0 : 1;
}

=head2 get_seasons

Get the seasons that this grid has been used in.

=cut

sub get_seasons {
  my $self = shift;
  my $schema = $self->result_source->schema;
  return $schema->resultset("Season")->search({"fixtures_grid.id" => $self->id}, {
    join => {
      division_seasons => [qw( fixtures_grid )]
    },
    group_by => [qw( me.id )]
  });
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my $self = shift;
  my ( $params ) = @_;
  
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
