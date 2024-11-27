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

=head2 system_event_log_event_groups

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogEventGroup>

=cut

__PACKAGE__->has_many(
  "system_event_log_event_groups",
  "TopTable::Schema::Result::SystemEventLogEventGroup",
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

=head2 tournament_round_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundPerson>

=cut

__PACKAGE__->has_many(
  "tournament_round_people",
  "TopTable::Schema::Result::TournamentRoundPerson",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundTeam>

=cut

__PACKAGE__->has_many(
  "tournament_round_teams",
  "TopTable::Schema::Result::TournamentRoundTeam",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_rounds_doubles",
  "TopTable::Schema::Result::TournamentRoundDoubles",
  { "foreign.tournament_group" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-24 00:42:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f3Y7X3BX6baj2K8BGo54Tg

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
    $member_rel = "tournament_round_teams";
    $attrib{prefetch} = {
      tournament_team => {
        team_season => [qw( team )]
      }
    };
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
    $attrib{prefetch} = {
      tournament_person => {
        person_season => [qw( person )]
      }
    };
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
    $attrib{prefetch} = {
      tournament_pair => [qw(  ), {
        person_season_person1_season_person1_team => [qw( person )],
        person_season_person2_season_person2_team => [qw( person )],
      }],
    };
  }
  
  return $self->search_related($member_rel);
}

=head2 can_edit_fixtures_settings

Return 1 if we can change the fixtures settings (that is the fixtures grid, or lack thereof - lack of a fixtures grid means you have to set fixtures manually).  Return 0 otherwise; return undef if this isn't a group round, as that's not relevant.

=cut

sub can_edit_fixtures_settings {
  my $self = shift;
  
  # If we have team matches (or individual matches when they're added), we can't edit fixtures settings
  my $team_matches = $self->search_related("team_matches")->count;
  return $team_matches ? 0 : 1;
}

=head2 can_edit_members

Return 1 if we can change the members of the group.  Return 0 otherwise.

=cut

sub can_edit_members {
  my $self = shift;
  
  # If we have team matches (or individual matches when they're added), we can't edit members
  my $team_matches = $self->search_related("team_matches")->count;
  return $team_matches ? 0 : 1;
}

=head2 can_edit_auto_qualifiers

Return 1 if we can change the number of automatic qualifiers of the group.  Return 0 otherwise.

=cut

sub can_edit_auto_qualifiers {
  my $self = shift;
  
  # This needs changing once the relationships are in place to check if matches have been created
  # If we have no incomplete team matches (or individual matches when they're added), we can't edit members - we can have matches, but we must have some incomplete
  my $matches = $self->search_related("team_matches");
  
  if ( $matches->count ) {
    my $incomplete_matches = $matches->search({
      complete => 0,
    });
    
    return $incomplete_matches ? 1 : 0;
  } else {
    # No matches, we can edit
    return 1;
  }
}

=head2 has_fixtures_grid

Return 1 if we have a fixtures grid assigned, or 0 if not (manual fixtures creation).

=cut

sub has_fixtures_grid {
  my $self = shift;
  return defined($self->fixtures_grid) ? 1 : 0;
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
  return 0 unless $self->has_fixtures_grid;
  
  # Get the entrants (we don't care which type, they all have a grid_position field)
  my $entrants = $self->members;
  
  # Return 0 if there are no entrants
  return 0 unless $entrants->count;
  
  # We can set the positions if we get this far, so long as there are no matches already for this group.
  return 1 unless $self->matches->count;
}

=head2 can_create_matches

Return 1 if fixtures can be created (either the grid positions are set, or there is no grid and fixtures are manually set, and there are no matches for this round already).

=cut

sub can_create_matches {
  my $self = shift;
  
  if ( defined($self->fixtures_grid) ) {
    # If there's a fixtures grid set, first check if we have the grid positions set already
    return 0 unless $self->grid_positions_set;
  }
  
  # Check the season this group is in is current
  my $season = $self->tournament_round->tournament->event_season->season;
  return 0 if $season->complete;
  
  # Now check if we have matches
  # If we have matches, we can't create more; if we don't, we can
  return $self->matches->count ? 0 : 1;
}

=head2 can_delete

Check if a group can be deleted.  It can only be deleted if it's in the current season and there are no matches attached to it.

=cut

sub can_delete {
  my $self = shift;
  my $season = $self->tournament_round->tournament->event_season->season;
  
  # Can't delete if the season is complete
  return 0 if $season->complete;
  
  # Can delete if we have matches, otherwise we can't.
  return $self->matches->count ? 0 : 1;
}

=head2 check_and_delete

Process the deletion of the group; checks that we're able to do this first (via can_delete).

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
  my $name = $self->name;
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Delete teams in the group, and then the group
  # Tournament teams will cascade deletion from tournament round teams
  my ( $round_member_rel, $tourn_member_rs );
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $round_member_rel = "tournament_round_teams";
    $tourn_member_rs = "TournamentTeam";
  } elsif ( $entry_type eq "singles" ) {
    $round_member_rel = "tournament_round_people";
    $tourn_member_rs = "TournamentPerson";
  } elsif ( $entry_type eq "doubles" ) {
    $round_member_rel = "tournament_rounds_doubles";
    $tourn_member_rs = "TournamentDoubles";
  }
  
  $schema->resultset($tourn_member_rs)->search({
    "tournament_group.id" => $self->id,
  }, {
    join => {
      $round_member_rel => [qw( tournament_group )]
    }
  })->delete;
  
  my $ok = $self->delete;
  
  # Recalculate the order of the remaining groups
  $self->tournament_round->recalculate_groups_order;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

=head2 can_delete_matches

Return 1 if fixtures can be created (either the grid positions are set, or there is no grid and fixtures are manually set, and there are no matches for this round already).

=cut

sub can_delete_matches {
  my $self = shift;
  
  my $matches = $self->matches;
  
  # Can't delete matches that don't exist
  return 0 unless $matches->count;
  
  # Now check if we have matches
  # If we have matches that have been started, cancelled or completed, we can't delete them; if we don't, we can
  return $self->matches->search([{complete => 1}, {started => 1}, {cancelled => 1}])->count ? 0 : 1;
}

=head2 match_rounds

Return the number of match rounds - this is essentially the number of entrants in the group (rounded UP to the nearest even number), minus 1

=cut

sub match_rounds {
  my $self = shift;
  my $entrants = $self->get_entrants->count;
  
  if ( $entrants ) {
    if ( $entrants % 2 ) {
      # Remainder 1 (true) - odd number - the number of rounds is the number of entrants - this is
      # because one team will have a bye each round
      return $entrants;
    } else {
      # Remainder 0 (false) - even number 0 the number of rounds is the number of entrants minus 1.
      return $entrants - 1;
    }
  } else {
    # No entrants
    return undef;
  }
}

=head2 matches_per_round

Return the number of matches per round of matches - this is essentially the number of entrants in the group (rounded DOWN to the nearest even number), divided by 2.

=cut

sub matches_per_round {
  my $self = shift;
  my $entrants = $self->get_entrants->count;
  
  if ( $entrants ) {
    # Remainder 1 (true) - odd number - the number of rounds is the number of entrants - this is
    # because one team will have a bye each round, so essentially the teams active per round is reduced
    $entrants-- if $entrants % 2;
    
    # Return the number of entrants we now have divided by 2 (takes 2 to make one match)
    return $entrants / 2;
  } else {
    # No entrants
    return undef;
  }
}

=head2 get_entrants

Retrieve entrants, in alphabetical order.

=cut

sub get_entrants {
  my $self = shift;
  my ( $member_rel, %attrib );
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
    %attrib = (
      prefetch => {
        tournament_team => {
          team_season => [qw( club_season )],
        },
      },
      order_by => {
        -asc => [qw( club_season.short_name team_season.name )],
      }
    );
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 get_entrants_in_table_order

Retrieve entrants in the order they'll be placed in the table.

=cut

sub get_entrants_in_table_order {
  my $self = shift;
  my $member_rel;
  my $tourn_round = $self->tournament_round;
  my $entry_type = $tourn_round->tournament->entry_type->id;
  my $rank_template = $tourn_round->rank_template;
  my $match_template = $tourn_round->match_template;
  
  # Setup the initial sort attribs
  my %attrib;
  
  if ( $entry_type eq "team" ) {
    my $winner_type = $match_template->winner_type->id;
    
    if ( $rank_template->assign_points ) {
      if ( $winner_type eq "games" ) {
        %attrib = (
          order_by => [{
            -desc => [qw( me.table_points me.games_won me.matches_won me.matches_drawn me.matches_played )],
          }, {
            -asc  => [qw( me.games_lost me.matches_lost )],
          }, {
            -desc => [qw( me.games_won )],
          }, {
            -asc => [qw( club_season.short_name team_season.name )]
          }]
        );
      } else {
        %attrib = (
          order_by => [{
            -desc => [qw( me.table_points me.points_difference me.points_won me.matches_played )],
          }, {
            -asc  => [qw( me.points_lost me.matches_lost club_season.short_name team_season.name )],
          }]
        );
      }
    } else {
      if ( $winner_type eq "games" ) {
        %attrib = (
          order_by => [{
            -desc => [qw( me.games_won me.matches_won me.matches_drawn me.matches_played )],
          }, {
            -asc  => [qw( me.games_lost me.matches_lost )],
          }, {
            -desc => [qw( me.games_won )],
          }, {
            -asc => [qw( club_season.short_name team_season.name )]
          }]
        );
      } else {
        %attrib = (
          order_by => [{
            -desc => [qw( me.points_difference me.points_won me.matches_played )],
          }, {
            -asc  => [qw( me.points_lost me.matches_lost club_season.short_name team_season.name )],
          }]
        );
      }
    }
    
    $member_rel = "tournament_round_teams";
    $attrib{prefetch} = {
      tournament_team => {
        team_season => [qw( team ), {
          club_season => [qw( club )],
        }]
      }
    };
    
    push(@{$attrib{order_by}}, {-asc => [qw( club.short_name team.name )]});
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 get_entrants_in_grid_position_order

Return the group entrants in order of grid position.

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
    $member_rel = "tournament_round_teams";
    $attrib{prefetch} = {
      tournament_team => {
        team_season => [qw( team ), {
          club_season => [qw( club )],
        }]
      }
    };
    push(@{$attrib{order_by}{-asc}}, qw( club.short_name team.name ));
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 has_entrant

Return true if the group has the given entrant (passed as a DB object - team, person or pair of people for doubles).

=cut

sub has_entrant {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  # Take two parameters, as we'll need the second one if we search for a doubles pairing
  my ( $potential1, $potential2 ) = @_;
  
  my %where = ();
  my %attrib = ();
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
    $where{"team.id"} = $potential1->id;
    $attrib{join} = {
      tournament_team => {
        team_season => [qw( team )]
      }
    };
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_rounds_doubles";
  }
  
  return $self->search_related($member_rel, \%where, \%attrib)->count;
}

=head2 get_tables_last_updated_timestamp

Return the last updated date / time.

=cut

sub get_tables_last_updated_timestamp {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_rounds_doubles";
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
        $entrant = $self->find_related("tournament_round_teams", {
          "tournament_team.team" => $id,
          "tournament_team.season" => $season->id,
        }, {
          prefetch => {
            tournament_team => {
              team_season => [qw( team ), {
                club_season => [qw( club )],
              }]
            }
          }
        });
      } elsif ( $entry_type eq "singles" ) {
        $entrant = $self->find_related("tournament_round_people", {
          "tournament_person.team" => $id,
        }, {
          prefetch => {
            tournament_person => {person_season => qw( person )},
          }
        });
      } elsif ( $entry_type eq "doubles" ) {
        $entrant = $self->find_related("tournament_round_doubles", {
          "tournament_pair.team" => $id,
          "tournament_pair.season" => $season->id,
        }, {
          prefetch => {
            tournament_pair => [qw( season_pair ), {
              person_season_person1_season_person1_team => [qw( person )],
              person_season_person2_season_person2_team => [qw( person )],
            }],
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
            tournament_team => {team_season => [qw( team )],
          }
        });
      } elsif ( $entry_type eq "singles" ) {
        %find = ("person.id" => $id);
        %attrib = (
          join => {
            tournament_person => {person_season => [qw( person )]
          }
        });
      } elsif ( $entry_type eq "doubles" ) {
        %find = ("tournament_pair.id" => $id);
        %attrib = (
          tournament_round_pair => [qw( tournament_pair )],
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

=head2 create_matches

Create the matches for this group.  How we do this depends on whether the group has a grid assigned or not.

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
  
  my $grid = $self->fixtures_grid;
  my $tourn_round = $self->tournament_round;
  my $tournament = $tourn_round->tournament;
  my $entry_type = $tourn_round->tournament->entry_type->id;
  my $match_template = $tourn_round->match_template;
  my $handicapped = $match_template->handicapped;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  my $season = $tournament->event_season->season;
  
  if ( !$self->can_create_matches ) {
    # Error, can't create fixtures
    my $msg;
    if ( $season->complete ) {
      $msg = $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.season-complete");
    } else {
      $msg = defined($self->fixtures_grid)
        ? $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.grid-positions-not-set")
        : $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.matches-already-exist");
      
    }
    
    push(@{$response->{errors}}, $msg);
    return $response;
  }
  
  if ( defined($grid) ) {
    # Create matches via the grid
    $response = $grid->create_matches($self, $params);
  } else {
    # Do the manual match creation
    
    # Hash structure:
    # $rounds{$roundnum}{round_date}{week_beginnind_id, week_beginning_date} = season week (team entry only)
    # $rounds{$roundnum}{matches}{$matchnum} = {
    #   home => (id),
    #   away team => (id),
    #   venue => (id), (null if using default),
    #   day (id), (null if using default),
    #   handicap => {headstart, awarded_to}
    #}
    my %rounds = ();
    my $raw_round_data = $params->{rounds};
    foreach my $key ( keys %{$raw_round_data} ) {
      if ( $key =~ /^round_(\d{1,2})_week$/ ) {
        # Just the week setting, not related to the match
        $rounds{$1}{round_date}{week_beginning_id} = $raw_round_data->{$key};
      } elsif ( $key =~ /^round_(\d{1,2})_match_(\d{1,2})_(home|away|venue|day|handicap_award|handicap)$/ ) {
        if ( $3 eq "handicap" ) {
          $rounds{$1}{matches}{$2}{handicap}{headstart} = $raw_round_data->{$key};
        } elsif ( $3 eq "handicap_award" ) {
          $rounds{$1}{matches}{$2}{handicap}{awarded_to} = $raw_round_data->{$key};
        } else {
          $rounds{$1}{matches}{$2}{$3} = $raw_round_data->{$key} || undef;
        }
      }
    }
    
    # Master copy of the entrants - so we only have to get them from the DB once, then read them into a hash.
    my @entrants_master = $self->get_entrants;
    my %entrants_master;
    $entrants_master{$_->object_id} = $_->object_name foreach @entrants_master;
    
    my $last_week;
    # Loop through all the rounds we *should* have and check them
    foreach my $round ( 1 .. $self->match_rounds ) {
      if ( $entry_type eq "team" ) {
        # If it's team entry, we need a season week to set these matches in
        if ( my $week_id = $rounds{$round}{round_date}{week_beginning_id} ) {
          my $week = $season->find_related("fixtures_weeks", {id => $week_id});
          
          if ( defined($week) ) {
            $rounds{$round}{round_date}{week_beginning_date} = $week->week_beginning_date;
            
            # The week is valid; ensure it doesn't occur prior to the last one.
            push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.date-occurs-before-previous-date", $round))
                if defined($last_week) and $week->week_beginning_date->ymd("") <= $last_week->week_beginning_date->ymd("");
            
            # Set the last season week so that we can check the next one occurs at a later date on the next iteration.
            $last_week = $week;
          } else {
            # Error, season week not found
            push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.week-invalid", $round));
          }
          
          $rounds{$round}{week} = $week;
        } else {
          # Error, season week not specified.
          push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.round-blank", $round));
        }
      }
      
      # Now loop through the matches and check all the data given
      # %used_entrants will hold entrants as we use them, with a count so we can check nothing is used more tha once in a given round
      # %entrants_to_use will hold all the entrants at the start, deleting as we use, so we can check at the end that there are none left
      # (there will be one left if we have an odd number of entrants, this is fine)
      my %used_entrants = ();
      my %entrants_to_use = %entrants_master;
      foreach my $match ( 1 .. $self->matches_per_round ) {
        my $home = $rounds{$round}{matches}{$match}{home};
        my $away = $rounds{$round}{matches}{$match}{away};
        my $venue = $rounds{$round}{matches}{$match}{venue} || undef;
        my $day = $rounds{$round}{matches}{$match}{day} || undef;
        my $handicap_start = $rounds{$round}{matches}{$match}{handicap}{headstart};
        my $handicap_awarded_to = $rounds{$round}{matches}{$match}{handicap}{awarded_to};
        
        # Hash to check the home / away competitors, so we can loop through
        my %check_competitors = (home => $home, away => $away);
        
        # Do any lookups we need to - we can pass in objects or IDs (URL keys too if it's not a team - teams also need club URL keys, and there's no way to pass in both)
        # Reverse key sort so we do home before away
        foreach my $home_away ( reverse sort keys %check_competitors ) {
          my $competitor = $check_competitors{$home_away};
          if ( defined($competitor) ) {
            # Look up the competitor from the relevant class
            my ( $comp_class, $object_name );
            if ( $entry_type eq "team" ) {
              $comp_class = "Team";
              $object_name = "full_name";
            } else {
              # Singles and doubles check the person class, just we check it twice for doubles
              $comp_class = "Person";
              $object_name = "display_name";
            }
            
            $competitor = $schema->resultset($comp_class)->find($competitor) unless $competitor->isa("TopTable::Schema::Result::$comp_class");
            
            if ( defined($competitor) ) {
              # Home team is valid, but check it's in the group
              if ( $self->has_entrant($competitor) ) {
                # Valid, set into the %used_entrants hash and delete from entrants to use
                if ( exists($used_entrants{$competitor->id}) ) {
                  # Seen already, increase the count
                  $used_entrants{$competitor->id}{count}++;
                } else {
                  # Not already seen, add into the hash
                  $used_entrants{$competitor->id} = {count => 1, name => $entrants_to_use{$competitor->id}};
                }
                
                delete $entrants_to_use{$competitor->id};
              } else {
                # Error, team not in the group
                if ( $entry_type eq "team" ) {
                  $object_name = $competitor->full_name;
                } elsif ( $entry_type eq "singles" ) {
                  $object_name = $competitor->display_name;
                } else {
                  # Doubles
                  #$object_name = 
                }
                
                push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-not-in-group", encode_entities($object_name), $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
              }
            } else {
              # Home team is invalid
              push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-invalid", $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
            }
          } else {
            # Error, home team not passed in
            push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-blank", $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
          }
          
          # Set the value we looked up (even if undef) back into the hash
          $rounds{$round}{matches}{$match}{$home_away} = $competitor;
        }
        
        # If either the venue or the day are undefined, we need to grab the home night / venue from the team's season settings
        # Make sure $home now refers to the team object we looked up
        $home = $rounds{$round}{matches}{$match}{home};
        my $home_season;
        $home_season = $home->get_season($season) if defined($home) and (!defined($venue) or !defined($day));
        
        if ( defined($venue) ) {
          # Venue passed in, so we will override
          $venue = $schema->resultset("Venue")->find($venue) unless $venue->isa("TopTable::Schema::Result::Venue");
          
          if ( defined($venue) ) {
            if ( $venue->active ) {
              $rounds{$round}{matches}{$match}{venue} = $venue;
            } else {
              push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.venue-inactive", encode_entities($venue->name), $round, $match));
            }
          } else {
            # Venue is now not defined after lookup, so can't have been valid
            push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.venue-invalid", $round, $match));
          }
        } else {
          # Venue not passed in - get it from the round settings if there's one there, or the team's home venue if not
          if ( defined($tourn_round->venue) ) {
            $rounds{$round}{matches}{$match}{venue} = $tourn_round->venue;
          } elsif ( defined($home_season) ) {
            $rounds{$round}{matches}{$match}{venue} = $home_season->club_season->venue;
          }
        }
        
        my $scheduled_date;
        my $week_date = $rounds{$round}{round_date}{week_beginning_date};
        if ( defined($day) ) {
          # Day passed in, so we will override
          $day = $schema->resultset("LookupWeekday")->find($day) unless $day->isa("TopTable::Schema::Result::LookupWeekday");
          
          # Day is now not defined after lookup, so can't have been valid
          if ( defined($day) ) {
            # Set the date to be a DateTime object based on the day selected
            $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_date, $day->weekday_number);
            $rounds{$round}{matches}{$match}{day} = $day;
          } else {
            push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.day-invalid", $round, $match));
          }
        } else {
          # Otherwise use the home team's night
          $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_date, $home_season->home_night->weekday_number) if defined($home_season);
        }
        
        $rounds{$round}{matches}{$match}{date} = $scheduled_date;
        
        # Check handicaps - first check if this is a handicapped event
        if ( defined($handicap_awarded_to) ) {
          # Handicap is defined
          if ( $handicapped ) {
            if ( $handicap_awarded_to eq "home" or $handicap_awarded_to eq "away" ) {
              if ( defined($handicap_start) ) {
                # Check there's a positive numeric value (not 0) in the handicap
                push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-invalid", $round, $match)) unless $handicap_start =~ /^[1-9]\d{0,2}$/;
              } else {
                # Error, no handicap set
                push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-not-set", $round, $match));
              }
            } elsif ( $handicap_awarded_to eq "set_later" or $handicap_awarded_to eq "scratch" ) {
              # Nothing to do here
            } else {
              # Error, invalid handicap option
              push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.invalid-handicap-option", $round, $match));
            }
          } else {
            # Handicap passed in, but the event isn't handicapped - this is just info, we can just not set the handicaps
            push(@{$response->{info}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-set-needlessly", $round, $match));
          }
        } else {
          # Handicap not defined - error 
          push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-option-blank", $round, $match)) if $handicapped;
        }
      }
      
      # Check nothing has been used more than once, and nothing has been left unused
      foreach my $entrant_used ( keys %used_entrants ) {
        push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrant-used-too-many-times", $round, $used_entrants{$entrant_used}{name}, $used_entrants{$entrant_used}{count})) if $used_entrants{$entrant_used}{count} > 1;
      }
      
      # Check nothing is left behind - slightly complicated by the fact we can have a bye round if there's an odd number ( % 2 gives a true value, because there is a remainder)
      my $bye_allowed = scalar @entrants_master % 2 ? 1 : 0;
      my $unused_count = scalar keys %entrants_to_use;
      if ( $bye_allowed ) {
        push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrants-unused-with-bye", $round)) if $unused_count > 1;
      } else {
        push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrants-unused", $round)) if $unused_count;
      }
    }
    
    $response->{fields}{rounds} = \%rounds;
    
    if ( @{$response->{errors}} == 0 ) {
      # No errors, build the match data
      my ( @match_games, @match_legs, @template_games );
      if ( $entry_type eq "team" ) {
        # If it's team entry, we have a team match template, which will have games - we need to build an array of games
        # so that we can just use that, rather than referring back to the DB each time.  Do this outside the loop here
        # because it's the same for each game being created
        my $template_games = $match_template->template_match_team_games;
        while ( my $game = $template_games->next ) {
          push(@template_games, {
            singles_home_player_number => $game->singles_home_player_number,
            singles_away_player_number => $game->singles_away_player_number,
            doubles_game => $game->doubles_game,
            match_template => $game->individual_match_template,
            match_game_number => $game->match_game_number,
            legs_per_game => $game->individual_match_template->legs_per_game,
          });
        }
      }
      
      # This will be the data used to populate the matches
      my ( $matches, @matches, @match_ids, @match_names );
      foreach my $round ( 1 .. $self->match_rounds ) {
        my $scheduled_week = $rounds{$round}{round_date}{week_beginning_id};
        my $week_beginning_date = $rounds{$round}{round_date}{week_beginning_date};
        
        # Loop through the matches
        foreach my $match ( 1 .. $self->matches_per_round ) {
          my $home = $rounds{$round}{matches}{$match}{home};
          my $away = $rounds{$round}{matches}{$match}{away};
          my $venue = $rounds{$round}{matches}{$match}{venue};
          my $handicap_start = $rounds{$round}{matches}{$match}{handicap}{headstart};
          my $handicap_awarded_to = $rounds{$round}{matches}{$match}{handicap}{awarded_to};
          my $scheduled_date = $rounds{$round}{matches}{$match}{date};
          my ( $start_time, %match_data );
          
          if ( $entry_type eq "team" ) {
            $start_time = $home->default_match_start // $home->club->default_match_start // $season->default_match_start;
            
            # Team match template, populate an array of games
            
            
            # Empty arrayref for the games - these will be populated in the next loop
            my @match_games = ();
            
            # Set up the league team match games / legs
            foreach my $game_template ( @template_games ) {
              # Loop through creating legs for each game
              # Empty arrayref for the legs - this will be populated on the next loop
              my @match_legs = ();
              foreach my $i ( 1 .. $game_template->{legs_per_game} ) {
                push(@match_legs, {
                  home_team => $home->id,
                  away_team => $away->id,
                  scheduled_date => $scheduled_date->ymd,
                  scheduled_game_number => $game_template->{match_game_number},
                  leg_number => $i,
                });
              }
              
              # What we populate will be different, depending on whether it's a doubles game or not
              my %game = (
                home_team => $home->id,
                away_team => $away->id,
                scheduled_date => $scheduled_date->ymd,
                scheduled_game_number => $game_template->{match_game_number},
                actual_game_number => $game_template->{match_game_number},
                individual_match_template => $game_template->{match_template}->id,
                doubles_game => $game_template->{doubles_game},
                team_match_legs => \@match_legs,
              );
              
              # Add player numbers for a doubles game
              if ( !$game_template->{doubles_game} ) {
                $game{home_player_number} = $game_template->{singles_home_player_number};
                $game{away_player_number} = $game_template->{singles_away_player_number};
              }
              
              push(@match_games, \%game);
            }
            
            # Now loop through and build the players.  We loop through twice for the number of players per team,
            # so that we do it for both teams
            # Empty arrayref to start off with
            my @match_players = ();
            foreach my $i ( 1 .. ( $match_template->singles_players_per_team * 2 ) ) {
              # Is it home or away?  If our loop counter is greater than the number of players in a team, we must have moved on to the away team
              my $location = $i > $match_template->singles_players_per_team ? "away" : "home";
              
              push(@match_players, {
                home_team => $home->id,
                away_team => $away->id,
                player_number => $i,
                location => $location,
              });
            }
            
            # Push on to the array that will populate the DB
            my %match = (
              home_team => $home->id,
              away_team => $away->id,
              scheduled_date => $scheduled_date->ymd,
              played_date => $scheduled_date->ymd,
              scheduled_start_time => $start_time,
              season => $season->id,
              division => undef,
              tournament_round => $tourn_round->id,
              tournament_group => $self->id,
              venue => $venue->id,
              scheduled_week => $scheduled_week,
              team_match_template => $match_template->id,
              team_match_games => \@match_games,
              team_match_players => \@match_players,
            );
            
            if ( $handicapped ) {
              # The only other option here is set later, in which case we leave the handicap fields alone and they get set to null
              if ( $handicap_awarded_to eq "home" ) {
                # Home get the head start, set home handicap to the handicap we want and away to 0
                $match{home_team_handicap} = $handicap_start;
                $match{away_team_handicap} = 0;
              } elsif ( $handicap_awarded_to eq "away" ) {
                # Away get the head start, set away handicap to the handicap we want and home to 0
                $match{home_team_handicap} = 0;
                $match{away_team_handicap} = $handicap_start;
              } elsif ( $handicap_awarded_to eq "scratch" ) {
                # Scratch, no one gets a head start, set both handicap fields to 0
                $match{home_team_handicap} = 0;
                $match{away_team_handicap} = 0;
              }
            }
            
            push(@matches, \%match);
            
            # Increase the number of matches we are creating
            $matches++;
            
            # Push on to the IDs / names arrays that we'll use for the event log
            push(@match_ids, {
              home_team => $home->id,
              away_team => $away->id,
              scheduled_date => $scheduled_date->ymd,
            });
            
            push(@match_names, sprintf("%s, (%s - %s)", $lang->maketext("matches.name", $home->full_name, $away->full_name), $tournament->event_season->name, $scheduled_date->dmy("/")));
          } else {
            # Individual match template
            
          }
        }
      }
      
      if ( $entry_type eq "team" ) {
        $schema->resultset("TeamMatch")->populate(\@matches);
        $response->{completed} = 1;
        push(@{$response->{success}}, $lang->maketext("events.tournaments.create-fixtures.success", scalar(@match_ids), $self->name, $season->name));
        
        $response->{match_ids} = \@match_ids;
        $response->{match_names} = \@match_names;
        $response->{matches} = \@matches;
      }
    }
  }
  
  return $response;
}

=head2 delete_matches



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
    my @rows_to_delete = $self->matches;
    
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
      
      my $ok = $self->matches->delete;
      
      if ( $ok ) {
        # Deleted ok
        $response->{match_names} = \@match_names;
        $response->{match_ids} = \@match_ids;
        $response->{rows} = $ok;
        $response->{completed} = 1;
        push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.groups.delete-fixtures.success", $ok, $self->name));
      } else {
        # Not okay, log an error
        push(@{$response->{errors}}, $lang->maktext("events.tournaments.rounds.groups.error.delete-failed"));
      }
    } else {
      $response->{rows} = 0;
    }
  } else {
    push(@{$response->{errors}}, $lang->maketext("events.tournaments.rounds.groups.delete-fixtures.error.cant-delete", $self->name));
  }
  
  return $response;
}

=head2 matches

Return the matches associated with this round.

=cut

sub matches {
  my $self = shift;
  my ( $params ) = @_;
  my $no_prefetch = $params->{no_prefetch};
  my ( $member_rel, %attrib );
  my $entry_type = $self->tournament_round->tournament->entry_type->id;
  
  if ( $entry_type eq "team" ) {
    $member_rel = "team_matches";
    %attrib = (
      prefetch  => [qw( venue ), {
        team_season_home_team_season => [qw( team ), {club_season => "club"}],
      }, {
        team_season_away_team_season => [qw( team ), {club_season => "club"}],
      }],
      order_by => {
        -asc => [qw( played_date club_season.short_name team_season_home_team_season.name )]
      },
    ) unless $no_prefetch;
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_group_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_group_doubles";
  }
  
  return $self->search_related($member_rel, {}, \%attrib);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
