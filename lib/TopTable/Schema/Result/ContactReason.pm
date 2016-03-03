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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-08 22:46:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Am7mM6IySLD37TvlTDIA7g

=head2 recipients

Get a list of recipients associated with this contact reason.

=cut

sub recipients {
  my ( $self ) = @_;
  
  return $self->search_related("contact_reason_recipients", {
    prefetch => "person",
  });
}

=head2 check_and_delete

Deletes the contact reason.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
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
