use utf8;
package TopTable::Schema::Result::TemplateMatchTeam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TemplateMatchTeam

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

=head1 TABLE: C<template_match_team>

=cut

__PACKAGE__->table("template_match_team");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 singles_players_per_team

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 winner_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

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
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "singles_players_per_team",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "winner_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 division_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->has_many(
  "division_seasons",
  "TopTable::Schema::Result::DivisionSeason",
  { "foreign.league_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_match_team_games

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchTeamGame>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_team_games",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchTeamGame",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_match_teams

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchTeam>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_teams",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchTeam",
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
  { "foreign.team_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 template_match_team_games

Type: has_many

Related object: L<TopTable::Schema::Result::TemplateMatchTeamGame>

=cut

__PACKAGE__->has_many(
  "template_match_team_games",
  "TopTable::Schema::Result::TemplateMatchTeamGame",
  { "foreign.team_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->has_many(
  "tournament_rounds",
  "TopTable::Schema::Result::TournamentRound",
  { "foreign.team_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 winner_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupWinnerType>

=cut

__PACKAGE__->belongs_to(
  "winner_type",
  "TopTable::Schema::Result::LookupWinnerType",
  { id => "winner_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-12-26 23:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2Sc3MAEUofXbaMG1CZDHaA

=head2 can_edit_or_delete

Checks whether this template is able to be deleted; it can be deleted if there are no matches or seasons in the database using it as a template.

=cut

sub can_edit_or_delete {
  my ( $self ) = @_;
  
  # Check seasons first, as this is quicker
  my $seasons_using_template = $self->search_related("division_seasons")->count;
  return 0 if $seasons_using_template;
  
  # Now check league matches
  my $league_matches_using_template = $self->search_related("team_matches")->count;
  return 0 if $league_matches_using_template;
  
  # If we get this far, we can delete
  return 1;
}

=head2 check_and_delete

Checks the template can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  
  # Check we can delete
  my $error .= sprintf( "%s cannot be deleted because there are seasons or matches assigned to it.\n", $self->name ) if !$self->can_edit_or_delete;
  
  # Delete
  my $ok = $self->delete if !$error;
  
  # Error if the delete was unsuccessful
  $error .= sprintf( "Error deleting %s", $self->full_name ) if !$ok;
  
  return $error;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
