package TopTable::Schema::ResultSet::User;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Digest::SHA qw( sha256_hex );
use DateTime;
use DateTime::TimeZone;
use Time::HiRes;

=head2 search_by_name

Return search results based on a supplied full or username.

=cut

sub search_by_name {
  my ( $self, $search_term ) = @_;
  my ( $where, $attributes );
  
  return $self->search({
    username   => {
      like => '%' . $search_term . '%',
    }
  }, {
    order_by => "username"
  });
}

=head2 page_records

Returns a paginated resultset of clubs.

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
      -asc => "username",
    },
  });
}

=head2 find_by_name

Return a single user based on the full username.

=cut

sub find_by_name {
  my ( $self, $username ) = @_;
  
  return $self->find({
    username => $username,
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
  
  return $self->find($where, {
    prefetch  => "person",
  });
}

=head2 reset_expired_invalid_login_counts

Get all of the invalid login counts that have expired and reset them to 0.

=cut

sub reset_expired_invalid_login_counts {
  my ( $self, $expiry_threshold_minutes ) = @_;
  
  # Set a default number of minutes if the number supplied is invalid
  $expiry_threshold_minutes = 30 if !defined( $expiry_threshold_minutes ) or !$expiry_threshold_minutes or $expiry_threshold_minutes!~ /^\d+$/ or $expiry_threshold_minutes < 1;
  
  my $time_limit_threshold = DateTime->now(time_zone => "UTC")->subtract(minutes => $expiry_threshold_minutes);
  
  $self->search({}, {
    where => {
      last_invalid_login => {
        "<=" => $time_limit_threshold->ymd . " " . $time_limit_threshold->hms,
      },
    },
  })->update({
    invalid_logins      => 0,
    last_invalid_login  => undef,
  });
}

=head2 delete_expired_keys

Get all of the activation keys and password reset keys that have expired and undef them.

=cut

sub delete_expired_keys {
  my ( $self ) = @_;
  my $now = DateTime->now( time_zone => "UTC" );
  
  # Password reset keys
  $self->search({}, {
    where => {
      password_reset_expires => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }
    }
  })->update({
    password_reset_key      => undef,
    password_reset_expires  => undef,
  });
  
  # Activation keys - user actually gets deleted if not activated in time.
  $self->search({}, {
    where => {
      activated => 0,
      activation_expires => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }
    }
  })->update({
    activation_key      => undef,
    activation_expires  => undef,
  });
}

=head2 create_or_edit

Error checks requested registration details and creates the user with an activation key that's emailed back to the user.

=cut

