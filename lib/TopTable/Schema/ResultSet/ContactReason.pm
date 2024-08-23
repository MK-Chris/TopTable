package TopTable::Schema::ResultSet::ContactReason;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 all_reasons

Search for all meeting types ordered by name.

=cut

sub all_reasons {
  my $class = shift;
  return $class->search({}, {order_by => {-asc => "name"}});
}

=head2 page_records

Retrieve a paginated list of contact reasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

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
    order_by => {-asc => "name"},
  });
}

=head2 check

Checks a given ID is valid, returns the contact reason prefetched with the recipients.

=cut

sub check {
  my $class = shift;
  my ( $query ) = @_;
  
  return $class->find({
    id => $query,
  }, {
    prefetch => {contact_reason_recipients => "person"},
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a contact reason.

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
  my $reason = $params->{reason};
  my $name = $params->{name} || undef;
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
  if ( defined($name) ) {
    # Full name entered, check it.
    push(@{$response->{errors}}, $lang->maketext("contact-reasons.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $reason}));
  } else {
    # Full name omitted.
    push(@{$response->{errors}}, $lang->maketext("ontact-reasons.form.error.name-blank"));
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
      push(@{$recipients}, $class->result_source->schema->resultset("Person")->find( $_ ) || $_ ) foreach ( @{$recipient_ids} );
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
      $url_key = $class->make_url_key($name, $reason);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Success, we need to do the database operations
    # Start a transaction so we don't have a partially updated database
    my $transaction = $class->result_source->schema->txn_scope_guard;
    
    if ( $action eq "create" ) {
      $reason = $class->create({
        name => $name,
        url_key => $url_key,
        contact_reason_recipients => \@recipient_list,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($reason->name), $lang->maketext("admin.message.created")));
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
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($reason->name), $lang->maketext("admin.message.edited")));
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    $response->{reason} = $reason;
  }
  
  return $response;
}

1;