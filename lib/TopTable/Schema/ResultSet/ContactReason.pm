package TopTable::Schema::ResultSet::ContactReason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;
use Data::Printer;

=head2 all_reasons

Search for all meeting types ordered by name.

=cut

sub all_reasons {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {-asc => "name"},
  });
}

=head2 page_records

Retrieve a paginated list of contact reasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

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
    order_by => {-asc => "name"},
  });
}

=head2 check

Checks a given ID is valid, returns the contact reason prefetched with the recipients.

=cut

sub check {
  my ( $self, $query ) = @_;
  
  return $self->find({
    id => $query,
  }, {
    prefetch => {contact_reason_recipients => "person"},
  });
}

=head2 find_url_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $exclude_id ) = @_;
  
  return $self->find({
    url_key => $url_key,
  }, {
    prefetch => {contact_reason_recipients => "person"}
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
  
  return $self->find( $where, {
    prefetch => {contact_reason_recipients => "person"}
  });
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

Provides the wrapper (including error checking) for adding / editing a contact reason.

=cut

sub create_or_edit {
  my ( $self, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext( TopTable::Maketext->get_handle( $locale ) ) unless defined( $schema->lang );
  my $lang = $schema->lang;
  
  # Grab the fields
  my $reason = $params->{reason};
  my $name = $params->{name};
  my $recipients = $params->{recipients};
  my $recipient_ids = $params->{recipient_ids};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name  => $name, # Don't need to do anything to sanitise the name, so just pass it back in
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $response->{errors} }, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    unless ( defined( $reason ) and ref( $reason ) eq "TopTable::Model::DB::MeetingType" ) {
      # Editing a meeting type that doesn't exist.
      push(@{ $response->{errors} }, $lang->maketext("meeting-types.form.error.meeting-type-invalid"));
      
      # Another fatal error
      return $response;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    my $reason_name_check;
    
    if ( $action eq "edit" ) {
      $reason_name_check = $self->find({}, {
        where => {
          name => $name,
          id => {"!=" => $reason->id}
        }
      });
    } else {
      $reason_name_check = $self->find({name => $name});
    }
    
    push(@{ $response->{errors} }, $lang->maketext("contact-reasons.form.error.name-exists")) if defined( $reason_name_check );
  } else {
    # Name omitted.
    push(@{ $response->{errors} }, $lang->maketext("contact-reasons.form.error.name-blank"));
  }
  
  # Check recipients - first set to an arrayref if it's not already, so we know we can loop
  $recipients = [ $recipients ] if defined( $recipients ) and ref( $recipients ) ne "ARRAY";
  $recipient_ids = [ $recipient_ids ] if defined( $recipient_ids ) and ref( $recipient_ids ) ne "ARRAY";
  
  if ( !defined( $recipients ) or scalar(@{$recipients}) == 0 ) {
    # Make sure $recipients is an arrayref so we can push on to it
    $recipients = [];
    
    # No already defined recipients, check recipient IDs
    if ( defined( $recipient_ids ) ) {
      # Now find the person for each ID given - just use the ID if we can't find anything; this means
      # we can raise an error when we then look for valid people in @$recipients
      push(@{$recipients}, $self->result_source->schema->resultset("Person")->find( $_ ) || $_ ) foreach ( @{$recipient_ids} );
    }
  }
  
  my $invalid_recipients  = 0; # Keep a count of invalid recipients for the error message
  my %recipient_ids = (); # Keep a list of recipients already specified so we don't add duplicates
  my @recipient_list = (); # Final list of recipients
  my @field_recipients = (); # List of recipients to go in the fields part of the response
  
  if ( scalar( @{ $recipients } ) ) {
    # We have recipients, check them
    foreach my $recipient ( @{ $recipients } ) {
      if ( defined( $recipient ) and ref( $recipient ) eq "TopTable::Model::DB::Person" ) {
        # Person is valid, add them if we haven't seen them before
        unless ( exists( $recipient_ids{$recipient->id} ) ) {
          # Now check we have an email address for that person.
          if ( $recipient->email_address ) {
            push(@recipient_list, {person => $recipient->id});
            
            # Make sure we add to the recipient_ids hash so we know we've now seen them on subsequent loops
            $recipient_ids{$recipient->id} = 1;
          } else {
            # No email address, error
            push(@{ $response->{errors} }, $lang->maketext("contact-reasons.form.error.no-email-for-person", $recipient->display_name));
          }
          
          # Push on to the fields
          push(@field_recipients, $recipient);
        }
      } else {
        # Not a valid person
        $invalid_recipients++;
      }
    }
    
    # Add the final recipients into the field list to return back
    $response->{fields}{recipients} = \@field_recipients;
    
    if ( $invalid_recipients ) {
      my $message_id = ( $invalid_recipients == 1 ) ? "contact-reasons.form.error.invalid-recipients-single" : "contact-reasons.form.error.invalid-recipients-multiple";
      push(@{ $response->{errors} }, $lang->maketext($message_id, $invalid_recipients));
    }
  } else {
    # No recipients, error
    push(@{ $response->{errors} }, $lang->maketext("contact-reasons.form.error.no-recipients"));
  }
  
  if ( scalar( @{ $response->{errors} } ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $reason->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to do the database operations
    # Start a transaction so we don't have a partially updated database
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    if ( $action eq "create" ) {
      $reason = $self->create({
        name => $name,
        url_key => $url_key,
        contact_reason_recipients => \@recipient_list,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $reason->name, $lang->maketext("admin.message.created")));
    } else {
      $reason->update({
        name => $name,
        url_key => $url_key,
      });
      
      # If we're updating, we need to delete all recipients that were previously there, then recreate them if necessary
      my $previous_recipients = $reason->search_related("contact_reason_recipients")->delete;
      
      # Loop through the attendees / apologies and add any that need adding
      foreach my $recipient ( @recipient_list ) {
        # Create the new attendee unless they exist already - we don't need to check whether they're an apology here, as that was all changed in the previous loop
        $reason->create_related("contact_reason_recipients", {
          person => $recipient->{person}->id,
          apologies => $recipient->{apologies},
        });
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $reason->name, $lang->maketext("admin.message.edited")));
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    $response->{reason} = $reason;
  }
  
  return $response;
}

1;