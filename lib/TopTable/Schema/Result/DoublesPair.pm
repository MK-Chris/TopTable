use utf8;
package TopTable::Schema::Result::DoublesPair;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::DoublesPair

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

=head1 TABLE: C<doubles_pairs>

=cut

__PACKAGE__->table("doubles_pairs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 person1

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person2

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 person1_loan

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person2_loan

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

=head2 legs_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
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
  "person1",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person2",
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
  "team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "person1_loan",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person2_loan",
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
  "legs_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "tinyint",
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

=head2 person_season_person1_season_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->belongs_to(
  "person_season_person1_season_team",
  "TopTable::Schema::Result::PersonSeason",
  { person => "person1", season => "season", team => "team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person_season_person2_season_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->belongs_to(
  "person_season_person2_season_team",
  "TopTable::Schema::Result::PersonSeason",
  { person => "person2", season => "season", team => "team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 season

Type: belongs_to

Related object: L<TopTable::Schema::Result::Season>

=cut

__PACKAGE__->belongs_to(
  "season",
  "TopTable::Schema::Result::Season",
  { id => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_match_games_away_doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games_away_doubles_pairs",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.away_doubles_pair" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games_home_doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games_home_doubles_pairs",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.home_doubles_pair" => "self.id" },
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

=head2 tournaments_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournaments_doubles",
  "TopTable::Schema::Result::TournamentDoubles",
  { "foreign.season_pair" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:tpPWZqs0jEChIo0v+x3VWQ

__PACKAGE__->add_columns(
    "last_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2

A simple way to get the URL keys for both pairs returned as an array.

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->person_season_person1_season_team->person->url_key, $self->person_season_person2_season_team->person->url_key];
}

=head2 object_name1

Player 1 object name.

=cut

sub object_name1 {
  my $self = shift;
  return $self->person_season_person1_season_team->display_name;
}

=head2 object_name2

Player 2 object name.

=cut

sub object_name2 {
  my $self = shift;
  return $self->person_season_person2_season_team->display_name;
}

=head2 head_to_heads

Return a list of head-to-heads with this pair and the other people specified in the function call.  Pass in an ID / URL key or a person object.

=cut

sub head_to_heads {
  my ( $self, $params ) = @_;
  my $schema = $self->result_source->schema;
  my ( $opponent1, $opponent2 ) = ( @{$params->{opponents}} );
  
  $opponent1 = $schema->resultset("Person")->find_id_or_url_key($opponent1) unless ref($opponent1);
  $opponent2 = $schema->resultset("Person")->find_id_or_url_key($opponent2) unless ref($opponent2);
  
  # Make sure the person is valid
  return undef unless defined($opponent1) and defined($opponent2);
  
  # Get the IDs to use in an IN statement
  my @opponent_ids = map($_->id, $opponent1, $opponent2);
  
  # This is a search regardless of season - because doubles pairs are tied to a season, we need to extract out person1 and 2 from this and use that in the search
  # No need to map, we can just use the field names here (not the relationship name, as that means going to that table)
  my @player_ids = ($self->person1, $self->person2);
  
  # Get all the doubles pairs that have these people in - do this for this pair and the opponent pair
  # We have a list of two IDs, and they must both appear in either person1 or person2
  my @doubles_pairs = $schema->resultset("DoublesPair")->search({
    person1 => {-in => \@player_ids},
    person2 => {-in => \@player_ids},
  });
  
  my @opponent_pairs = $schema->resultset("DoublesPair")->search({
    person1 => {-in => \@opponent_ids},
    person2 => {-in => \@opponent_ids},
  });
  
  # Then map to the IDs
  @doubles_pairs = map($_->id, @doubles_pairs);
  @opponent_pairs = map($_->id, @opponent_pairs);
  
  
  return $schema->resultset("TeamMatchGame")->search([{
    "home_doubles_pair.id" => {-in => \@doubles_pairs},
    "away_doubles_pair.id" => {-in => \@opponent_pairs},
    doubles_game => 1,
  }, {
    "home_doubles_pair.id" => {-in => \@opponent_pairs},
    "away_doubles_pair.id" => {-in => \@doubles_pairs},
    doubles_game => 1,
  }], {
    prefetch => [{
      home_doubles_pair => [{
        person_season_person1_season_team => "person",
        person_season_person2_season_team => "person",
      }],
      away_doubles_pair => [{
        person_season_person1_season_team => "person",
        person_season_person2_season_team => "person",
      }],
      team_match => [{
        division_season => "division",
        team_season_home_team_season => [qw( team ), {
          club_season => "club",
        }],
        team_season_away_team_season => [qw( team ), {
          club_season => "club",
        }],
      }, qw( season venue )],
    }, qw( team_match_legs )],
    order_by => {-asc => [qw( season.start_date season.end_date team_match.played_date )]},
  });
}

=head2 eq

Determine whether the people in this doubles pair are the same as the one passed in; return 1 or 0 accordingly.

=cut

sub eq {
  my ( $self, $comparison ) = @_;
  
  if ( $self->id == $comparison->id ) {
    return 1;
  } elsif ( ($self->person_season_person1_season_team->person->id == $comparison->person_season_person1_season_team->person->id || $self->person_season_person1_season_team->person->id == $comparison->person_season_person2_season_team->person->id)
      && ($self->person_season_person2_season_team->person->id == $comparison->person_season_person1_season_team->person->id || $self->person_season_person2_season_team->person->id == $comparison->person_season_person2_season_team->person->id) ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 contains

Check to see if one of the people in this pair is the passed in person (i.e., the doubles pair contains the person we're checking). 1 = yes, 0 = no.

=cut

sub contains {
  my ( $self, $person ) = @_;
  
  return ($self->person_season_person1_season_team->person->id == $person->id or $self->person_season_person2_season_team->person->id == $person->id) ? 1 : 0;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
