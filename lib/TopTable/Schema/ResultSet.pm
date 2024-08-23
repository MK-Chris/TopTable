package TopTable::Schema::ResultSet;
use strict;
use warnings;
use base qw( DBIx::Class::ResultSet );

=head2 find_url_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $class, $url_key ) = @_;
  return $class->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $class, $id_or_url_key, $params ) = @_;
  my $no_prefetch = $params->{no_prefetch} || 0;
  my $schema = $class->result_source->schema;
  
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      "me.id" => $id_or_url_key
    }, {
      "me.url_key" => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {"me.url_key" => $id_or_url_key};
  }
  
  # Setup attribs, and get the prefetches based on what's calling
  my %attrib = ();
  
  if ( $class->isa(__PACKAGE__ . "::Club") ) {
    # Club, prefetch secretary and venue
    $attrib{prefetch} = [qw( secretary venue )] unless $no_prefetch;
  } elsif ( $class->isa(__PACKAGE__ . "::ContactReason") ) {
    $attrib{prefetch} = {contact_reason_recipients => "person"} unless $no_prefetch;
  } elsif ( $class->isa(__PACKAGE__ . "::Person") ) {
    $attrib{prefetch} = "user" unless $no_prefetch;
  } elsif ( $class->isa(__PACKAGE__ . "::User") ) {
    $attrib{prefetch} = "person" unless $no_prefetch;
  }
  
  return $class->find($where, \%attrib);
}

=head2 make_url_key

Generate a unique key from the given name.  Must be used on a resultset where the objects have an id and url_key field.

=cut

sub make_url_key {
  my ( $class, $name, $exclusion_obj ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc($original_url_key); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = sprintf("%s-%d", $original_url_key, $count);
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $conflict;
    if ( defined($exclusion_obj) ) {
      # Find anything with this value, excluding the exclusion object passed in
      $conflict = $class->find({}, {
        where => {
          url_key => $url_key,
          id => {"!=" => $exclusion_obj->id},
        }
      });
    } else {
      # Find anything with this value
      $conflict = $class->find({url_key => $url_key});
    }
    
    # If not, return it
    return $url_key unless defined($conflict);
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}


=head2 search_single_field

Check the field given in the parameter 'field' for the value given in 'value'.  Optionally takes an 'exclusion_obj', which is excluded from the search (this is useful if we want to check if a supposedly unique value is already entered, but want to exclude the object we're supposed to be editing).

Returns the results of the find (which is obviously undef if nothing comes back).

=cut

sub search_single_field {
  my ( $class, $params ) = @_;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $field = $params->{field};
  my $value = $params->{value};
  my $exclusion_obj = $params->{exclusion_obj};
  
  if ( defined($exclusion_obj) ) {
    # Find anything with this value, excluding the exclusion object passed in
    return $class->find({}, {
      where => {
        $field => $value,
        id => {"!=" => $exclusion_obj->id},
      }
    });
  } else {
    # Find anything with this value
    return $class->find({$field => $value});
  }
}

1;