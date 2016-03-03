use utf8;
package TopTable::Schema::Result::TemplateLeagueTableRanking;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TemplateLeagueTableRanking

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

=head1 TABLE: C<template_league_table_ranking>

=cut

__PACKAGE__->table("template_league_table_ranking");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 assign_points

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 points_per_win

  data_type: 'tinyint'
  is_nullable: 1

=head2 points_per_draw

  data_type: 'tinyint'
  is_nullable: 1

=head2 points_per_loss

  data_type: 'tinyint'
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
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "assign_points",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "points_per_win",
  { data_type => "tinyint", is_nullable => 1 },
  "points_per_draw",
  { data_type => "tinyint", is_nullable => 1 },
  "points_per_loss",
  { data_type => "tinyint", is_nullable => 1 },
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
  { "foreign.league_table_ranking_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_league_table_rankings

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateLeagueTableRanking>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_league_table_rankings",
  "TopTable::Schema::Result::SystemEventLogTemplateLeagueTableRanking",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-13 08:59:34
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P5nzd19ZyzDFKofhGKxvSg

=head2 can_edit_or_delete

Checks whether this template is able to be deleted; it can be deleted if there are no matches or seasons in the database using it as a template.

=cut

sub can_edit_or_delete {
  my ( $self ) = @_;
  
  my $divisions_using_template = $self->search_related("division_seasons")->count;
  
  return ( $divisions_using_template == 0 ) ? 1 : 0;
}

=head2 check_and_delete

Checks the template can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "templates.delete.error.not-allowed",
    parameters  => [$self->name],
  }) unless $self->can_edit_or_delete;
  
  # Delete
  my $ok = $self->delete unless scalar( @{ $error } );
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
