package TopTable::Schema::ResultSet::Venue;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Email::Valid;
use HTML::Entities;

=head2 all_venues

A predefined search for all venues returned in venue order.  If a season is specified, only the venues with clubs / teams playing in that season will be returned.

=cut

sub all_venues {
  my ( $self, $season ) = @_;
  my ( $where, $attrib );
  
  if ( $season ) {
    $where = {"team_seasons.season" => $season->id};
    $attrib = {
      join => {
        "clubs" => {teams => "team_seasons"},
      },
      order_by => {-asc => qw( me.name )},
      group_by => qw( me.id ),
    };
  } else {
    $where = undef;
    $attrib = {
      order_by => {-asc => qw( me.name )},
    };
  }
  
  return $self->search($where, $attrib);
}

=head2 active_venues

A predefined search for all active venues returned in venue order.

=cut

sub active_venues {
  my ( $self ) = @_;
  
  return $self->search({active => 1}, {
    order_by => {-asc => qw( me.name )},
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = delete $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my ( $where );
  if ( $split_words ) {
    my @words = split(/\s+/, $q);
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{name => \@constructed_like}];
  } else {
    # Don't split words up before performing a like
    $where = {
      name => {-like => "%$q%"}
    };
  }
  
  my $attrib = {
    order_by => {-asc => [qw( name )]},
    group_by => [qw( name )],
  };
  
  my $use_paging = ( defined($page) ) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  return $self->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of venues.

=cut

sub page_records {
  my ( $self, $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search(undef, {
    page => $page_number,
    rows => $results_per_page,
    order_by  => {-asc => qw( name )},
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key ) = @_;
  return $self->find({url_key => $url_key});
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
      id => $id_or_url_key
    }, {
      url_key => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $self->search($where, {rows => 1})->single;
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
    my $key_check = $self->find_url_key($url_key);
    
    # If not, return it
    return $url_key if !defined($key_check) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a venue.

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
  my $venue = $params->{venue} || undef;
  my $name = $params->{name} || undef;
  my $address1 = $params->{address1} || undef;
  my $address2 = $params->{address2} || undef;
  my $address3 = $params->{address3} || undef;
  my $address4 = $params->{address4} || undef;
  my $address5 = $params->{address5} || undef;
  my $postcode = $params->{postcode} || undef;
  my $telephone = $params->{telephone} || undef;
  my $email_address = $params->{email_address} || undef;
  my $geolocation = $params->{geolocation} || undef;
  my $active = $params->{active};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      address1 => $address1,
      address2 => $address2,
      address3 => $address3,
      address4 => $address4,
      address5 => $address5,
      postcode => $postcode,
      telephone => $telephone,
      email_address => $email_address,
    },
    completed => 0,
  };
  
  $logger->("debug", sprintf("Active: %s (defined: %s)", $active, defined($active)));
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( defined($venue) ) {
      if ( ref($venue) ne "TopTable::Model::DB::Venue" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $venue = $self->find_id_or_url_key($venue);
        
        # Definitely error if we're now undef
        push(@{$response->{errors}}, $lang->maketext("venues.form.error.venue-invalid")) unless defined($venue);
        
        # Another fatal error
        return $response;
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("venues.form.error.venue-not-specified"));
      return $response;
    }
    
    # Will always be active unless we can deactivate it.
    $active = 1 unless $venue->can_deactivate;
    $logger->("debug", "Can't be deactivated, setting active to 1") unless $venue->can_deactivate;
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    # Full name entered, check it.
    my $venue_name_check;
    if ( $action eq "edit" ) {
      $venue_name_check = $self->find(undef, {
        where => {
          name => $name,
          id => {"!=" => $venue->id}
        }
      });
    } else {
      $venue_name_check = $self->find({name => $name});
    }
    
    push(@{$response->{errors}}, $lang->maketext("venues.form.error.name-exists", encode_entities($name))) if defined($venue_name_check);
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("venues.form.error.name-blank"));
  }
  
  my ( $map_lat, $map_lng );
  if ( defined($geolocation) ) {
    if ( ref($geolocation) eq "ARRAY" ) {
      # If we've been passed an array, join it with a comma
      $geolocation = join(",", @{$geolocation}) if ref($geolocation) eq "ARRAY";
    } elsif ( ref($geolocation) eq "HASH" ) {
      # If it's a hash, join the lat and lng keys
      $geolocation = sprintf("%s,%s", $geolocation->{lat}, $geolocation->{lng});
    }
    
    if ( $geolocation =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ ) {
      # Split it out again after
      ( $map_lat, $map_lng ) = split(",", $geolocation);
    } else {
      push(@{$response->{errors}}, $lang->maketext("venues.form.error.map-coordinates-invalid"));
    }
  }
  
  # Phone / email - check they're valid (if entered)
  push(@{$response->{errors}}, $lang->maketext("venues.form.error.telephone-invalid")) if ( defined($telephone) and $telephone !~ m/([0-9x ])/ );
  
  if ( defined($email_address) ) {
    $email_address = Email::Valid->address($email_address);
    push(@{$response->{errors}}, $lang->maketext("venues.form.error.email-invalid")) unless defined($email_address);
  }
  
  # Active - must be 1 or 0
  if ( defined($active) ) {
    $logger->("debug", sprintf("Active is defined, doing sanity check for 1 or 0: %s", $active));
    $active = $active ? 1 : 0;
  } else {
    $active = 0;
    $logger->("debug", sprintf("Active is not defined, setting to 0: %s", $active));
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # Success, we need to create the venue
    if ( $action eq "create" ) {
      $venue = $self->create({
        name => $name,
        url_key => $self->generate_url_key($name),
        address1 => $address1,
        address2 => $address2,
        address3 => $address3,
        address4 => $address4,
        address5 => $address5,
        postcode => $postcode,
        telephone => $telephone,
        email_address => $email_address,
        coordinates_latitude => $map_lat,
        coordinates_longitude => $map_lng,
        active => $active,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($venue->name), $lang->maketext("admin.message.created")));
    } else {
      $venue->update({
        name => $name,
        url_key => $self->generate_url_key($name, $venue->id),
        address1 => $address1,
        address2 => $address2,
        address3 => $address3,
        address4 => $address4,
        address5 => $address5,
        postcode => $postcode,
        telephone => $telephone,
        email_address => $email_address,
        coordinates_latitude => $map_lat,
        coordinates_longitude => $map_lng,
        active => $active,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($venue->name), $lang->maketext("admin.message.edited")));
    }
    
    $response->{venue} = $venue;
  }
  
  return $response;
}

1;
