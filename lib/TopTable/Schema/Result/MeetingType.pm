use utf8;
package TopTable::Schema::Result::MeetingType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::MeetingType

=head1 DESCRIPTION

This is only used for non-event meetings (that is meetings that are not listed from the events page - this could be regular committee meetings, for example).

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

=head1 TABLE: C<meeting_types>

=cut

__PACKAGE__->table("meeting_types");

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

=head2 meetings

Type: has_many

Related object: L<TopTable::Schema::Result::Meeting>

=cut

__PACKAGE__->has_many(
  "meetings",
  "TopTable::Schema::Result::Meeting",
  { "foreign.type" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_meeting_types

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogMeetingType>

=cut

__PACKAGE__->has_many(
  "system_event_log_meeting_types",
  "TopTable::Schema::Result::SystemEventLogMeetingType",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+7yMIn5ozaeFjUgFDezmnw

=head2 can_delete

Performs the logic checks to see if the meeting type can be deleted; returns true if it can or false if it can't.  A meeting type can be deleted if it has no meetings using it.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # Check if there are meetings using this meeting type.
  my $meetings = $self->search_related("meetings")->count;
  return 0 if $meetings;
  
  # If we get this far, we can delete.
  return 1;
}

=head2 check_and_delete

Checks that the meeting type can be deleted (via can_delete) and then performs the deletion.

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
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{error}}, $lang->maketext("meeting-types.delete.error.not-allowed", $self->name));
    return $response;
  }
  
  # Get the name for messaging, then delete
  my $name = $self->name;
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
