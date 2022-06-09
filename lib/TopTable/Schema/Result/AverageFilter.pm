use utf8;
package TopTable::Schema::Result::AverageFilter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::AverageFilter

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

=head1 TABLE: C<average_filters>

=cut

__PACKAGE__->table("average_filters");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 show_active

  data_type: 'tinyint'
  default_value: 1
  extra: {unsigned => 1}
  is_nullable: 1

=head2 show_loan

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 show_inactive

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 criteria_field

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 operator

  data_type: 'varchar'
  is_nullable: 1
  size: 2

=head2 criteria

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 criteria_type

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Ties the filter to a user so users can create their own; NULL = a system filter, appears for all users.

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
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "show_active",
  {
    data_type => "tinyint",
    default_value => 1,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "show_loan",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "show_inactive",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "criteria_field",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "operator",
  { data_type => "varchar", is_nullable => 1, size => 2 },
  "criteria",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 0 },
  "criteria_type",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_user>

=over 4

=item * L</name>

=item * L</user>

=back

=cut

__PACKAGE__->add_unique_constraint("name_user", ["name", "user"]);

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 system_event_log_average_filters

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogAverageFilter>

=cut

__PACKAGE__->has_many(
  "system_event_log_average_filters",
  "TopTable::Schema::Result::SystemEventLogAverageFilter",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "TopTable::Schema::Result::User",
  { id => "user" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-11-11 23:19:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9iX/k6gsyeRqDCnA+aHsgA

=head2 can_delete

Performs the checks we need to ensure the object is deletable.  Currently this will always return 1, but could be added to in future; mainly at the moment, it's here so we can call ->can_delete before deleting, which ensures consistency across other DB result classes.

=cut

sub can_delete {
  my ( $self ) = @_;
  return 1;
}

=head2 check_and_delete

Performs the deletion of the filter; currently no checks to perform, but this may change.

=cut

sub check_and_delete{
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
  
  # Check we can delete
  my $enc_name = encode_entities($self->name);
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("average-filters.delete.error.cannot-delete", $enc_name));
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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
