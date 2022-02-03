package TopTable::Schema::ResultSet::AverageFilter;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;

=head2 all_filters

Search for all meeting types ordered by name.

=cut

sub all_filters {
  my ( $self, $parameters ) = @_;
  my $where;
  
  my $user  = $parameters->{user} || undef;
  my $all   = $parameters->{all} || 0;
  
  if ( $all ) {
    # Return everything
    $where = {};
  } elsif ( defined( $user ) ) {
    # Return all filters for the given user and all public filters
    $where = [{
      user => undef,
    }, {
      user => $user->id,
    }];
  } else {
    # Return all public filters
    $where = {user => undef};
  }
  
  return $self->search($where, {
    order_by => {
      -asc => "name",
    },
  });
}

=head2 page_records

Retrieve a paginated list of seasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $where;
  my $page_number       = $parameters->{page_number} || 1;
  my $results_per_page  = $parameters->{results_per_page} || 25;
  my $user              = $parameters->{user} || undef;
  my $all               = $parameters->{view_all} || 0;
  
  if ( $all ) {
    # Return everything
    $where = {};
  } elsif ( defined( $user ) ) {
    # Return all filters for the given user and all public filters
    $where = [{
      user => undef,
    }, {
      user => $user->id,
    }];
  } else {
    # Return all public filters
    $where = {user => undef};
  }
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search($where, {
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => {
      -asc    => [qw( name )]
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
  }, {
    prefetch => "user",
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
    prefetch => "user"
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

Provides the wrapper (including error checking) for adding / editing a meeting type.

=cut

sub create_or_edit {
  my ( $self, $action, $params ) = @_;
  
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext( TopTable::Maketext->get_handle( $locale ) ) unless defined( $schema->lang );
  my $lang = $schema->lang;
  
  # Defaults
  my $show_active   = 0;
  my $show_loan     = 0;
  my $show_inactive = 0;
  
  # Grab the fields
  my $filter = delete $params->{filter};
  my $name = delete $params->{name};
  my $player_types = delete $params->{player_type} || [];
  my $criteria_field = delete $params->{criteria_field} || undef;
  my $operator = delete $params->{operator} || undef;
  my $criteria_type = delete $params->{criteria_type} || undef;
  my $criteria = delete $params->{criteria} || undef;
  my $user = delete $params->{user} || undef;
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
    push(@{ $response->{fatal} }, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    unless ( defined( $filter ) and ref( $filter ) eq "TopTable::Model::DB::AverageFilter" ) {
      # Editing a meeting type that doesn't exist.
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.filter-invalid"));
      
      # Another fatal error
      return $response;
    }
    
    # The user is the one already in the database if we're editing
    $user = $filter->user;
  } else {
    # Creating - make sure we have a valid user (if defined).  We should never set this error, as the currently
    # logged in user should get passed in. 
    if ( defined( $user ) and ref( $user ) ne "Catalyst::Authentication::Store::DBIx::Class::User" ) {
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.user-invalid"));
      return $response;
    }
  }
  
  # Check the user is valid if we're creating only (this is not altered if we're editing)
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Name entered, check it - the name only has to be unique against the user who owns it (including 'undef' if it's a public filter).
    my $user_id = $user->id if defined( $user );
    
    my $filter_name_check;
    if ( $action eq "edit" ) {
      $filter_name_check = $self->find({}, {
        where => {
          name => $name,
          user => $user_id,
          id => {"!=" => $filter->id}
        }
      });
    } else {
      $filter_name_check = $self->find({
        name => $name,
        user => $user_id,
      });
    }
    
    # The message is slightly different for public and user filters
    my $message_id = ( defined( $user ) ) ? "average-filter.form.error.name-exists-user" : "average-filter.form.error.name-exists-public";
    push(@{ $response->{errors} }, $lang->maketext($message_id)) if defined( $filter_name_check );
  } else {
    # Name omitted.
    push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.name-blank"));
  }
  
  # Check player types - first set to an arrayref if it's not already, so we know we can loop
  $player_types = [ $player_types ] unless ref( $player_types ) eq "ARRAY";
  
  if ( scalar( @{ $player_types } ) ) {
    # We have recipients, check them
    foreach my $player_type ( @{ $player_types } ) {
      if ( defined( $player_type ) ) {
        if ( $player_type eq "active" ) {
          $show_active = 1;
        } elsif ( $player_type eq "loan" ) {
          $show_loan = 1;
        } elsif ( $player_type eq "inactive" ) {
          $show_inactive = 1;
        }
      }
    }
    
    $response->{fields}{show_active} = $show_active;
    $response->{fields}{show_loan} = $show_loan;
    $response->{fields}{show_inactive} = $show_inactive;
    
    # No valid types selected
    push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.no-player-types")) unless $show_active or $show_loan or $show_inactive;
  } else {
    # No recipients, error
    push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.no-player-types"));
  }
  
  # Check the criteria fields as long as at least one is filled out
  if ( defined( $criteria_field ) or defined( $operator ) or defined( $criteria ) or defined( $criteria_type ) ) {
    unless ( $criteria_field eq "played" or $criteria_field eq "won" or $criteria_field eq "lost" ) {
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.criteria-field-invalid"));
      $criteria_field = "";
    }
    
    unless ( $operator eq ">" or $operator eq ">=" or $operator eq "=" or $operator eq "<=" or $operator eq "<" ) {
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.operator-invalid"));
      $operator = "";    
    }
    
    unless ( !defined( $criteria ) or $criteria =~ /^\d+$/ ) {
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.criteria-invalid"));
      $criteria = "";
    }
    
    unless ( $criteria_type eq "matches" or $criteria_type eq "matches-pc" or $criteria_type eq "games" ) {
      push(@{ $response->{errors} }, $lang->maketext("average-filter.form.error.criteria-type-invalid"));
      $criteria_type = "";
    }
  }
  
  $response->{fields}{criteria_field} = $criteria_field;
  $response->{fields}{operator} = $operator;
  $response->{fields}{criteria} = $criteria;
  $response->{fields}{criteria_type} = $criteria_type;
  
  if ( scalar( @{ $response->{errors} } ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $filter->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to do the database operations
    
    if ( $action eq "create" ) {
      # Set the user value to be its on ID if we have one - saves big if statements with separate creates
      $user = ( defined( $user ) ) ? $user->id : undef;
      
      $filter = $self->create({
        name => $name,
        url_key => $url_key,
        show_active => $show_active,
        show_loan => $show_loan,
        show_inactive => $show_inactive,
        criteria_field => $criteria_field,
        operator => $operator,
        criteria => $criteria,
        criteria_type => $criteria_type,
        user => $user,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $filter->name, $lang->maketext("admin.message.created")));
    } else {
      $filter->update({
        url_key => $url_key,
        show_active => $show_active,
        show_loan => $show_loan,
        show_inactive => $show_inactive,
        criteria_field => $criteria_field,
        operator => $operator,
        criteria => $criteria,
        criteria_type => $criteria_type,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $filter->name, $lang->maketext("admin.message.edited")));
    }
    
    $response->{filter} = $filter;
  }
  
  return $response;
}

1;