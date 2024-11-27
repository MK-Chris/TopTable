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

=head2 tournament_round_groups

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroup>

=cut

__PACKAGE__->has_many(
  "tournament_round_groups",
  "TopTable::Schema::Result::TournamentRoundGroup",
  { "foreign.fixtures_grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:M5EjIIFX4S3F9PMsUq5bSg

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
  
  # Then check tournament groups
  my $tourn_groups = $self->search_related("tournament_round_groups")->count;
  return 0 if $tourn_groups;
  
  my $matches = $self->search_related("team_matches")->count;
  return 0 if $matches;
  
  # If we get this far, we can delete
  return 1;
}

=head2 restricted_edit

Returns 1 if we can only edit the name of the grid, not the maximum number of teams, or number of times they're repeated (because there are matches created from this one already).  Returns 0 if edit is not restricted.

=cut

sub restricted_edit {
  my ( $self ) = shift;
  return $self->can_edit_matches ? 0 : 1;
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
  my $name = encode_entities($self->name);
  
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

=head2 can_create_matches

Checks that all the requirements are in place to create the fixtures.  (i.e., the grid matches and team position numbers are filled out and there are no fixtures created for this grid already).

=cut

sub can_create_matches {
  my $self = shift;
  my $schema = $self->result_source->schema;
  
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
  
  # Check the grid is used in this season
  my $current_season = $schema->resultset("Season")->get_current;
  return 0 unless defined($current_season); # If there's no current season, we can't continue
  return 0 unless $self->used_in_league_season($current_season); # If we're not using this grid in the current season, we also can't continue
  
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

=head2 can_delete_matches

Checks to see whether the fixtures for the current season that have been created by this grid are able to be deleted.  This is basically if there are no scores filled out for any matches.

=cut

sub can_delete_matches {
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
  return $matches == 0 ? 1 : 0;
}

=head2 matches_per_round

Return the number of matches per round (or week, as we sometimes refer to it, since fixtures grids were originally just for league matches).

=cut

sub matches_per_round {
  my $self = shift;
  return $self->maximum_teams / 2;
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
  my ( $params ) = @_;
  my $season = $params->{season};
  
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

=head2 rounds

Get the rounds for this grid (this used to be called weeks because a fixtures grid used to only be used for a league season; now it can be used for tournaments, which doesn't necessarily have to include teams that are only playing one match per week).

=cut

sub rounds {
  my $self = shift;
  return $self->search_related("fixtures_grid_weeks", {}, {
    order_by => {-asc => [qw( week )]}
  });
}

=head2 used_in_league_season

Returns 1 if the grid is used for any divisions in the given season, or 0 if not.

=cut

sub used_in_league_season {
  my $self = shift;
  my ( $season ) = @_;
  return $self->search_related("division_seasons", {"me.season" => $season->id})->count ? 1 : 0;
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
  my $max_teams = $self->maximum_teams;
  my $fixtures_repeated_count = $self->fixtures_repeated;
  
  # The number of weeks required to complete a set of fixtures (i.e., everybody playing everybody) will always be the number of teams minus 1 (as everybody plays everybody but themselves)
  my $first_pass_fixtures_weeks = $max_teams - 1;
  my $weeks = $self->fixtures_grid_weeks;
  
  # This array will hold the match number / week number information from the database as well as the submitted form information (home / away teams for each match) 
  my @fixtures_grid_weeks = ();
  # Loop through all weeks
  while ( my $week = $weeks->next ) {
    # Push this week on to the array, with an empty arrayref for matches
    push(@fixtures_grid_weeks, {week => $week->week, matches => []});
    
    # Week type must be entirely dynamic or entirely static
    my $week_type = undef;
    
    my $matches = $week->fixtures_grid_matches;
    while ( my $match = $matches->next ) {
      # Create the arrayref of matches within this week
      # Match number will always go in fine...
      my %match_details = (match_number => $match->match_number);
      
      # ...but we need to do some checking on home / away values (and parse it)
      if ( !defined($match_teams{$week->week}{$match->match_number}{home}) ) {
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.home-team-blank", $week->{week}, $match->{match_number}));
      }
      
      if ( !defined($match_teams{$week->week}{$match->match_number}{away}) ) {
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.away-team-blank", $week->{week}, $match->{match_number}));
      }
      
      my ( $home_type, $home_team ) = ( $match_teams{$week->week}{$match->match_number}{home} =~ /^([a-z0-9-]+)_(\d{1,3})$/ );
      my ( $away_type, $away_team ) = ( $match_teams{$week->week}{$match->match_number}{away} =~ /^([a-z0-9-]+)_(\d{1,3})$/ );
      
      # Store the home and away team numbers in the database
      $match_details{home} = $home_team;
      $match_details{away} = $away_team;
      
      # Lookup the types to verify
      $home_type = $schema->resultset("LookupGridTeamType")->find($home_type);
      $away_type = $schema->resultset("LookupGridTeamType")->find($away_type);
      
      if ( defined($home_type) and defined($away_type) ) {
        # Types are valid
        $match_details{home_type} = $home_type;
        $match_details{away_type} = $away_type;
        
        if ( $match->match_number == 1 ) {
          # Match 1, so these will set the week type
          if ( $home_type->type eq "static" xor $away_type->type eq "static" ) {
            # One is static, one is not - error
            push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.type-mismatch-in-match", $week->week, $match->match_number));
          } else {
            # We dont' have one static / one not, so at least either both are static OR both are dynamic - we can do more complicated checks here now
            # Set the week type to the home team type (the away team type will be the same, as this has already been checked)
            $week_type = $home_type->type;
            
            if ( $week_type eq "dynamic" ) {
              # Dynamic type - we need to check each type is compatible
              # Split off the bit after the dynamic type
              my $home_result = $home_type->player;
              my $away_result = $away_type->player;
            }
          }
        } else {
          # Match is not 1, so we need to check the types against the week type
          if ( $week_type eq "static" ) {
            if ( $home_type->type eq "dynamic" or $away_type->type eq "dynamic" ) {
              # Error, as we have a dynamic type in a week that's already set as static
              push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.type-mismatch-in-week", $week->week));
            }
          } else {
            # Dynamic round type
            if ( $week->week == 1 ) {
              # Can't have a dynamic round 1
              push(@{$response->{errors},}, $lang->maketext("fixtures-grids.form.matches.error-round1-dynamic"));
            } elsif ( $home_type->type eq "static" or $away_type->type eq "static" ) {
              # Error, as we have a static type in a week that's already set as dynamic
              push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.type-mismatch-in-week", $week->week));
            }
          }
        }
      } else {
        # One or both types are invalid
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.invalid-competitor", $week->week, $match->match_number));
      }
      
      push(@{$fixtures_grid_weeks[$#fixtures_grid_weeks]{matches}}, \%match_details);
    }
    
    # Break out of the loop if we are repeating and we have reached the end of the first pass of fixtures
    last if $repeat_fixtures and $week->week == $first_pass_fixtures_weeks;
  }
  
  $response->{fields}{weeks} = \@fixtures_grid_weeks;
  
  # This hash will hold a hashref of weeks and the keys to each week will be a team number; keys will be added as teams are used so that we can check
  # if a key exists when validating the teams selected
  # e.g.:
  # static: $used_teams{$weeknumber}{$teamnumber} = {type => static, detail => [array of lang messages showing "match num (home|away)"]}
  # dynamic: $used_teams{$weeknumber}{$teamnumber} = {type => dynamic, detail => {(winner|loser) => [array of lang messages showing "match num (home|away)"]}}
  my %used_teams = ();
  
  # Now loop through the data structure we've created and make sure everything is valid.
  # Each week / round must entirely consist of either dynamic or static types, they cannot be mixed
  if ( scalar @{$response->{errors}} == 0 ) {
    foreach my $week ( @fixtures_grid_weeks ) {
      foreach my $match ( @{$week->{matches}} ) {
        # Type checks first of all
        my $home_type = $match->{home_type};
        my $away_type = $match->{away_type};
        
        # Ensure they're valid
        # If it's a static match, the maximum teams in the grid is the maximum number we can reach
        # If it's dynamic, it's effectively half that, since we play winner or loser of match X.
        my $max_check = $home_type->type eq "static" ? $max_teams : int($max_teams / 2);
        
        my @teams = ( $match->{home}, $match->{away} );
        
        # Loop through home and away
        foreach my $idx ( 0 .. $#teams ) {
          # Grab the reference to the team and check the location (first element = home, second element = away)
          my $team = $teams[$idx];
          my ( $location, $type );
          
          if ( $idx == 0 ) {
            # Home
            $location = "home";
            $type = $home_type;
          } else {
            # Away
            $location = "away";
            $type = $away_type;
          }
          
          if ( !$team ) {
            push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.$location-team-blank", $week->{week}, $match->{match_number}));
          } elsif ( $team !~ m/^[1-$max_check]$/ ) {
            push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.$location-number-invalid", $week->{week}, $match->{match_number}, $max_teams));
          } else {
            if ( $type->id eq "static" ) {
              # Static checks to make sure we only see each team once
              # The value is valid, but has it been entered in a previous match for this week?
              if ( exists($used_teams{$week->{week}}{$match->{$location}})  ) {
                # Already exists, push it on to the arrayref
                push(@{$used_teams{$week->{week}}{$match->{$location}}{detail}}, $lang->maketext("fixtures-grids.form.matches.error.team-overused.match-details.$location", $match->{match_number}));
              } else {
                # Doesn't exist, create a new arrayref
                $used_teams{$week->{week}}{$match->{$location}} = {
                  type => $type->type,
                  detail => [$lang->maketext("fixtures-grids.form.matches.error.team-overused.match-details.$location", $match->{match_number})],
                };
              }
            } else {
              # Dynamic checks - we use each match exactly twice (once as winner, once as loser)
              # The value is valid, but has it been entered in a previous match for this week?
              if ( exists($used_teams{$week->{week}}{$match->{$location}})  ) {
                # Already exists - check the player type hash exists now
                if ( exists($used_teams{$week->{week}}{$match->{$location}}{detail}{$type->player}) ) {
                  # It does - push it on
                  push(@{$used_teams{$week->{week}}{$match->{$location}}{detail}{$type->player}}, $lang->maketext("fixtures-grids.form.matches.error.team-overused.match-details.$location", $match->{match_number}));
                } else {
                  # Create the hashref as an array we can push on to if there are any more of these
                  $used_teams{$week->{week}}{$match->{$location}}{detail}{$type->player} = [$lang->maketext("fixtures-grids.form.matches.error.team-overused.match-details.$location", $match->{match_number})];
                }
              } else {
                # Doesn't exist, create a new arrayref
                $used_teams{$week->{week}}{$match->{$location}} = {
                  type => $type->type,
                  detail => {
                    $type->player => [$lang->maketext("fixtures-grids.form.matches.error.team-overused.match-details.$location", $match->{match_number})]
                  },
                };
              }
            }
          }
        }
      }
    }
    
    # Now loop through our %used_teams hash and make sure we haven't used any team more than once.
    foreach my $week ( keys %used_teams ) {
      foreach my $team ( keys %{$used_teams{$week}} ) {
        if ( $used_teams{$week}{$team}{type} eq "static" ) {
          # If there's more than one match listed for this team, error
          push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.team-overused", $week, $team, join(", ", @{$used_teams{$week}{$team}{detail}}))) if scalar(@{$used_teams{$week}{$team}{detail}}) > 1;
        } else {
          push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.dynamic-winner-team-overused", $week, $team, join(", ", @{$used_teams{$week}{$team}{winner}{detail}}))) if scalar(@{$used_teams{$week}{$team}{winner}{detail}}) > 1;
          push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.matches.error.dynamic-loser-team-overused", $week, $team, join(", ", @{$used_teams{$week}{$team}{loser}{detail}}))) if scalar(@{$used_teams{$week}{$team}{loser}{detail}}) > 1;
        }
      }
    }
  }
  
  # If we've errored, we need to return all the values so - for example - a web application can set them back into the form - we didn't do this originally, as we didn't know if there was an error or not.
  if ( scalar @{$response->{errors}} == 0 ) {
    # Finally we need to loop through again updating the home / away teams for each match
    # If we're repeating, we need to do multiple loops through; if not, the loop just goes from 1 to 1
    my $loop_end = $repeat_fixtures ? $fixtures_repeated_count : 1;
    
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
          my ( $home_team, $away_team, $home_type, $away_type );
          
          if ( $i % 2 ) {
            # Odd number (no remainder), don't swap home and away teams
            $home_team = $match->{home};
            $home_type = $match->{home_type};
            $away_team = $match->{away};
            $away_type = $match->{away_type}
          } else {
            # Even number (remainder 1), swap home and away teams
            $home_team = $match->{away};
            $home_type = $match->{away_type};
            $away_team = $match->{home};
            $away_type = $match->{home_type};
          }
          
          my $ok = $weeks->find({
            grid => $self->id,
            week => $week_number,
          })->fixtures_grid_matches->find({
            match_number => $match->{match_number},
          })->update({
            home_team => $home_team,
            away_team => $away_team,
            home_team_type => $home_type->id,
            away_team_type => $away_type->id,
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
  my ( $tourn_group, $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $rounds = $params->{rounds};
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
  
  # If there's no current season, we can't create matches - that's true whether we're creating league or tournament group matches
  unless ( defined($season) ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.no-current-season"));
    $response->{can_complete} = 0;
  }
  
  if ( defined($tourn_group) ) {
    # If we have a tournament group, check it's correct
    if ( $tourn_group->isa("TopTable::Schema::Result::TournamentRoundGroup") ) {
      # It is a group - need to check that A) there's a fixtures grid and B) it's this grid
      if ( defined($tourn_group->fixtures_grid) ) {
        # There's a fixtures grid, need to check it's this one
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.group-wrong-grid", $tourn_group->name, encode_entities($self->name))) unless $tourn_group->fixtures_grid->id == $self->id;
        $response->{can_complete} = 0;
      } else {
        # No fixtures grid
        push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.group-no-grid"));
        $response->{can_complete} = 0;
      }
    } else {
      # Not a tournament group
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.grid-invalid"));
      $response->{can_complete} = 0;
    }
  }
  
  # If we have errors at the moment, just return straight away
  return $response if scalar @{$response->{errors}};
  
  my ( $is_tournament, $entry_type, $team_entry, $comp_name );
  
  if ( defined($tourn_group) ) {
    $is_tournament = 1;
    $entry_type = $tourn_group->tournament_round->tournament->entry_type->id;
    $team_entry = $entry_type eq "team" ? 1 : 0;
    $comp_name = $tourn_group->tournament_round->tournament->event_season->name;
  } else {
    $is_tournament = 0;
    $team_entry = 1; # Not a tournament, so a league division - must be team entry
  }
  
  # Check we don't have matches for this grid already - in this season (if creating league matches) or group (if creating group matches for a tournament)
  my $existing_matches = $is_tournament
    ? $tourn_group->matches->count
    : $schema->resultset("TeamMatch")->season_matches($season, {grid => $self})->count;
  
  if ( $existing_matches > 0 ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.matches-exist"));
    $response->{can_complete} = 0;
  }
  
  # Check if we have some incomplete matches set up for this grid
  my $grid_weeks = $self->search_related("fixtures_grid_weeks", undef, {prefetch => "fixtures_grid_matches"});
  
  # This will store home / away team information for each match of each week; team numbers are 1-[$max_teams].
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
    push(@{$response->{error}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.matches-incomplete"));
    $response->{can_complete} = 0;
  }
  
  # Check if we have incomplete grid positions for any teams involved in divisions that use this fixtures grid for the current season
  my @grid_users;
  
  if ( $is_tournament ) {
    # Group
    # Only one user of this grid in a tournament setting, and that's the current group we're working on
    # It needs to be in the array so we can loop through regardless of setting
    @grid_users = ( $tourn_group );
  } else {
    # League
    @grid_users = $self->search_related("division_seasons", {
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
  }
  
  # %position_info will hold the positions for each division like so:
  # $position_info{($division_id|$group_id)}{$position} = ($team|$person|$doubles tournament pair) (value is a DB object).
  # $incomplete_grid_positions will hold a count of the team grid positions that aren't yet completed.
  my ( %position_info, $incomplete_grid_positions, %templates );
  
  # Loop through our divisions and within them the team season objects, saving away the grid position / team for each
  foreach my $grid_user ( @grid_users ) {
    # Grid user (group or division) ID is used as a key in the %position_info hash
    my $grid_user_id = $is_tournament ? $grid_user->id : $grid_user->division->id;
    
    my $grid_positions;
    if ( $is_tournament ) {
      $grid_positions = $grid_user->get_entrants;
    } else {
      # Not a tournament, this must be league, so it's a team
      $grid_positions = $grid_user->team_seasons;
    }
    
    # Loop through and store each team's grid position
    while( my $competitor = $grid_positions->next ) {
      if ( defined($competitor->grid_position) ) {
        # The grid position is set; use it as a hashref key so we can easily access it when creating matches
        $position_info{$grid_user_id}{$competitor->grid_position} = $competitor;
      } else {
        $incomplete_grid_positions++;
      }
    }
    
    # Store this group user's template information in a hashref.  This is better than a resultset that we need to keep resetting,
    # as we'd be doing this a lot and it would slow us down.
    # How we get these depends on whether this is a tournament group (set at tournament round level) or a league match (set at division level)
    my ( $match_template );
    if ( $is_tournament ) {
      # For tournaments we could either be storing a team match template, or an individual one
      if ( $entry_type eq "team" ) {
        # Team match template
        $match_template = $tourn_group->tournament_round->team_match_template;
        $match_template = $tourn_group->tournament_round->tournament->default_team_match_template unless defined($match_template);
      } else {
        # Individual match templates apply to both doubles and singles
        $match_template = $tourn_group->tournament_round->individual_match_template;
      }
    } else {
      # League - always a team match
      $match_template = $grid_user->league_match_template;
    }
    
    $templates{$grid_user_id} = {match => $match_template};
    
    if ( $team_entry ) {
      # Loop through and add the games rules for a team match
      my $template_games = $match_template->template_match_team_games;
      
      # Empty array for games to push on to
      $templates{$grid_user_id}{games} = [];
      while ( my $game = $template_games->next ) {
        push(@{$templates{$grid_user_id}{games}}, {
          singles_home_player_number => $game->singles_home_player_number,
          singles_away_player_number => $game->singles_away_player_number,
          doubles_game => $game->doubles_game,
          match_template => $game->individual_match_template,
          match_game_number => $game->match_game_number,
          legs_per_game => $game->individual_match_template->legs_per_game,
        });
      }
    }
  }
  
  # Check if we have any incomplete grid positions
  if ( $incomplete_grid_positions ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.teams-incomplete"));
    $response->{can_complete} = 1;
  }
  
  # Return at this point if we have any errors so far
  return $response if scalar @{$response->{errors}};
  
  # Now we've done our fatal error checks, we need to loop through the values we've been given and check them for errors
  # We store the last season week's date that we processed, so we can ensure this one does not occur before the last one. 
  my $last_season_week;
  
  # This hash will hold the values we can use to repopulate the form if we need to
  my %week_allocations = ();
  
  # Now loop through the weeks ensuring that we have a valid season week ID for each and that they are in order.
  # Go back to the first record
  $grid_weeks->reset;
  while ( my $week = $grid_weeks->next ) {
    $week_allocations{"week_" . $week->week}{id} = $week->week;
    
    if ( $rounds->{"round_" . $week->week} ) {
      # Find this week in the fixtures_weeks table
      my $season_week = $season->find_related("fixtures_weeks", {id => $rounds->{"round_" . $week->week}});
      
      if ( defined($season_week) ) {
        # Set the week beginning date for that week ID so we can refer to it later without going back to the DB
        $week_allocations{"week_" . $week->week}{week_beginning_id} = $season_week->id;
        $week_allocations{"week_" . $week->week}{week_beginning_date} = $season_week->week_beginning_date;
        
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
    my ( @matches, @match_ids, @match_names );
    my $matches = 0;
    
    # Loop through each week for the grid
    foreach my $week_allocation ( sort { $week_allocations{$a}{id} <=> $week_allocations{$b}{id} } keys %week_allocations ) {
      # Store the ID in a more easily readable variable
      my $scheduled_week = $week_allocations{$week_allocation}{week_beginning_id};
      my $league_week_number = $week_allocations{$week_allocation}{id};
      my $week_beginning_date = $week_allocations{$week_allocation}{week_beginning_date};
      
      # Loop through the grid users (division or tournament group), creating each match for each one
      foreach my $grid_user_id ( sort keys( %position_info ) ) {
        # Store the template for this grid user
        my $match_template = $templates{$grid_user_id}{match};
        
        if ( $team_entry ) {
          my $singles_players_per_team = $match_template->singles_players_per_team;
          my @team_match_games_templates = @{$templates{$grid_user_id}{games}};
        
          foreach my $match ( @{$grid_matches{$league_week_number}} ) {
            # Store the home and away team for easy access
            my ( $home_team, $away_team, $home_team_season, $away_team_season );
            
            if ( $is_tournament ) {
              # If it's a tournament, the home and away team objects come from the tournament data
              $home_team_season = $position_info{$grid_user_id}{$match->{home_team}}->tournament_team->team_season if defined($position_info{$grid_user_id}{$match->{home_team}});
              $away_team_season = $position_info{$grid_user_id}{$match->{away_team}}->tournament_team->team_season if defined($position_info{$grid_user_id}{$match->{away_team}});
            } else {
              # League
              $home_team_season = $position_info{$grid_user_id}{$match->{home_team}};
              $away_team_season = $position_info{$grid_user_id}{$match->{away_team}};
            }
            
            # This defined() check protects against teams that have a bye.
            if ( defined($home_team_season) and defined($away_team_season) ) {
              $home_team = $home_team_season->team;
              $away_team = $away_team_season->team;
              
              my $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_beginning_date, $home_team_season->home_night->weekday_number);
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
                    individual_match_template => $game_template->{match_template}->id,
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
                    individual_match_template => $game_template->{match_template}->id,
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
                division => $is_tournament ? undef : $grid_user_id, # If it's not a tournament, this 
                tournament_round => $is_tournament ? $tourn_group->tournament_round->id : undef,
                tournament_group => $is_tournament ? $tourn_group->id: undef,
                venue => $home_team->club->venue->id,
                scheduled_week => $scheduled_week,
                team_match_template => $match_template->id,
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
              
              if ( $is_tournament ) {
                push(@match_names, sprintf("%s, (%s - %s)", $lang->maketext("matches.name", $home_team->full_name, $away_team->full_name), $comp_name, $scheduled_date->dmy("/")));
              } else {
                push(@match_names, sprintf("%s, (%s)", $lang->maketext("matches.name", $home_team->full_name, $away_team->full_name), $scheduled_date->dmy("/")));
              }
            }
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

Deletes the fixtures for the grid in the current season (so long as they are able to be deleted - this is checked with can_delete_matches).

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
  
  if ( $self->can_delete_matches ) {
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

Get the seasons that this grid has been used in either as a divisional grid or a tournament group grid (or both technically, this is unlikely though).

=cut

sub get_seasons {
  my $self = shift;
  my ( $params ) = @_;
  my $schema = $self->result_source->schema;
  my $no_prefetch = $params->{no_prefetch} || 0;
  my $join = $no_prefetch ? "join" : "prefetch";
  
  # fixtures_grid is the division_seasons relationship; fixtures_grid_2 is the tournament group one.
  return $schema->resultset("Season")->search([{"fixtures_grid.id" => $self->id}, {"fixtures_grid_2.id" => $self->id}], {
    $join => {
      division_seasons => [qw( fixtures_grid )],
      event_seasons => {
        tournaments => {
          tournament_rounds => {
            tournament_round_groups => [qw( fixtures_grid )],
          },
        },
      },
    },
    group_by => [qw( me.id )],
  });
}

=head2 get_uses

Retrieve objects that use this season - that's division seasons or tournament groups.  Return in a hash with keys {divisions => [array], tournament_groups => [array]}.

If either of the keys have no items, it'll be an empty array.

=cut

sub get_uses {
  my $self = shift;
  my ( $params ) = @_;
  my $season = $params->{season}; # We can limit uses to a specific season with this parameter
  my $no_prefetch = $params->{no_prefetch} || 0;
  my ( %where );
  my $join = $no_prefetch ? "join" : "prefetch";
  
  # Attribs setup for division first of all
  my %attrib = (
    $join => [qw( division season )],
  );
  
  # Setup season criteria
  %where = ("season.id" => $season->id) if defined($season);
  
  # Lookup divisions
  my @divisions = $self->search_related("division_seasons", \%where, \%attrib);
  
  # Setup join or prefetch for tournaments
  $attrib{$join} = {
    tournament_round => {
      tournament => {
        event_season => [qw( season )],
      },
    },
  };
  
  my @tourn_groups = $self->search_related("tournament_round_groups", \%where, \%attrib);
  
  return {divisions => \@divisions, tourn_groups => \@tourn_groups};
}

=head2 get_tournaments

Get tournaments the group is used in; 

=cut

sub get_tournament_groups {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $schema = $self->result_source->schema;
  
  my $season = $params->{season};
  
  # Initial criteria is just that the fixtures grid is set to this one in the group (and that the event type is a tournament)
  my %where = ("me.fixtures_grid" => $self->id);
  
  # Add the season in if it's provided
  $where{"season.id"} = $season->id if defined($season);
  
  return $schema->resultset("TournamentRoundGroup")->search(\%where, {
    prefetch => {
      tournament_round => {
        tournament => [qw( entry_type ), {
          event_season => [qw( event season )],
        }],
      },
    },
    order_by => {
      -asc => [qw( event_season.name tournament_round.round_number me.group_order )],
    },
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
