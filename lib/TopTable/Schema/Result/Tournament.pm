use utf8;
package TopTable::Schema::Result::Tournament;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Tournament

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

=head1 TABLE: C<tournaments>

=cut

__PACKAGE__->table("tournaments");

=head1 ACCESSORS

=head2 id

  data_type: 'bigint'
  is_auto_increment: 1
  is_nullable: 0

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

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 entry_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 allow_online_entries

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 default_team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 default_individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 allow_loan_players_below

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Allow loan players from a lower division than the match being played.  NULL inherits the setting from the season.

=head2 allow_loan_players_above

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Allow loan players from a higher division than the match being played.  NULL inherits the setting from the season.

=head2 allow_loan_players_across

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Allow loan players from the same division as the match being played.  NULL inherits the setting from the season.

=head2 allow_loan_players_multiple_teams

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Allow loan players to play on loan for more than one team.  NULL inherits the setting from the season.

=head2 allow_loan_players_same_club_only

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Only allow loan players from the same club as the team they are on loan for.  NULL inherits the setting from the season.

=head2 loan_players_limit_per_player

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Maximum number of times a player may play on loan in total (0 for no limit).  NULL inherits the setting from the season.

=head2 loan_players_limit_per_player_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Maximum number of times a player may play on loan for the same team (0 for no limit).  NULL inherits the setting from the season.

=head2 loan_players_limit_per_player_per_opposition

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Maximum number of times a player may play on loan against the same team (0 for no limit).  NULL inherits the setting from the season.

=head2 loan_players_limit_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Maximum number of times a team may play loan players (0 for no limit).  NULL inherits the setting from the season.

=head2 void_unplayed_games_if_both_teams_incomplete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Void games (no team wins) between a present and absent player if both teams have missing players.  NULL inherits the setting from the season.

=head2 forefeit_count_averages_if_game_not_started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

Count a game as won in the player averages even if it was not started (the opposition player pulled out before the game started).  NULL inherits the setting from the season.

=head2 missing_player_count_win_in_averages

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

If a player is missing, count as a win for the opposition players in the player averages.  NULL inherits the setting from the season.

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "bigint", is_auto_increment => 1, is_nullable => 0 },
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "entry_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "allow_online_entries",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "default_team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "default_individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "allow_loan_players_below",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "allow_loan_players_above",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "allow_loan_players_across",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "allow_loan_players_multiple_teams",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "allow_loan_players_same_club_only",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "loan_players_limit_per_player",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "loan_players_limit_per_player_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "loan_players_limit_per_player_per_opposition",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "loan_players_limit_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "void_unplayed_games_if_both_teams_incomplete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "forefeit_count_averages_if_game_not_started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "missing_player_count_win_in_averages",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 default_individual_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchIndividual>

=cut

