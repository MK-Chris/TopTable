package TopTable::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use DateTime::TimeZone;
use Set::Object;
use HTML::Entities;
use Regexp::Common qw( URI );
use Email::Valid;
use Bytes::Random::Secure qw( random_bytes_hex );

=head2 search_by_name

Return search results based on a supplied full or username.

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
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{username => \@constructed_like}];
  } else {
    # Don't split words up before performing a like
    $where = {username => {-like => "%$q%"}};
  }
  
  my $attrib = {
    order_by => {-asc => [qw( username )]},
    group_by => [qw( username )],
  };
  
  my $use_paging = defined($page) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  return $class->search( $where, $attrib );
}

=head2 page_records

Returns a paginated resultset of clubs.

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
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( username )},
  });
}

=head2 all_users

Returns a paginated resultset of clubs.

=cut

sub all_users {
  my $class = shift;
  my ( $params ) = @_;
  
  return $class->search(undef, {
    prefetch => "person",
    order_by => {-asc => qw( username )}
  });
}

=head2 find_by_name

Return a single user based on the full username.

=cut

sub find_by_name {
  my $class = shift;
  my ( $username ) = @_;
  return $class->find({username => $username});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my $class = shift;
  my ( $id_or_url_key ) = @_;
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
  
  return $class->search($where, {
    prefetch => "person",
    rows => 1,
  })->single;
}

=head2 reset_expired_invalid_login_counts

Get all of the invalid login counts that have expired and reset them to 0.

=cut

sub reset_expired_invalid_login_counts {
  my $class = shift;
  my ( $expiry_threshold_minutes ) = @_;
  
  # Set a default number of minutes if the number supplied is invalid
  $expiry_threshold_minutes = 30 if !defined($expiry_threshold_minutes) or !$expiry_threshold_minutes or $expiry_threshold_minutes!~ /^\d+$/ or $expiry_threshold_minutes < 1;
  
  my $time_limit_threshold = DateTime->now(time_zone => "UTC")->subtract(minutes => $expiry_threshold_minutes);
  
  $class->search(undef, {
    where => {
      last_invalid_login => {"<=" => $time_limit_threshold->ymd . " " . $time_limit_threshold->hms},
    },
  })->update({
    invalid_logins => 0,
    last_invalid_login => undef,
  });
}

=head2 delete_expired_keys

Get all of the activation keys and password reset keys that have expired and undef them.

=cut

sub delete_expired_keys {
  my $class = shift;
  my $now = DateTime->now(time_zone => "UTC");
  
  # Password reset keys
  $class->search(undef, {
    where => {
      password_reset_expires => {"<=" => sprintf("%s %s", $now->ymd, $now->hms)}
    }
  })->update({
    password_reset_key => undef,
    password_reset_expires => undef,
  });
  
  # Activation keys - user actually gets deleted if not activated in time.
  $class->search(undef, {
    where => {
      activated => 0,
      activation_expires => {"<=" => sprintf("%s %s", $now->ymd, $now->hms)}
    }
  })->delete;
}

=head2 get_unapproved

Get a list of unapproved users.

=cut

sub get_unapproved {
  my $class = shift;
  return $class->search({approved => 0}, {prefetch => "person"});
}

=head2 create_or_edit

