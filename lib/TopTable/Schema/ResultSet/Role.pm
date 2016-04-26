package TopTable::Schema::ResultSet::Role;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;
use Set::Object;
use Data::Dumper;

__PACKAGE__->load_components(qw{Helper::ResultSet::SetOperations});

=head2 all_roles

Return a list of all roles ordered by built-in status (system roles at the top), then sysadmin status (sysadmin at the top), then anonymous status (anonymous at the top), then name.

You should then get a list consisting of: Administrators, Anonymous, any other system roles (ordered by name), then any user-defined roles (ordered by name).  Note that system role names may differ from their language versions, so may not strictly be in order as the user sees them.

=cut

sub all_roles {
  my ( $self, $parameters ) = @_;
  my $include_anonymous = $parameters->{include_anonymous};
  
  my $where = ( $include_anonymous ) ? {} : {anonymous => 0};
  
  return $self->search($where, {
    order_by => [{
      -desc => [ qw( system sysadmin anonymous ) ],
    }, {
      -asc  => [ qw( name ) ],
    }],
  });
}

=head2 page_records

Retrieve a paginated list of contact reasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number       = $parameters->{page_number} || 1;
  my $results_per_page  = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page      => $page_number,
    rows      => $results_per_page,
    order_by => [{
      -desc => [ qw( system sysadmin anonymous ) ],
    }, {
      -asc  => [ qw( name ) ],
    }],
  });
}

=head2 find_url_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $exclude_id ) = @_;
  return $self->find({url_key => $url_key});
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
  
  return $self->find( $where, );
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

Provides the wrapper (including error checking) for adding / editing a role.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters, $c ) = @_;
  my ( $role_name_check );
  my $return_value = {error => [], warning => []};
  
  my $role              = $parameters->{role};
  my $name              = $parameters->{name};
  my $members           = $parameters->{members};
  my $permission_values = $parameters->{fields};
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ( $action eq "edit" ) {
    unless ( defined( $role ) and ref( $role ) eq "TopTable::Model::DB::Role" ) {
      # Editing a meeting type that doesn't exist.
      push(@{ $return_value->{error} }, {id => "roles.form.error.role-invalid"});
      
      # Another fatal error
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already - if it's a system role, it can't be renamed, so we don't do this check.
  if ( $action eq "create" or ( $action eq "edit" and $role->system ) ) {
    if ( $name ) {
      # Full name entered, check it.
      if ( $action eq "edit" ) {
        $role_name_check = $self->find({}, {
          where => {
            name  => $name,
            id    => {
              "!=" => $role->id,
            }
          }
        });
      } else {
        $role_name_check = $self->find({name => $name});
      }
      
      push(@{ $return_value->{error} }, {
        id          => "roles.form.error.name-exists",
        parameters  => [ encode_entities( $name ) ],
      }) if defined( $role_name_check );
    } else {
      # Name omitted.
      push(@{ $return_value->{error} }, {id => "roles.form.error.name-blank"});
    }
  }
  
  # Check permissions - first get the list of possible fields from result_source
  my $column_names = Set::Object->new( $self->result_source->columns );
  
  # Delete the ones we're not bothered about - leave only permissions fields
  $column_names->delete( qw( id url_key name system sysadmin anonymous apply_on_registration ) );
  
  # Map them to a hash with the column names as keys and the values passed in $field_values as values
  my %fields = map{ $_ => $permission_values->{$_} || 0 } @$column_names;
  
  $c->log->debug( Dumper( \%fields ) );
  
  # Loop through and check that all the permissions are 1 or 0
  $fields{$_} = ( $fields{$_} ) ? 1 : 0 foreach ( keys %fields );
  
  # Check members - first make it an array if it isn't already
#   $members = [ $members ] unless ref( $members ) eq "ARRAY";
#   
#   # Set into an object so we can delete objects easily
#   my @members = @$members;
#   $members    = Set::Object->new( @members );
#   
#   # Loop through and check each one
#   my $invalid_members = 0;
#   foreach my $member ( @members ) {
#     $member = $self->result_source->schema->resultset("User")->find({id => $member});
#     
#     if ( defined( $member ) ) {
#       $members->insert( $member );
#     } else {
#       $invalid_members++;
#       
#       # Delete from the member IDs
#       $members->delete( $member );
#     }
#   }
#   
#   # Set the array of member IDs again from the object (which has now had invalid IDs deleted)
#   @members = @$members;
#   
#   push( @{ $return_value->{warning} }, {
#     id          => "roles.form.warning.users-invalid",
#     parameters  => [$invalid_members],
#   });
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" and $role->system == 0 ) {
      $url_key = $self->generate_url_key( $name, $role->id );
    } elsif ( $action eq "create" ) {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Sort out the fields we need to insert
    if ( $action eq "create" or $role->system == 0 ) {
      $fields{name}     = $name;
      $fields{url_key}  = $url_key;
    }
    
    # Success, we need to do the database operations
    # Start a transaction so we don't have a partially updated database
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    if ( $action eq "create" ) {
      # Now we have to map the member IDs into hashrefs
#       @members = map( {user => $_}, @members );
      
      # Take the fields hash (which currently just has the permissions in) and add in the other fields
      $fields{name}       = $name;
      $fields{url_key}    = $url_key;
#       $fields{user_roles} = \@members;
      
      $role = $self->create( \%fields );
    } else {
      # Editing
      # Take the fields hash (which currently just has the permissions in) and add in the other fields
      $fields{name}       = $name;
      $fields{url_key}    = $url_key;
      
      # Do the update
      $role->update( \%fields );
      
#       # Get the current roles so we can compare to the list of users submitted with the form
#       my @current_members = $role->search_related("user_roles", {}, {
#         prefetch => "user",
#       });
#       
#       # Map the ID only so that we can compare IDs to the IDs in the @roles
#       @current_members    = map( $_->user->id, @current_members );
#       
#       # From those two arrays we can now work out what to add and remove: currently @members contains all
#       # the roles we need to add; @current_members contains the current members.  We can use Set::Object
#       # to return a list of what's in @current_members and not in @members (members to remove) and also
#       # what's in @members and not in @current_members (members to add).  Anything in both is a role
#       # that is currently assigned and should stay assigned, so doesn't need to be touched.
#       my $current_members   = Set::Object->new( @current_members );
#       my $new_members       = Set::Object->new( @members );
#       my $members_to_add    = $new_members->difference( $current_members );
#       my $members_to_remove = $current_members->difference( $new_members );
#       
#       # Get the arrays back
#       my @members_to_add    = @$members_to_add;
#       my @members_to_remove = @$members_to_remove;
#       
#       # Now do the SQL operations themselves
#       $role->delete_related("user_roles", {
#         user => {
#           -in => \@members_to_remove,
#         },
#       }) if scalar @members_to_remove;
#       
#       $role->create_related("user_roles", {user => $_}) foreach @members_to_add;
    }
    
    # Commit the database transactions
    $transaction->commit;
    
    $return_value->{role} = $role;
  }
  
  return $return_value;
}

1;
