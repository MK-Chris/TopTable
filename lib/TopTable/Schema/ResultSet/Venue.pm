package TopTable::Schema::ResultSet::Venue;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_venues

A predefined search for all venues returned in venue order.  If a season is specified, only the venues with clubs / teams playing in that season will be returned.

=cut

sub all_venues {
  my ( $self, $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where      = {
      "team_seasons.season" => $season->id,
    };
    
    $attributes = {
      join      => {
        "clubs" => {
          teams => "team_seasons",
        },
      },
      order_by  => {
        -asc => "me.name"
      },
      group_by  => "me.id"
    };
  } else {
    $where      = {};
    $attributes = {
      order_by => {
        -asc => "name"
      },
    };
  }
  
  return $self->search( $where, $attributes );
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
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
    }
    
    $where = [{
      name => \@constructed_like,
    }];
  } else {
    # Don't split words up before performing a like
    $where = {
      name => {-like => "%$q%"}
    };
  }
  
  my $attrib = {
    order_by => {-asc => [ qw( name ) ]},
    group_by => [ qw( name ) ],
  };
  
  my $use_paging = ( defined( $page ) ) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  return $self->search( $where, $attrib );
}

=head2 page_records

Returns a paginated resultset of venues.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number         = $parameters->{page_number} || 1;
  my $results_per_page    = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => {
      -asc => "name",
    },
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
    $where = {
      id => $id_or_url_key,
    };
  } else {
    # Not numeric - must be the URL key
    $where = {
      url_key => $id_or_url_key,
    };
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

Provides the wrapper (including error checking) for adding / editing a venue.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $venue_name_check );
  my $return_value = {error => []};
  
  my $venue         = $parameters->{venue};
  my $name          = $parameters->{name};
  my $address1      = $parameters->{address1};
  my $address2      = $parameters->{address2};
  my $address3      = $parameters->{address3};
  my $address4      = $parameters->{address4};
  my $address5      = $parameters->{address5};
  my $postcode      = $parameters->{postcode};
  my $telephone     = $parameters->{telephone};
  my $email_address = $parameters->{email_address};
  my $latitude      = $parameters->{coordinates_latitude};
  my $longitude     = $parameters->{coordinates_longitude};
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ( $action eq "edit" ) {
    unless ( defined( $venue ) and ref( $venue ) eq "TopTable::Model::DB::Venue" ) {
      # Editing a venue that doesn't exist.
      push(@{ $return_value->{error} }, {id => "venues.form.error.venue-invalid"});
      
      # Another fatal error
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    if ( $action eq "edit" ) {
      $venue_name_check = $self->find({}, {
        where => {
          name  => $name,
          id    => {
            "!=" => $venue->id,
          }
        }
      });
    } else {
      $venue_name_check = $self->find({name => $name});
    }
    
    push(@{ $return_value->{error} }, {id => "venues.form.error.name-exists"}) if defined( $venue_name_check );
  } else {
    # Name omitted.
    push(@{ $return_value->{error} }, {id => "venues.form.error.name-blank"});
  }
  
  if ( $latitude and $longitude ) {
    my $geolocation = $latitude . "," . $longitude;
    push(@{ $return_value->{error} }, {id => "venues.form.error.map-coordinates-invalid"}) if $geolocation and $geolocation !~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/;
  }
  
  # Phone / email - check they're valid (if entered)
  push(@{ $return_value->{error} }, {id => "venues.form.error.telephone-invalid"}) if ( $telephone and $telephone !~ m/([0-9x ])/ );
  push(@{ $return_value->{error} }, {id => "venues.form.error.email-invalid"}) if $email_address and $email_address !~ m/^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i;
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $venue->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to create the venue
    if ( $action eq "create" ) {
      $venue = $self->create({
        name                  => $name,
        url_key               => $url_key,
        address1              => $address1,
        address2              => $address2,
        address3              => $address3,
        address4              => $address4,
        address5              => $address5,
        postcode              => $postcode,
        telephone             => $telephone,
        email_address         => $email_address,
        coordinates_latitude  => $latitude,
        coordinates_longitude => $longitude,
      });
    } else {
      $venue->update({
        name                  => $name,
        url_key               => $url_key,
        address1              => $address1,
        address2              => $address2,
        address3              => $address3,
        address4              => $address4,
        address5              => $address5,
        postcode              => $postcode,
        telephone             => $telephone,
        email_address         => $email_address,
        coordinates_latitude  => $latitude,
        coordinates_longitude => $longitude,
      });
    }
    
    $return_value->{venue} = $venue;
  }
  
  return $return_value;
}

1;
