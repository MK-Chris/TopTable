package TopTable::Schema::ResultSet::Role;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;
use Set::Object;

=head2 all_roles

Return a list of all roles ordered by built-in status (system roles at the top), then sysadmin status (sysadmin at the top), then anonymous status (anonymous at the top), then name.

You should then get a list consisting of: Administrators, Anonymous, any other system roles (ordered by name), then any user-defined roles (ordered by name).  Note that system role names may differ from their language versions, so may not strictly be in order as the user sees them.

=cut

sub all_roles {
  my $class = shift;
  my ( $parameters ) = @_;
  my $include_anonymous = $parameters->{include_anonymous};
  
  my $where = $include_anonymous ? {} : {anonymous => 0};
  
  return $class->search($where, {
    order_by => [{
      -desc => [qw( me.system me.sysadmin me.anonymous )],
    }, {
      -asc  => [qw( me.name )],
    }],
  });
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
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => [{
      -desc => [qw( me.system me.sysadmin me.anonymous )],
    }, {
      -asc  => [qw( me.name )],
    }],
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a role.

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
  # Non-permissions fields
  my $role = $params->{role} || undef;
  my $name = $params->{name} || undef;
  my $members = $params->{members} || [];
  
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {name => $name},
    completed => 0,
    new_members => [],
    existing_members => [],
    removed_members => [],
    members => [], # validated full list of members
  };
  
  # Default to 1 - if we're editing the sysadmin role, all we can do is set members, permissions should *always* be set to 1, so we won't allow them to be edited.
  # Sysadmin users are god.
  # If we're editing the registered users or anonymous roles, these can't have members set
  my $can_set_permissions = 1;
  my $can_edit_members = 1;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{error}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( defined($role) ) {
      if ( ref($role) ne "TopTable::Model::DB::Role" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $role = $class->find_id_or_url_key($role);
        
        # Definitely error if we're now undef
        if ( defined($role) ) {
          $can_set_permissions = 0 if $role->sysadmin;
          $can_edit_members = 0 if $role->anonymous or $role->apply_on_registration;
        } else {
          push(@{$response->{error}}, $lang->maketext("roles.form.error.role-invalid")) unless defined($role);
          
          # Another fatal error
          return $response;
        }
        
      }
    } else {
      push(@{$response->{error}}, $lang->maketext("roles.form.error.role-not-specified"));
    }
  } else {
    # Create - not a sytem role, we can definitely accept permissions
  }
  
  # Error checking
  # Check the names were entered and don't exist already - if it's a system role, it can't be renamed, so we don't do this check.
  if ( $action eq "create" or ( $action eq "edit" and !$role->system ) ) {
    if ( defined($name) ) {
      push(@{$response->{error}}, $lang->maketext("roles.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $role}));
    } else {
      # Name omitted.
      push(@{$response->{error}}, $lang->maketext("roles.form.error.name-blank"));
    }
  }
  
  # Check the members are valid - this doesn't duplicate work when we set the members, as if they are already objects (which this will ensure),
  # the set_members routine will just check they're the correct reference.  Doing it here means we generate the errors / warnings even if there are
  # other errors to show (set_members is only called if there are no errors in the processing of the role)
  # Loop through and check each one
  my $invalid_members = 0;
  my @validated_members = ();
  foreach my $member ( @{$members} ) {
    if ( defined($member) ) {
      if ( ref($member) ne "TopTable::Model::DB::User" ) {
        $member = $schema->resultset("User")->find_id_or_url_key($member);
        
        if ( defined($member) ) {
          push(@validated_members, $member);
        } else {
          $invalid_members++;
        }
      }
    } else {
      $invalid_members++;
    }
  }
  
  if ( $action eq "edit" and $role->sysadmin and scalar @validated_members == 0 ) {
    push(@{$response->{error}}, $lang->maketext("roles.form.error.cant-remove-all-sysadmins"));
    return $response;
  }
  
  # Replace the members with the validated members
  $members = \@validated_members;
  $response->{fields}{members} = $members;
  
  # Warn if we had invalid users
  push(@{$response->{warning}}, $lang->maketext("roles.form.warning.users-invalid", $invalid_members)) if $invalid_members;
  
  # Check permissions - first get the list of possible fields from result_source
  my $columns = Set::Object->new($class->result_source->columns);
  
  # Delete the ones we're not bothered about - leave only permissions fields
  $columns->delete(qw( id url_key name system sysadmin anonymous apply_on_registration ));
  
  # Map them to a hash with the column names as keys and the values passed in $params as values.  If we can't set permissions (because this is the sysadmin account),
  # we just won't set these into the hash
  my %fields = $can_set_permissions ? map{$_ => $params->{$_} || 0} @$columns : ();
  
  # Loop through and check that all the permissions are 1 or 0
  $response->{fields}{$_} = $fields{$_} ? 1 : 0 foreach keys %fields;
  
  if ( scalar @{$response->{error}} == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" and !$role->system ) {
      $url_key = $class->make_url_key($name, $role);
    } elsif ( $action eq "create" ) {
      $url_key = $class->make_url_key($name);
    }
    
    # Success, we need to do the database operations
    if ( $action eq "create" ) {
      # Take the fields hash (which currently just has the permissions in) and add in the other fields
      $fields{name} = $name;
      $fields{url_key} = $url_key;
      
      $role = $class->create(\%fields);
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($role->name), $lang->maketext("admin.message.created")));
    } else {
      # Editing
      # Take the fields hash (which currently just has the permissions in) and add in the other fields
      my $role_name = $role->name;
      
      if ( $role->system ) {
        # System roles are defined in the language codes
        $role_name = $lang->maketext("roles.name.$role_name");
      } else {
        # Only add the name / URL key if it's not a system role
        $fields{name} = $name;
        $fields{url_key} = $url_key;
        $role_name = encode_entities($role_name);
      }
      
      # Do the update
      $role->update(\%fields);
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $role_name, $lang->maketext("admin.message.edited")));
    }
    
    if ( defined($role) and !$role->apply_on_registration ) {
      # Set the members for the role using the IDs / objects passed in.  The set_members routine does all the checks
      my $members_response = $role->set_members($members);
      
      # Push all messages from the setting of the member list into the response we send back
      push(@{$response->{error}}, @{$members_response->{error}});
      push(@{$response->{warning}}, @{$members_response->{warning}});
      push(@{$response->{info}}, @{$members_response->{info}});
      push(@{$response->{success}}, @{$members_response->{success}});
    }
    
    $response->{role} = $role;
  }
  
  return $response;
}

1;
