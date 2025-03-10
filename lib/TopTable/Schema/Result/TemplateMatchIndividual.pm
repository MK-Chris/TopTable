use utf8;
package TopTable::Schema::Result::TemplateMatchIndividual;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TemplateMatchIndividual

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

=head1 TABLE: C<template_match_individual>

=cut

__PACKAGE__->table("template_match_individual");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 game_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 legs_per_game

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 minimum_points_win

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 clear_points_win

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 serve_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 serves

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 serves_deuce

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 handicapped

  data_type: 'tinyint'
  default_value: 0
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
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 60 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "game_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "legs_per_game",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "minimum_points_win",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "clear_points_win",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "serve_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "serves",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "serves_deuce",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "handicapped",
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

=head2 game_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupGameType>

=cut

__PACKAGE__->belongs_to(
  "game_type",
  "TopTable::Schema::Result::LookupGameType",
  { id => "game_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 serve_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupServeType>

=cut

__PACKAGE__->belongs_to(
  "serve_type",
  "TopTable::Schema::Result::LookupServeType",
  { id => "serve_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 system_event_log_template_match_individuals

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchIndividual>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_individuals",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchIndividual",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.individual_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 template_match_team_games

Type: has_many

Related object: L<TopTable::Schema::Result::TemplateMatchTeamGame>

=cut

__PACKAGE__->has_many(
  "template_match_team_games",
  "TopTable::Schema::Result::TemplateMatchTeamGame",
  { "foreign.individual_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->has_many(
  "tournament_rounds",
  "TopTable::Schema::Result::TournamentRound",
  { "foreign.individual_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournaments

Type: has_many

Related object: L<TopTable::Schema::Result::Tournament>

=cut

__PACKAGE__->has_many(
  "tournaments",
  "TopTable::Schema::Result::Tournament",
  { "foreign.default_individual_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xGpSUgKHYlk9RI4/ZtCw9w

use HTML::Entities;

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->url_key];
}

=head2 can_edit_or_delete

Checks whether this template is able to be deleted; it can be deleted if there are no matches or seasons in the database using it as a template.

=cut

sub can_edit_or_delete {
  my ( $self ) = @_;
  
  # Check game templates first, as this is quicker
  my $game_templates_using_template = $self->search_related("template_match_team_games")->count;
  return 0 if $game_templates_using_template;
  
  # Now check league match games
  my $league_match_games_using_template = $self->search_related("team_match_games")->count;
  return 0 if $league_match_games_using_template;
  
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
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  my $enc_name = encode_entities($self->name);
  
  # Check we can delete
  unless ( $self->can_edit_or_delete ) {
    push(@{$response->{error}}, $lang->maketext("templates.delete.error.not-allowed", $enc_name));
    return $response;
  }
  
  # Delete
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $enc_name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $enc_name));
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
