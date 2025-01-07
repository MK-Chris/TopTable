use utf8;
package TopTable::Schema::Result::TournamentRoundTeam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TournamentRoundTeam

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

=head1 TABLE: C<tournament_round_teams>

=cut

__PACKAGE__->table("tournament_round_teams");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 tournament_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_group

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

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

=head2 table_points

  data_type: 'smallint'
  default_value: 0
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
  is_nullable: 1

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

=head2 grid_position

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 matches_cancelled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 last_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
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
  "tournament_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tournament_group",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
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
  "table_points",
  { data_type => "smallint", default_value => 0, is_nullable => 0 },
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
    is_nullable => 1,
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
  "grid_position",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "matches_cancelled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "last_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 tournament_group

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRoundGroup>

=cut

__PACKAGE__->belongs_to(
  "tournament_group",
  "TopTable::Schema::Result::TournamentRoundGroup",
  { id => "tournament_group" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_team_points_adjustments

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundTeamPointsAdjustment>

=cut

__PACKAGE__->has_many(
  "tournament_round_team_points_adjustments",
  "TopTable::Schema::Result::TournamentRoundTeamPointsAdjustment",
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundDoubles>

=cut

__PACKAGE__->has_many(
  "tournament_rounds_doubles",
  "TopTable::Schema::Result::TournamentRoundDoubles",
  { "foreign.tournament_round_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentTeam>

=cut

__PACKAGE__->belongs_to(
  "tournament_team",
  "TopTable::Schema::Result::TournamentTeam",
  { id => "tournament_team" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-12-31 16:31:44
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ReTa21DCDyED2ukXmjv0Wg

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 object_id

Return the ID of the team linked.

=cut

sub object_id {
  my $self = shift;
  return $self->tournament_team->team_season->team->id;
}

=head2 url_key

Return the ID of the team linked.

=cut

sub url_key {
  my $self = shift;
  return $self->tournament_team->team_season->team->url_key;
}

=head2 object_name

Get the name of the team from the team season object linked.

=cut

sub object_name {
  my $self = shift;
  
  my $team_season = $self->tournament_team->team_season;
  return sprintf("%s %s", $team_season->club_season->short_name, $team_season->name);
}

=head2 matches_for_team

Return a list of all matches where the given team is playing

=cut

sub matches_for_team {
  my $self = shift;
  my $schema = $self->result_source->schema;
  
  my ( $params ) = @_;
  my $team = $self->tournament_team->team_season->team;
  my $started = $params->{started};
  my $complete = $params->{complete};
  my $cancelled = $params->{cancelled};
  
  # Default criteria, always there
  my @where = ({
    "me.home_team" => $team->id,
    "tournament_round.id" => $self->tournament_round->id,
  }, {
    "me.away_team" => $team->id,
    "tournament_round.id" => $self->tournament_round->id,
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
    join => [qw( tournament_round )]
  });
}

=head2 adjust_points

Perform some error checking and then adjust the team's points.

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
  
  # Get the fields passed in
  my $action = $params->{action};
  my $points_adjustment = $params->{points_adjustment} || 0;
  my $reason = $params->{reason} || undef;
  
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 0, # Default to 0, we'll recreate that key in the overwritten $response from the team season if we get that far.
    fields => {
      # Action and reason don't need sanitising before adding to the fields hash; points adjustment does
      action => $action,
      reason => $reason,
    },
  };
  
  # Check we can override scores for this match, if not return with the error logged
  my %can = $self->tournament_team->can_update("points");
  
  unless ( $can{allowed} ) {
    push(@{$response->{errors}}, $can{reason});
    return $response;
  }
  
  # If we get this far, we can complete
  $response->{can_complete} = 1;
  
  # Check our fields
  push(@{$response->{errors}}, $lang->maketext("tournament.team.update.points.error.invalid-action")) unless defined($action) and ($action eq "award" or $action eq "deduct");
  
  if ( $points_adjustment =~ m/^[1-9]+$/ ) {
    # Points adjustment is fine, set it into the fields to be passed back
    $response->{fields}{points_adjustment} = $points_adjustment;
  } else {
    # Points adjustment is invalid
    push(@{$response->{errors}}, $lang->maketext("tournament.team.update.error.invalid-points-adjustment"));
  }
  
  push(@{$response->{errors}}, $lang->maketext("tournament.team.update.error.blank-reason")) unless defined($reason) and length($reason) > 0;
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # No errors, do the update
    # First get the ranking template in use
    my $group = $self->tournament_group;
    my $round = $self->tournament_round;
    my $rank_template = $round->rank_template;
    my $match_template = $round->match_template;
    
    # Now get the fields we're going to update, based on the ranking template
    my ( $points_field, $points_against_field, $diff_field );
    if ( $rank_template->assign_points ) {
      $points_field = "table_points";
    } else {
      if ( $match_template->winner_type->id eq "games" ) {
        $points_field = "games_won";
        $points_against_field = "games_lost";
        $diff_field = "games_difference";
      } else {
        $points_field = "points_won";
        $points_against_field = "points_lost";
        $diff_field = "points_difference";
      }
    }
    
    # Convert points adjustment to a minus if the action is deduct
    $points_adjustment *= -1 if $action eq "deduct";
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $schema->txn_scope_guard;
    
    # Create a new points adjustment record
    my $rec = $self->create_related("tournament_round_team_points_adjustments", {
      adjustment => $points_adjustment,
      reason => $reason,
    });
    
    # Update the team season
    $self->$points_field($self->$points_field + $points_adjustment);
    $self->$diff_field($self->$points_field - $self->$points_against_field) if defined($diff_field);
    $self->update;
    
    # Commit the transaction
    $transaction->commit;
    
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("tournament.team.update.success"));
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
