use utf8;
package TopTable::Schema::Result::NewsArticle;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::NewsArticle

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

=head1 TABLE: C<news_articles>

=cut

__PACKAGE__->table("news_articles");

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

=head2 published_year

  data_type: 'year'
  is_nullable: 1

=head2 published_month

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 updated_by_user

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 ip_address

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 date_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 headline

  data_type: 'varchar'
  is_nullable: 0
  size: 500

=head2 article_content

  data_type: 'longtext'
  is_nullable: 0

=head2 original_article

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 pinned

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 pinned_expires

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 published_date

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
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "published_year",
  { data_type => "year", is_nullable => 1 },
  "published_month",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "updated_by_user",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "ip_address",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "date_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "headline",
  { data_type => "varchar", is_nullable => 0, size => 500 },
  "article_content",
  { data_type => "longtext", is_nullable => 0 },
  "original_article",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "pinned",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "pinned_expires",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "published_date",
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

=item * L</published_year>

=item * L</published_month>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key", "published_year", "published_month"]);

=head1 RELATIONS

=head2 news_articles

Type: has_many

Related object: L<TopTable::Schema::Result::NewsArticle>

=cut

__PACKAGE__->has_many(
  "news_articles",
  "TopTable::Schema::Result::NewsArticle",
  { "foreign.original_article" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 original_article

Type: belongs_to

Related object: L<TopTable::Schema::Result::NewsArticle>

=cut

__PACKAGE__->belongs_to(
  "original_article",
  "TopTable::Schema::Result::NewsArticle",
  { id => "original_article" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 system_event_log_news

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogNews>

=cut

__PACKAGE__->has_many(
  "system_event_log_news",
  "TopTable::Schema::Result::SystemEventLogNews",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 updated_by_user

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "updated_by_user",
  "TopTable::Schema::Result::User",
  { id => "updated_by_user" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-25 13:33:57
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8zisShUlpf2+Ioaw+UDikw

use HTML::Entities;

=head2 date_updated_tz

Return the log_created time with the correct timezone.

=cut

sub date_updated_tz {
  my ( $self, $tz ) = @_;
  
  # Set the timezone if we have one specified
  $self->date_updated->set_time_zone($tz) if $tz;
  
  # Return the new time
  return $self->date_updated;
}

# Enable automatic date handling
__PACKAGE__->add_columns(
    "date_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0,},
);

=head2 current_details

Return the correct details for the current edit of this article.  Returns all of the column names in the keys of a hashref, but the details are correct as of the current edit, not the row we're quering.  One additional column that comes back is number_of_edits.

=cut

sub current_details {
  my ( $self, $tz ) = @_;
  my $return_value;
  
  my $edits = $self->search_related("news_articles", {}, {
    order_by => {-desc => "date_updated"},
  });
  
  if ( $edits->count > 0 ) {
    my $latest_edit = $edits->search({}, {
      rows => 1,
      order_by => {-desc => "date_updated"},
    })->single;
    
    $return_value = {
      pinned => $latest_edit->pinned,
      pinned_expires => $latest_edit->pinned_expires,
      updated_by_user => $latest_edit->updated_by_user,
      ip_address => $latest_edit->ip_address,
      date_updated => $latest_edit->date_updated_tz($tz),
      headline => $latest_edit->headline,
      article_content => $latest_edit->article_content,
      number_of_edits => $edits->count,
    };
  } else {
    # If there are no edits, just return the current column's values
    $return_value = {
      pinned => $self->pinned,
      pinned_expires => $self->pinned_expires,
      updated_by_user => $self->updated_by_user,
      ip_address => $self->ip_address,
      date_updated => $self->date_updated_tz($tz),
      headline => $self->headline,
      article_content => $self->article_content,
      number_of_edits => 0,
    };
  }
  
  return $return_value;
}

=head2 article_description

Returns an article description of either a brief description field (to be created) or the first 150 characters of the article itself.

=cut

sub article_description {
  my ( $self ) = @_;
  
  # Get the current details so we access the latest edit
  my $current_article_text = $self->current_details->{article_content};
  
  # Return a substring of the article
  return substr($current_article_text, 0, 150);
}

=head2 can_delete

Performs the checks we need to ensure the news article is deletable.  Currently this will always return 1, but could be added to in future; mainly at the moment, it's here so we can call ->can_delete before deleting, which ensures consistency across other DB result classes.

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
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{error}}, $lang->maketext("news.delete.error.cannot-delete", encode_entities($self->current_details->{headline})));
    return $response;
  }
  
  # Get the name for messaging, then delete
  my $name = $self->current_details->{headline};
  
  # Delete previous edits
  my $ok = $self->delete_related("news_articles");
  $ok = $self->delete if $ok;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($name), $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", encode_entities($name)));
  }
  
  return $response;
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
