use utf8;
package TopTable::Schema::Result::TemplateMatchTeamGame;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TemplateMatchTeamGame

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

=head1 TABLE: C<template_match_team_games>

=cut

__PACKAGE__->table("template_match_team_games");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 match_game_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_game

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 singles_home_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

Only used for singles

=head2 singles_away_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

Only used for singles

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "match_game_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "doubles_game",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "singles_home_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "singles_away_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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

=head2 team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "team_match_template" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:S87dI4UgbfMxtvfKtLD8VA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
