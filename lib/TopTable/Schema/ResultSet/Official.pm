package TopTable::Schema::ResultSet::Official;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;
use DDP;

=head2 all_officials_in_season

Returns all the officials for a given season.  Search / return the season object

=cut

sub all_officials_in_season {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "official_seasons.season" => $season->id,
  }, {
    prefetch => {
      official_seasons => [qw( official season ), {
      official_season_people => "position_holder",
    }]},
    order_by => {
      -asc => [qw( position_order )],
    }
  });
}

=head2 page_records

Returns a paginated resultset of clubs.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => "position_name"},
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      "me.url_key" => $id_or_url_key
    }, {
      "me.id" => $id_or_url_key
    }];
    #$where = {"me.id" => $id_or_url_key};
  } else {
    # Not numeric - must be the URL key
    $where = {"me.url_key" => $id_or_url_key};
  }
  
  return $self->search($where, {
    prefetch => {
      official_seasons => [qw( season ), {
        official_season_people => "position_holder",
      }]
    },
    oder_by => [{
      -asc => [qw( season.complete )]
    }, {
      -desc => [qw( season.start_date season.end_date )]
    }],
  })->first;
}

=head2 find_url_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $exclude_id ) = @_;
  
  return $self->find({
    url_key => $url_key,
  }, {
    #prefetch => {contact_reason_recipients => "person"}
  });
}

=head2 generate_url_key

