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
  { "foreign.object_round" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-12-31 16:31:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sSJSuNCYin8HUFVDFqaJYA

use HTML::Entities;
use List::MoreUtils qw( duplicates );
use Set::Object;

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
  
  # Setup schema / lang
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  return defined($self->_name) ? encode_entities($self->_name) : $lang->maketext("tournament.round.default-name", $self->round_number);
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
    return defined($self->team_match_template) ? $self->team_match_template : $self->tournament->default_team_match_template;
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
  
  my $round_number = $self->round_number;
  my $tourn = $self->tournament;
  my $entry_type = $self->entry_type;
  
  if ( $entry_type eq "teams" ) {
    # Teams - work out if we have matches
    my $matches = $self->search_related("team_matches");
    
    if ( $matches->count == 0 ) {
      # No matches, not complete
      return 0;
    } else {
      # Check if there's another round after this one
      my $next_round = $tourn->find_related("tournament_rounds", {round_number => $round_number + 1});
      
      # If there's a round after this one, it's complete
      return 1 if defined($next_round);
      
      # If there's no Check all matches are complete
      if ( $matches->incomplete_and_not_cancelled->count == 0 ) {
        # All matches are complete
        return 1;
      } else {
        # Not all matches are complete, round is not complete
        return 0;
      }
      
      return 1;
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
    errors => [],
    warnings => [],
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
    push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.season-not-current"));
    return $response;
  }
  
  if ( !$self->group_round ) {
    push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.not-group-round"));
    return $response;
  }
  
  if ( defined($group) ) {
    # Group specified, we must be editing
    $action = "edit";
    
    # Check the group passed is valid
    if ( $group->isa("TopTable::Schema::Result::TournamentRoundGroup") ) {
      # Group is defined, set the ability to edit settings from that
      $can_edit{fixtures} = $group->can_edit_fixtures_settings;
      $can_edit{members} = $group->can_edit_members;
      $can_edit{qualifiers} = $group->can_edit_auto_qualifiers;
      
      # Group order is the same as it was if we're editing
      $write_data{group_order} = $group->group_order;
    } else {
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.group-invalid"));
      
      # Another fatal error
      return $response;
    }
  } else {
    # No group specified, so we're creating
    $action = "create";
    
    # Creation means we just add to the list of groups at the end
    $write_data{group_order} = $self->next_group_order;
  }
  
  if ( $self->groups_can_be_named ) {
    # Check the names were entered and don't exist already.
    if ( defined($name) ) {
      # Name entered, check it.
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.name-exists", encode_entities($name))) if defined($schema->resultset("TournamentRoundGroup")->search_single_field($self, {field => "name", value => $name, exclusion_obj => $group}));
      $write_data{url_key} = $schema->resultset("TournamentRoundGroup")->make_url_key($self, $name, $group);
    } else {
      # Name omitted.
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.name-blank-but-shouldnt-be")) if $self->groups_must_be_named;
    }
    
    $write_data{name} = $name;
  } else {
    # Groups can't be named, so if we have a name specified, that's an error
    push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.name-not-blank-but-should-be")) if defined($name);
  }
  
  if ( $can_edit{fixtures} ) {
    # Sanity check - 1 or 0
    $manual_fixtures = $manual_fixtures ? 1 : 0;
    
    # Check the fixtures grid
    if ( defined($fixtures_grid) ) {
      # Fixtures grid selected - only valid if manual fixtures is false
      $fixtures_grid = $schema->resultset("FixturesGrid")->find_id_or_url_key($fixtures_grid) unless $fixtures_grid->isa("TopTable::Schema::Result::FixturesGrid");
      
      if ( $manual_fixtures ) {
        # Error, as manual fixtures and a fixtures grid have been specified
        push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.manual-fixtures-and-fixtures-grid"));
      } else {
        # Check the fixtures grid is valid
        push(@{$response->{errors}}, $lang->maketext("tournaments.rounds.group.field.form.error.grid-invalid")) unless defined($fixtures_grid);
      }
    } else {
      # Fixtures grid not selected - okay if manual fixtures is false, otherwise error
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.no-fixtures-grid-or-manual-fixtures")) unless $manual_fixtures;
    }
    
    $write_data{fixtures_grid} = defined($fixtures_grid) ? $fixtures_grid->id : undef;
  }
  
  $response->{fields}{manual_fixtures} = $manual_fixtures;
  
  my ( $member_class, %member_cls_attrib, $tourn_member_class, $round_member_class, $group_member_class, $member_rel_round );
  if ( $can_edit{members} ) {
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
          push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.doubles-members-needs-two-entries", ($idx + 1), $elms)) unless $elms == 2;
        } else {
          # Not an array, error
          push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.doubles-members-not-array", ($idx + 1)));
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
              
              push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.member-already-entered", encode_entities($name))) if $conflicting_groups->count;
            } else {
              # Not entered this season, error
              push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.not-entered-season", encode_entities($name), encode_entities($season->name)));
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
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.invalid-members-$plural", $invalid_members)) if $invalid_members;
    }
    
    # We now need to compare the submitted values to ensure there are no duplicates
    my @duplicates = duplicates(@dup_check);
    
    if ( scalar @duplicates ) {
      # We have some duplicates, so raise an error - to do this, we need to convert the IDs back to objects so we can display the names
      my @names = map(encode_entities($schema->resultset($member_class)->find_id_or_url_key($_)), @duplicates);
      
      # Get the last element from the list, as we don't want this to have commas before it
      my $last = pop(@names);
      my $duplicate_names = sprintf("%s %s %s", join(", ", @names), $lang->maketext("msg.and"), $last);
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.member-duplicates", $duplicate_names));
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
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.members-exceed-grid-maximum", $member_count, encode_entities($fixtures_grid->name), $fixtures_grid->maximum_teams));
    } elsif ( $member_count < 2 ) {
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.members-must-have-at-least-two"));
    }
  }
  
  # Look up the members from the IDs stored for the response field
  $response->{fields}{members} = [map($schema->resultset($member_class)->find($_, \%member_cls_attrib), @members)];
  
  # Check the number of qualifiers
  if ( $can_edit{qualifiers} ) {
    if ( defined($automatic_qualifiers) ) {
      # We have a value, ensure it's positive and numeric, and not more than the number of competitors in the group.
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.qualifiers-invalid")) unless $automatic_qualifiers =~ m/^\d+$/ or $automatic_qualifiers > scalar @members;
    } else {
      # Error, we need this specified
      push(@{$response->{errors}}, $lang->maketext("tournaments.round.group.form.error.qualifiers-blank"));
    }
    
    $write_data{automatic_qualifiers} = $automatic_qualifiers;
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
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
    if ( $can_edit{members} ) {
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
