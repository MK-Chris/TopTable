use utf8;
package TopTable::Schema::Result::Official;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Official

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

=head1 TABLE: C<officials>

=cut

__PACKAGE__->table("officials");

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

=head2 position_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

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
  "position_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
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

=head2 official_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::OfficialSeason>

=cut

__PACKAGE__->has_many(
  "official_seasons",
  "TopTable::Schema::Result::OfficialSeason",
  { "foreign.official" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_official_positions

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogOfficialPosition>

=cut

__PACKAGE__->has_many(
  "system_event_log_official_positions",
  "TopTable::Schema::Result::SystemEventLogOfficialPosition",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-03-17 23:33:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PqEZDmJsfssufuiDst12wQ

use HTML::Entities;

=head2 get_season

Get the corresponding OfficialSeason object

=cut

sub get_season {
  my ( $self, $season ) = @_;
  return $self->find_related("official_seasons", {season => $season->id}, {
    prefetch => {official_season_people => "position_holder"},
    order_by => {-asc => [qw( position_holder.surname position_holder.first_name )]}
  });
}

=head2 get_holders

Retrieve a list of people who hold this position in the given season.

=cut

sub get_holders {
  my ( $self, $params ) = @_;
  my $season = $params->{season};
  
  my $official_seasons = $self->find_related("official_seasons", {season => $season->id});
  
  return $official_seasons->search_related("official_season_people", undef, {
    prefetch => "position_holder",
    order_by => {-asc => [qw( position_holder.surname position_holder.first_name )]}
  })->search_related("position_holder") if defined($official_seasons);
  
  return undef;
}

=head2 can_delete

Check if we can delete this position.  A position can be deleted if it's not been used in an archived season.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  my $complete_seasons = $self->search_related("official_seasons", {
    "season.complete" => 1,
  }, {
    join => "season"
  })->count;
  
  return $complete_seasons ? 0 : 1;
}

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

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
  
  # Get the name for messaging
  my $name = encode_entities($self->position_name);
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("officials.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Delete
  my $seasons = $self->search_related("official_seasons");
  
  my $ok = $seasons->search_related("official_season_people")->delete;
  $ok = $self->delete_related("official_seasons") if $ok;
  $ok = $self->delete if $ok;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