Generate a unique key from the given contact reason name.

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
    my $key_check = $self->find_url_key($url_key);
    
    # If not, return it
    return $url_key if !defined($key_check) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
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
  $logger->("debug", sprintf("Locale: '%s'", $locale));
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $position = $params->{position};
  my $position_name = $params->{position_name};
  my $holders = $params->{holders};
  my $holder_ids = $params->{holder_ids};
  my @officials_in_season = ();
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      position_name => $position_name, # Don't need to do anything to sanitise the name, so just pass it back in
      holders => [],
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    unless ( defined($position) and ref($position) eq "TopTable::Model::DB::Official" ) {
      # Editing a meeting type that doesn't exist.
      push(@{$response->{errors}}, $lang->maketext("officials.form.error.position-invalid"));
      
      # Another fatal error
      return $response;
    }
  }
  
  # Error checking
  # Check there's a current season (we'll need it later anyway, but it's an error if there isn't)
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    # No current season, which is a fatal error, return
    push(@{$response->{errors}}, $lang->maketext("officials.form.error.no-current-season"));
    return $response;
  }

  # Check the names were entered and don't exist already.
  if ( defined($position_name) ) {
    # Full name entered, check it.
    my $position_name_check;
    
    if ( $action eq "edit" ) {
      $position_name_check = $self->find({}, {
        where => {
          position_name => $position_name,
          id => {"!=" => $position->id}
        }
      });
    } else {
      $position_name_check = $self->find({position_name => $position_name});
      undef($position); # Make sure we don't have a position passed in if we're creating
    }
    
    push(@{$response->{errors}}, $lang->maketext("officials.form.error.name-exists")) if defined($position_name_check);
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("officials.form.error.name-blank"));
  }
  
  # Check holders - first set to an arrayref if it's not already, so we know we can loop
  $holders = [$holders] if defined($holders) and ref($holders) ne "ARRAY";
  $holder_ids = [$holder_ids] if defined($holder_ids) and ref($holder_ids) ne "ARRAY";
  
  if ( !defined($holders) or scalar(@{$holders}) == 0 ) {
    # Make sure $holders is an arrayref so we can push on to it
    $holders = [];
    
    # No already defined holders, check recipient IDs
    if ( defined($holder_ids) ) {
      # Now find the person for each ID given - just use the ID if we can't find anything; this means
      # we can raise an error when we then look for valid people in @$holders
      push(@{$holders}, $schema->resultset("Person")->find($_) || $_ ) foreach (@{$holder_ids});
    }
  }
  
  my $invalid_holders  = 0; # Keep a count of invalid holders for the error message
  my %holder_ids = (); # Keep a list of holders already specified so we don't add duplicates
  my @holder_list = (); # Final list of holders
  my @field_holders = (); # List of holders to go in the fields part of the response
  
  if ( scalar(@{$holders}) ) {
    # We have holders, check them
    foreach my $holder ( @{$holders} ) {
      $logger->("debug", sprintf("holder: %s, ref: %s", $holder, ref($holder)));
      if ( defined($holder) and ref($holder) eq "TopTable::Model::DB::Person" ) {
        
        # Person is valid, add them if we haven't seen them before
        unless ( exists($holder_ids{$holder->id}) ) {
          push(@holder_list, {position_holder => $holder->id, season => $season->id});
          
          # Make sure we add to the holder_ids hash so we know we've now seen them on subsequent loops
          $holder_ids{$holder->id} = 1;
          
          # Push on to the fields
          push(@field_holders, $holder);
          
          # This player is valid, so we definitely will add it to sanitised fields to pass back in case we are redirecting to the error form
          push(@{$response->{fields}{holders}}, $holder);
        }
      } else {
        # Not a valid person
        $invalid_holders++;
      }
    }
    
    # Add the final holders into the field list to return back
    $response->{fields}{holders} = \@field_holders;
    
    if ( $invalid_holders ) {
      my $message_id = ( $invalid_holders == 1 ) ? "officials.form.error.invalid-holders-single" : "officials.form.error.invalid-holders-multiple";
      push(@{$response->{errors}}, $lang->maketext($message_id, $invalid_holders));
    }
  } else {
    # No holders, error
    push(@{$response->{errors}}, $lang->maketext("officials.form.error.no-holders"));
  }
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key($position_name, $position->id);
    } else {
      $url_key = $self->generate_url_key($position_name);
    }
    
    # Success, we need to do the database operations
    # Start a transaction so we don't have a partially updated database
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # All new officials will be positioned at the end; same goes for officials not as yet used in the current season
    my @officials_in_season = $self->all_officials_in_season($season);
    my $position_order;
    
    my $official_season;
    if ( $action eq "create" or !defined($official_season = $position->get_season($season)) ) {
      # Check we have officials already
      if ( scalar(@officials_in_season) ) {
        # Position at the end - add one to the last position order we have
        $position_order = $officials_in_season[-1]->get_season($season)->position_order;
        $position_order++;
      } else {
        # This is the first official in the season, order is 1
        $position_order = 1;
      }
    }
    
    if ( $action eq "create" ) {
      # Create the new position
      $position = $self->create({
        position_name => $position_name,
        url_key => $url_key,
        official_seasons => [{
          season => $season->id,
          position_name => $position_name,
          position_order => $position_order,
          official_season_people => \@holder_list,
        }],
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($position->position_name), $lang->maketext("admin.message.created")));
    } else {
      $position->update({
        position_name => $position_name,
        url_key => $url_key,
      });
      
      if ( defined($official_season) ) {
        # Delete all existing people, then re-add our new list.  Eventually we'll try and do something cleverer than this, but this will do for now
        $official_season->update({
          position_name => $position_name,
          position_order => $position_order,
        });
        
        $official_season->delete_related("official_season_people");
        $official_season->create_related("official_season_people", $_) foreach @holder_list;
      } else {
        # It wasn't already set in this season, so set the new season object up
        $position->create_related("official_seasons", {
          season => $season->id,
          position_name => $position_name,
          position_order => $position_order,
          official_season_people => \@holder_list,
        });
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($position->position_name), $lang->maketext("admin.message.edited")));
    }
    
    # Run through and update all the officials that have had positional orders udpated
    if ( scalar(@officials_in_season) ) {
      $_->update foreach @officials_in_season;
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    $response->{position} = $position;
  }
  
  return $response;
}