__PACKAGE__->belongs_to(
  "default_individual_match_template",
  "TopTable::Schema::Result::TemplateMatchIndividual",
  { id => "default_individual_match_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 default_team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "default_team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "default_team_match_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 entry_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupTournamentType>

=cut

__PACKAGE__->belongs_to(
  "entry_type",
  "TopTable::Schema::Result::LookupTournamentType",
  { id => "entry_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 event_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->belongs_to(
  "event_season",
  "TopTable::Schema::Result::EventSeason",
  { event => "event", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentPerson>

=cut

__PACKAGE__->has_many(
  "tournament_people",
  "TopTable::Schema::Result::TournamentPerson",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->has_many(
  "tournament_rounds",
  "TopTable::Schema::Result::TournamentRound",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeam>

=cut

__PACKAGE__->has_many(
  "tournament_teams",
  "TopTable::Schema::Result::TournamentTeam",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournaments_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournaments_doubles",
  "TopTable::Schema::Result::TournamentDoubles",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-25 16:29:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zXGd/SsNUDmgatdvZbvNBQ
use HTML::Entities;
use POSIX;
use Math::Complex;

=head2 can_add_round

Check if we can create another round for the tournament, return 1 if we can or 0 if not. 

=cut

sub can_add_round {
  my $self = shift;
  
  if ( $self->has_ko_round ) {
    # We have a knock-out round, so we should know exactly how many rounds we need to create
    my $existing_ko_rounds = $self->search_related("tournament_rounds", {group_round => 0})->count;
    my $required_ko_rounds = $self->calculate_ko_rounds->{rounds};
    return $existing_ko_rounds < $required_ko_rounds ? 1 : 0;
  } else {
    # No knock-out rounds yet - we can create
    return 1;
  }
}

=head2 create_or_edit_round

Add or edit the given round number.  Should only be called by the application itself when adding - a round is never added manually.

=cut

sub create_or_edit_round {
  my $self = shift;
  my ( $round_number, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $name = $params->{round_name};
  my $group = $params->{round_group} || 0;
  my $rank_template = $params->{round_group_rank_template};
  my $team_match_template = $params->{round_team_match_template} || undef;
  my $individual_match_template = $params->{round_individual_match_template} || undef;
  my $date = $params->{round_date};
  my $week_commencing = $params->{round_week_commencing};
  my $venue = $params->{round_venue} || undef;
  my $round_of = $params->{round_of};
  
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {name => $name},
    completed => 0,
  };
  
  # Check there's the tournament is for the current season
  if ( $self->event_season->season->complete ) {
    push(@{$response->{error}}, $lang->maketext("tournaments.round.form.error.season-not-current"));
  }
  
  # Check the round number, if given
  my ( $round, $create );
  if ( defined($round_number) ) {
    $create = 0;
    $round = $self->find_related("tournament_rounds", {round_number => $round_number});
    
    if ( !defined($round) ) {
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.round-doesnt-exist"));
      return $response; # fatal
    }
  } else {
    # If a round number wasn't passed in, we create a new round, 
    $create = 1;
    $round_number = $self->next_round_number;
  }
  
  # Check we can create rounds
  if ( !$self->can_add_round ) {
    push(@{$response->{error}}, $lang->maketext("tournaments.form.error.rounds-complete", encode_entities($self->name)));
    return $response; # fatal
  }
  
  # Round name check - can be null, as we can just use the round number instead.  Must be unique to the current tournament
  if ( $create ) {
    push(@{$response->{error}}, $lang->maketext("tournaments.form.error.round-name-exists", encode_entities($name))) if defined($name) and defined($schema->resultset("TournamentRound")->search_single_field($self, {field => "name", value => $name}));
  } else {
    push(@{$response->{error}}, $lang->maketext("tournaments.form.error.round-name-exists", encode_entities($name))) if defined($name) and defined($schema->resultset("TournamentRound")->search_single_field($self, {field => "name", value => $name, exclusion_obj => $round}));
  }
  
  
  
  # Sanity check, the group flag must be 1 or 0
  $group = $group ? 1 : 0;
  
  # Can't have a group round past round 1, but this is easy to fix, so raise it as a warning and set the flag to 0
  if ( $group and $round_number > 1 ) {
    push(@{$response->{warning}}, $lang->maketext("tournaments.form.error.group-round-past-round1-not-allowed"));
    $group = 0;
  }
  
  if ( $group ) {
    # If it's a group round, we need a ranking template
    # Check the template
    if ( defined($rank_template) ) {
      $rank_template = $schema->resultset("TemplateLeagueTableRanking")->find($rank_template) unless $rank_template->isa("TopTable::Schema::Result::TemplateLeagueTableRanking");
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.group-round-invalid-rank-template")) unless defined($rank_template);
    } else {
      # No rank template
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.group-round-needs-rank-template"));
    }
  }
  
  # Get the class to check the template again based on whether this is a team entry or not
  my ( $match_template, $tpl_class, $tpl_fld ) = $self->entry_type->id eq "team"
    ? ($team_match_template, qw( TemplateMatchTeam team_match_template ))
    : ($individual_match_template, qw( TemplateMatchIndividual individual_match_template ));
  
  # Check the template
  if ( defined($match_template) ) {
    $match_template = $schema->resultset($tpl_class)->find($match_template) unless $match_template->isa("TopTable::Schema::Result::$tpl_class");
    push(@{$response->{error}}, $lang->maketext("events.form.error.round.match-template-invalid")) unless defined($match_template);
  }
  
  # Check the date if it was sent
  if ( defined($date) ) {
    # Check if the week beginning field is ticked - if it is, we require a Monday to be selected
    $week_commencing = ( defined($week_commencing) and $week_commencing ) ? 1 : 0;
    my $date_error = 0;
    
    if ( ref($date) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $date->{year};
      my $month = $date->{month};
      my $day = $date->{day};
      
      # Make sure the date is valid
      try {
        $date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        push(@{$response->{error}}, $lang->maketext("tournaments.form.error.date-invalid"));
        $date_error = 1;
      };
    } elsif ( !$date->isa("DateTime") ) {
      # Not a hashref, not a DateTime
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.date-invalid"));
      $date_error = 1;
    }
    
    if ( !$date_error ) {
      push(@{$response->{error}}, $lang->maketext("tournaments.rounds.form.error.date-should-be-monday", $date->day_name)) if $week_commencing and $date->day_of_week != 1;
    }
  } else {
    # Week beginning has to be undef if the date is also
    undef($week_commencing);
    
    # If it's not a group round, we need a date
    if ( !$group ) {
      push(@{$response->{error}}, $lang->maketext("tournaments.rounds.form.error.date-required"));
    }
  }
  
  # Check the venue if it was sent
  if ( defined($venue) ) {
    # Venue has been passed, make sure it's valid
    if ( !$venue->isa("TopTable::Schema::Result::Venue") ) {
      # Venue hasn't been passed in as an object, try and lookup as an ID / URL key
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue);
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.venue-invalid")) unless defined($venue);
    }
    
    # Now check the venue is active if we have one
    push(@{$response->{error}}, $lang->maketext("tournaments.form.error.venue-inactive", encode_entities($venue->name))) if defined($venue) and !$venue->active;
  }
  
  if ( defined($round_of) ) {
    my ( $group_round, $group_qualifiers );
    
    if ( $self->has_group_round ) {
      $group_round = $self->find_round_by_number_or_url_key(1);
      $group_qualifiers = $group_round->qualifiers;
    }
    
    if ( $round_of =~ m/^\d+$/ ) {
      # Number of entrants is valid, save the value into the fields to be written back in case of errors
      $response->{fields}{round_of} = $round_of;
      
      # If the number of qualifiers from the group rounds is greater than the number we've specified here, we need to ask the user to increase
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.number-of-entrants-too-low", $group_qualifiers)) if $self->has_group_round and $round_of < $group_qualifiers;
    } else {
      # Number of entrants invalid
      push(@{$response->{error}}, $lang->maketext("tournaments.form.error.number-of-entrants-invalid-min", $group_qualifiers));
    }
  } else {
    push(@{$response->{error}}, $lang->maketext("tournaments.form.error.number-of-entrants-required")) unless $group or $self->has_ko_round;
  }
  
  if ( scalar(@{$response->{error}}) == 0 ) {
    # Success, we need to create / edit the event
    # Build the key from the name
    my $url_key = $schema->resultset("TournamentRound")->make_url_key($self, $name, $round) if defined($name);
    
    if ( $create ) {
      $round = $self->create_related("tournament_rounds", {
        url_key => $url_key,
        round_number => $round_number,
        name => $name,
        group_round => $group,
        rank_template => $rank_template,
        $tpl_fld => defined($match_template) ? $match_template->id : undef,
        date => defined($date) ? $date->ymd : undef,
        week_commencing => $week_commencing,
        venue => defined($venue) ? $venue->id : undef,
        round_of => $round_of,
      });
    } else {
      $round->update({
        url_key => $url_key,
        round_number => $round_number,
        name => $name,
        group_round => $group,
        $tpl_fld => defined($match_template) ? $match_template->id : undef,
        date => defined($date) ? $date->ymd : undef,
        week_commencing => $week_commencing,
        venue => defined($venue) ? $venue->id : undef,
        round_of => $round_of,
      });
    }
    
    $response->{round} = $round;
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 next_round_number

Return the next round number to be created.

=cut

sub next_round_number {
  my $self = shift;
  
  my $last_round_number = $self->search_related("tournament_rounds", {}, {
    columns => [{
      last_round_number => {max => "round_number"}
    }],
  })->single->get_column("last_round_number");
  
  # Next round number is either the last round number + 1, or round 1
  my $next_round_number = defined($last_round_number) ? $last_round_number + 1 : 1;
  
  # Return the date as a DateTime object if we have a result; if not return undef
  return $next_round_number;
}

=head2 can_edit_default_templates

Determines whether the match and ranking (for groups only) templates can be edited.  They can't if matches already exist in the tournament.

=cut

sub can_edit_default_templates {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  
  # Now search for the event-type specific stuff, if there are any
  my $event_season = $self->event_season;
  my $season = $event_season->season;
  
  if ( $season->complete ) {
    # Season complete, nothing can be edited
    return 0;
  } else {
    my $matches = $schema->resultset("TeamMatch")->search({
      "tournament.id" => $self->id,
    }, {
      join => {
        tournament_round => [qw( tournament )]
      }
    });
    
    return 0 if $matches->count;
  }
  
  # If we get this far, we can edit the event type
  return 1;
}

=head2 has_group_round

Return 1 if the tournament has a group round, or 0 if not.  Group rounds can only be round 1.

=cut

sub has_group_round {
  my $self = shift;
  return $self->search_related("tournament_rounds", {group_round => 1})->count ? 1 : 0;
}

=head2 has_ko_round

Return 1 if the tournament has at least one knock-out round, or 0 if not.

=cut

sub has_ko_round {
  my $self = shift;
  return $self->search_related("tournament_rounds", {group_round => 0})->count ? 1 : 0;
}

=head2 calculate_ko_rounds

Takes a number of participants and calculates the number of knock-out rounds that will be needed to whittle it down to a two-participant final.  Also returns the number of byes in the first round required, if we can't have matches for everyone.

Returned as a hash (or hashref in scalar context): %response = (rounds => x, byes => y).

=cut

sub calculate_ko_rounds {
  my $self = shift;
  
  # If we don't have a knock-out round yet, we can't work out how many rounds will be needed.
  return undef unless $self->has_ko_round;
  
  my $ko = $self->first_ko_round;
  
  # If the round is complete, we'll take the entrants that have been setup, otherwise take the entered value
  my $players = $ko->complete ? $ko->entrants : $ko->round_of;
  
  # Rounds is base 2 logarithm of the number of players, rounded up (ceil).
  my $rounds = ceil(logn($players, 2));
  
  # Byes is 2 to the power of the number of rounds, minus the number of players
  my $byes = (2 ** $rounds) - $players;
  
  # Return our values
  my %response = (rounds => $rounds, byes => $byes);
  return wantarray ? %response : \%response;
}

=head2 rounds

Return the rounds in round number order.

=cut

sub rounds {
  my $self = shift;
  return $self->search_related("tournament_rounds", {}, {
    order_by => {-asc => [qw( round_number )]}
  });
}

=head2 find_round_by_number_or_url_key

Get a specific round number, either by round number or URL key.

=cut

sub find_round_by_number_or_url_key {
  my $self = shift;
  my ( $round_id ) = @_;
  
  if ( $round_id =~ m/^\d+$/ ) {
    # Numeric value, check the ID first, then check the URL key
    my $obj = $self->find_related("tournament_rounds", {round_number => $round_id}, {
      prefetch => [qw( venue )],
    });
    return $obj if defined($obj);
    $obj = $self->find_related("tournament_rounds", {url_key => $round_id}, {
      prefetch => [qw( venue )],
    });
    return $obj;
  } else {
    # Not numeric, so it can't be the ID - just check the URL key
    return $self->find_related("tournament_rounds", {url_key => $round_id}, {
      prefetch => [qw( venue )],
    });
  }
}

=head2 first_ko_round

Return the first round that's a knockout round (not a group round).  This will either be round 1 or 2.

=cut

sub first_ko_round {
  my $self = shift;
  
  return $self->search_related("tournament_rounds", {group_round => 0}, {
    order_by => {-asc => [qw( round_number )]},
    rows => 1,
  })->single;
}

=head2 get_team_by_url_key

Return a team searched for by URL key if they are in the tournament.

=cut

sub get_team_by_url_key {
  my $self = shift;
  my ( $club_url_key, $team_url_key ) = @_;
  return $self->find_related("tournament_teams", {
    "club.url_key" => $club_url_key,
    "team.url_key" => $team_url_key,
  }, {
    prefetch => {
      team_season => [qw( division_season team ), {
        club_season => [qw( club )],
      }],
    },
  });
}

=head2 get_team_by_id

Return a team searched for by ID if they are in the tournament.

=cut

sub get_team_by_id {
  my $self = shift;
  my ( $team_id ) = @_;
  return $self->find_related("tournament_teams", {"tournament_teams.id" => $team_id}, {
    prefetch => {
      team_season => [qw( division_season team ), {
        club_season => [qw( club )],
      }],
    },
  });
}

=head2 get_person

Return a person if they are in the tournament.

=cut

sub get_person {
  my $self = shift;
  my ( $person_id ) = @_;
  return $self->find_related("tournament_people", {"person.id" => $person_id}, {
    prefetch => {
      tournament_team => {
        team_season => [qw( division_season team ), {
          club_season => [qw( club )],
        }],
      },
      person_season => [qw( person )],
    },
  });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