sub create_or_edit {
  my ( $self, $parameters ) = @_;
  my $action                = $parameters->{action};
  my $user                  = $parameters->{user};
  my $id                    = $parameters->{id};
  my $username              = $parameters->{username};
  my $username_editable     = $parameters->{username_editable};
  my $email_address         = $parameters->{email_address};
  my $confirm_email_address = $parameters->{confirm_email_address};
  my $password              = $parameters->{password};
  my $confirm_password      = $parameters->{confirm_password};
  my $current_password      = $parameters->{current_password};
  my $language              = $parameters->{language};
  my $facebook              = $parameters->{facebook};
  my $twitter               = $parameters->{twitter};
  my $aim                   = $parameters->{aim};
  my $jabber                = $parameters->{jabber};
  my $website               = $parameters->{website};
  my $interests             = $parameters->{interests};
  my $occupation            = $parameters->{occupation};
  my $location              = $parameters->{location};
  my $timezone              = $parameters->{timezone};
  my $html_emails           = $parameters->{html_emails};
  my $hide_online           = $parameters->{hide_online};
  my $ip_address            = $parameters->{ip_address};
  my $editing_user          = $parameters->{editing_user};
  my $role                  = $parameters->{role};
  my $installed_languages   = $parameters->{installed_languages};
  my $set_locale;
  my $return_value          = {error => []};
  
  # Check the username is valid
  if ( $action ne "register" and $action ne "edit" ) {
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ( $action eq "edit" ) {
    # Check the user passed is valid
    unless ( defined( $user ) and ref( $user ) eq "TopTable::Model::DB::User" ) {
      push(@{ $return_value->{error} }, {id => "user.form.error.user-invalid"});
      
      # Another fatal error
      return $return_value;
    }
  }
  
  # If the following fields are changed, we will need to check the 
  my ( $username_changed, $email_changed, $password_changed );
  
  if ( $action eq "edit" ) {
    $username_changed = ( $username ne $user->username and $username_editable ) ? 1 : 0;
    $email_changed    = $email_address eq $user->email_address ? 0 : 1;
    $password_changed = $password eq "" ? 0 : 1; # We don't check this against the current password at the moment, if there is a password entered, assume it's changing
  }
  
  # Check the username if we're creating a new user OR we are allowing this username to be edited and we've detected a change
  if ( $action eq "register" or ( $username_editable and $username_changed ) ) {
    if ( $username ) {
      if ( $username =~ m/[a-z0-9-_ ]/i ) {
        # If the username is valid, check it isn't already registered
        my $check_username;
        
        if ( $action eq "register" ) {
          $check_username = $self->find({username => $username});
        } else {
          $check_username = $self->find({}, {
            where       => {
              username  => $username,
              id        => {
                "!=" => $user->id
              },
            },
          });
        }
        push(@{ $return_value->{error} }, {id => "user.form.error.username-registered"}) if defined( $check_username );
      } else {
        # Invalid username
        push(@{ $return_value->{error} }, {id => "user.form.error.username-invalid"});
      }
    } else {
      # Blank username
      push(@{ $return_value->{error} }, {id => "user.form.error.username-blank"});
    }
  }
  
  # Check the email addresses match
  if ( $action eq "register" or $email_changed ) {
    if ( $email_address ) {
      if ( $email_address eq $confirm_email_address ) {
        # If they match, check the email address is valid
        if ( $email_address =~ m/^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i ) {
          # Email is valid, check it isn't already registered
          my $check_email;
          
          if ( $action eq "register" ) {
            $check_email = $self->find({email_address => $email_address});
          } else {
            $check_email = $self->find({}, {
              where       => {
                username  => $username,
                id        => {
                  "!=" => $user->id
                },
              },
            });
          }
          
          push(@{ $return_value->{error} }, {id => "user.form.error.email-registered"}) if defined( $check_email );
        } else {
          # Invalid email address.
          push(@{ $return_value->{error} }, {id => "user.form.error.email-invalid"});
        }
      } else {
        # Non-matching email addresses
        push(@{ $return_value->{error} }, {id => "user.form.error.email-confirm-mismatch"});
      }
    } else {
      # Email address not entered
      push(@{ $return_value->{error} }, {id => "user.form.error.email-blank"});
    }
  }
  
  # Check the password was provided
  if ( $action eq "register" or $password_changed ) {
    if ( $password ) {
      # Check the passwords match
      if ( $password ne $confirm_password ) {
        # Non-matching passwords
        push(@{ $return_value->{error} }, {id => "user.form.error.password-confirm-mismatch"});
      } else {
        # Check password strength
        if ( length( $password ) < 8 ) {
          # Password too short
          push(@{ $return_value->{error} }, {
            id          => "user.form.error.password-too-short",
            parameters  => [8],
          });
        } else {
          # Check password complexity
          push(@{ $return_value->{error} }, {id => "user.form.error.password-complexity"}) unless $password =~ /[A-Z]/ and $password =~ /[a-z]/ and $password =~ /\d/;
        }
      }
    } else {
      # Password is blank
      push(@{ $return_value->{error} }, {id => "user.form.error.password-blank"});
    }
  }
  
  if ( ( $username_changed or $email_changed or $password_changed ) and defined( $editing_user ) ) {
    # The username, email or password has changed, so we need to authenticate the current password
    if ( $current_password ) {
      # Check the current password entered is correct
      push(@{ $return_value->{error} }, {id => "user.form.error.curent-password-incorrect"}) unless $editing_user->check_password( $current_password );
    } else {
      # Current password field is blank
      push(@{ $return_value->{error} }, {id => "user.form.error.curent-password-blank"});
    }
  }
  
  if ( $language ) {
    # Language selected, check it's installed
    push(@{ $return_value->{error} }, {id => "user.form.error.language-invalid"}) unless exists( $installed_languages->{$language} );
  } else {
    # Error, language is not selected
    push(@{ $return_value->{error} }, {id => "user.form.error.language-blank"});
  }
  
  if ( $timezone ) {
    push(@{ $return_value->{error} }, {id => "user.form.error.timezone-invalid"}) unless DateTime::TimeZone->is_valid_name( $timezone );
  } else {
    push(@{ $return_value->{error} }, {id => "user.form.error.timezone-blank"});
  }
  
  # Boolean sanity check - true = 1, false = 0
  $html_emails = ( $html_emails ) ? 1 : 0;
  
  if ( scalar( @{ $return_value->{error} } == 0 ) ) {
    # This is a random verification key that we can then put into an email.
    my $activation_key = sha256_hex( $username . Time::HiRes::time . int(rand(100)) ) if $action eq "register";
    
    # Build the key from the username
    my $url_key;
    if ( $action eq "edit" and $username_changed and $username_editable ) {
      $url_key = $self->generate_url_key( $username, $user->id );
    } elsif ( $action eq "register" ) {
      $url_key = $self->generate_url_key( $username );
    }
    
    if ( $action eq "register" ) {
      # Create new user
      $user = $self->create({
        username        => $username,
        url_key         => $url_key,
        email_address   => $email_address,
        password        => $password,
        registered_ip   => $ip_address,
        last_active_ip  => $ip_address,
        locale          => $language,
        timezone        => $timezone,
        html_emails     => $html_emails,
        activation_key  => $activation_key,
        activated       => 0,
        user_roles      => [{
          role          => $role->id, # Registered Users role
        }],
      });
      
      # We will NEVER set locale if the user is being created, as that user needs to be activated first
      $set_locale = 0;
    } else {
      # Edit
      # Set hide online to 1 or 0 (sanity check)
      $hide_online = $hide_online ? 1 : 0;
      
      # Check if we need to set the locale - true if the language has changed and we're editing the logged in user
      $set_locale = ( $language ne $user->locale and defined( $editing_user ) and $user->id == $editing_user->id ) ? 1 : 0;
      
      my $update_data = {
        email_address   => $email_address,
        last_active_ip  => $ip_address,
        locale          => $language,
        timezone        => $timezone,
        html_emails     => $html_emails,
        facebook        => $facebook,
        twitter         => $twitter,
        aim             => $aim,
        jabber          => $jabber,
        website         => $website,
        interests       => $interests,
        occupation      => $occupation,
        location        => $location,
        hide_online     => $hide_online,
      };
      
      # Add the new username and URL key to the updated data if it's editable and been changed
      if ( $username_editable and $username_changed ) {
        $update_data->{username}  = $username;
        $update_data->{url_key}   = $url_key;
      }
      
      # Add the new password to the updated data if it's been updated
      $update_data->{password} = $password if $password_changed;
      
      $user->update( $update_data );
    }
    
    $return_value->{set_locale} = $set_locale;
    $return_value->{user}       = $user;
  }
  
  return $return_value;
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key ) = @_;
  
  return $self->find({
    url_key => $url_key,
  });
}

=head2 generate_url_key

Generate a unique key from the given club short name.

=cut

sub generate_url_key {
  my ( $self, $short_name, $exclude_id ) = @_;
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
    my $key_check = $self->find_url_key( $url_key );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

1;