sub reorder {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  $logger->("debug", sprintf("Locale: '%s'", $locale));
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $official_ids = $params->{official_positions};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  # Get the current season, as we can only change this for the current season
  my $season = $self->result_source->schema->resultset("Season")->get_current;
  
  unless ( defined( $season ) ) {
    # No current season, fatal error
    push( @{$response->{errors}}, $lang->maketext("officials.reorder.error.no-current-season") );
    $response->{can_complete} = 0;
    return $response;
  }
  
  my $officials = $self->all_officials_in_season($season);
    
  # If we have a grid and a season, we need to see if matches have already been set for that grid
  if ( $officials->count == 0 ) {
    push(@{$response->{errors}}, $lang->maketext("officials.reorder.error.no-officials-in-current-season") );
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Get the submitted values into an array if it's not already
  $official_ids = [$official_ids] unless ref($official_ids) eq "ARRAY";
  
  # This hash will hold divisions and their teams and their positions as well as
  # some other name data so that we can use it in error messages.
  my %submitted_data = ();
  
  # This will hold the values we've seen for each division so we can make sure we've not seen any
  # position more than once for any divisioon
  my %used_values = ();
  
  # The error message to build up
  my $error;
  
  # Loop through the team IDs; make sure each team belongs to this division and is only itemised once and that no teams are missing.
  my $position = 1;
  foreach my $id ( @{$official_ids} ) {
    # If we have an ID, make sure it's in the resultset for this season
    my $official = $self->find_id_or_url_key($id);
    my $official_season = $official->get_season($season);
    
    if ( defined($official_season) ) {
      $submitted_data{$official->url_key} = {
        name => $official->position_name,
        position => $position,
        # Hold the DB objects so we don't have to look them up again
        db => {
          official => $official,
          official_season => $official_season,
        }
      };
      
      if ( defined( $used_values{$official->url_key}{$position} ) ) {
        # Already exists, push it on to the arrayref
        push(@{$used_values{$official->url_key}{$position}} , $official->position_name);
      } else {
        # Doesn't exist, create a new arrayref
        $used_values{$official->url_key}{$position} = [$official->position_name];
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("officials.reorder.error.wrong-official-id", $id));
    }
    
    $position++;
  }
  
  # After we loop through the IDs, make sure we have each team in there
  $officials->reset;
  while ( my $official = $officials->next ) {
    my $official_season = $official->get_season($season);
    push(@{$response->{errors}}, $lang->maketext("officials.reorder.error.no-position-for-official", encode_entities($official->position_name), encode_entities($season->name)))  if !exists($submitted_data{$official->url_key});
  }
  
  # Now loop through our %used_values hash and make sure we haven't used any position more than once for each division.
  foreach my $official_key ( keys(%used_values) ) {
    foreach my $position ( keys( %{$used_values{$official_key}} ) ) {
      push(@{$response->{errors}}, $lang->maketext("officials.reorder.error.position-used-more-than-once", $position, join(", ", @{$used_values{$official_key}{$position}}))) if scalar(@{$used_values{$official_key}{$position}}) > 1;
    }
  }
  
  $response->{fields} = \%submitted_data;
  
  # Check for errors
  if ( scalar @{$response->{errors}} == 0 ) {
    # Start a transaction so we don't have a partially updated database
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Finally we need to loop through again updating the home / away teams for each match
    foreach my $official_key ( keys %submitted_data ) {
      # Get the division DB object, then the team seasons object
      my $official = $submitted_data{$official_key}{db}{official};
      my $official_season = $submitted_data{$official_key}{db}{official_season};
      my $position_order = $submitted_data{$official_key}{position};
      
      $official_season->update({position_order => $position_order});
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    push(@{$response->{success}}, $lang->maketext("officials.reorder.success"));
    $response->{completed} = 1;
  }
  
  return $response;
}

1;