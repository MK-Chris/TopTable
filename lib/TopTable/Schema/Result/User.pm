use utf8;
package TopTable::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::User

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

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

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

=head2 username

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 email_address

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 person

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 0

=head2 change_password_next_login

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 html_emails

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 registered_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 registered_ip

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 last_visit_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 last_visit_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 last_active_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 last_active_ip

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 locale

  data_type: 'varchar'
  is_nullable: 0
  size: 6

=head2 timezone

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 avatar

  data_type: 'varchar'
  is_nullable: 1
  size: 500

"Upload" = uploaded image (will be a pre-defined URI based on the user ID; anything else should be assumed to be a remotely linked web address

=head2 posts

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 comments

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 signature

  data_type: 'mediumtext'
  is_nullable: 1

=head2 facebook

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 twitter

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=head2 instagram

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 snapchat

  data_type: 'varchar'
  is_nullable: 1
  size: 15

=head2 tiktok

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 interests

  data_type: 'text'
  is_nullable: 1

=head2 occupation

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 location

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 hide_online

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 approved

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 approved_by

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 approved_by_name

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 registration_reason

  data_type: 'text'
  is_nullable: 1

=head2 activation_key

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 activated

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 activation_expires

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 invalid_logins

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 password_reset_key

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 password_reset_expires

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 last_invalid_login

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
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
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "username",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "email_address",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "person",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "password",
  { data_type => "text", is_nullable => 0 },
  "change_password_next_login",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "html_emails",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "registered_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "registered_ip",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "last_visit_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "last_visit_ip",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "last_active_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "last_active_ip",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "locale",
  { data_type => "varchar", is_nullable => 0, size => 6 },
  "timezone",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "avatar",
  { data_type => "varchar", is_nullable => 1, size => 500 },
  "posts",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "comments",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "signature",
  { data_type => "mediumtext", is_nullable => 1 },
  "facebook",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "twitter",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "instagram",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "snapchat",
  { data_type => "varchar", is_nullable => 1, size => 15 },
  "tiktok",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "interests",
  { data_type => "text", is_nullable => 1 },
  "occupation",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "location",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "hide_online",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "approved",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "approved_by",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "approved_by_name",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "registration_reason",
  { data_type => "text", is_nullable => 1 },
  "activation_key",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "activated",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "activation_expires",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "invalid_logins",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "password_reset_key",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "password_reset_expires",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "last_invalid_login",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head2 C<user_person_idx>

=over 4

=item * L</person>

=back

=cut

__PACKAGE__->add_unique_constraint("user_person_idx", ["person"]);

=head1 RELATIONS

=head2 approved_by

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "approved_by",
  "TopTable::Schema::Result::User",
  { id => "approved_by" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "SET NULL",
  },
);

=head2 average_filters

Type: has_many

Related object: L<TopTable::Schema::Result::AverageFilter>

=cut

