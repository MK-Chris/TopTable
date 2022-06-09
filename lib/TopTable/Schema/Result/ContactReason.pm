use utf8;
package TopTable::Schema::Result::ContactReason;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::ContactReason

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

=head1 TABLE: C<contact_reasons>

=cut

__PACKAGE__->table("contact_reasons");

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
  size: 50

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
  { data_type => "varchar", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 contact_reason_recipients

Type: has_many

Related object: L<TopTable::Schema::Result::ContactReasonRecipient>

=cut

__PACKAGE__->has_many(
  "contact_reason_recipients",
  "TopTable::Schema::Result::ContactReasonRecipient",
  { "foreign.contact_reason" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_contact_forms

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogContactForm>

=cut

__PACKAGE__->has_many(
  "system_event_log_contact_forms",
  "TopTable::Schema::Result::SystemEventLogContactForm",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_contact_reasons

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogContactReason>

=cut

__PACKAGE__->has_many(
  "system_event_log_contact_reasons",
  "TopTable::Schema::Result::SystemEventLogContactReason",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 people

Type: many_to_many

Composing rels: L</contact_reason_recipients> -> person

=cut

__PACKAGE__->many_to_many("people", "contact_reason_recipients", "person");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-02-04 13:40:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:soOfjT5rZRHtApZYajg8+Q

use HTML::Entities;

=head2 recipients

Get a list of recipients associated with this contact reason.

=cut

sub recipients {
  my ( $self ) = @_;
  return $self->search_related("contact_reason_recipients", undef, {prefetch => "person"});
}

=head2 can_delete

Performs the checks we need to ensure the object is deletable.  Currently this will always return 1, but could be added to in future; mainly at the moment, it's here so we can call ->can_delete before deleting, which ensures consistency across other DB result classes.

=cut

sub can_delete {
  my ( $self ) = @_;
  return 1;
}

=head2 check_and_delete

Performs the deletion of a ban.

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
  
  # Check we can delete
  my $enc_name = encode_entities($self->name);
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("contact-reasons.delete.error.cannot-delete", $enc_name));
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
