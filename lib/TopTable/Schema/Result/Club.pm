use utf8;
package TopTable::Schema::Result::Club;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Club

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

=head1 TABLE: C<clubs>

=cut

__PACKAGE__->table("clubs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 full_name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 short_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 secretary

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 facebook

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 twitter

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 instagram

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 youtube

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 default_match_start

  data_type: 'time'
  is_nullable: 1

=head2 abbreviated_name

  data_type: 'varchar'
  is_nullable: 1
  size: 20

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
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "full_name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "short_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "secretary",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "facebook",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "twitter",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "instagram",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "youtube",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "default_match_start",
  { data_type => "time", is_nullable => 1 },
  "abbreviated_name",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<abbreviated_name>

=over 4

=item * L</abbreviated_name>

=back

=cut

__PACKAGE__->add_unique_constraint("abbreviated_name", ["abbreviated_name"]);

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 secretary

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "secretary",
  "TopTable::Schema::Result::Person",
  { id => "secretary" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 system_event_log_clubs

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogClub>

=cut

__PACKAGE__->has_many(
  "system_event_log_clubs",
  "TopTable::Schema::Result::SystemEventLogClub",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.club" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 teams

Type: has_many

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->has_many(
  "teams",
  "TopTable::Schema::Result::Team",
  { "foreign.club" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 venue

Type: belongs_to

Related object: L<TopTable::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "TopTable::Schema::Result::Venue",
  { id => "venue" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:26:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Y8c+Rk0Pvi311TQWFOiK0A

=head2 can_delete

Performs the checks we need to ensure the club is deletable (i.e., has no teams).

=cut

sub can_delete {
  my ( $self ) = @_;
  
  my $teams = $self->search_related("team_seasons")->count;
  
  # Return true if the number of teams is zero, otherwise false.
  return ( $teams == 0 ) ? 1 : 0;
}

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "clubs.delete.error.cannot-delete",
    parameters  => [$self->name],
  }) unless $self->can_delete;
  
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
