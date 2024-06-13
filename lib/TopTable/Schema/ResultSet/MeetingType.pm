package TopTable::Schema::ResultSet::MeetingType;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_meeting_types

Search for all meeting types ordered by name.

=cut

sub all_meeting_types {
  my ( $self ) = @_;
  
  return $self->search(undef, {
    order_by => {-asc => "name"},
  });
}

=head2 page_records

Retrieve a paginated list of seasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => [qw( name )]},
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $exclude_id ) = @_;
  
  return $self->find({
    url_key => $url_key,
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my ( $where );
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - assume it's the ID
    $where = {id => $id_or_url_key};
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $self->find( $where );
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key = lc( $original_url_key ); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = $original_url_key . "-" . $count;
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $key_check = $self->find_url_key( $url_key );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a meeting type.

=cut

sub create_or_edit {
  my ( $self, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $meeting_type = delete $params->{meeting_type};
  my $name = delete $params->{name};
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
      $meeting_type = $self->find_id_or_url_key( $meeting_type );
      
      # Definitely error if we're now undef
      push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.meeting-type-invalid")) unless defined( $meeting_type );
      
      # Another fatal error
      return $response;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Name entered, check it.
    my $meeting_type_name_check;
    if ( $action eq "edit" ) {
      $meeting_type_name_check = $self->find({}, {
        where => {
          name  => $name,
          id    => {"!=" => $meeting_type->id}
        }
      });
    } else {
      $meeting_type_name_check = $self->find({name => $name});
    }
    
    push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.name-exists")) if defined( $meeting_type_name_check );
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("meeting-types.form.error.name-blank"));
  }
  
  if ( scalar( @{$response->{errors}} ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $meeting_type->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to create the meeting type
    if ( $action eq "create" ) {
      $meeting_type = $self->create({
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