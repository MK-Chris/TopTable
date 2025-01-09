use utf8;
package TopTable::Schema::Result::TournamentTeam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentTeam

=head1 DESCRIPTION

Tournament teams - team stats for team tournaments are held here.  Individual (singles / doubles) are also listed here in the same way that person_seasons / doubles_pairs links to a team_seasons

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

=head1 TABLE: C<tournament_teams>

=cut

__PACKAGE__->table("tournament_teams");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 matches_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 matches_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 total_handicap

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 points_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_game_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_games_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_legs_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_legs_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 doubles_points_played

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_won

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_lost

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_points_difference

  data_type: 'smallint'
  default_value: 0
  is_nullable: 0

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 matches_cancelled

  data_type: 'tinyint'
  default_value: 0
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
  "event",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "team",
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
  "matches_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "matches_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "total_handicap",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "points_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_game_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_games_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_legs_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_legs_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "doubles_points_played",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_won",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_lost",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_points_difference",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "matches_cancelled",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 system_event_log_tourn_teams

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTournTeam>

=cut

__PACKAGE__->has_many(
  "system_event_log_tourn_teams",
  "TopTable::Schema::Result::SystemEventLogTournTeam",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->belongs_to(
  "team_season",
  "TopTable::Schema::Result::TeamSeason",
  { season => "season", team => "team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
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

=head2 tournament_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentPerson>

=cut

__PACKAGE__->has_many(
  "tournament_people",
  "TopTable::Schema::Result::TournamentPerson",
  { "foreign.tournament_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundTeam>

=cut

__PACKAGE__->has_many(
  "tournament_round_teams",
  "TopTable::Schema::Result::TournamentRoundTeam",
  { "foreign.tournament_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournaments_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournaments_doubles",
  "TopTable::Schema::Result::TournamentDoubles",
  { "foreign.tournament_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-01-07 10:38:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kd9F91sMIAOZFuZj2D7IwQ

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 object_id

Return the ID of the team linked.

=cut

sub object_id {
  my $self = shift;
  return $self->team_season->team->id;
}

=head2 url_key

Return the ID of the team linked.

=cut

sub url_key {
  my $self = shift;
  return $self->team_season->team->url_key;
}

=head2 object_name

Get the name of the team from the team season object linked.

=cut

sub object_name {
  my $self = shift;
  return sprintf("%s %s", $self->team_season->club_season->short_name, $self->team_season->name);
}

=head2 can_update($type)

1 if we can update the team $type; 0 if not.

In list context, a hash will be returned with keys 'allowed' (1 or 0) and potentially 'reason' (if not allowed, to give the reason we can't update).  The reason can be passed back in the interface as an error message.

No permissions are checked here, this is purely to see if it's possible to update the match based on season / tournament.

$type tells us what we want to update and is currently only allowed to be "points" (for points adjustments), but maybe expanded in future.  If not passed, we get a hash (or hashref in scalar context) of all types - scalar context just returns 1 or 0 for all of these, list context returns the hashref with allowed and reason keys.  If nothing can be updated for the same reason (i.e., the season is complete), the types will not be returned, and you'll get a 1 or 0 in scalar context, or 'allowed' and 'reason' keys in list context, just as if it had been called with a specific type.

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
  return undef if defined($type) and $type ne "points";
  
  # Default to allowed.
  my $allowed = 1;
  my $reason;
  my $season = $self->tournament->event_season->season;
  
  # If the season is complete, we can't update anything
  if ( $season->complete ) {
    $allowed = 0;
    $reason = $lang->maketext("matches.update.error.season-complete");
    return wantarray ? (allowed => $allowed, reason => $reason) : $allowed;
  }
  
  # What we do now depends on type.
  if ( defined($type) ) {
    if ( $type eq "points" ) {
      my %can = $self->_can_update_points;
      $reason = $can{reason};
      $allowed = $can{allowed};
    }
    
    # Return the requested results
    return wantarray ? (allowed => $allowed, reason => $reason) : $allowed;
  } else {
    # All types, get the hashes back for each one
    my %points = $self->_can_update_points;
    
    my %types = wantarray
      ? (
          points => {
            allowed => $points{allowed},
            reason => $points{reason},
          },
        ) # We want the reasons back if we've asked for an array, the hash will contain 'allowed' and 'reason' keys
      : (
        points => $points{allowed},
      );
    
    # Return a reference to the hash in scalar context, or the hash itself in list context
    return wantarray ? %types : \%types;
  }
}

=head2 _can_update_points

Internal methods, do not call directly.  These assume the check for $season->complete has been done, so we only check the other parts.  Called from can_update.

These always return the hashed version with reason, for ease - can_update decides whether or not to use the reason.

=cut

sub _can_update_points {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $allowed = 1;
  my $reason;
  
  my $tourn = $self->tournament;
  if ( $tourn->has_group_round ) {
    my $group_round = $tourn->find_round_by_number_or_url_key(1);
    
    if ( $group_round->complete ) {
      # Can't update points in a complete group round
      $allowed = 0;
      $reason = $lang->maketext("tournament.team.update.points.error.group-round-complete");
    }
  } else {
    # Can't update points in a group round
    $allowed = 0;
    $reason = $lang->maketext("tournament.team.update.points.error.no-group-round");
  }
  
  return (allowed => $allowed, reason => $reason);
}

=head2 adjust_points($params)

Shortcut to adjust the points for a team in the tournament group they're in; gets the relevant TournamentRoundTeam and returns with an error if there we can't do it.

=cut

sub adjust_points {
  my $self = shift;
  my ( $params ) = @_;
  
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 0, # Default to 0, we'll recreate that key in the overwritten $response from the team season if we get that far.
  };
  
  # Check we can override scores for this match, if not return with the error logged
  my %can = $self->can_update("points");
  
  unless ( $can{allowed} ) {
    push(@{$response->{error}}, $can{reason});
    return $response;
  }
  
  # If we get this far, we can
  $response->{can_complete} = 1;
  my $group_round = $self->tournament->find_round_by_number_or_url_key(1);
  my $tourn_round_team = $self->find_related("tournament_round_teams", {"tournament_round.id" => $group_round->id}, {
    join => [qw( tournament_round )],
  });
  
  if ( defined($tourn_round_team) ) {
    $response = $tourn_round_team->adjust_points($params);
  } else {
    push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.team-not-entered-season", encode_entities($self->full_name)));
  }
}

=head2 points_adjustments

Get all the adjustments for the team's season.

=cut

sub points_adjustments {
  my $self = shift;
  
  my $tourn = $self->tournament;
  
  # No points adjustments possible if there's no group round
  return undef unless $tourn->has_group_round;
  my $group_round = $self->tournament->find_round_by_number_or_url_key(1);
  my $tourn_round_team = $self->find_related("tournament_round_teams", {"tournament_round.id" => $group_round->id}, {
    join => [qw( tournament_round )],
  });
  
  return $tourn_round_team->search_related("tournament_round_team_points_adjustments");
}

=head2 matches_for_team

Return a list of all matches where the given team is playing

=cut

sub matches_for_team {
  my $self = shift;
  my $schema = $self->result_source->schema;
  
  my ( $params ) = @_;
  my $team = $self->team_season->team;
  my $started = $params->{started};
  my $complete = $params->{complete};
  my $cancelled = $params->{cancelled};
  
  # Default criteria, always there
  my @where = ({
    "me.home_team" => $team->id,
    "tournament.season" => $self->season,
    "tournament.event" => $self->event,
  }, {
    "me.away_team" => $team->id,
    "tournament.season" => $self->season,
    "tournament.event" => $self->event,
  });
  
  # Add status stipulations if required
  if ( $started ) {
    $where[0]{"me.started"} = 1;
    $where[1]{"me.started"} = 1;
  }
  
  if ( $complete ) {
    $where[0]{"me.complete"} = 1;
    $where[1]{"me.complete"} = 1;
  }
  
  if ( $cancelled ) {
    $where[0]{"me.cancelled"} = 1;
    $where[1]{"me.cancelled"} = 1;
  }
  
  return $schema->resultset("TeamMatch")->search(\@where, {
    join => {
      tournament_round => [qw( tournament )]
    },
  });
}

=head2 singles_averages

Get the averages for the singles matches for the team within the tournament.

=cut

sub singles_averages {
  my $self = shift;
  my ( $params ) = @_;
  my $player_type = $params->{player_type} || undef;
  my $criteria_field = $params->{criteria_field} || undef;
  my $operator = $params->{operator} || undef;
  my $criteria_type = $params->{criteria_type} || undef;
  my $criteria = $params->{criteria} || undef;
  my $log = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.

  # Set up the team if there is one
  my %where;
  
  # Set up the player type if there is one
  if ( defined($player_type) ) {
    $player_type = [$player_type] unless ref($player_type) eq "ARRAY";
    $where{"me.team_membership_type"} = {-in => $player_type};
  }
  
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and defined($criteria_type) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    if ( $criteria_type eq "matches-pc" ) {
      # We need to work out a percentage of the available matches, which means we need to work out the percentage from the criteria, rather than use it directly
      $where{"me.matches_played"} = {
        $operator => \sprintf("((team_season.matches_played - team_season.matches_cancelled) / 100) * %d", $criteria),
      };
    } else {
      $where{sprintf("me.%s_%s", $criteria_type, $criteria_field)} = {
        $operator => $criteria,
      };
    }
  }
  return $self->search_related("tournament_people", \%where, {
    prefetch => {
      person_season => [qw( person team_membership_type )],
    },
    order_by  => [{
      -desc => [qw( me.average_game_wins me.games_played me.games_won me.matches_played)]}, {
      -asc => [qw( person_season.surname person_season.first_name)]}
    ],
  });
}

=head2 doubles_individual_averages

Get the averages for the doubles matches for individual players within the team for this tournament.

=cut

sub doubles_individual_averages {
  my $self = shift;
  my ( $params ) = @_;
  my $player_type = $params->{player_type};
  my $criteria_field = $params->{criteria_field};
  my $operator = $params->{operator};
  my $criteria = $params->{criteria};
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.

  # Set up the team if there is one
  my %where;
  
  # Set up the player type if there is one
  if ( defined($player_type) ) {
    $player_type = [$player_type] unless ref($player_type) eq "ARRAY";
    $where{"me.team_membership_type"} = {-in => $player_type};
  }
  
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where{sprintf("me.doubles_games_%s", $criteria_field)} = {
      $operator => $criteria,
    };
  }
  
  return $self->search_related("tournament_people", \%where, {
    prefetch => {
      person_season => [qw( person team_membership_type )],
    },
    order_by => [{
      -desc => [qw( me.doubles_average_game_wins me.doubles_games_played me.doubles_games_won )],
    }, {
      -asc => [qw( person_season.surname person_season.first_name )],
    }],
  });
}

=head2 doubles_pairs_averages

Get the averages for the doubles matches for pairs within the team for this tournament.

=cut

sub doubles_pairs_averages {
  my $self = shift;
  my ( $params ) = @_;
  my $criteria_field = $params->{criteria_field};
  my $operator = $params->{operator};
  my $criteria = $params->{criteria};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  $logger->("debug", "Searching for doubles pairs");
  my %where;
  if ( defined($criteria_field) and defined($operator) and defined($criteria) and ( $operator eq "<" or $operator eq "<=" or $operator eq "=" or $operator eq ">=" or $operator eq ">" ) and $criteria =~ /^\d+$/ ) {
    $where{sprintf("me.games_%s", $criteria_field)} = {
      $operator => $criteria,
    };
  }
  
  my $recs = $self->search_related("tournaments_doubles", \%where, {
    prefetch  => {
      season_pair => {
        person_season_person1_season_team => [qw( person team_membership_type )],
        person_season_person2_season_team => [qw( person team_membership_type )],
      },
    },
    order_by  => [{
      -desc => [qw( me.average_game_wins me.games_played me.games_won )],
    }, {
      -asc  => [qw( person_season_person1_season_team.surname person_season_person1_season_team.first_name person_season_person2_season_team.surname person_season_person2_season_team.first_name )],
    }],
  });
  
  $logger->("debug", sprintf("Found %d records", $recs->count));
  
  return $recs
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