Error checks requested registration details and creates the user with an activation key that's emailed back to the user.

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
  my $user = $params->{user} || undef;
  my $username = $params->{username} || undef;
  my $username_editable = $params->{username_editable} || 0;
  my $email_address = $params->{email_address} || undef;
  my $confirm_email_address = $params->{confirm_email_address} || "";
  my $password = $params->{password} || undef;
  my $confirm_password = $params->{confirm_password} || "";
  my $current_password = $params->{current_password} || undef;
  my $language = $params->{language} || undef;
  my $facebook = $params->{facebook} || undef;
  my $twitter = $params->{twitter} || undef;
  my $instagram = $params->{instagram} || undef;
  my $snapchat = $params->{snapchat} || undef;
  my $tiktok = $params->{tiktok} || undef;
  my $website = $params->{website} || undef;
  my $interests = $params->{interests} || undef;
  my $occupation = $params->{occupation} || undef;
  my $location = $params->{location} || undef;
  my $timezone = $params->{timezone} || undef;
  my $roles = $params->{roles} || undef;
  my $registration_reason = $params->{registration_reason} || undef;
  my $html_emails = $params->{html_emails} || 0;
  my $hide_online = $params->{hide_online} || 0;
  my $ip_address = $params->{ip_address} || undef;
  my $editing_user = $params->{editing_user} || undef;
  my $activation_expiry_limit = $params->{activation_expiry_limit} || 24;
  my $manual_approval = $params->{manual_approval} || 0;
  my $require_reason = $params->{require_reason} || 0;
  my $installed_languages = $params->{installed_languages};
  my $set_locale;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      username => $username,
      email_address => $email_address,
      confirm_email_address => $confirm_email_address,
      facebook => $facebook,
      twitter => $twitter,
      instagram => $instagram,
      snapchat => $snapchat,
      tiktok => $tiktok,
      website => $website,
      interests => $interests,
      occupation => $occupation,
      location => $location,
      timezone => $timezone,
      registration_reason => $registration_reason,
    },
    completed => 0,
  };
  
  my $can_edit_roles = 0;
  
  # Sanitise the activation expiry limit - default to 24 if it's not numeric
  $activation_expiry_limit = 24 unless $activation_expiry_limit =~ /^\d+$/;
  
  # Check the username is valid
  if ( $action ne "register" and $action ne "edit" ) {
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # Check the user passed is valid
    if ( defined($user) ) {
      if ( ref($user) ne "TopTable::Model::DB::User" ) {
        push(@{$response->{errors}}, $lang->maketext("user.form.error.user-invalid"));
        return $response;
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("user.form.error.user-not-specified"));
      return $response;
    }
  }
  
  # If the following fields are changed, we will need to check the 
  my ( $username_changed, $email_changed, $password_changed );
  
  if ( $action eq "register" ) {
    # Check we're not banned from registering - check the IP passed in and the email entered; if either is banned, we error
    my $banned = $class->result_source->schema->resultset("Ban")->is_banned({
      ip_address => $ip_address,
      email_address => $email_address,
      level => "registration",
      log_allowed => 0,
      log_banned => 1,
    });
    
    # Log our responses
    $logger->("error", $_) foreach @{$banned->{errors}};
    $logger->("warning", $_) foreach @{$banned->{warnings}};
    $logger->("info", $_) foreach @{$banned->{info}};
    
    if ( $banned->{is_banned} ) {
      push(@{$response->{errors}}, $lang->maketext("user.form.error.registration-banned"));
      return $response;
    }
  } elsif ( $action eq "edit" ) {
    $username_changed = ( $username ne $user->username and $username_editable ) ? 1 : 0;
    $email_changed = $email_address eq $user->email_address ? 0 : 1;
    $password_changed = defined($password) ? 1 : 0; # We don't check this against the current password at the moment, if there is a password entered, assume it's changing
  }
  
  # Check the username if we're creating a new user OR we are allowing this username to be edited and we've detected a change
  if ( $action eq "register" or ( $username_editable and $username_changed ) ) {
    if ( $username ) {
      if ( $username =~ m/^[a-z][a-z0-9-_ .]{2,45}$/i ) {
        # If the username is valid, check it isn't already registered
        my $check_username;
        
        if ( $action eq "register" ) {
          $check_username = $class->find({username => $username});
        } else {
          $check_username = $class->find(undef, {
            where => {
              username => $username,
              id => {"!=" => $user->id},
            },
          });
        }
        push(@{$response->{errors}}, $lang->maketext("user.form.error.username-registered")) if defined($check_username);
      } else {
        # Invalid username
        push(@{$response->{errors}}, $lang->maketext("user.form.error.username-invalid"));
      }
    } else {
      # Blank username
      push(@{$response->{errors}}, $lang->maketext("user.form.error.username-blank"));
    }
  }
  
  # Check the email addresses match
  if ( $action eq "register" or $email_changed ) {
    if ( defined($email_address) ) {
      if ( $email_address eq $confirm_email_address ) {
        # If they match, check the email address is valid
        $email_address = Email::Valid->address($email_address);
        
        if ( defined($email_address) ) {
          # Email is valid, check it isn't already registered
          my $check_email;
          
          if ( $action eq "register" ) {
            $check_email = $class->find({email_address => $email_address});
          } else {
            $check_email = $class->find({}, {
              where => {
                username  => $username,
                id => {"!=" => $user->id},
              },
            });
          }
          
          push(@{$response->{errors}}, $lang->maketext("user.form.error.email-registered")) if defined($check_email);
        } else {
          # Invalid email address.
          push(@{$response->{errors}}, $lang->maketext("user.form.error.email-invalid"));
        }
      } else {
        # Non-matching email addresses
        push(@{$response->{errors}}, $lang->maketext("user.form.error.email-confirm-mismatch"));
      }
    } else {
      # Email address not entered
      push(@{$response->{errors}}, $lang->maketext("user.form.error.email-blank"));
    }
  }
  
  # Check the password was provided
  if ( $action eq "register" or $password_changed ) {
    if ( defined($password) ) {
      # Check the passwords match
      if ( $password ne $confirm_password ) {
        # Non-matching passwords
        push(@{$response->{errors}}, $lang->maketext("user.form.error.password-confirm-mismatch"));
      } else {
        # Check password strength
        if ( length($password) < 8 ) {
          # Password too short
          push(@{$response->{errors}}, $lang->maketext("user.form.error.password-too-short", 8));
        } else {
          # Check password complexity
          push(@{$response->{errors}}, $lang->maketext("user.form.error.password-complexity")) unless $password =~ /[A-Z]/ and $password =~ /[a-z]/ and $password =~ /\d/;
        }
      }
    } else {
      # Password is blank
      push(@{$response->{errors}}, $lang->maketext("user.form.error.password-blank"));
    }
  }
  
  if ( ( $username_changed or $email_changed or $password_changed ) and defined($editing_user) and $editing_user->id == $user->id ) {
    # The username, email or password has changed, so we need to authenticate the current password
    if ( defined($current_password) ) {
      # Check the current password entered is correct
      push(@{$response->{errors}}, $lang->maketext("user.form.error.curent-password-incorrect")) unless $editing_user->check_password($current_password);
    } else {
      # Current password field is blank
      push(@{$response->{errors}}, $lang->maketext("user.form.error.curent-password-blank"));
    }
  }
  
  # Social / website checks
  push(@{$response->{errors}}, $lang->maketext("user.form.error.facebook-invalid")) if defined($facebook) and $facebook !~ m/^[a-z0-9_.]+$/i;
  push(@{$response->{errors}}, $lang->maketext("user.form.error.twitter-invalid")) if defined($twitter) and $twitter !~ m/^[a-z0-9_.]{1,15}$/i;
  push(@{$response->{errors}}, $lang->maketext("user.form.error.instagram-invalid")) if defined($instagram) and $instagram !~ m/^[a-z0-9_.]{1,30}$/i;
  push(@{$response->{errors}}, $lang->maketext("user.form.error.snapchat-invalid")) if defined($snapchat) and $snapchat !~ m/^[a-z][a-z0-9_.-]{1,13}[a-z0-9]$/i;
  push(@{$response->{errors}}, $lang->maketext("user.form.error.tiktok-invalid")) if defined($tiktok) and ( length($tiktok) < 2 or length($tiktok) > 24 );
  push(@{$response->{errors}}, $lang->maketext("user.form.error.website-invalid")) if defined($website) and $website !~ m/$RE{URI}{HTTP}{-scheme => qr<https?>}/;
  
  if ( $language ) {
    # Language selected, check it's installed
    push(@{$response->{errors}}, $lang->maketext("user.form.error.language-invalid")) unless exists($installed_languages->{$language});
  } else {
    # Error, language is not selected
    push(@{$response->{errors}}, $lang->maketext("user.form.error.language-blank"));
  }
  
  if ( $timezone ) {
    push(@{$response->{errors}}, $lang->maketext("user.form.error.timezone-invalid")) unless DateTime::TimeZone->is_valid_name($timezone);
  } else {
    push(@{$response->{errors}}, $lang->maketext("user.form.error.timezone-blank"));
  }
  
  push(@{$response->{errors}}, $lang->maketext("user.form.error.reason-blank")) if $action eq "register" and $manual_approval and $require_reason and ( !defined($registration_reason) or !$registration_reason );
  
  # Boolean sanity check - true = 1, false = 0
  $html_emails = $html_emails ? 1 : 0;
  $response->{fields}{html_emails} = $html_emails;
  
  # Check roles - if we're editing, we need to check the editing user has permissions to do this.
  # Default to check roles (we'll check roles if we're registering or if the user is authorised) to
  # do so.
  my @roles = (); # Final role objects to assign the users to
  
  if ( $action eq "register" ) {
    # Add any roles that need to be added to newly registered users by default.
    my $default_roles = $class->result_source->schema->resultset("Role")->search({apply_on_registration => 1});
    
    if ( $default_roles->count ) {
      while ( my $role = $default_roles->next ) {
        push(@roles, {role => $role->id});
      }
    }
  } elsif ( $action eq "edit" ) {
    # Check that we can edit roles, then loop through and add them
    my @need_roles = $class->result_source->schema->resultset("Role")->search({role_edit => 1});
    my @have_roles = $editing_user->all_roles;
    @need_roles = map($_->name, @need_roles);
    @have_roles = map($_->name, @have_roles);
    my $have_roles = Set::Object->new(@have_roles);
    my $need_roles = Set::Object->new(@need_roles);
    
    # Set check roles to zero unless we're authorised to do it.
    $can_edit_roles = $have_roles->intersection($need_roles)->size > 0 ? 1 : 0;
    
    if ( $can_edit_roles ) {
      # Check the roles we have.
      $roles = [$roles] unless ref($roles) eq "ARRAY";
      
      my $invalid_roles = 0;
      foreach my $role_id ( @{$roles} ) {
        my $role = $class->result_source->schema->resultset("Role")->find($role_id);
        
        if ( defined($role) ) {
          if ( $role->anonymous ) {
            # Don't push and warn that we can't add to anonymous
            push(@{$response->{warnings}}, $lang->maketext("user.form.warning.cant-add-to-anonymous"));
          } else {
            push(@roles, $role->id);
          }
        } else {
          $invalid_roles++;
        }
      }
      
      # Warn if any of the roles were invalid
      push(@{$response->{warnings}}, $lang->maketext("user.form.warning.one-or-more-roles-invalid", $invalid_roles)) if $invalid_roles;
      
      my @default_roles = $class->result_source->schema->resultset("Role")->search({apply_on_registration => 1});
      @default_roles = map($_->id , @default_roles);
      my $default_roles = Set::Object->new(@default_roles);
      my $selected_roles = Set::Object->new(@roles);
      my $default_roles_not_selected = $default_roles->difference($selected_roles);
      
      # Check we have all the default roles selected
      if ( $default_roles_not_selected->size ) {
        $selected_roles->insert(@$default_roles_not_selected);
        
        push(@{$response->{warnings}}, $lang->maketext("user.form.warning.default-roles-added", $invalid_roles));
      }
      
      @roles = $selected_roles->members;
      push(@{$response->{error}}, $lang->maketext("user.form.error.no-valid-roles")) if scalar @roles == 0;
    }
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # This is a random verification key that we can then put into an email.
    my $activation_key = random_bytes_hex(32) if $action eq "register";
    
    # Build the key from the username
    my $url_key;
    if ( $action eq "edit" and $username_changed and $username_editable ) {
      $url_key = $class->generate_url_key($username, $user->id);
    } elsif ( $action eq "register" ) {
      $url_key = $class->generate_url_key($username);
    }
    
    # Start a transaction so we don't have a partially updated database
    my $transaction = $class->result_source->schema->txn_scope_guard;
    
    if ( $action eq "register" ) {
      # Create new user
      my $activation_expires = DateTime->now(time_zone  => "UTC")->add(hours => $activation_expiry_limit);
      
      my $create_options = {
        username => $username,
        url_key => $url_key,
        email_address => $email_address,
        password => $password,
        registered_ip => $ip_address,
        last_active_ip => $ip_address,
        locale => $language,
        timezone => $timezone,
        html_emails => $html_emails,
        activated => 0,
        activation_expires => sprintf("%s %s", $activation_expires->ymd, $activation_expires->hms),
        registration_reason => $registration_reason,
        user_roles => \@roles,
      };
      
      if ( $manual_approval ) {
        # Manual approval, set 'approved' to 0
        $create_options->{approved} = 0;
      } else {
        # Automatic approval, set 'approved' to 1
        $create_options->{approved} = 1;
      }
      
      $user = $class->create($create_options);
      
      # Activation key has to be updated afterwards, so it can go through the hashing routine
      $user->activation_key($activation_key);
      $user->update;
      $response->{completed} = 1;
      $response->{activation_key} = $activation_key;
      
      # We will NEVER set locale if the user is being created, as that user needs to be activated first
      $set_locale = 0;
    } else {
      # Edit
      # Set hide online to 1 or 0 (sanity check)
      $hide_online = $hide_online ? 1 : 0;
      
      # Check if we need to set the locale - true if the language has changed and we're editing the logged in user
      $set_locale = ( $language ne $user->locale and defined($editing_user) and $user->id == $editing_user->id ) ? 1 : 0;
      
      my $update_data = {
        email_address => $email_address,
        last_active_ip => $ip_address,
        locale => $language,
        timezone => $timezone,
        html_emails => $html_emails,
        facebook => $facebook,
        twitter => $twitter,
        instagram => $instagram,
        snapchat => $snapchat,
        tiktok => $tiktok,
        website => $website,
        interests => $interests,
        occupation => $occupation,
        location => $location,
        hide_online => $hide_online,
      };
      
      # Add the new username and URL key to the updated data if it's editable and been changed
      if ( $username_editable and $username_changed ) {
        $update_data->{username} = $username;
        $update_data->{url_key} = $url_key;
      }
      
      # Add the new password to the updated data if it's been updated
      $update_data->{password} = $password if $password_changed;
      
      $user->update($update_data);
      
      if ( $can_edit_roles ) {
        # Set up the roles - get the current roles first
        my @current_roles = $user->search_related("user_roles");
        
        # From those two arrays we can now work out what to add and remove: currently @roles contains
        # all the roles we need to add; @current_roles contains the current roles.  We can use Set::Object
        # to return a list of what's in @current_roles and not in @roles (roles to remove) and also what's
        # in @roles and not in @current_roles (roles to add).  Anything in both is a role that is currently
        # assigned and should stay assigned, so doesn't need to be touched.
        @current_roles = map($_->id, @current_roles);
        my $current_roles = Set::Object->new(@current_roles);
        my $new_roles = Set::Object->new(@roles);
        my $roles_to_add = $new_roles->difference($current_roles);
        my $roles_to_remove = $current_roles->difference($new_roles);
        
        # Get the arrays back
        my @roles_to_add = @$roles_to_add;
        my @roles_to_remove = @$roles_to_remove;
        
        # Check if any of the roles we're removing is the sysadmin role
        my $sysadmin_role = $class->result_source->schema->resultset("Role")->find({
          sysadmin => 1,
          id => {-in => \@roles_to_remove}
        });
        
        if ( defined( $sysadmin_role ) ) {
          my $users = $sysadmin_role->search_related("user_roles")->search_related("user", {
            id => {"!=" => $user->id}
          })->count;
          
          if ( $users == 0 ) {
            # Trying to remove the last user from the sysadmin group - error
            push( @{ $response->{warning} }, {
              id => "user.form.warning.cant-remove-last-sysadmin",
              parameters => [ encode_entities( $user->username ) ],
            });
            
            $roles_to_remove->delete( $sysadmin_role->id );
            @roles_to_remove = @$roles_to_remove;
          }
        }
        
        # Now do the SQL operations themselves
        $user->delete_related("user_roles", {
          role => {-in => \@roles_to_remove},
        }) if scalar @roles_to_remove;
        
        $user->create_related("user_roles", {role => $_}) foreach @roles_to_add;
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("user.edit.success", encode_entities($user->username)));
    }
    
    # Commit the transaction
    $transaction->commit;
    
    $response->{set_locale} = $set_locale;
    $response->{user} = $user;
  }
  
  # Return the roles too, as they may have been altered
  $response->{roles} = \@roles;
  return $response;
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my $class = shift;
  my ( $url_key ) = @_;
  return $class->find({url_key => $url_key});
}

=head2 generate_url_key

Generate a unique key from the given club short name.

=cut

sub generate_url_key {
  my $class = shift;
  my ( $short_name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($short_name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc( $original_url_key ); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = $original_url_key . $count;
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $key_check = $class->find_url_key($url_key);
    
    # If not, return it
    return $url_key if !defined($key_check) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

1;
