use utf8;
package TopTable::Schema::Result::CalendarType;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::CalendarType - Calendar types for importing fixtures / results into.

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

=head1 TABLE: C<calendar_types>

=cut

__PACKAGE__->table("calendar_types");

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

Name that appears in the select list.

=head2 uri

  data_type: 'varchar'
  is_nullable: 0
  size: 500

URI to redirect to.  Enter {cal-uri} to replace with the URI that generates the ICS file.

=head2 calendar_scheme

  data_type: 'varchar'
  is_nullable: 1
  size: 10

Enter a value, for example webcal, to change the calendar scheme URI to webcal://

=head2 uri_escape_replacements

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 display_order

  data_type: 'smallint'
  is_nullable: 0

The order that the item will be displayed in the select list.

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
  "uri",
  { data_type => "varchar", is_nullable => 0, size => 500 },
  "calendar_scheme",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "uri_escape_replacements",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "display_order",
  { data_type => "smallint", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1mhIbeMQcizQpZ0ZjSGuwg

use URI::Escape;

=head2 generate_uri

Generate a URI to redirect for subscription to, for example, Google Calendar.

=cut

sub generate_uri {
  my ( $self, $parameters ) = @_;
  my $download_uri              = $parameters->{download_uri};
  my $calendar_name             = $parameters->{calendar_name};
  
  # Get the default URI
  my $uri           = $self->uri;
  my $scheme        = $self->calendar_scheme;
  
  # Alter the scheme if required
  $download_uri->scheme( $scheme ) if defined( $scheme ) and $download_uri->scheme ne $scheme;
  
  # URI escape if we need to
  if ( $self->uri_escape_replacements ) {
    $calendar_name = uri_escape_utf8( $calendar_name );
    $download_uri = uri_escape_utf8( $download_uri );
  }
  
  # Now put it in the redirect URI
  $uri =~ s/{cal-uri}/$download_uri/g;
  $uri =~ s/{cal-name}/$calendar_name/g;
  
  return $uri;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
