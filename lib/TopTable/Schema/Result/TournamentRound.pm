use utf8;
package TopTable::Schema::Result::TournamentRound;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRound

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

=head1 TABLE: C<tournament_rounds>

=cut

__PACKAGE__->table("tournament_rounds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  accessor: '_url_key'
  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 event

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 round_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 round_of

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

Round of how many competitors - NULL if this is a group round, otherwise contains the number of competitors in the round.  If the number of competitors does not split down to 2 in the final, there may be bye(s) in this round.  This must be manually provided  for the first knock-out round, but can be calculated after that.

=head2 name

  accessor: '_name'
  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 group_round

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 rank_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

If this is a team match, this can be null, which indicates that the matches are to be played on the home night of the home team.

=head2 week_commencing

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

This is a modifier for the date field - if this is true, the date field is a week commencing date (meaning matches start in that week).  In this case, the date selected must be a Monday.   Should only be NULL if date is also NULL; if date is set, this should be 1 or 0.

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

If this is a team match, this can be null, which indicates the the matches are to be played at the venue the home team play at.

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
  {
    accessor => "_url_key",
    data_type => "varchar",
    is_nullable => 1,
    size => 45,
  },
  "event",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "round_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "round_of",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "name",
  { accessor => "_name", data_type => "varchar", is_nullable => 1, size => 150 },
  "group_round",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "rank_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "week_commencing",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key_unique_in_tournament_season>

=over 4

=item * L</url_key>

=item * L</event>

=item * L</season>

=back

=cut

__PACKAGE__->add_unique_constraint(
  "url_key_unique_in_tournament_season",
  ["url_key", "event", "season"],
);

=head1 RELATIONS

=head2 individual_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchIndividual>

=cut

__PACKAGE__->belongs_to(
  "individual_match_template",
  "TopTable::Schema::Result::TemplateMatchIndividual",
  { id => "individual_match_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 rank_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateLeagueTableRanking>

=cut

__PACKAGE__->belongs_to(
  "rank_template",
  "TopTable::Schema::Result::TemplateLeagueTableRanking",
  { id => "rank_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 system_event_log_event_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogEventRound>

=cut

__PACKAGE__->has_many(
  "system_event_log_event_rounds",
  "TopTable::Schema::Result::SystemEventLogEventRound",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "team_match_template" },
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
  { "foreign.tournament_round" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament

Type: belongs_to

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->belongs_to(
  "tournament",
  "TopTable::Schema::Result::Tournament",
  { event => "event", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_round_groups

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroup>

=cut

__PACKAGE__->has_many(
  "tournament_round_groups",
  "TopTable::Schema::Result::TournamentRoundGroup",
  { "foreign.tournament_round" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundPerson>

=cut

__PACKAGE__->has_many(
  "tournament_round_people",
  "TopTable::Schema::Result::TournamentRoundPerson",
  { "foreign.tournament_round" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundTeam>

=cut

__PACKAGE__->has_many(
  "tournament_round_teams",
  "TopTable::Schema::Result::TournamentRoundTeam",
  { "foreign.tournament_round" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_rounds_doubles",
  "TopTable::Schema::Result::TournamentRoundDoubles",
  { "foreign.tournament_round" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue

Type: belongs_to

Related object: L<TopTable::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "TopTable::Schema::Result::Venue",
  { id => "venue" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-01-16 08:32:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1+XYGQxbhVSU0jun7KYaeA

use HTML::Entities;
use List::MoreUtils qw( duplicates );
use Set::Object;

# Enable automatic date handling
__PACKAGE__->add_columns(
    "date",
    { data_type => "date", timezone => "UTC", set_on_create => 0, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0, },
);

=head2 url_key

Return the URL key if defined, or the round number if not.

=cut

sub url_key {
  my $self = shift;
  return defined($self->_url_key) ? $self->_url_key : $self->round_number;
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
    $name = $encode ? $lang->maketext("tournament.round.default-name", $self->round_number) : decode_entities($lang->maketext("tournament.round.default-name", $self->round_number));
  }
  
  return $name;
}

=head2 entry_type

Shortcut to $self->tournament->entry_type->id.

=cut

sub entry_type {
  my $self = shift;
  return $self->tournament->entry_type->id;
}

=head2 match_template

Return either the team match template or the individual match template, depending on the entry type.  Return from the round, if it's specifically set, if not return from the tournament.

=cut

sub match_template {
  my $self = shift;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "team" ) {
    # Team match template
    my %attrib = (prefetch => [qw( winner_type )]);
    return defined($self->team_match_template) ? $self->find_related("team_match_template", {}, \%attrib) : $self->tournament->find_related("default_team_match_template", {}, \%attrib);
  } else {
    # Individual match template for singles and doubles
    return defined($self->individual_match_template) ? $self->individual_match_template : $self->tournament->default_individual_match_template;
  }
}

=head2 groups

Return all groups in display order.

=cut

sub groups {
  my $self = shift;
  return $self->search_related("tournament_round_groups", {}, {
    order_by => {-asc => [qw( group_order )]}
  });
}

=head2 has_entrants

Check if this round has entrants, return 1 or 0.

=cut

sub has_entrants {
  my $self = shift;
  my $entry_type = $self->entry_type;
  
  my $rel;
  if ( $entry_type eq "team" ) {
    # Team match template
    $rel = "tournament_round_teams";
  } elsif ( $entry_type eq "singles" ) {
    $rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $rel = "tournament_rounds_doubles";
  }
  
  return $self->search_related($rel)->count ? 1 : 0;
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

=head2 has_matches

Check if the round has any matches yet; return 1 if so or 0 if not.

=cut

sub has_matches {
  my $self = shift;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "team" ) {
    # Team match search
    return $self->search_related("team_matches")->count ? 1 : 0;
  } elsif ( $entry_type eq "singles" ) {
    # Individual search
  } elsif ( $entry_type eq "doubles" ) {
    # Doubles search
  }
}

=head2 matches

Return the matches associated with this round.

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
      }, {
        team_season_winner_season => [qw( team ), {club_season => "club"}],
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

=head2 can_update($type)

1 if we can update the round $type; 0 if not.

In list context, a hash will be returned with keys 'allowed' (1 or 0) and potentially 'reason' (if not allowed, to give the reason we can't update).  The reason can be passed back in the interface as an error message.

No permissions are checked here, this is purely to see if it's possible to update the round based on factors in the tournament.

$type tells us what we want to update and can be "add-groups", "entrants", "manual-entrants", "delete-entrants" or "matches".  If not passed, we get a hash (or hashref in scalar context) of all types - scalar context just returns 1 or 0 for all of these, list context returns the hashref with allowed and reason keys.  If nothing can be updated for the same reason (i.e., the season is complete), the types will not be returned, and you'll get a 1 or 0 in scalar context, or 'allowed' and 'reason' keys in list context, just as if it had been called with a specific type.

Possible $type values:
"add-groups": we're checking if we can add groups to the round.
"entrants": checks we can add entrants to the round.
"manual-entrants": checks if we can add entrants manually (along with the automatic qualifiers) to the round - this doesn't do any checking that "entrants" does, so they'll need to be called separately.
"delete-entrants": checks if we can remove the entrants from this round.
"matches": checks if we can create matches for this round.  If it's a group round, this will be 0, as matches are created in individual groups, not in the round as a whole.
"delete-matches": checks if we can delete matches for this round.  If it's a group round, this will be 0, as matches are deleted in individual groups, not in the round as a whole.

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
  return undef if defined($type) and $type ne "add-groups" and $type ne "entrants" and $type ne "manual-entrants" and $type ne "delete-entrants" and $type ne "matches" and $type ne "delete-matches";
  
  # Default to allowed.
  my $allowed = 1;
  my ( $reason, $level );
  my $season = $self->tournament->event_season->season;
  
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
            "add-groups" => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            entrants => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            "manual-entrants" => {
              allowed => 0,
              reason => $reason,
              level => "error",
            },
            "delete-entrants" => {
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
          "add-groups" => 0,
          entrants => 0,
          "manual-entrants" => 0,
          "delete-entrants" => 0,
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
    if ( $type eq "add-groups" ) {
      %can = $self->_can_add_groups;
    } elsif ( $type eq "entrants" ) {
      %can = $self->_can_update_entrants;
    } elsif ( $type eq "manual-entrants" ) {
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
    my %add_groups = $self->_can_add_groups;
    my %entrants = $self->_can_update_entrants;
    my %manual_entrants = $self->_can_add_manual_entrants;
    my %delete_entrants = $self->_can_delete_entrants;
    my %matches = $self->_can_create_matches;
    my %delete_matches = $self->_can_delete_matches;
    
    my %types = wantarray
      ? (
          "add-groups" => {
            allowed => $add_groups{allowed},
            reason => $add_groups{reason},
            level => $add_groups{level},
          },
          entrants => {
            allowed => $entrants{allowed},
            reason => $entrants{reason},
            level => $entrants{level},
          },
          "manual-entrants" => {
            allowed => $manual_entrants{allowed},
            reason => $manual_entrants{reason},
            level => $manual_entrants{level},
          },
          "delete-entrants" => {
            allowed => $delete_entrants{allowed},
            reason => $delete_entrants{reason},
            level => $delete_entrants{level},
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
        "add-groups" => $add_groups{allowed},
        entrants => $entrants{allowed},
        "manual-entrants" => $manual_entrants{allowed},
        "delete-entrants" => $delete_entrants{allowed},
        matches => $matches{allowed},
        "delete-matches" => $delete_matches{allowed},
      );
    
    # Return a reference to the hash in scalar context, or the hash itself in list context
    return wantarray ? %types : \%types;
  }
}

=head2 _can_add_groups

Check if we can add groups.  Don't do the season complete check, this is done in can_update.

=cut

sub _can_add_groups {
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
  # Handicap can be updated if this is a handicapped match and the match doesn't have any scores (so isn't marked as 'started').
  if ( !$self->group_round ) {
    # Can't set handicap, this match isn't handicapped
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.create.error.not-group-round", $self->name);
    $level = "error";
  } elsif ( $self->search_related("team_matches")->count ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.groups.create.error.matches-created");
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_update_entrants

Check if we can add entrants to the round.  Don't do the season complete check, this is done in can_update.

=cut

sub _can_update_entrants {
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
  
  # The entrants of a round can't be updated if:
  # - The round is a group round
  # - The round already has entrants
  # - The round before it is not yet complete
  if ( $self->group_round ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.update.error.group-round", $self->name);
    $level = "error";
  } elsif ( $self->has_entrants ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.update.error.round-already-has-entrants", $self->name);
    $level = "error";
  } else {
    my $prev_round = $self->prev_round;
    
    if ( defined($prev_round) and !$prev_round->complete({logger => $logger}) ) {
      $allowed = 0;
      $reason = $lang->maketext("events.tournaments.rounds.entrants.update.error.prev-round-incomplete");
      $level = "error";
    }
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_add_manual_entrants

Check if we can add entrants manually to the round.  Don't do the season complete check, this is done in can_update.  This doesn't do any of the checks of _can_update_entrants, so they'll need to be called separately.

=cut

sub _can_add_manual_entrants {
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
  
  if ( !$self->is_first_ko_round ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.update.add-manual.error.not-first-ko-round");
    $level = "error";
  } else {
    my $prev_round = $self->prev_round;
    
    if ( defined($prev_round) ) {
      if ( $prev_round->num_qualifiers >= $self->round_of ) {
        # There's a previous round and the number of qualifiers are greater than or equal to the number of people in this round
        # (they should never be greater than, but let's just be safe).
        $allowed = 0;
        $reason = $lang->maketext("events.tournaments.rounds.entrants.update.add-manual.error.auto-fills-all-spaces");
        $level = "error";
      }
    }
    
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_delete_entrants

Check if we can add entrants to the round.  Don't do the season complete check, this is done in can_update.

=cut

sub _can_delete_entrants {
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
  
  # The entrants of a round can't be deleted if:
  # - It's a group round
  # - They haven't been set
  # - There are matches in this round
  if ( $self->group_round ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.delete.error.group-round", $self->name);
    $level = "error";
  } elsif ( !$self->has_entrants ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.delete.error.round-no-entrants", $self->name);
    $level = "error";
  } elsif ( $self->has_matches ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.entrants.delete.error.matches-created", $self->name);
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_create_matches

Check if we can create matches for the round.  Don't do the season complete check, this is done in can_update.

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
  
  # The entrants of a round can't be updated if:
  # - The round is a group round
  # - The round doesn't have entrants
  if ( $self->group_round ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.matches.create.error.group-round", $self->name);
    $level = "error";
  } elsif ( !$self->has_entrants ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.matches.create.error.round-has-no-entrants", $self->name);
    $level = "error";
  } elsif ( $self->has_matches ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.matches.create.error.round-already-has-matches", $self->name);
    $level = "error";
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 _can_delete_matches

Check if we can delete matches for the round.  Don't do the season complete check, this is done in can_update.

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
  
  # The entrants of a round can't be updated if:
  # - The round is a group round
  # - The round doesn't have entrants
  if ( $self->group_round ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.matches.delete.error.group-round", $self->name);
    $level = "error";
  } elsif ( !$self->has_matches ) {
    $allowed = 0;
    $reason = $lang->maketext("events.tournaments.rounds.matches.delete.error.round-has-no-matches", $self->name);
    $level = "error";
  } else {
    my $with_results = $self->matches->search([{complete => 1}, {started => 1}, {cancelled => 1}]);
    if ( $with_results->count ) {
      $allowed = 0;
      $reason = $lang->maketext("events.tournaments.rounds.matches.delete.error.matches-have-results", $self->name);
      $level = "error";
    }
  }
  
  return (allowed => $allowed, reason => $reason, level => $level);
}

=head2 date_range

Return a hash (or hashref in scalar context) with keys 'first' and 'last' containing the first and last dates of the round, taken from the dates of matches assigned to this round.

=cut

sub date_range {
  my $self = shift;
  my $schema = $self->result_source->schema;
  my $dtf = $schema->storage->datetime_parser;
  
  # First check there are matches
  my $matches = $self->search_related("team_matches")->count;
  return undef unless $matches;
  
  my $first = $self->search_related("team_matches", {}, {
    columns => [{
      first_date => {min => "played_date"}
    }],
  })->single->get_column("first_date");
  
  my $last = $self->search_related("team_matches", {}, {
    columns => [{
      last_date => {max => "played_date"}
    }],
  })->single->get_column("last_date");
  
  $first = $dtf->parse_date($first) if defined($first);
  $last = $dtf->parse_date($last) if defined($last);
  
  return wantarray ? (first_date => $first, last_date => $last) : {first_date => $first, last_date => $last};
}

=head2 get_entrants

Return the entrants (what these are depends on the entry type of the tournament).

=cut

sub get_entrants {
  my $self = shift;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "team" ) {
    return $self->search_related("tournament_round_teams", {}, {
      prefetch => {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }]
        }
      },
      order_by => {
        -asc => [qw( club_season.short_name team_season.name )],
      }
    });
  } elsif ( $entry_type eq "singles" ) {
    return $self->search_related("tournament_round_people");
  } elsif ( $entry_type eq "doubles" ) {
    return $self->search_related("tournament_rounds_doubles");
  }
}

=head2 groups_can_be_named

If we have any groups WITHOUT names, we can't name the groups - they'll just be numbered, and we'll create the next number when we add a new group.  Function returns 1 if there are groups with names (or no groups yet), 0 if there are groups without names.

=cut

sub groups_can_be_named {
  my $self = shift;
  my $groups = $self->groups;
  return 1 unless $groups->count;
  return $groups->search({
    name => {"!=" => undef},
  })->count ? 1 : 0;
}

=head2 groups_must_be_named

If we have any groups WITH names, we must name the rest of the groups.  Function returns 1 if there are groups with names, 0 if there are groups without names (or no groups yet).

=cut

sub groups_must_be_named {
  my $self = shift;
  my $groups = $self->groups;
  return 0 unless $groups->count;
  return $groups->search({
    name => {"!=" => undef},
  })->count ? 1 : 0;
}

=head2 recalculate_groups_order

Recalculate the order for all groups in this round.

=cut

sub recalculate_groups_order {
  my $self = shift;
  
  my $groups = $self->search_related("tournament_round_groups", {}, {
    order_by => {-asc => [qw( group_order )]},
  });
  
  my $transaction = $self->result_source->schema->txn_scope_guard;
  my $i = 0;
  while ( my $group = $groups->next ) {
    $i++;
    $group->update({
      group_order => $i,
    });
  }
  
  $transaction->commit;
}

=head2 find_group_by_id_or_url_key

Get a specific round number, either by round number or URL key.

=cut

sub find_group_by_id_or_url_key {
  my $self = shift;
  my ( $group_id, $params ) = @_;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  if ( $group_id =~ m/^\d+$/ ) {
    # Numeric value, check the ID first, then check the URL key
    my $obj = $self->find_related("tournament_round_groups", {group_order => $group_id});
    
    if ( defined($obj) ) {
      return $obj;
    } else {
      $obj = $self->find_related("tournament_round_groups", {url_key => $group_id});
    }
    
    return $obj;
  } else {
    # Not numeric, so it can't be the ID - just check the URL key
    return $self->find_related("tournament_round_groups", {
      url_key => $group_id
    }, {
      prefetch => [qw( fixtures_grid )]
    });
  }
}

=head2 complete

Work out if this round is complete, return 1 if so or 0 if not.

=cut

sub complete {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $round_number = $self->round_number;
  my $tourn = $self->tournament;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "team" ) {
    # Teams - work out if we have matches
    my $matches = $self->search_related("team_matches");
    
    if ( $matches->count == 0 ) {
      # No matches, not complete
      return 0;
    } else {
      # If there's no Check all matches are complete
      if ( $matches->incomplete_and_not_cancelled->count == 0 ) {
        # All matches are complete - but if it's a group round we need to check all groups have matches
        if ( $self->group_round ) {
          # If it's a group round we need to do an additional check for groups without matches
          my @groups = $self->search_related("tournament_round_groups");
          
          foreach my $group ( @groups ) {
            # As soon as we come across a group with no matches, return 0
            return 0 if $group->search_related("team_matches")->count == 0;
          }
        }
        
        return 1;
      } else {
        # Not all matches are complete, round is not complete
        return 0;
      }
    }
  } elsif ( $entry_type eq "singles" ) {
    # To be completed
    
  } elsif ( $entry_type eq "doubles" ) {
    # To be completed
    
  }
}

=head2 next_group_order

Return the next group_order sequence number to be used.

=cut

sub next_group_order {
  my $self = shift;
  
  my $last_group_order = $self->search_related("tournament_round_groups", {}, {
    columns => [{
      last_group_order => {max => "group_order"}
    }],
  })->single->get_column("last_group_order");
  
  # Next round number is either the last round number + 1, or round 1
  my $next_group_order = defined($last_group_order) ? $last_group_order + 1 : 1;
  
  # Return the date as a DateTime object if we have a result; if not return undef
  return $next_group_order;
}

=head2 prev_round

Return the previous round in the tournament; if there's no previous round, return undef.

=cut

sub prev_round {
  my $self = shift;
  
  # Find and return the first round that comes before this one.  Search all rows where the round number
  # is less than this one, but order by round number descendingly and only return the top 1; this is safer than
  # searching by round number specifically, just in case things have gone awry in round numbering.
  return $self->tournament->search_related("tournament_rounds", {
    round_number => {"<" => $self->round_number},
  }, {
    order_by => {
      -desc => [qw( round_number )],
    },
    rows => 1,
  })->single;
}

=head2 next_round

Return the next round in the tournament; if there's no next round, return undef.

=cut

sub next_round {
  my $self = shift;
  
  # Find and return the first round that comes after this one.  Search all rows where the round number
  # is greater than this one, but order by round number and only return the top 1; this is safer than
  # searching by round number specifically, just in case things have gone awry in round numbering.
  return $self->tournament->search_related("tournament_rounds", {
    round_number => {">" => $self->round_number},
  }, {
    order_by => {
      -asc => [qw( round_number )],
    },
    rows => 1,
  })->single;
}

=head2 is_first_ko_round

Returns 1 if this is the first knock-out round of the tournament, 0 if not.

=cut

sub is_first_ko_round {
  my $self = shift;
  
  # If this is a group round, just return 0 straight away
  return 0 if $self->group_round;
  
  # We can only be the first knock-out round if this is round 1 or 2
  return 0 if $self->round_number > 2;
  
  # If not, try and get the previous round
  my $prev_round = $self->prev_round;
  
  if ( defined($prev_round) ) {
    # If the previous round is a group round, return 1, otherwise return 0
    return $prev_round->group_round ? 1 : 0;
  } else {
    # There's no previous round, this must be the first round - we already know it's not a group round, so return 1
    return 1;
  }
}

=head2 is_final_round

Return 1 if this is the final round, or 0 if not.

=cut

sub is_final_round {
  my $self = shift;
  return (defined($self->round_of) and $self->round_of == 2) ? 1 : 0;
}

=head2 num_qualifiers

The number of qualifiers to go through from this round.  If this is a group round, it'll be the minimum number of qualifiers that can go through (taken from the sum of automatic_qualifiers in all groups); if it's a knock-out round it'll be half the number of people in the group.

=cut

sub num_qualifiers {
  my $self = shift;
  
  if ( $self->group_round ) {
    return $self->search_related("tournament_round_groups", {}, {
      select => [{sum => "automatic_qualifiers"}],
      as => [qw( total_qualifiers )],
      rows => 1,
    })->single->get_column("total_qualifiers");
  } else {
    # If the previous round doesn't exist, or is a group round (i.e., this is the first knock-out round)
    return $self->round_of / 2;
  }
}

=head2 get_table_order_attribs

Based on the rules for this round, get the table sort instructions for the entrants.  The return value from this can be used directly in an order_by attribute clause.

=cut

sub get_table_order_attribs {
  my $self = shift;
  my ( $params ) = @_;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $entry_type = $self->entry_type;
  my $rank_template = $self->rank_template;
  my $match_template = $self->match_template;
  my $winner_type = $match_template->winner_type->id;
  my $alias = $params->{alias} || "me";
  
  my $order_by;
  if ( defined($rank_template) and $rank_template->assign_points ) {
    if ( $winner_type eq "games" ) {
      $order_by = [{
        -desc => ["$alias.table_points", "$alias.games_won", "$alias.matches_won", "$alias.matches_drawn", "$alias.matches_played"],
      }, {
        -asc  => ["$alias.games_lost", "$alias.matches_lost"],
      }, {
        -desc => ["$alias.games_won"],
      }];
    } else {
      $order_by = [{
        -desc => ["$alias.table_points", "$alias.points_difference", "$alias.points_won", "$alias.matches_played"],
      }, {
        -asc  => ["$alias.points_lost", "$alias.matches_lost"],
      }];
    }
  } else {
    if ( $winner_type eq "games" ) {
      $order_by = [{
        -desc => ["$alias.games_won", "$alias.matches_won", "$alias.matches_drawn", "$alias.matches_played"],
      }, {
        -asc  => ["$alias.games_lost", "$alias.matches_lost"],
      }, {
        -desc => ["$alias.games_won"],
      }];
    } else {
      $order_by = [{
        -desc => ["$alias.points_difference", "$alias.points_won", "$alias.matches_played"],
      }, {
        -asc  => ["$alias.points_lost", "$alias.matches_lost"],
      }];
    }
  }
  
  return $order_by;
}

=head2 auto_qualifiers

Get the entrants into this round (in all groups if it's a group round) that have automatically qualified for the next round.  It doesn't matter if the round is finished, this will show in current positions.

=cut

sub auto_qualifiers {
  my $self = shift;
  my ( $group, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $entry_type = $self->entry_type;
  if ( $self->group_round ) {
    # Group round - we need to get all the groups, then map that into automatic qualifiers from each group
    my @groups = $self->search_related("tournament_round_groups", {}, {
      order_by => {-asc => [qw( group_order )]}
    });
    
    # Now map the array so it's the automatic qualifiers from each group
    @groups = map($_->get_automatic_qualifiers, @groups);
    
    # We can't union due to Dbix::Class::Helpers::ResultSet::SetOperations not formatting the query correctly when each query has order_by / limit clauses,
    # so just return the array.  Each element is a resultset of group qualifiers (top X from each group).
    #return wantarray ? @groups : \@groups;
    
    # Flatten the array so we just get the qualifiers
    my @qual_ids;
    foreach my $group ( @groups ) {
      while ( my $qual = $group->next ) {
        push(@qual_ids, $qual->id);
      }
    }
    
    # Since we had to get the qualifiers from each group individually, we now want to rank them in the same way we would have if we'd got them all in one go.
    # First convert to resultset
    my $rs;
    if ( $entry_type eq "team" ) {
      $rs = "Team";
    } elsif ( $entry_type eq "singles" ) {
      $rs = "Person";
    } elsif ( $entry_type eq "doubles" ) {
      $rs = "Doubles";
    }
    
    return $self->result_source->schema->resultset("TournamentRound$rs")->search({
      "me.id" => {-in => \@qual_ids},
    }, {
      order_by => $self->get_table_order_attribs,
    });
  } else {
    # Knock-out round - get the list of winners
    my ( $rel, $comp_tourn_rel, $comp_round_rel, $round_rel );
    if ( $entry_type eq "team" ) {
      $rel = "team_season_winner_season";
      $comp_tourn_rel = "tournament_teams";
      $comp_round_rel = "tournament_round_teams";
      $round_rel = "tournament_round";
    } elsif ( $entry_type eq "singles" ) {
      #$rel = ""; # Unknown until we complete that bit
    } elsif ( $entry_type eq "doubles" ) {
      #$rel = ""; # Unknown until we complete that bit
    }
    
    return $self->matches->search_related($rel)->search_related($comp_tourn_rel)->search_related($comp_round_rel, {
      "$round_rel.round_number" => $self->round_number,
    }, {
      join => $round_rel,
      order_by => $self->get_table_order_attribs({alias => $comp_round_rel}),
    });
  }
}

=head2 non_auto_qualifiers

Get the entrants into this round (in all groups if it's a group round) that have NOT automatically qualified for the next round.  It doesn't matter if the round is finished, this will show in current positions.

=cut

sub non_auto_qualifiers {
  my $self = shift;
  my ( $params ) = @_;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $member_rel;
  my $entry_type = $self->entry_type;
  my $rank_template = $self->rank_template;
  my $match_template = $self->match_template;
  
  # Setup the initial sort attribs
  my %attrib;
  
  if ( $entry_type eq "team" ) {
    # Prefetch is the same for team entry regardless of the other rank / winner type settings
    %attrib = (
      prefetch => [qw( tournament_group ), {
        tournament_team => {
          team_season => [qw( team ), {
            club_season => [qw( club )],
          }],
        },
      }],
      order_by => $self->get_table_order_attribs,
    );
    
    $member_rel = "tournament_round_teams";
    push(@{$attrib{order_by}}, {-asc => [qw( club.short_name team.name )]});
  } elsif ( $entry_type eq "singles" ) {
    $member_rel = "tournament_round_people";
  } elsif ( $entry_type eq "doubles" ) {
    $member_rel = "tournament_round_doubles";
  }
  
  # Get the automatic qualifiers first, then grab the rest by specifying the IDs we don't want
  my @auto_qualifiers = $self->auto_qualifiers;
  @auto_qualifiers = map($_->id, @auto_qualifiers);
  
  my $rel;
  if ( $self->entry_type eq "team" ) {
    $rel = "tournament_round_teams";
  } elsif ( $self->entry_type eq "singles" ) {
    $rel = "tournament_round_people";
  } elsif ( $self->entry_type eq "doubles" ) {
    $rel = "tournament_rounds_doubles";
  }
  
  return $self->search_related($rel, {
    "me.id" => {-not_in => \@auto_qualifiers},
  }, \%attrib);
}

=head2 get_entrants_in_table_order($group)

Retrieve entrants in the order they'll be placed in the table (returns undef if not a group round; $group specifies the group we'll return.  The reason this is not a TournamentRoundGroup method, is the group can be undef, in which case the entrants are returned for all groups, which is helpful when calculating best X entrants who've not qualified ).

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
    order_by => $self->get_table_order_attribs,
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

=head2 create_or_edit_group

Add or edit a group (this must be a group round of course).

=cut

sub create_or_edit_group {
  my $self = shift;
  my ( $group, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my ( $action );
  
  # Hash of which settings can be changed
  my %can_edit = (
    fixtures => 1,
    members => 1,
    qualifiers => 1,
  );
  
  # Grab the fields
  my $name = $params->{name} || undef;
  my $manual_fixtures = $params->{manual_fixtures} || undef;
  my $fixtures_grid = $params->{fixtures_grid} || undef;
  my $group_members = $params->{members} || [];
  my @members = @$group_members;
  my $automatic_qualifiers = $params->{automatic_qualifiers} || undef;
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      automatic_qualifiers => $automatic_qualifiers,
    },
    completed => 0,
  };
  
  # If we're editing, we may only be able to touch certain fields, so we'll keep a hash of the data to write and add to it as we know what we're able to
  # change / write.
  my %write_data = ();
  
  # Error checking
  # Check the tournament is for the current season
  my $tournament = $self->tournament;
  my $event = $tournament->event_season->event;
  my $season = $tournament->event_season->season;
  my $entry_type = $self->entry_type;
  
  if ( $season->complete ) {
    push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.season-not-current"));
    return $response;
  }
  
  if ( !$self->group_round ) {
    push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.not-group-round"));
    return $response;
  }
  
  my $can_update;
  if ( defined($group) ) {
    # Group specified, we must be editing
    $action = "edit";
    
    # Check the group passed is valid
    if ( $group->isa("TopTable::Schema::Result::TournamentRoundGroup") ) {
      # Group is defined, set the ability to edit settings from that
      $can_update = $group->can_update;
      
      # Group order is the same as it was if we're editing
      $write_data{group_order} = $group->group_order;
    } else {
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.group-invalid"));
      
      # Another fatal error
      return $response;
    }
  } else {
    # No group specified, so we're creating
    $action = "create";
    $can_update = {
      "auto-qualifiers" => 1,
      members => 1,
      grid => 1,
    };
    
    # Creation means we just add to the list of groups at the end
    $write_data{group_order} = $self->next_group_order;
  }
  
  if ( $self->groups_can_be_named ) {
    # Check the names were entered and don't exist already.
    if ( defined($name) ) {
      # Name entered, check it.
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.name-exists", encode_entities($name))) if defined($schema->resultset("TournamentRoundGroup")->search_single_field($self, {field => "name", value => $name, exclusion_obj => $group}));
      $write_data{url_key} = $schema->resultset("TournamentRoundGroup")->make_url_key($self, $name, $group);
    } else {
      # Name omitted.
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.name-blank-but-shouldnt-be")) if $self->groups_must_be_named;
    }
    
    $write_data{name} = $name;
  } else {
    # Groups can't be named, so if we have a name specified, that's an error
    push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.name-not-blank-but-should-be")) if defined($name);
  }
  
  if ( $can_update->{grid} ) {
    # Sanity check - 1 or 0
    $manual_fixtures = $manual_fixtures ? 1 : 0;
    
    # Check the fixtures grid
    if ( defined($fixtures_grid) ) {
      # Fixtures grid selected - only valid if manual fixtures is false
      $fixtures_grid = $schema->resultset("FixturesGrid")->find_id_or_url_key($fixtures_grid) unless $fixtures_grid->isa("TopTable::Schema::Result::FixturesGrid");
      
      if ( $manual_fixtures ) {
        # Error, as manual fixtures and a fixtures grid have been specified
        push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.manual-fixtures-and-fixtures-grid"));
      } else {
        # Check the fixtures grid is valid
        push(@{$response->{error}}, $lang->maketext("tournaments.rounds.group.field.form.error.grid-invalid")) unless defined($fixtures_grid);
      }
    } else {
      # Fixtures grid not selected - okay if manual fixtures is false, otherwise error
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.no-fixtures-grid-or-manual-fixtures")) unless $manual_fixtures;
    }
    
    $write_data{fixtures_grid} = defined($fixtures_grid) ? $fixtures_grid->id : undef;
  }
  
  $response->{fields}{manual_fixtures} = $manual_fixtures;
  
  my ( $member_class, %member_cls_attrib, $tourn_member_class, $round_member_class, $group_member_class, $member_rel_round );
  if ( $can_update->{members} ) {
    # Check the members of the group
    # First check we're checking the right table
    my @dup_check = (); # Will hold a list of all the submitted IDs
    if ( $entry_type eq "team" ) {
      $member_class = "Team";
      $member_rel_round = "tournament_round_teams";
      %member_cls_attrib = (prefetch => [qw( club )]);
    } elsif ( $entry_type eq "singles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_round_people";
    } elsif ( $entry_type eq "doubles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_rounds_doubles";
    }
    
    $tourn_member_class = "Tournament$member_class";
    $round_member_class = "TournamentRound$member_class";
    $group_member_class = "TournamentGroup$member_class";
    
    my $invalid_members = 0;
    
    # We're only interested in one set of entries if it's not a doubles pair
    @members = $members[0] unless $entry_type eq "doubles";
    my @team_singles_members = (); # Placeholder, as we're only ever working on the first element of the members array, the entries will keep overwriting
    while ( my ($idx, $members) = each @members ) {
      # Initial check of the format
      if ( $entry_type eq "doubles" ) {
        if ( ref($members) eq "ARRAY" ) {
          # Array, must be exactly two entries
          my $elms = scalar @{$members};
          push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.doubles-members-needs-two-entries", ($idx + 1), $elms)) unless $elms == 2;
        } else {
          # Not an array, error
          push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.doubles-members-not-array", ($idx + 1)));
        }
      }
      
      # Create an array of members to check - this is so we can handle doubles pairs, which should be an array of two people
      # Putting the team / singles members in the same array means we can loop through knowing we have the right number of
      # elements (1 or 2).
      my @check_members = $entry_type eq "doubles" ? ( $members->[0], $members->[1] ) : ( @$members );
      
      # For doubles, we need a pair index too, so we know which doubles partner in the array to modify
      my $pair_idx = 0;
      foreach my $member ( @check_members ) {
        # Ensure we are undef if blank
        $member ||= undef;
        
        if ( defined($member) ) {
          $member = $schema->resultset($member_class)->find_id_or_url_key($member) unless blessed($member) and $member->isa("TopTable::Schema::Result::$member_class");
          
          # Set the looked up value's ID back to the array (even if undef, the grep below will pick it out)
          # We are using ID here because we need to check it against existing lists / arrays and Set::Object
          if ( defined($member) ) {
            # Get the name for messaging / errors
            my $name = $entry_type eq "team" ? sprintf("%s %s", $member->club->short_name, $member->name) : $member->display_name;
            
            # Member is valid, check they've entered the season - players and teams both have 
            my $season_entered = $member->get_season($season);
            
            if ( defined($season_entered) ) {
              # Season has been entered, ensure they're not in any other groups for this tournament
              my $conflicting_groups;
              if ( $entry_type eq "team" ) {
                # Search the team membership table
                $conflicting_groups = $schema->resultset("TournamentRoundTeam")->search({
                  "me.id" => $self->id,
                  "tournament_team.team" => $member->id,
                }, {
                  join => [qw( tournament_team )]
                });
              } elsif ( $entry_type eq "singles" ) {
                # Search the person member table
                $conflicting_groups = $schema->resultset("TournamentRoundPerson")->search({
                  "me.id" => $self->id,
                  "tournament_person.person" => $member->id,
                }, {
                  join => [qw( tournament_person )]
                });
              } elsif ( $entry_type eq "doubles" ) {
                # Search the person member table
                $conflicting_groups = $schema->resultset("TournamentRoundDoubles")->search({
                  -and => {
                    "tournament_round.id" => $self->id,
                    "tournament.season" => $season->id,
                  },
                  -or => [{
                    "tournament_pair.person1" => $member->id,
                  }, {
                    "tournament_pair.person2" => $member->id,
                  }],
                }, {
                  join => [qw( tournament_pair )]
                });
              }
              
              push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.member-already-entered", encode_entities($name))) if $conflicting_groups->count;
            } else {
              # Not entered this season, error
              push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.not-entered-season", encode_entities($name), encode_entities($season->name)));
            }
            
            if ( $entry_type eq "doubles" ) {
              $members[$idx][$pair_idx] = $member->id;
            } else {
              push(@team_singles_members, $member->id);
            }
            
            push(@dup_check, $member->id);
          } else {
            # Increase invalid count and add undef into the array (which will be removed later with grep)
            if ( $entry_type eq "doubles" ) {
              $members[$idx][$pair_idx] = undef;
            } else {
              push(@team_singles_members, undef);
            }
            
            $invalid_members++;
          }
        }
        
        $pair_idx++;
      }
    }
    
    if ( $invalid_members ) {
      my $plural = $invalid_members > 1 ? "plural" : "singular";
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.invalid-members-$plural", $invalid_members)) if $invalid_members;
    }
    
    # We now need to compare the submitted values to ensure there are no duplicates
    my @duplicates = duplicates(@dup_check);
    
    if ( scalar @duplicates ) {
      # We have some duplicates, so raise an error - to do this, we need to convert the IDs back to objects so we can display the names
      my @names = map(encode_entities($schema->resultset($member_class)->find_id_or_url_key($_)), @duplicates);
      
      # Get the last element from the list, as we don't want this to have commas before it
      my $last = pop(@names);
      my $duplicate_names = sprintf("%s %s %s", join(", ", @names), $lang->maketext("msg.and"), $last);
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.member-duplicates", $duplicate_names));
    }
    
    # grep the undefined members
    if ( $entry_type eq "doubles" ) {
      # Go into the array of arrays to grep and then validate
      while ( my ($idx, $pair) = each @members ) {
        my @pair = grep(defined, @$pair);
        @members[$idx] = \@pair;
      }
    } else {
      # Singles / teams are just a list of IDs or undef values, so grep out the undefs
      @members = grep(defined, @members);
    }
    
    # If there's a fixtures grid here, we need to make sure the number of members doesn't exceed the maximum number of entrants specified by the grid
    @members = @team_singles_members unless $entry_type eq "doubles";
    my $member_count = scalar @members;
    
    if ( !$manual_fixtures and defined($fixtures_grid) and $member_count > $fixtures_grid->maximum_teams ) {
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.members-exceed-grid-maximum", $member_count, encode_entities($fixtures_grid->name), $fixtures_grid->maximum_teams));
    } elsif ( $member_count < 2 ) {
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.members-must-have-at-least-two"));
    }
  }
  
  # Look up the members from the IDs stored for the response field
  $response->{fields}{members} = [map($schema->resultset($member_class)->find($_, \%member_cls_attrib), @members)];
  
  # Check the number of qualifiers
  if ( $can_update->{"auto-qualifiers"} ) {
    if ( defined($automatic_qualifiers) ) {
      # We have a value, ensure it's positive and numeric, and not more than the number of competitors in the group.
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.qualifiers-invalid")) unless $automatic_qualifiers =~ m/^\d+$/ or $automatic_qualifiers > scalar @members;
    } else {
      # Error, we need this specified
      push(@{$response->{error}}, $lang->maketext("tournaments.round.group.form.error.qualifiers-blank"));
    }
    
    $write_data{automatic_qualifiers} = $automatic_qualifiers;
  }
  
  if ( scalar @{$response->{error}} == 0 ) {
    # Create a transaction to safeguard - if either operation fails, nothing is written / updated
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # No errors, do the group creation / edit
    if ( $action eq "create" ) {
      # Create
      $group = $self->create_related("tournament_round_groups", \%write_data);
    } else {
      # Edit
      $group->update(\%write_data);
    }
    
    # Update the members if we're allowed
    if ( $can_update->{members} ) {
      my $round = $group->tournament_round;
      
      if ( $action eq "edit" ) {
        # First delete the memberships we have that don't match this one - search query will differ depending on entry type
        # We need to setup the delete / creation search hashes - initially they with both refer to the current tournament (event / season combination)
        my $round_rel;
        if ( $entry_type eq "team" ) {
          $round_rel = "tournament_round_teams";
        } elsif ( $entry_type eq "singles" ) {
          $round_rel = "tournament_round_people";
        } elsif ( $entry_type eq "doubles" ) {
          $round_rel = "tournament_rounds_doubles";
        }
        
        $schema->resultset($tourn_member_class)->search({
          "tournament_group.id" => $group->id,
        }, {
          join => {
            $round_rel => [qw( tournament_group )]
          },
        })->delete;
      }
      
      # Setup the member data
      foreach my $member ( @members ) {
        # Initial member data is the event / season and related group membership
        my %member_data = (
          event => $self->tournament->event,
          season => $self->tournament->season,
          $member_rel_round => [{
            tournament_round => $round->id,
            tournament_group => $group->id,
          }],
        );
        
        if ( $entry_type eq "singles" ) {
          $member_data{person} = $member;
        } elsif ( $entry_type eq "doubles" ) {
          $member_data{person1} = $member->[0];
          $member_data{person2} = $member->[1];
        } elsif ( $entry_type eq "team" ) {
          $member_data{team} = $member;
        }
        
        my $tourn_member = $schema->resultset($tourn_member_class)->create(\%member_data);
      }
    }
    
    if ( $action eq "create" ) {
      # Create
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($group->name), $lang->maketext("admin.message.created")));
    } else {
      # Edit
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($group->name), $lang->maketext("admin.message.edited")));
    }
    
    $transaction->commit;
    $response->{group} = $group;
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 number_of_matches

Calculate the number of matches required; this will return undef for a group round, it's to work out the number of matches required to play a knock-out round

=cut

sub number_of_matches {
  my $self = shift;
  
  if ( $self->is_first_ko_round ) {
    # For the first knock-out round, it's not just the number of participants, we need to work out based on the number of byes too
    my %calc = $self->tournament->calculate_ko_rounds;
    return ($self->round_of - $calc{byes}) / 2;
  } else {
    # Otherwise it's just the number of participants divided by 2.
    return $self->round_of / 2;
  }
}

=head2 add_entrants

Add the entrants to the round.

=cut

sub add_entrants {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $manual_entrants = $params->{manual_entrants};
  my @manual_entrants = @{$manual_entrants};
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      manual_entrants => [],
    },
    completed => 0,
    can_complete => 1,
  };
  
  my %can = $self->can_update("entrants");
  
  if ( !$can{allowed} ) {
    $response->{can_complete} = 0;
    push(@{$response->{level}}, $can{reason});
    return;
  }
  
  # Get the previous round so we can get the list of automatic / possible manual entrants
  my $prev_round = $self->prev_round;
  
  my ( @auto_qualifiers, @non_auto_qualifiers );
  my @entrants_to_add;
  my $can_add_manual = $self->can_update("manual-entrants");
  if ( defined($prev_round) ) {
    @auto_qualifiers = $prev_round->auto_qualifiers;
    @non_auto_qualifiers = $prev_round->non_auto_qualifiers if $can_add_manual;
  }
  
  # Set object arrays for the IDs so we can compare
  my $auto_ids = Set::Object->new(map($_->id, @auto_qualifiers));
  my $non_auto_ids = Set::Object->new(map($_->id, @non_auto_qualifiers));
  
  my @submitted_ids = ();
  if ( $can_add_manual ) {
    @submitted_ids = map{
      ref ? $_->id : $_ # Return the ID of the object if it's an object, or the value itself if it's not (assume it's the ID)
    } @manual_entrants;
    my $submitted_ids = Set::Object->new(@submitted_ids);
    $response->{fields}{manual_entrants} = \@submitted_ids;
    
    # First check none of our submitted IDs are in the auto qualifier list
    my $submitted_autos = $submitted_ids->intersection($auto_ids);
    push(@{$response->{error}}, $lang->maketext("events.tournament.rounds.select-entrants.in-auto-qualifiers", $submitted_autos->size)) if $submitted_autos->size;
    
    # Check all the submitted values are in the non-qualifiers list
    push(@{$response->{error}}, $lang->maketext("events.tournament.rounds.select-entrants.invalid-entries")) if $non_auto_ids->includes($submitted_ids);
    
    # Check we have the right number of entrants selected
    my $expected_entrants = $self->round_of - $prev_round->num_qualifiers;
    push(@{$response->{error}}, $lang->maketext("events.tournament.rounds.select-entrants.wrong-number-of-entrants-selected", $submitted_ids->size, $expected_entrants)) if $submitted_ids->size != $expected_entrants;
  }
  
  if ( scalar @{$response->{error}} == 0 ) {
    # No errors, make our list
    # Translate our submitted IDs into the TournamentRound[Type] objects - these will be for the previous round, so we then need to grab the TournamentX object and create a
    # record for this tournament.
    my $entry_type = $self->entry_type;
    my ( $member_class, $round_member_class, $member_rel_tourn, $member_rel_round );
    if ( $entry_type eq "team" ) {
      $member_class = "Team";
      $member_rel_round = "tournament_round_teams";
      $member_rel_tourn = "tournament_team";
    } elsif ( $entry_type eq "singles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_round_people";
      $member_rel_tourn = "tournament_person";
    } elsif ( $entry_type eq "doubles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_rounds_doubles";
      $member_rel_tourn = "tournament_pair";
    }
    
    $round_member_class = "TournamentRound$member_class";
    
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Combine the audo IDs and the submitted ones into a single array 
    my @ids_to_create = ( @$auto_ids, @submitted_ids );
    foreach my $entrant ( @ids_to_create ) {
      # Find the entrant - we know it exists, because it was in the list of valid IDs we could select - this is why we also have no need to
      # check if this ID is for the correct tournament / round.
      $entrant = $schema->resultset($round_member_class)->find($entrant);
      my $tourn_entry = $entrant->$member_rel_tourn;
      my $new_round_entrant = $tourn_entry->create_related($member_rel_round, {
        tournament_round => $self->id,
      });
    }
    
    $transaction->commit;
    push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.entrants.update.success"));
    $response->{round} = $self; # Because the code we're returning to expects a round in the response 
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 delete_entrants

Delete the entrants from the round.

=cut

sub delete_entrants {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the entrants
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      manual_entrants => [],
    },
    completed => 0,
    can_complete => 1,
  };
  
  my %can = $self->can_update("delete-entrants");
  
  if ( !$can{allowed} ) {
    $response->{can_complete} = 0;
    push(@{$response->{level}}, $can{reason});
    return;
  }
  
  if ( scalar @{$response->{error}} == 0 ) {
    # No errors, make our list
    # Translate our submitted IDs into the TournamentRound[Type] objects - these will be for the previous round, so we then need to grab the TournamentX object and create a
    # record for this tournament.
    my $entry_type = $self->entry_type;
    my ( $member_class, $round_member_class, $member_rel_tourn, $member_rel_round );
    if ( $entry_type eq "team" ) {
      $member_class = "Team";
      $member_rel_round = "tournament_round_teams";
      $member_rel_tourn = "tournament_team";
    } elsif ( $entry_type eq "singles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_round_people";
      $member_rel_tourn = "tournament_person";
    } elsif ( $entry_type eq "doubles" ) {
      $member_class = "Person";
      $member_rel_round = "tournament_rounds_doubles";
      $member_rel_tourn = "tournament_pair";
    }
    
    $round_member_class = "TournamentRound$member_class";
    
    my $transaction = $self->result_source->schema->txn_scope_guard;
    $self->delete_related($member_rel_round);
    
    $transaction->commit;
    push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.entrants.delete.success"));
    $response->{round} = $self; # Because the code we're returning to expects a round in the response 
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 create_matches

Create the matches for this round.

=cut

sub create_matches {
  my $self = shift;
  my ( $group, $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $tournament = $self->tournament;
  my $entry_type = $self->entry_type;
  my $match_template = $self->match_template;
  my $handicapped = $match_template->handicapped;
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  # Hash structure:
  # $rounds{$roundnum}{round_date}{week_beginnind_id, week_beginning_date} = season week (team entry only)
  # $rounds{$roundnum}{matches}{$matchnum} = {
  #   home => (id),
  #   away team => (id),
  #   venue => (id), (null if using default),
  #   day (id), (null if using default),
  #   handicap => {headstart, awarded_to}
  #}
  # If this isn't a group round, there will only be one round, but we'll put it in the same structure (without the round_date element)
  my %rounds = ();
  my $group_round = $self->group_round;
  if ( $group_round ) {
    if ( defined($group) ) {
      # Make sure we have a group if it's a group round
      if ( $group->tournament_round->id != $self->id ) {
        # The group specified doesn't belong to this round, so can't be correct
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.matches.create.error.group-not-in-round", $self->name, encode_entities($self->tournament->name)));
        return $response;
      }
    } else {
      # No group specified
      push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.matches.create.error.group-not-specified", $self->name));
      return $response;
    }
    
    # Chekc from the group whether we can create matches
    my %can = $group->can_update("matches");
    if ( !$can{allowed} ) {
      push(@{$response->{$can{level}}}, $can{reason});
      return $response;
    }
    
    my $raw_data = $params->{rounds};
    foreach my $key ( keys %{$raw_data} ) {
      if ( $key =~ /^round_(\d{1,2})_week$/ ) {
        # Just the week setting, not related to the match
        $rounds{$1}{round_date}{week_beginning_id} = $raw_data->{$key};
      } elsif ( $key =~ /^round_(\d{1,2})_match_(\d{1,2})_(home|away|venue|day|handicap_award|handicap)$/ ) {
        if ( $3 eq "handicap" ) {
          $rounds{$1}{matches}{$2}{handicap}{headstart} = $raw_data->{$key};
        } elsif ( $3 eq "handicap_award" ) {
          $rounds{$1}{matches}{$2}{handicap}{awarded_to} = $raw_data->{$key};
        } else {
          $rounds{$1}{matches}{$2}{$3} = $raw_data->{$key} || undef;
        }
      }
    }
  } else {
    # Not a group round, check from the round whether we can create matches
    my %can = $self->can_update("matches");
    if ( !$can{allowed} ) {
      push(@{$response->{$can{level}}}, $can{reason});
      return $response;
    }
    
    my $raw_data = $params->{matches};
    foreach my $key ( keys %{$raw_data} ) {
      if ( $key =~ /^match_(\d{1,2})_(home|away|venue|day|handicap_award|handicap)$/ ) {
        if ( $2 eq "handicap" ) {
          $rounds{1}{matches}{$1}{handicap}{headstart} = $raw_data->{$key};
        } elsif ( $2 eq "handicap_award" ) {
          $rounds{1}{matches}{$1}{handicap}{awarded_to} = $raw_data->{$key};
        } else {
          $rounds{1}{matches}{$1}{$2} = $raw_data->{$key} || undef;
        }
      }
    }
    
    # Make sure group is undef
    undef($group);
  }
  
  # Master copy of the entrants - so we only have to get them from the DB once, then read them into a hash.
  my @entrants_master = $group_round ? $group->get_entrants : $self->get_entrants;
  my %entrants_master;
  $entrants_master{$_->object_id} = $_->object_name foreach @entrants_master;
  
  # Grab the season
  my $season = $tournament->event_season->season;
  
  my $last_week;
  # Loop through all the rounds we *should* have and check them
  # If it's not a group round, it'll just be looping from 1 to 1
  my $rounds = $group_round ? $group->match_rounds : 1;
  foreach my $round ( 1 .. $rounds ) {
    if ( $entry_type eq "team" ) {
      # If it's team entry, we need a season week to set these matches in
      if ( $group_round ) {
        if ( my $week_id = $rounds{$round}{round_date}{week_beginning_id} ) {
          my $week = $season->find_related("fixtures_weeks", {id => $week_id});
          
          if ( defined($week) ) {
            $rounds{$round}{round_date}{week_beginning_date} = $week->week_beginning_date;
            
            # The week is valid; ensure it doesn't occur prior to the last one.
            push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.date-occurs-before-previous-date", $round))
              if defined($last_week) and $week->week_beginning_date->ymd("") <= $last_week->week_beginning_date->ymd("");
            
            # Set the last season week so that we can check the next one occurs at a later date on the next iteration.
            $last_week = $week;
          } else {
            # Error, season week not found
            push(@{$response->{error}}, $lang->maketext("fixtures-grids.form.create-fixtures.error.week-invalid", $round));
          }
          
          $rounds{$round}{week} = $week;
        } else {
          # Error, season week not specified.
          push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.round-blank", $round));
        }
      }
    }
    
    # Setup the week date for this round
    my ( $week_date, $scheduled_date );
    my $wc = $self->week_commencing;
    if ( $group_round ) {
      $week_date = $rounds{$round}{round_date}{week_beginning_date};
    } else {
      if ( $wc ) {
        # Week commencing, set the week date from the round's date
        $week_date = $self->date;
      } else {
        $scheduled_date = $self->date;
      }
    }
    
    # Now loop through the matches and check all the data given
    # %used_entrants will hold entrants as we use them, with a count so we can check nothing is used more tha once in a given round
    # %entrants_to_use will hold all the entrants at the start, deleting as we use, so we can check at the end that there are none left
    # (there will be one left if we have an odd number of entrants, this is fine)
    my %used_entrants = ();
    my %entrants_to_use = %entrants_master;
    my $matches = $group_round ? $group->matches_per_round : $self->number_of_matches;
    foreach my $match ( 1 .. $matches ) {
      $logger->("debug", "match $match");
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
          $logger->("debug", sprintf("loction: %s, competitor: %s, name: %s", $home_away, $competitor, defined($competitor) ? $competitor->object_name : "not found"));
          
          if ( defined($competitor) ) {
            # Home team is valid, but check it's in the group
            my $has_entrant = $group_round ? $group->has_entrant($competitor) : $self->has_entrant($competitor);
            
            if ( $has_entrant ) {
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
              
              if ( defined($group) ) {
                # Group message
                push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-not-in-group", encode_entities($object_name), $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
              } else {
                # Round message
                push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.matches.create.error.comp-not-in-round", encode_entities($object_name), $lang->maketext("events.tournaments.rounds.create-matches.$home_away"), $match));
              }
            }
          } else {
            # Team is invalid
            push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-invalid", $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
          }
        } else {
          # Error, team not passed in
          push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.comp-blank", $lang->maketext("events.tournaments.rounds.groups.create-fixtures.$home_away"), $round, $match));
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
            push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.venue-inactive", encode_entities($venue->name), $round, $match));
          }
        } else {
          # Venue is now not defined after lookup, so can't have been valid
          push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.venue-invalid", $round, $match));
        }
      } else {
        # Venue not passed in - get it from the round settings if there's one there, or the team's home venue if not
        if ( defined($self->venue) ) {
          $rounds{$round}{matches}{$match}{venue} = $self->venue;
        } elsif ( defined($home_season) ) {
          $rounds{$round}{matches}{$match}{venue} = $home_season->club_season->venue;
        }
      }
      
      if ( $group_round ) {
        # Group round, take the submitted date for this round of matches
        if ( defined($day) ) {
          # Day passed in, so we will override the home team's night
          $day = $schema->resultset("LookupWeekday")->find($day) unless $day->isa("TopTable::Schema::Result::LookupWeekday");
          
          if ( defined($day) ) {
            # Set the date to be a DateTime object based on the day selected
            $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_date, $day->weekday_number);
            $rounds{$round}{matches}{$match}{day} = $day;
          } else {
            # Day is now not defined after lookup, so can't have been valid
            push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.day-invalid", $round, $match));
          }
        } else {
          # Otherwise use the home team's night
          $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_date, $home_season->home_night->weekday_number) if defined($home_season);
        }
      } else {
        # Not a group round, take the date from the round date
        if ( $wc ) {
          # Use the team's home night, set the day from the week date and home team's night - if this is not the case, the scheduled date is already set for all matches this round
          $scheduled_date = TopTable::Controller::Root::get_day_in_same_week($week_date, $home_season->home_night->weekday_number);
        }
      }
      
      $rounds{$round}{matches}{$match}{date} = $scheduled_date;
      
      # Check handicaps - first check if this is a handicapped event
      if ( defined($handicap_awarded_to) ) {
        # Handicap is defined
        if ( $handicapped ) {
          if ( $handicap_awarded_to eq "home" or $handicap_awarded_to eq "away" ) {
            if ( defined($handicap_start) ) {
              # Check there's a positive numeric value (not 0) in the handicap
              push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-invalid", $round, $match)) unless $handicap_start =~ /^[1-9]\d{0,2}$/;
            } else {
              # Error, no handicap set
              push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-not-set", $round, $match));
            }
          } elsif ( $handicap_awarded_to eq "set_later" or $handicap_awarded_to eq "scratch" ) {
            # Nothing to do here
          } else {
            # Error, invalid handicap option
            push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.invalid-handicap-option", $round, $match));
          }
        } else {
          # Handicap passed in, but the event isn't handicapped - this is just info, we can just not set the handicaps
          push(@{$response->{info}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-set-needlessly", $round, $match));
        }
      } else {
        # Handicap not defined - error 
        push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.error.handicap-option-blank", $round, $match)) if $handicapped;
      }
    }
    
    # Check nothing has been used more than once, and nothing has been left unused
    foreach my $entrant_used ( keys %used_entrants ) {
      push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrant-used-too-many-times", $round, $used_entrants{$entrant_used}{name}, $used_entrants{$entrant_used}{count})) if $used_entrants{$entrant_used}{count} > 1;
    }
    
    # Check nothing is left behind - slightly complicated by the fact we can have a bye round if there's an odd number ( % 2 gives a true value, because there is a remainder)
    my $bye_allowed = scalar @entrants_master % 2 ? 1 : 0;
    my $unused_count = scalar keys %entrants_to_use;
    if ( $bye_allowed ) {
      push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrants-unused-with-bye", $round)) if $unused_count > 1;
    } else {
      push(@{$response->{error}}, $lang->maketext("events.tournaments.rounds.groups.create-fixtures.entrants-unused", $round)) if $unused_count;
    }
  }
  
  $response->{fields}{rounds} = \%rounds;
  
  if ( @{$response->{error}} == 0 ) {
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
    foreach my $round ( 1 .. $rounds ) {
      my $scheduled_week = $rounds{$round}{round_date}{week_beginning_id};
      my $week_beginning_date = $rounds{$round}{round_date}{week_beginning_date};
      
      # Loop through the matches
      my $matches = $group_round ? $group->matches_per_round : $self->number_of_matches;
      foreach my $match ( 1 .. $matches ) {
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
            tournament_round => $self->id,
            tournament_group => defined($group) ? $group->id : undef,
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
      my $created_in = $group_round ? $group->name : $self->name;
      push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.create-matches.success", scalar(@match_ids), $created_in));
      
      $response->{match_ids} = \@match_ids;
      $response->{match_names} = \@match_names;
      $response->{matches} = \@matches;
    }
  }
  
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
  
  my %can = $self->can_update("delete-matches");
  if ( !$can{allowed} ) {
    push(@{$response->{$can{level}}}, $can{reason});
    return $response;
  }
  
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
      push(@{$response->{success}}, $lang->maketext("events.tournaments.rounds.delete-fixtures.success", $ok, $self->name));
    } else {
      # Not okay, log an error
      push(@{$response->{error}}, $lang->maktext("events.tournaments.rounds.groups.error.delete-failed"));
    }
  } else {
    $response->{rows} = 0;
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
