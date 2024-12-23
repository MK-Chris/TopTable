package TopTable::Schema::ResultSet::Venue;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use Email::Valid;
use HTML::Entities;

=head2 all_venues

A predefined search for all venues returned in venue order.  If a season is specified, only the venues with clubs / teams playing in that season will be returned.

=cut

sub all_venues {
  my $class = shift;
  my ( $season ) = @_;
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
  
  return $class->search($where, $attrib);
}

=head2 active_venues

A predefined search for all active venues returned in venue order.

=cut

sub active_venues {
  my $class = shift;
  
  return $class->search({active => 1}, {
    order_by => {-asc => qw( me.name )},
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my $class = shift;
  my ( $params ) = @_;
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
  
  return $class->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of venues.

=cut

sub page_records {
  my $class = shift;
  my ( $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search(undef, {
    page => $page_number,
    rows => $results_per_page,
    order_by  => {-asc => qw( name )},
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a venue.

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
  
  #$logger->("debug", sprintf("Active: %s (defined: %s)", $active, defined($active)));
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( defined($venue) ) {
      if ( ref($venue) ne "TopTable::Model::DB::Venue" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $venue = $class->find_id_or_url_key($venue);
        
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
    #$logger->("debug", "Can't be deactivated, setting active to 1") unless $venue->can_deactivate;
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    push(@{$response->{errors}}, $lang->maketext("venues.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $venue}));
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
    #$logger->("debug", sprintf("Active is defined, doing sanity check for 1 or 0: %s", $active));
    $active = $active ? 1 : 0;
  } else {
    $active = 0;
    #$logger->("debug", sprintf("Active is not defined, setting to 0: %s", $active));
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # Success, we need to create the venue
    if ( $action eq "create" ) {
      $venue = $class->create({
        name => $name,
        url_key => $class->make_url_key($name),
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
        url_key => $class->generate_url_key($name, $venue->id),
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
