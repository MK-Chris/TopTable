use utf8;
package TopTable::Schema::Result::TournamentRoundGroup;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRoundGroup

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

=head1 TABLE: C<tournament_round_groups>

=cut

__PACKAGE__->table("tournament_round_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 url_key

  accessor: '_url_key'
  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 name

  accessor: '_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 group_order

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 automatic_qualifiers

  data_type: 'smallint'
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
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "url_key",
  {
    accessor => "_url_key",
    data_type => "varchar",
    is_nullable => 1,
    size => 45,
  },
  "name",
  { accessor => "_name", data_type => "varchar", is_nullable => 1, size => 150 },
  "group_order",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "fixtures_grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "automatic_qualifiers",
  { data_type => "smallint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<tournament_round_group_order>

=over 4

=item * L</tournament_round>

=item * L</group_order>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "tournament_round_group_order",
  ["tournament_round", "group_order"],
);

=head2 C<url_key_unique_in_round>

=over 4

=item * L</url_key>

=item * L</tournament_round>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key_unique_in_round", ["url_key", "tournament_round"]);

=head1 RELATIONS

=head2 fixtures_grid

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGrid>

=cut

__PACKAGE__->belongs_to(
  "fixtures_grid",
  "TopTable::Schema::Result::FixturesGrid",
  { id => "fixtures_grid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_group_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentGroupPerson>

=cut

__PACKAGE__->has_many(
  "tournament_group_people",
  "TopTable::Schema::Result::TournamentGroupPerson",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_group_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentGroupTeam>

=cut

__PACKAGE__->has_many(
  "tournament_group_teams",
  "TopTable::Schema::Result::TournamentGroupTeam",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_groups_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentGroupDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_groups_doubles",
  "TopTable::Schema::Result::TournamentGroupDoubles",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->belongs_to(
  "tournament_round",
  "TopTable::Schema::Result::TournamentRound",
  { id => "tournament_round" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-30 10:56:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nzXdBYxYZyY5lhglkKdwyg

use HTML::Entities;

=head2 url_key

Return the URL key if defined, or the group order number if not.

=cut

sub url_key {
  my $self = shift;
  return defined($self->_url_key) ? $self->_url_key : $self->group_order;
}

=head2 name

Return the name of the round, or the default (from the user's language) for that round.

=cut

sub name {
  my $self = shift;
  my ( $params ) = @_;
  
  # Setup schema / lang
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  return defined($self->_name) ? encode_entities($self->_name) : $lang->maketext("tournament.round.group.default-name", $self->group_order);
}

=head2 members

Return the entrants, depending on the entry type - no ordering is performed on this, however there's a prefetch to get the season and the object (so those IDs can be accessed).

=cut

sub members {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  my %attrib = ();
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_group_teams";
    $attrib{prefetch} = {
      tournament_round_team => {
        tournament_team => {
          team_season => [qw( team )]
        }
      }
    };
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
    $attrib{prefetch} = {
      tournament_round_person => {
        tournament_person => {
          person_season => [qw( person )]
        }
      }
    };
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
    $attrib{prefetch} = {
      tournament_round_pair => {
        tournament_pair => [qw(  ), {
          person_season_person1_season_person1_team => [qw( person )],
          person_season_person2_season_person2_team => [qw( person )],
        }],
      }
    };
  }
  
  return $self->search_related($member_rel);
}

=head2 can_edit_fixtures_settings

Return 1 if we can change the fixtures settings (that is the fixtures grid, or lack thereof - lack of a fixtures grid means you have to set fixtures manually).  Return 0 otherwise; return undef if this isn't a group round, as that's not relevant.

=cut

sub can_edit_fixtures_settings {
  my $self = shift;
  
  # This needs changing once the relationships are in place to check if matches have been created
  if ( $self->group_round ) {
    # If we have team matches (or individual matches when they're added), we can't edit fixtures settings
    my $team_matches = $self->search_related("team_matches")->count;
    return $team_matches ? 0 : 1;
  } else {
    return undef;
  }
}

=head2 can_edit_members

Return 1 if we can change the members of the group.  Return 0 otherwise; return undef if this isn't a group round, as that's not relevant.

=cut

sub can_edit_members {
  my $self = shift;
  
  # This needs changing once the relationships are in place to check if matches have been created
  if ( $self->group_round ) {
    # If we have team matches (or individual matches when they're added), we can't edit members
    my $team_matches = $self->search_related("team_matches")->count;
    return $team_matches ? 0 : 1;
  } else {
    return undef;
  }
}

=head2 can_edit_auto_qualifiers

Return 1 if we can change the number of automatic qualifiers of the group.  Return 0 otherwise; return undef if this isn't a group round, as that's not relevant.

=cut

sub can_edit_auto_qualifiers {
  my $self = shift;
  
  # This needs changing once the relationships are in place to check if matches have been created
  if ( $self->group_round ) {
    # If we have no incomplete team matches (or individual matches when they're added), we can't edit members - we can have matches, but we must have some incomplete
    my $incomplete_matches = $self->search_related("team_matches", {
      complete => 0
    })->count;
    
    return $incomplete_matches ? 1 : 0;
  } else {
    return undef;
  }
}

=head2 can_set_grid_positions

Return 1 if the grid positions can be set (or re-set), or 0 if they're can't because matches already exist, or there are no members yet, there's no grid for this group or the season is complete.

=cut

sub can_set_grid_positions {
  my $self = shift;
  
  my $season = $self->tournament_round->tournament->event_season->season;
  
  # First and foremost, can't set grid positions if the season is complete
  return 0 if $season->complete;
  
  # Can't set fixtures if there's no grid
  return 0 unless defined($self->fixtures_grid);
  
  # Get the entrants (we don't care which type, they all have a grid_position field)
  my $entrants = $self->members;
  
  # Return 0 if there are no entrants
  return 0 unless $entrants->count;
  
  # We can set the positions if we get this far, so long as there are no matches already for this group.
  return 1 unless $self->matches->count;
}

=head2 can_create_fixtures

Return 1 if fixtures can be created (either the grid positions are set, or there is no grid and fixtures are manually set, and there are no matches for this round already).

=cut

sub can_create_fixtures {
  my $self = shift;
  
  if ( defined($self->fixtures_grid) ) {
    # If there's a fixtures grid set, first check if we have the grid positions set already
    return 0 unless $self->grid_positions_set;
  }
  
  # Now check if we have matches
  # If we have matches, we can't create more; if we don't, we can
  return $self->matches->count ? 0 : 1;
}

=head2 can_delete_fixtures

Return 1 if fixtures can be created (either the grid positions are set, or there is no grid and fixtures are manually set, and there are no matches for this round already).

=cut

sub can_delete_fixtures {
  my $self = shift;
  
  my $matches = $self->matches;
  
  # Can't delete matches that don't exist
  return 0 unless $matches->count;
  
  # Now check if we have matches
  # If we have matches that have been started, cancelled or completed, we can't delete them; if we don't, we can
  return $self->matches->search([{complete => 1}, {started => 1}, {cancelled => 1}]) ? 0 : 1;
}

=head2 get_entrants_in_table_order

Retrieve entrants in the order they'll be placed in the table.

=cut

sub get_entrants_in_table_order {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  # Setup the initial sort attribs
  my %attrib = (
    order_by => [{
      -desc => [qw( me.games_won me.matches_won me.matches_drawn me.matches_played )],
    }, {
      -asc  => [qw( me.games_lost me.matches_lost )],
    }, {
      -desc => [qw( me.games_won )],
    }]
  );
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_group_teams";
    $attrib{prefetch} = {
      tournament_round_team => {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
      }
    };
    push(@{$attrib{order_by}}, {-asc => [qw( club.short_name team.name )]});
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 get_entrants_in_grid_position_order



=cut

sub get_entrants_in_grid_position_order {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  # Setup the initial sort attribs
  my %attrib = (
    order_by => {
      -asc => [qw( me.grid_position )],
    }
  );
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_group_teams";
    $attrib{prefetch} = {
      tournament_round_team => {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
      }
    };
    push(@{$attrib{order_by}{-asc}}, qw( club.short_name team.name ));
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 get_tables_last_updated_timestamp

Return the last updated date / time.

=cut

sub get_tables_last_updated_timestamp {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_group_teams";
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
  }
  
  my $last_updated_entrant = $self->search_related($member_rel, {}, {
    rows => 1,
    order_by => {-desc => "last_updated"}
  })->single;
  
  return $last_updated_entrant->last_updated if defined($last_updated_entrant);
}

=head2 grid_positions_set

Return 1 if the grid positions are set, or 0 if they're not.  Return undef if there's no grid for this group.

=cut

sub grid_positions_set {
  my $self = shift;
  
  # Undef if there's no fixtures gricd
  return undef unless defined($self->fixtures_grid);
  
  # Get the entrants (we don't care which type, they all have a grid_position field)
  my $entrants = $self->members;
  
  # Return 0 if there are no entrants
  return 0 unless $entrants->count;
  
  if ( $entrants->search({grid_position => undef})->count ) {
    # There are entrants without grid positions set, can't set
    return 0;
  } else {
    # There are entrants (and due to the previous search, they must have a grid position set), so all grid positions are set
    return 1;
  }
}

=head2 set_grid_positions

Set the teams to their grid numbers for the current season.

=cut

sub set_grid_positions {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $grid_positions = $params->{grid_positions};
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
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    # No current season, fatal error
    push(@{$response->{errors}}, $lang->maketext("events.edit.error.no-current-season"));
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Error if matches set already
  push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.teams.error.matches-already-set")) if $self->matches->count;
  
  # This hash will hold divisions and their teams and their positions as well as
  # some other name data so that we can use it in error messages.
  #  - Key: ID of submitted entrant (this will be a team ID, person ID or doubles ID - doubles IDs link to the tournament_group_doubles table)
  #  - Value: {name, position} - stored as a hash with those keys
  my %submitted_entrants = ();
  
  # This will hold the values we've seen for each division so we can make sure we've not seen any position more than once
  #  - Key: Position number
  #  - Value: [names] stored as an array of entrant names with that position (in theory each array should have one element, but that's what we'll check at the end)
  my %used_values = ();
  
  # The error message to build up
  my $error;
  
  # Store the name for purposes of error messages
  # Get the submitted value for this division
  $grid_positions = [$grid_positions] unless ref($grid_positions) eq "ARRAY";
  
  # Grab the entry type
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  # Loop through the team IDs; make sure each team belongs to this division and is only itemised once and that no teams are missing.
  my $position = 1;
  foreach my $id ( @{$grid_positions} ) {
    if ( $id ) {
      # If we have an ID, make sure it's in the resultset for this division
      my ( $entrant, $name );
      
      if ( $entry_type eq "team" ) {
        $entrant = $self->find_related("tournament_group_teams", {
          "tournament_team.team" => $id,
          "tournament_team.season" => $season->id,
        }, {
          prefetch => {
            tournament_round_team => {
              tournament_team => {
                team_season => [qw( team ), {
                  club_season => [qw( club )],
                }]
              }
            }
          }
        });
      } elsif ( $entry_type eq "singles" ) {
        $entrant = $self->find_related("tournament_group_people", {
          "tournament_person.team" => $id,
        }, {
          prefetch => {
            tournament_round_person => {
              tournament_person => {person_season => qw( person )}
            }
          }
        });
      } elsif ( $entry_type eq "doubles" ) {
        $entrant = $self->find_related("tournament_group_doubles", {
          "tournament_pair.team" => $id,
          "tournament_pair.season" => $season->id,
        }, {
          prefetch => {
            tournament_round_pair => {
              tournament_pair => [qw( season_pair ), {
                person_season_person1_season_person1_team => [qw( person )],
                person_season_person2_season_person2_team => [qw( person )],
              }],
            }
          }
        });
      }
      
      if ( defined($entrant) ) {
        $submitted_entrants{$id} = {
          name => $entrant->object_name,
          position => $position,
        };
        
        if ( defined($used_values{$position}) ) {
          # Already exists, push it on to the arrayref
          push(@{$used_values{$position}}, $name);
        } else {
          # Doesn't exist, create a new arrayref
          $used_values{$position} = [$name];
        }
      } else {
        push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.teams.error.wrong-team-id", $id));
      }
    } else {
      # No ID, push undefined values for the bye
      $submitted_entrants{0} = {
        id => 0,
        name => "[Bye]",
        position => $position,
      };
    }
    
    $position++;
  }
  
  # After we loop through the IDs, make sure we have each team in there
  my $entrants_required = $self->members;
  while ( my $entrant_required = $entrants_required->next ) {
    push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.error.no-position-for-entrant", encode_entities($entrant_required->object_name))) unless exists($submitted_entrants{$entrant_required->object_id});
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $position ( keys(%used_values) ) {
    push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.teams.error.position-used-more-than-once", $position, join(", ", @{$used_values{$position}}))) if scalar(@{$used_values{$position}}) > 1;
  }
  
  $response->{fields} = \%submitted_entrants;
  
  # Check for errors
  if ( scalar @{$response->{errors}} == 0 ) {
    # Finally we need to loop through again updating the home / away teams for each match
    foreach my $id ( keys %submitted_entrants ) {
      # Get the member DB object, then the team seasons object
      my ( %find, %attrib );
      if ( $entry_type eq "team" ) {
        %find = ("team.id" => $id);
        %attrib = (
          join => {
            tournament_round_team => {
              tournament_team => {team_season => [qw( team )]
            }
          }
        });
      } elsif ( $entry_type eq "singles" ) {
        %find = ("person.id" => $id);
        %attrib = (
          join => {
            tournament_round_person => {
              tournament_person => {person_season => [qw( person )]
            }
          }
        });
      } elsif ( $entry_type eq "doubles" ) {
        %find = ("tournament_pair.id" => $id);
        %attrib = (
          join => {
            tournament_round_pair => [qw( tournament_pair )],
          }
        );
      }
      
      $entrants_required->find(\%find, \%attrib)->update({
        grid_position => $submitted_entrants{$id}{position},
      }) if $id;
    }
    
    push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.form.teams.success"));
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 matches

Return the matches associated with this round.

=cut

sub matches {
  my $self = shift;
  my ( $member_rel );
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $member_rel = "team_matches";
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
  }
  
  return $self->search_related($member_rel);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
