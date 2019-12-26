use utf8;
package TopTable::Schema::Result::SystemEventLog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::SystemEventLog

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

=head1 TABLE: C<system_event_log>

=cut

__PACKAGE__->table("system_event_log");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 object_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 40

=head2 event_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 ip_address

  data_type: 'varchar'
  is_nullable: 0
  size: 40

=head2 log_created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 log_updated

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 number_of_edits

  data_type: 'integer'
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
  "object_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 40 },
  "event_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "ip_address",
  { data_type => "varchar", is_nullable => 0, size => 40 },
  "log_created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "log_updated",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 0,
  },
  "number_of_edits",
  { data_type => "integer", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 system_event_log_average_filters

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogAverageFilter>

=cut

__PACKAGE__->has_many(
  "system_event_log_average_filters",
  "TopTable::Schema::Result::SystemEventLogAverageFilter",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_clubs

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogClub>

=cut

__PACKAGE__->has_many(
  "system_event_log_clubs",
  "TopTable::Schema::Result::SystemEventLogClub",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_contact_reasons

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogContactReason>

=cut

__PACKAGE__->has_many(
  "system_event_log_contact_reasons",
  "TopTable::Schema::Result::SystemEventLogContactReason",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_divisions

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogDivision>

=cut

__PACKAGE__->has_many(
  "system_event_log_divisions",
  "TopTable::Schema::Result::SystemEventLogDivision",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_events

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogEvent>

=cut

__PACKAGE__->has_many(
  "system_event_log_events",
  "TopTable::Schema::Result::SystemEventLogEvent",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_files

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogFile>

=cut

__PACKAGE__->has_many(
  "system_event_log_files",
  "TopTable::Schema::Result::SystemEventLogFile",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_fixtures_grids

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogFixturesGrid>

=cut

__PACKAGE__->has_many(
  "system_event_log_fixtures_grids",
  "TopTable::Schema::Result::SystemEventLogFixturesGrid",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_images

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogImage>

=cut

__PACKAGE__->has_many(
  "system_event_log_images",
  "TopTable::Schema::Result::SystemEventLogImage",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_meeting_types

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogMeetingType>

=cut

__PACKAGE__->has_many(
  "system_event_log_meeting_types",
  "TopTable::Schema::Result::SystemEventLogMeetingType",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_meetings

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogMeeting>

=cut

__PACKAGE__->has_many(
  "system_event_log_meetings",
  "TopTable::Schema::Result::SystemEventLogMeeting",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_news

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogNews>

=cut

__PACKAGE__->has_many(
  "system_event_log_news",
  "TopTable::Schema::Result::SystemEventLogNews",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_people

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogPerson>

=cut

__PACKAGE__->has_many(
  "system_event_log_people",
  "TopTable::Schema::Result::SystemEventLogPerson",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_roles

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogRole>

=cut

__PACKAGE__->has_many(
  "system_event_log_roles",
  "TopTable::Schema::Result::SystemEventLogRole",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogSeason>

=cut

__PACKAGE__->has_many(
  "system_event_log_seasons",
  "TopTable::Schema::Result::SystemEventLogSeason",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTeamMatch>

=cut

__PACKAGE__->has_many(
  "system_event_log_team_matches",
  "TopTable::Schema::Result::SystemEventLogTeamMatch",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_teams

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTeam>

=cut

__PACKAGE__->has_many(
  "system_event_log_teams",
  "TopTable::Schema::Result::SystemEventLogTeam",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_league_table_rankings

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateLeagueTableRanking>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_league_table_rankings",
  "TopTable::Schema::Result::SystemEventLogTemplateLeagueTableRanking",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_match_individuals

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchIndividual>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_individuals",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchIndividual",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_match_team_games

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchTeamGame>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_team_games",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchTeamGame",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_template_match_teams

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTemplateMatchTeam>

=cut

__PACKAGE__->has_many(
  "system_event_log_template_match_teams",
  "TopTable::Schema::Result::SystemEventLogTemplateMatchTeam",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::SystemEventLogType>

=cut

__PACKAGE__->belongs_to(
  "system_event_log_type",
  "TopTable::Schema::Result::SystemEventLogType",
  { event_type => "event_type", object_type => "object_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 system_event_log_users

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogUser>

=cut

__PACKAGE__->has_many(
  "system_event_log_users",
  "TopTable::Schema::Result::SystemEventLogUser",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_venues

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogVenue>

=cut

__PACKAGE__->has_many(
  "system_event_log_venues",
  "TopTable::Schema::Result::SystemEventLogVenue",
  { "foreign.system_event_log_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: belongs_to

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "TopTable::Schema::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-04-26 22:08:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xhaWjKCzTmH7dvLM6GE6Vg

#
# Enable automatic date handling
#
__PACKAGE__->add_columns(
    "log_created",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0, },
    "log_updated",
    { data_type => "datetime", timezone => "UTC", set_on_create => 1, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 0, },
);

=head2 log_created_tz

Return the log_created time with the correct timezone.

=cut

sub log_created_tz {
  my ( $self, $tz ) = @_;
  
  # Set the timezone if we have one specified
  $self->log_created->set_time_zone( $tz ) if $tz;
  
  # Return the new time
  return $self->log_created;
}

=head2 log_created_tz

Return the log_created time with the correct timezone.

=cut

sub log_updated_tz {
  my ( $self, $tz ) = @_;
  
  # Set the timezone if we have one specified
  $self->log_updated->set_time_zone( $tz ) if $tz;
  
  # Return the new time
  return $self->log_updated;
}

=head2 display_description

Groups all the related objects for this row into hashrefs of 'for_display', 'for_tooltip' and 'other' for ease of creating a description string.

=cut

sub display_description {
  my ( $self, $maximum_items_display, $maximum_items_tooltip ) = @_;
  
  # Maximum objects to display in the main text - default to 2 if not specified or invalid (non-numeric or less than 0)
  $maximum_items_display = 2 if !defined( $maximum_items_display ) or $maximum_items_display !~ /^\d+$/ or $maximum_items_display < 0;
  $maximum_items_tooltip = 10 if !defined( $maximum_items_tooltip ) or $maximum_items_tooltip !~ /^\d+$/ or $maximum_items_tooltip < 0;
  
  # Returned objects will be a hashref like this:
  # $returned_objects = {
  #   for_display [{
  #     ids => [all_ids],
  #     name => $name,
  #   }],
  #   for_tooltip [{
  #     ids => [all_ids],
  #     name => $name,
  #   }],
  #   other = [{
  #     ids => [all_ids],
  #     name => $name,
  #   }],
  # }
  my $returned_objects = {
    for_display => [],
    for_tooltip => [],
    other       => [],
  };
  
  # Get the SytemEventLog relation - this will tend to be the object type prefixed with "system_event_log_" and suffixed with "s" 
  my $object_relation = sprintf( "system_event_log_%ss", $self->object_type );
  
  # Dashes will have underscores instead
  $object_relation =~ s/-/_/g;
  
  # Exceptions to the rule
  if ( $self->object_type eq "person" ) {
    # people instead of persons
    $object_relation = "system_event_log_people";
  } elsif ( $self->object_type eq "team-match" ) {
    # matches instead of matchs
    $object_relation = "system_event_log_team_matches";
  } elsif ( $self->object_type eq "news" ) {
    # news instead of newss
    $object_relation = "system_event_log_news";
  }
  
  # Get this event's objects to loop through
  my $objects = $self->search_related($object_relation, {}, {
    order_by => {
      -desc => "log_updated",
    },
  });
  
  # Get an array of columns on this event's related objects - we only need to do this on a single record, as all columns will be the same
  my @columns = $objects->search({}, {
    rows => 1,
  })->single->columns;
  
  my $i = 0;
  while ( my $object = $objects->next ) {
    # Increment the item number
    $i++;
    
    # Set the hash key that this object will go into
    my $hash_key;
    if ( $i <= $maximum_items_display or $maximum_items_display == 0 ) {
      # This item will be displayed on the page
      $hash_key = "for_display";
    } elsif ( $i <= $maximum_items_tooltip or $maximum_items_tooltip == 0 ) {
      # This item will be displayed in a tooltip
      $hash_key = "for_tooltip";
    } else {
      # This item will be at the bottom of the tooltip in a count only (e.g., 'and x others') 
      $hash_key = "other";
    }
    
    # Get a list of the column IDs from the columns array - because an object can have more than one primary key, we have to get all columns that begin
    # "object_", because the object ID fields are called "object_<column name>" - most will probably be called object_id, but some will not (i.e., linking
    # to tables with multiple primary keys).
    my $ids = [];
    
    # Push 'league' on to the IDs so the URL is correct for league matches
    push( @{ $ids }, "league" ) if $self->object_type eq "league-team-match";
    
    foreach my $column ( @columns ) {
      if ( $column =~ /^object_([a-z_]+)$/ ) {
        # Save away the stored value - the object relationship columns are set up such that the column name will always be "object_<relationship_name>", so that this can be extracted
        my $column_relation_accessor = $1;
        
        # The pushed values is a list, as we may push more than one (if we have a date, for example)
        my @pushed_values = ();
        # Need to do some checks on what type of column this is
        if ( !ref( $object->$column ) ) {
          # The column is a straight link to an ID somewhere, just push the column value
          $pushed_values[0] = $object->$column;
        } elsif ( ref( $object->$column ) eq "DateTime" ) {
          # A DateTime object needs to be returned in all its components (year, month, day)
          @pushed_values = ( $object->$column->year, $object->$column->month, $object->$column->day );
        } elsif ( ref( $object->$column ) =~ /^TopTable::Model::DB::[A-Z][A-Za-z]+/ ) {
          # The column is a link to another column with a relationship (this table probably has multiple primary keys linking elsewhere)
          # In this case, we need to use the value in memory from the match as the relationship accessor for the actual value
          # We now need to check the ref of that to see what type of object it is
          if ( ref( $object->$column->$column_relation_accessor ) eq "DateTime" ) {
            # A DateTime object needs to be returned in all its components (year, month, day)
            @pushed_values = ( $object->$column->$column_relation_accessor->year, $object->$column->$column_relation_accessor->month, $object->$column->$column_relation_accessor->day );
          } elsif ( ref( $object->$column->$column_relation_accessor ) =~ /^TopTable::Model::DB::[A-Z][A-Za-z]+/ ) {
            # The object refers to another DB table - in this case, the accessor will always be 'id'
            $pushed_values[0] = $object->$column->$column_relation_accessor->id;
          }
        }
        
        # Push the value we need on to the IDs array
        push( @{ $ids }, @pushed_values );
      }
    }
    
    # Push the name and ID(s) on to the specified hash's array
    push( @{ $returned_objects->{$hash_key} }, {
      ids   => $ids,
      name  => $object->name,
    });
  }
  
  # If we only have one tooltip element, it's pointless, so move it on to for_display and empty for_tooltip.
  if ( @{ $returned_objects->{for_tooltip} } == 1 ) {
    push( @{ $returned_objects->{for_display} }, ${ $returned_objects->{for_tooltip} }[0] );
    @{ $returned_objects->{for_tooltip} } = [];
  }
  
  return $returned_objects;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