__PACKAGE__->has_many(
  "average_filters",
  "TopTable::Schema::Result::AverageFilter",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 banned_users_banned

Type: has_many

Related object: L<TopTable::Schema::Result::BannedUser>

=cut

__PACKAGE__->has_many(
  "banned_users_banned",
  "TopTable::Schema::Result::BannedUser",
  { "foreign.banned_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 banned_users_banned_by

Type: has_many

Related object: L<TopTable::Schema::Result::BannedUser>

=cut

__PACKAGE__->has_many(
  "banned_users_banned_by",
  "TopTable::Schema::Result::BannedUser",
  { "foreign.banned_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 bans

Type: has_many

Related object: L<TopTable::Schema::Result::Ban>

=cut

__PACKAGE__->has_many(
  "bans",
  "TopTable::Schema::Result::Ban",
  { "foreign.banned_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 news_articles

Type: has_many

Related object: L<TopTable::Schema::Result::NewsArticle>

=cut

__PACKAGE__->has_many(
  "news_articles",
  "TopTable::Schema::Result::NewsArticle",
  { "foreign.updated_by_user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "person",
  "TopTable::Schema::Result::Person",
  { id => "person" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 sessions

Type: has_many

Related object: L<TopTable::Schema::Result::Session>

=cut

__PACKAGE__->has_many(
  "sessions",
  "TopTable::Schema::Result::Session",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_users

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogUser>

=cut

__PACKAGE__->has_many(
  "system_event_log_users",
  "TopTable::Schema::Result::SystemEventLogUser",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_logs

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLog>

=cut

__PACKAGE__->has_many(
  "system_event_logs",
  "TopTable::Schema::Result::SystemEventLog",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_reports

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchReport>

=cut

__PACKAGE__->has_many(
  "team_match_reports",
  "TopTable::Schema::Result::TeamMatchReport",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_ip_addresses_browsers

Type: has_many

Related object: L<TopTable::Schema::Result::UserIpAddressesBrowser>

=cut

__PACKAGE__->has_many(
  "user_ip_addresses_browsers",
  "TopTable::Schema::Result::UserIpAddressesBrowser",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<TopTable::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "TopTable::Schema::Result::UserRole",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 users

Type: has_many

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->has_many(
  "users",
  "TopTable::Schema::Result::User",
  { "foreign.approved_by" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 roles

Type: many_to_many

Composing rels: L</user_roles> -> role

=cut

__PACKAGE__->many_to_many("roles", "user_roles", "role");


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2022-01-15 21:50:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XaoqzN7qRiHcD42jcvbGGA

use Digest::SHA qw( sha256_hex );
use Time::HiRes;
use DateTime;
use HTML::Entities;

# Have the 'password' column use a SHA-1 hash and 20-byte salt
# with RFC 2307 encoding; Generate the 'check_password" method
# Also enable automatic date handling
__PACKAGE__->add_columns(
    "password" => {
        data_type => "text",
        is_nullable => 0,
        passphrase => "rfc2307",
        passphrase_class => "BlowfishCrypt",
        passphrase_args => {
            cost => 14,
            salt_random => 1,
        },
        passphrase_check_method => "check_password",
    },
    "registered_date" =>
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0, },
    "last_visit_date" =>
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 1, },
    "last_active_date" =>
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 1, },
    "activation_expires" =>
    { data_type => "datetime", timezone => "UTC", set_on_create => 0, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 1, },
    "password_reset_expires" =>
    { data_type => "datetime", timezone => "UTC", set_on_create => 0, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 1, },
);

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [$self->url_key];
}

=head2 can_delete

Performs the logic checks to see if the user can be deleted; returns true if it can or false if it can't.  Currently this just returns 1 so we can always delete.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # If we get this far, we can delete.
  return 1;
}

=head2 check_and_delete

Checks that the venue can be deleted (via can_delete) and then performs the deletion.

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
  my $name = encode_entities($self->username);
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{errors}}, $lang->maketext("user.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Delete
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

=head2 approve

Approve the user

=cut

sub approve {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $approver = $params->{approver};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  if ( ref($approver) eq "Catalyst::Authentication::Store::DBIx::Class::User" ) {
    # We have passed in the logged in user
    # Update to approved
    # Also activated / null the activation key - even if the user hasn't activated, assume the admin knows best.
    my $ok = $self->update({
      approved => 1,
      approved_by => $approver->id,
      approved_by_name => $approver->username,
      activated => 1,
      activation_key => undef,
      activation_expires => undef,
    });
    
    # Error if the delete was unsuccessful
    if ( $ok ) {
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("users.approve.user-approved", encode_entities($self->username)));
    } else {
      push(@{$response->{errors}}, $lang->maketext("admin.update.error.database"));
    }
  } else {
    # No user passed in
    push(@{$response->{errors}}, $lang->maketext("admin.performing-user-invalid"));
  }
  
  return $response;
}

=head2 reject

Disapprove the user (delete).

=cut

sub reject {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $approver = $params->{approver};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # We have passed in the logged in user
  # Update to approved
  my $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("users.approve.user-rejected", encode_entities($self->username)));
  } else {
    push(@{$response->{errors}}, $lang->maketext("admin.delete.error.database"));
  }
  
  return $response;
}

=head2 display_name

Display the person's name instead if there's a person associated

=cut

sub display_name {
  my ( $self ) = @_;
  
  my $person = $self->search_related("person", undef, {rows => 1})->single;
  
  if ( defined($person) ) {
    return $person->display_name;
  } else {
    return $self->username;
  }
}

=head2 display_user_and_name

Display the user with the person's name in brackets if there is a person associated. 

=cut

sub display_user_and_name {
  my ( $self ) = @_;
  
  my $person = $self->find_related("person", undef, {rows => 1});
  
  if ( defined( $person ) ) {
    return sprintf("%s (%s)", $self->username, $person->display_name);
  } else {
    return $self->username;
  }
}

=head2 activate

Sets the user to 'activated' and clears out the activation key.

=cut

sub activate {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $person = $params->{person};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Check we're activating with a person ID or no person at all
  $person = defined($person) ? $person->id : undef;
  
  my $ok = $self->update({
    person => $person,
    activated => 1,
    activation_key => undef,
    activation_expires => undef,
  });
  
  if ( $ok ) {
    if ( $self->approved ) {
      # Auto-approval must be in place
      push(@{$response->{success}}, $lang->maketext("user.activation.success-login"));
    } else {
      # Manual approval
      push(@{$response->{success}}, $lang->maketext("user.activation.success-approval-needed"));
    }
    
    
    $response->{completed} = 1;
  } else {
    push(@{$response->{errors}}, $lang->maketext("user.activation.error.failed"));
  }
  
  
  return $response;
}

=head2 set_password_reset_key

Generate a password reset key.

=cut

sub set_password_reset_key {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $person = $params->{person};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the expiry
  my $expires = DateTime->now(time_zone  => "UTC")->add(hours => 1);
  
  my $ok = $self->update({
    password_reset_key => sha256_hex($self->username . Time::HiRes::time . int(rand(100))),
    password_reset_expires => sprintf("%s %s", $expires->ymd, $expires->hms),
  });
  
  if ( $ok ) {
    $response->{completed} = 1;
  } else {
    push(@{$response->{errors}}, $lang->maketext("user.forgot-password.error.failed-to-set-key"));
  }
  
  return $response;
}

=head2 reset_password

Check and reset the user's password, given a new password and a confirm password (hopefully the same!)

=cut

sub reset_password {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $person = $params->{person};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Grab the fields
  my $password = $params->{password} || undef;
  my $confirm_password = $params->{confirm_password} || "";
  
  if ( defined($password) ) {
    # Check the passwords match
    if ( $password ne $confirm_password ) {
      # Non-matching passwords
      push(@{$response->{errors}}, $lang->maketext("user.form.error.password-confirm-mismatch"));
    } else {
      # Check password strength
      if ( length($password) < 8 ) {
        # Password too short
        push(@{$response->{errors}}, $lang->maketext("user.form.error.password-too-short", 8));
      } else {
        # Check password complexity
        push(@{$response->{errors}}, $lang->maketext("user.form.error.password-complexity")) unless $password =~ /[A-Z]/ and $password =~ /[a-z]/ and $password =~ /\d/;
      }
    }
  } else {
    # Password is blank
    push(@{$response->{errors}}, $lang->maketext("user.form.error.password-blank"));
  }
  
  # Update if there are no errors.  Ensure the password reset key is removed.
  if ( scalar( @{$response->{errors}} ) == 0 ) {
    my $ok = $self->update({
      password => $password,
      password_reset_key => undef,
      password_reset_expires => undef,
    });
    
    if ( $ok ) {
      $response->{completed} = 1;
    } else {
      push(@{$response->{errors}}, $lang->maketext("user.reset-password.error.failed-to-reset"));
    }
  }
  
  return $response;
}

=head2 plays_for

Returns true if the user plays for the specified team in the specified season.

=cut

sub plays_for {
  my ( $self, $params ) = @_;
  my $team = $params->{team};
  my $season = $params->{season};
  
  # Get the person associated with this user
  my $person = $self->person;
  
  # Return false straight away if there's no person associated
  return 0 unless defined($person);
  
  # Otherwise return the value of the same routine in the Person model
  return $person->plays_for({
    team => $team,
    season => $season,
  });
}

=head2 captain_for

Returns true if the user is captain for the specified team in the specified season.

=cut

sub captain_for {
  my ( $self, $params ) = @_;
  my $team_season = $params->{team};
  
  # Get the person associated with this user
  my $person = $self->person;
  
  # Return false straight away if there's no person associated
  return 0 unless defined($person);
  
  # Otherwise return the value of the same routine in the Person model
  return $person->captain_for({team => $team_season});
}

=head2 secretary_for

Returns true if the user is secretary for the specified club in the specified season.

=cut

sub secretary_for {
  my ( $self, $params ) = @_;
  my $club = $params->{club};
  
  # Get the person associated with this user
  my $person = $self->person;
  
  # Return false straight away if there's no person associated
  return 0 unless defined($person);
  
  # Otherwise return the value of the same routine in the Person model
  return $person->secretary_for({club => $club});
}

=head2 has_role

Checks if the user has the given role.

=cut

sub has_role {
  my ( $self, $role ) = @_;
  return defined($self->find_related("user_roles", {role => $role->id})) ? 1 : 0;
}

=head2 all_roles

Return the roles that this user is a member of.

=cut

sub all_roles {
  my ( $self ) = @_;
  return $self->roles;
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->username,
    url_keys => $self->url_keys,
    type => "user",
  };
}

=head2 registered_long_date

Return the long registered date.

=cut

sub registered_long_date {
  my ( $self ) = @_;
  return sprintf("%s, %s %s %s", ucfirst($self->registered_date->day_name), $self->registered_date->day, $self->registered_date->month_name, $self->registered_date->year);
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
