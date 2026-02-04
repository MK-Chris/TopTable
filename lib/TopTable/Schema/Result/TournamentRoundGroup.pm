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
  # Encoding has to be explicitly turned off; if it's not specified, it's on by default.
  my $encode = exists($params->{encode}) and !$params->{encode} ? 0 : 1;
  
  # Setup schema / lang
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $name;
  if ( defined($self->_name) ) {
    # If encoding is on, encode the name first.
    $name = $encode ? encode_entities($self->_name) : $self->_name;
  } else {
    # If encoding is OFF, we need to decode the name, as the language code is encoded already.
    $name = $encode ? $lang->maketext("tournament.round.group.default-name", $self->group_order) : decode_entities($lang->maketext("tournament.round.group.default-name", $self->group_order));
  }
  
  return $name;
}

=head2 entry_type

Shortcut to the tournament's entry type (team, singles, doubles).

=cut

sub entry_type {
  my $self = shift;
  return $self->tournament_round->tournament->entry_type->id;
}

=head2 members

Return the entrants, depending on the entry type - no ordering is performed on this, however there's a prefetch to get the season and the object (so those IDs can be accessed).

=cut

sub members {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->entry_type;
  my %attrib = ();
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
    $attrib{prefetch} = {
      prefetch => {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
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

=head2 can_update($type)

1 if we can update the round $type; 0 if not.

In list context, a hash will be returned with keys 'allowed' (1 or 0) and potentially 'reason' (if not allowed, to give the reason we can't update).  The reason can be passed back in the interface as an error message.

No permissions are checked here, this is purely to see if it's possible to update the round based on factors in the tournament.

$type tells us what we want to update and can be "matches", "members", "auto-qualifiers", or "delete-matches".  If not passed, we get a hash (or hashref in scalar context) of all types - scalar context just returns 1 or 0 for all of these, list context returns the hashref with allowed and reason keys.  If nothing can be updated for the same reason (i.e., the season is complete), the types will not be returned, and you'll get a 1 or 0 in scalar context, or 'allowed' and 'reason' keys in list context, just as if it had been called with a specific type.

Possible $type values:
"auto-qualifiers": checks if we can change the number of auto-qualifiers from the group
"members": checks we can change the entrants for the group
"grid": checks if we can change the grid, or change whether we use a grid for this group
"grid-positions": checks if we can set / change the grid positions for the group
"matches": we're checking if we can add matches
"delete-matches": checks if we can delete matches from this group

=cut

sub can_update {
  my $self = shift;
  my ( $type, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Check we have a valid type, if it's provided (if it's not provided, check all types)
  return undef if defined($type) and $type ne "auto-qualifiers" and $type ne "members" and $type ne "grid-positions" and $type ne "matches" and $type ne "delete-matches";
  
  # Default to allowed.
  my $allowed = 1;
  my ( $reason, $level );
  my $season = $self->tournament_round->tournament->event_season->season;
  
  # If the season is complete, we can't update anything
  if ( $season->complete ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.update.error.season-complete");
    
    if ( defined($type) ) {
      # We have a type, so not expecting multiple keys
      return wantarray ? (allowed => $allowed, reason => $reason) : $allowed;
    } else {
      # No type, so the caller will expect all the keys back
      my %types = wantarray
        ? (
            "auto-qualifiers" => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            members => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            grid => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            "grid-positions" => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            matches => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            "delete-matches" => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
          ) # We want the reasons back if we've asked for an array, the hash will contain 'allowed' and 'reason' keys
        : (
          "auto-qualifiers" => 0,
          members => 0,
          grid => 0,
          "grid-positions" => 0,
          matches => 0,
          "delete-matches" => 0,
        );
        
      # Return a reference to the hash in scalar context, or the hash itself in list context
      return wantarray ? %types : \%types;
    }
  }
  
  # What we do now depends on type.
  if ( defined($type) ) {
    my %can;
    if ( $type eq "auto-qualifiers" ) {
      %can = $self->_can_edit_auto_qualifiers;
    } elsif ( $type eq "members" ) {
      %can = $self->_can_update_members;
    } elsif ( $type eq "grid" ) {
      %can = $self->_can_add_manual_entrants;
    } elsif ( $type eq "delete-entrants" ) {
      %can = $self->_can_delete_entrants;
    } elsif ( $type eq "matches" ) {
      %can = $self->_can_create_matches;
    } elsif ( $type eq "delete-matches" ) {
      %can = $self->_can_delete_matches;
    }
    
    # Grab the reason and allowed flag
    $reason = $can{reason};
    $allowed = $can{allowed};
    $level = $can{level};
    
    # Return the requested results
    return wantarray ? (allowed => $allowed, reason => $reason, level => $level) : $allowed;
  } else {
    # All types, get the hashes back for each one
    my %auto_quals = $self->_can_edit_auto_qualifiers;
    my %members = $self->_can_update_members;
    my %grid = $self->_can_update_grid;
    my %matches = $self->_can_create_matches;
    my %delete_matches = $self->_can_delete_matches;
    
    my %types = wantarray
      ? (
          "auto-qualifiers" => {
            allowed => $auto_quals{allowed},
            reason => $auto_quals{reason},
            level => $auto_quals{level},
          },
          members => {
            allowed => $members{allowed},
            reason => $members{reason},
            level => $members{level},
          },
          grid => {
            allowed => $grid{allowed},
            reason => $grid{reason},
            level => $grid{level},
          },
          matches => {
            allowed => $matches{allowed},
            reason => $matches{reason},
            level => $matches{level},
          },
          "delete-matches" => {
            allowed => $delete_matches{allowed},
            reason => $delete_matches{reason},
            level => $delete_matches{level},
          },
        ) # We want the reasons back if we've asked for an array, the hash will contain 'allowed' and 'reason' keys
      : (
        "auto-qualifiers" => $auto_quals{allowed},
        members => $members{allowed},
        grid => $grid{allowed},
        matches => $matches{allowed},
        "delete-matches" => $delete_matches{allowed},
      );
    
    # Return a reference to the hash in scalar context, or the hash itself in list context
    return wantarray ? %types : \%types;
  }
}

=head2 _can_edit_auto_qualifiers

Check if we can change the number of automatic qualifiers of the group.

=cut

sub _can_edit_auto_qualifiers {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my ( $reason, $level );
  # Auto-qualifying number can be updated if there are no matches, or if there are incomplete matches.
  my $matches = $self->search_related("team_matches");
  if ( $matches->count ) {
    # If we have matches, we need to check some are incomplete
    my $incomplete_matches = $matches->search({
      complete => 0,
    });
    
    if ( $incomplete_matches ) {
      $allowed = 0;
      $reason = $lang->maketext("events.tournaments.rounds.groups.auto-qualifiers.error.all-matches-complete", $self->name);
      $level = "error";
    }
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_update_members

Check if we can change the members of the group.

=cut

sub _can_update_members {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my ( $reason, $level );
  # Members can be updated if there are no matches in the group (individuals need adding in when that's done)
  my $matches = $self->search_related("team_matches")->count;
  if ( $matches ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.members.error.matches-created", $self->name);
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_update_grid

Check if we can change the fixtures grid (change the grid, or remove it - or add one that wasn't being used).

=cut

sub _can_update_grid {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my ( $reason, $level );
  # Members can be updated if there are no matches in the group (individuals need adding in when that's done)
  my $matches = $self->search_related("team_matches")->count;
  if ( $matches ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.grid.error.matches-created", $self->name);
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_create_matches

Check if matches can be created (either the grid positions are set, or there is no grid and fixtures are manually set, and there are no matches for this round already).

=cut

sub _can_create_matches {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my ( $reason, $level );
  if ( $self->has_fixtures_grid ) {
    if ( !$self->grid_positions_set ) {
      $allowed = 0;
      $reason = $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.grid-positions-not-set", $self->name);
      $level = "error";
    }
  }
  
  if ( $allowed ) {
    if ( $self->matches->count ) {
      $allowed = 0;
      $reason = $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.matches-already-exist");
      $level = "error";
    }
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_delete_matches

Check if matches can be deleted.

=cut

sub _can_delete_matches {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my ( $reason, $level );
  my $matches = $self->matches;
  if ( $matches->count == 0 ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.delete-matches.error.no-matches", $self->name);
    $level = "error";
  } elsif ( $matches->search([{started => 1}, {complete => 1}, {cancelled => 1}])->count ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.delete-matches.error.matches-have-results", $self->name);
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
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
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the name for messaging
  my $name = $self->name;
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Delete teams in the group, and then the group
  # Tournament teams will cascade deletion from tournament round teams
  my ( $round_member_rel, $tourn_member_rs );
  my $entry_type = $self->entry_type;
  
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
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $name));
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
  my $entry_type = $self->entry_type;
  
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
  my ( $params ) = @_;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $rows = $params->{rows};
  my $prefetch_group = $params->{prefetch_group} || 0;
  my $member_rel;
  my $tourn_round = $self->tournament_round;
  my $entry_type = $self->entry_type;
  my $rank_template = $tourn_round->rank_template;
  my $match_template = $tourn_round->match_template;
  
  # Setup the initial sort attribs
  my %attrib = (
    order_by => $self->tournament_round->get_table_order_attribs,
  );
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
    
    if ( $prefetch_group ) {
      $attrib{prefetch} = [qw( tournament_group ), {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
      }];
    } else {
      $attrib{prefetch} = {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
      };
    }
    
    push(@{$attrib{order_by}}, {-asc => [qw( club.short_name team.name )]});
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  $attrib{rows} = $rows if defined($rows);
  
  return $self->search_related($member_rel, {}, \%attrib);
}

=head2 get_tables_last_updated_timestamp

Return the last updated date / time for the group.

=cut

sub get_tables_last_updated_timestamp {
  my $class = shift;
  my $member_rel;
  my $entry_type = $class->entry_type;
  my %attrib = ();
  
  if ( $entry_type eq "team" ) {
    $member_rel = "tournament_round_teams";
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  my $member_last_updated = $class->find_related($member_rel, {}, {
    rows => 1,
    order_by => {-desc => "last_updated"},
  });
  
  return defined($member_last_updated) ? $member_last_updated->last_updated : undef;
}

=head2 get_automatic_qualifiers

Return the current automatic qualifiers in the top [automatic_qualifiers] positions.

=cut

sub get_automatic_qualifiers {
  my $self = shift;
  my ( $params ) = @_;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $auto = $self->get_entrants_in_table_order({
    rows => $self->automatic_qualifiers,
    prefetch_group => 1,
  });
  
  return $auto;
}

=head2 get_entrants_in_grid_position_order

Return the group entrants in order of grid position.

=cut

sub get_entrants_in_grid_position_order {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->entry_type;
  
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
  my $entry_type = $self->entry_type;
  
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

=head2 table_last_updated

Return the last updated date / time.

=cut

sub table_last_updated {
  my $self = shift;
  my $member_rel;
  my $entry_type = $self->entry_type;
  
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
    error => [],
    warning => [],
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
    push(@{$response->{error}}, $lang->maketext("events.edit.error.no-current-season"));
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Error if matches set already
  push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.teams.error.matches-already-set")) if $self->matches->count;
  
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
  my $entry_type = $self->entry_type;
  
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
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.teams.error.wrong-team-id", $id));
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
    push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.error.no-position-for-entrant", encode_entities($entrant_required->object_name))) unless exists($submitted_entrants{$entrant_required->object_id});
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $position ( keys(%used_values) ) {
    push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.fixtures-grids.teams.error.position-used-more-than-once", $position, join(", ", @{$used_values{$position}}))) if scalar(@{$used_values{$position}}) > 1;
  }
  
  $response->{fields} = \%submitted_entrants;
  
  # Check for errors
  if ( scalar @{$response->{error}} == 0 ) {
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
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  my $match_create_cls = defined($grid) ? $grid : $self->tournament_round;
  $response = $match_create_cls->create_matches($self, $params);
  
  return $response;
}

=head2 delete_matches

Delete the matches in this group.

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
    error => [],
    warning => [],
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
        push(@{$response->{error}}, $lang->maktext("events.tournaments.rounds.groups.error.delete-failed"));
      }
    } else {
      $response->{rows} = 0;
    }
  } else {
    push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.delete-fixtures.error.cant-delete", $self->name));
  }
  
  return $response;
}

=head2 matches

Return the matches associated with this group.

=cut

sub matches {
  my $self = shift;
  my ( $params ) = @_;
  my $no_prefetch = $params->{no_prefetch};
  my ( $member_rel, %attrib );
  my $entry_type = $self->entry_type;
  
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

=head2 points_adjustments

Get a list of all points adjustments for this division/season from the team_seasons relation.

=cut

sub points_adjustments {
  my $self = shift;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "team" ) {
    return $self->search_related("tournament_round_teams")->search_related("tournament_round_team_points_adjustments");
  } elsif ( $entry_type eq "singles" ) {
    return $self->search_related("tournament_round_people")->search_related("tournament_round_people_points_adjustments");
  } elsif (  $entry_type eq "doubles" ) {
    return $self->search_related("tournament_rounds_doubles")->search_related("tournament_round_doubles_points_adjustments");
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
