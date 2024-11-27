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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-18 10:55:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v1blubmQbg18+5yok20LDA

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

=head2 object_name

Get the name of the team from the team season object linked.

=cut

sub object_name {
  my $self = shift;
  return sprintf("%s %s", $self->team_season->club_season->short_name, $self->team_season->name);
}

=head2 matches_for_team

Return a list of all matches where the given team is playing

=cut

sub matches_for_team {
  my $self = shift;
  my $schema = $self->result_source->schema;
  
  my ( $params ) = @_;
  my $team = $params->{team};
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
