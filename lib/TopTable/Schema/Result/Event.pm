use utf8;
package TopTable::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Event

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

=head1 TABLE: C<events>

=cut

__PACKAGE__->table("events");

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
  size: 300

=head2 event_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 description

  data_type: 'longtext'
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
  "name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "event_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "description",
  { data_type => "longtext", is_nullable => 1 },
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

=head2 event_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->has_many(
  "event_seasons",
  "TopTable::Schema::Result::EventSeason",
  { "foreign.event" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupEventType>

=cut

__PACKAGE__->belongs_to(
  "event_type",
  "TopTable::Schema::Result::LookupEventType",
  { id => "event_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 system_event_log_events

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogEvent>

=cut

__PACKAGE__->has_many(
  "system_event_log_events",
  "TopTable::Schema::Result::SystemEventLogEvent",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2025-01-14 23:27:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ib8OoPGsJeIhr481/YjaxA

=head2 single_season

Get a single specified season associated with this event.

=cut

sub single_season {
  my $self = shift;
  my ( $season ) = @_;
  
  return $self->find_related("event_seasons", {season => $season->id});
}

=head2 can_edit_details

Check whether we can edit details (essentially if we have an instance of the event in the current season).

=cut

sub can_edit_details {
  my $self = shift;
  my $schema = $self->result_source->schema;
  my $current_season = $schema->resultset("Season")->get_current;
  
  if ( defined($current_season) ) {
    # IF there's an instance this season, we can edit the details of it; if there's not, we can't
    return defined($self->single_season($current_season)) ? 1 : 0;
  } else {
    # No current season, can't edit details
    return 0;
  }
}

=head2 can_delete

Check whether the even can be deleted.

=cut

sub can_delete {
  my $self = shift;
  
  ## NEEDS WRITING
  return 1;
}

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my $self = shift;
  my ( $params ) = @_;
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
    push(@{$response->{error}}, $lang->maketext("events.delete.error.cannot-delete", $self->name));
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

=head2 can_edit_event_type

Determines whether the event type is editable by searching for previous seasons 

=cut

sub can_edit_event_type {
  my $self = shift;
  
  # We're going to set this to false for now - it's more complex than originally thought, so we'll just not allow editing of event types unless / until I can work out
  # all the logic
  return 0;
  
  # First search for this event in previous (completed) seasons
  my $previous_events = $self->search_related("event_seasons", {
    "season.complete" => 1,
  }, {
    join => "season",
  })->count;
  
  # If we have any, we straight away return false, as we can't edit and event type where the event
  # has already been used in previous seasons.
  return 0;
  
  # Now search for the event-type specific stuff, if there are any
  if ( $self->event_type->id eq "single-tournament" ) {
    my $tournament_matches_started = $self->search_related("tournaments", {
      "team_matches.started" => 1,
      "team_matches.complete" => 1,
    }, {
      join => {
        tournament_seasons => {tournament_rounds => "team_matches"}
      }
    });
    
    return 0 if $tournament_matches_started->count;
  } elsif ( $self->event_type->id eq "meeting" ) {
    my $meetings_attended = $self->search_related("event_seasons", {}, {
      select => ["name", {count => "meeting_attendees.person"}],
      as => [qw( name attendees )],
      join => {meetings => "meeting_attendees"},
      group_by => "id",
      rows => 1,
    })->single;
    
    return 0 if $meetings_attended->get_column("attendees") > 0;
  }
  
  return 1;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
