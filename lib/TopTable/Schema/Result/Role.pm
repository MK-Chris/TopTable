use utf8;
package TopTable::Schema::Result::Role;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Role

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

=head1 TABLE: C<roles>

=cut

__PACKAGE__->table("roles");

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
  size: 100

For system (built-in) roles, this will not be the actual name, but the key for the translation routine to get the actual name in the correct language; for user-defined roles, it will be the name itself as entered by the user.

=head2 system

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

System (built-in) roles are built-in from installation; they can't be deleted or renamed; the permissions can be edited (except administrators; anyone in administrators can do anything - they are denoted by the sysadmin field being 1).

=head2 sysadmin

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Should only be applied to built-in "Administrators" role - permissions cannot be altered.

=head2 anonymous

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Should only be applied to built-in "anonymous" role - anyone not logged in gets these permissions.

=head2 apply_on_registration

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

If this is 1, upon registration, users will get assigned to the role automatically.  This can be altered on user-defined roles, but not on built-in roles.

=head2 average_filter_create_public

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_filter_edit_public

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_filter_delete_public

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_filter_view_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_filter_edit_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_filter_delete_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 club_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 club_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 club_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 club_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 committee_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 committee_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 committee_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 committee_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 contact_reason_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 contact_reason_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 contact_reason_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 contact_reason_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 event_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 event_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 event_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 event_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 file_upload

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 image_upload

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_update

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_cancel

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_report_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

If 1 the person can create match reports for any team.

=head2 match_report_create_associated

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

If 1 the person can create match reports involving teams the user is associated with (by playing for or captaining the team or being secretary for the club)

=head2 match_report_edit_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_report_edit_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_report_delete_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 match_report_delete_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_type_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_type_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_type_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 meeting_type_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_edit_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_edit_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_delete_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_delete_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 news_article_pin

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 online_users_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 anonymous_online_users_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 view_users_ip

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 view_users_user_agent

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person_contact_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 person_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 privacy_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 privacy_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 role_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 role_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 role_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 role_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 season_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 season_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 season_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 season_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 season_archive

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 session_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 system_event_log_view_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 team_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 team_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 team_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 team_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 template_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 template_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 template_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 template_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 tournament_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 tournament_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 tournament_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 tournament_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_edit_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_edit_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_delete_all

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_delete_own

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 venue_view

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 venue_create

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 venue_edit

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 venue_delete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
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
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "system",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "sysadmin",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "anonymous",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "apply_on_registration",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_create_public",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_edit_public",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_delete_public",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_view_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_edit_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_filter_delete_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "club_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "club_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "club_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "club_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "committee_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "committee_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "committee_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "committee_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "contact_reason_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "contact_reason_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "contact_reason_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "contact_reason_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "event_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "event_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "event_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "event_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "file_upload",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "fixtures_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "fixtures_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "fixtures_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "fixtures_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "image_upload",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_update",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_cancel",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_create_associated",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_edit_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_edit_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_delete_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "match_report_delete_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_type_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_type_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_type_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "meeting_type_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_edit_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_edit_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_delete_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_delete_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "news_article_pin",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "online_users_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "anonymous_online_users_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "view_users_ip",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "view_users_user_agent",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person_contact_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "person_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "privacy_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "privacy_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "role_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "role_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "role_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "role_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "season_archive",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "session_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "system_event_log_view_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "team_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "team_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "team_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "team_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "template_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "template_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "template_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "template_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "tournament_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "tournament_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "tournament_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "tournament_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "user_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "user_edit_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "user_edit_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "user_delete_all",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "user_delete_own",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "venue_view",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "venue_create",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "venue_edit",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "venue_delete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
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

=head2 system_event_log_roles

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogRole>

=cut

__PACKAGE__->has_many(
  "system_event_log_roles",
  "TopTable::Schema::Result::SystemEventLogRole",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<TopTable::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "TopTable::Schema::Result::UserRole",
  { "foreign.role" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: many_to_many

Composing rels: L</user_roles> -> user

=cut

__PACKAGE__->many_to_many("users", "user_roles", "user");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-28 21:50:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AiyGbBnGo68new2QyaH47Q

=head2 members

Get a list of recipients associated with this contact reason.

=cut

sub members {
  my ( $self ) = @_;
  
  return $self->search_related("user_roles", {}, {
    prefetch => "user",
  });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
