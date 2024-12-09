use utf8;
package TopTable::Schema::Result::TemplateMatchTeam;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TemplateMatchTeam

=head1 DESCRIPTION

Team match templates - holds the main configuration for a team match; individual games within a team match are set within the match_templates_individual table.

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

=head2 handicapped

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 allow_final_score_override

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

Particularly helpful if the winner is calculated by points won and teams have calculated incorrectly, there may be rules in place to state the signed scorecard submitted has the final score.

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
  "handicapped",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "allow_final_score_override",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
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

=head2 tournaments

Type: has_many

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->has_many(
  "tournaments",
  "TopTable::Schema::Result::Tournament",
  { "foreign.default_team_match_template" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-05 09:18:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:5nY8Da0qetlvGg8xkNwvKA

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->url_key];
}

=head2 games

Return the games (TemplateMatchTeamGame) associated with this template in the order they're played in.

=cut

sub games {
  my ( $self ) = @_;
    return $self->search_related("template_match_team_games", undef, {
    prefetch => "individual_match_template",
    order_by => {
      -asc => "match_game_number"
    },
  });
}

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
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  my $enc_name = encode_entities($self->name);
  
  # Check we can delete
  unless ( $self->can_edit_or_delete ) {
    push(@{$response->{errors}}, $lang->maketext("templates.delete.error.not-allowed", $enc_name));
    return $response;
  }
  
  # Delete
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $enc_name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $enc_name));
  }
  
  return $response;
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name,
    url_keys => $self->url_keys,
    type => "template-match-individual"
  };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
