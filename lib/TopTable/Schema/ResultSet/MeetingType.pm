package TopTable::Schema::ResultSet::MeetingType;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 all_meeting_types

Search for all meeting types ordered by name.

=cut

sub all_meeting_types {
  my $class = shift;
  
  return $class->search(undef, {
    order_by => {-asc => "name"},
  });
}

=head2 page_records

Retrieve a paginated list of seasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my $class = shift;
  my ( $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => [qw( name )]},
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a meeting type.

=cut

sub create_or_edit {
  my $class = shift;
  my ( $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $meeting_type = $params->{meeting_type};
  my $name = $params->{name} || undef;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {name => $name},
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( ref( $meeting_type ) ne "TopTable::Model::DB::MeetingType" ) {
      # This may not be an error, we may just need to find from an ID or URL key
      $meeting_type = $class->find_id_or_url_key($meeting_type);
      
      # Definitely error if we're now undef
      push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.meeting-type-invalid")) unless defined($meeting_type);
      
      # Another fatal error
      return $response;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $meeting_type}));
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.name-blank"));
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($name, $meeting_type);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Success, we need to create the meeting type
    if ( $action eq "create" ) {
      $meeting_type = $class->create({
        name => $name,
        url_key => $url_key,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $meeting_type->name, $lang->maketext("admin.message.created")));
    } else {
      $meeting_type->update({
        name => $name,
        url_key => $url_key,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $meeting_type->name, $lang->maketext("admin.message.edited")));
    }
    
    $response->{meeting_type} = $meeting_type;
  }
  
  return $response;
}

1;