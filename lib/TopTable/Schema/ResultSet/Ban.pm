package TopTable::Schema::ResultSet::Ban;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;
use Try::Tiny;
use HTML::Entities;

=head2 get_by_id_and_type

Get a specific ban by ID and type.

=cut

sub get_by_id_and_type {
  my $class = shift;
  my ( $params ) = @_;
  my $type = $params->{type};
  my $id = $params->{id};
  
  if ( $type->id eq "username" ) {
    # Return from BannedUser instead
    $class->result_source->schema->resultset("BannedUser")->find({id => $id}, {
      prefetch => [qw( banned_by banned )],
    });
  } else {
    # Search for this type in the main bans table
    return $class->search({
      "me.type" => $type->id,
      "me.id" => $id,
    }, {
      prefetch => [qw( banned_by type )],
      rows => 1,
    })->single;
  }
}

=head2 get_bans

Return either all bans, or all bans with a specific type.

=cut

sub get_bans {
  my $class = shift;
  my ( $params ) = @_;
  my $type = $params->{type};
  
  if ( $type->id eq "username" ) {
    # Return from BannedUser instead
    $class->result_source->schema->resultset("BannedUser")->search(undef, {
      prefetch => [qw( banned_by banned )],
    });
  } else {
    # Search for this type
    return $class->search({type => $type->id}, {
      prefetch => [qw( banned_by type )],
    });
  }
}

=head2 create_or_edit

Create or edit a ban, with error checking beforehand.

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
  my $ban = $params->{ban} || undef;
  my $ban_type = $params->{ban_type} || undef;
  my $banned_id = $params->{banned_id} || undef;
  my $expires_date = $params->{expires_date} || undef;
  my $expires_hour = $params->{expires_hour} || undef;
  my $expires_minute = $params->{expires_minute} || undef;
  my $expires_timezone = $params->{expires_timezone} || undef;
  my $ban_access = $params->{ban_access} || 0;
  my $ban_registration = $params->{ban_registration} || 0;
  my $ban_login = $params->{ban_login} || 0;
  my $ban_contact = $params->{ban_contact} || 0;
  my $banning_user = $params->{banning_user};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      banned_id => $banned_id,
      expires_date => $expires_date,
      expires_hour => $expires_hour,
      expires_minute => $expires_minute,
    },
    completed => 0,
  };
  
  # Check the passed in user
  $logger->("debug", sprintf("user ref:%s", ref($banning_user)));
  push(@{$response->{errors}}, $lang->maketext("admin.performing-user-invalid")) unless defined($banning_user) and ref($banning_user) eq "Catalyst::Authentication::Store::DBIx::Class::User";
  
  # Check we have a valid ban type
  if ( defined($ban_type) ) {
    # Just use the ID if it's passed, it tells us all we need to know
    if ( ref($ban_type) ne "TopTable::Model::DB::LookupBanType" ) {
      # Not passed in as an object, check if it's an ID
      $ban_type = $schema->resultset("LookupBanType")->find($ban_type);
      
      unless ( defined($ban_type) ) {
        # Invalid ban type passed
        push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.ban-type-invalid"));
        return $response;
      }
    }
  } else {
    # No ban type specified
    push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.ban-type-blank"));
    return $response;
  }
  
  if ( $action ne "create" and $action ne "edit" ) {
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    # Check the ban passed is valid
    if ( defined($ban) ) {
      if ( ref($ban) ne "TopTable::Model::DB::Ban" and ref($ban) ne "TopTable::Model::DB::BannedUser" ) {
        # Not passed as an object, see if it's a valid ID
        $ban = $ban_type->id eq "username" ? $schema->resultset("BannedUser")->find($ban) : $class->find($ban);
        
        unless ( defined($ban) ) {
          push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.ban-invalid"));
          return $response;
        }
      }
    } else {
      # No ban specified
      push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.ban-blank"));
    }
  }
  
  # Now check the other data.  banned_id is the actual value of what we want to ban,
  # so how we check depends on the ban type
  if ( defined($banned_id) ) {
    my $banned_id_valid;
    if ( $ban_type->id eq "ip" ) {
      # IP address, check validity against a regex
      $banned_id_valid = $banned_id =~ /^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$/ ? 1 : 0;
    } elsif ( $ban_type->id eq "email" ) {
      $banned_id_valid = $banned_id =~ /^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i ? 1 : 0;
      
      # Can't have a total access ban with email-address, so set that to 0 regardless
      $ban_access = 0;
    } elsif ( $ban_type->id eq "username" ) {
      if ( ref($banned_id) ne "TopTable::Model::DB::User" ) {
        # Not passed in as a user, check if it's a URL key or ID
        $banned_id = $schema->resultset("User")->find_id_or_url_key($banned_id);
      }
      
      if ( defined($banned_id) ) {
        # Because the banned id is now an object, we need to set it back to the ID if it's been validated successfully.
        $response->{banned_user} = $banned_id;
        $banned_id = $banned_id->id;
        $banned_id_valid = 1;
      } else {
        $banned_id_valid = 0;
      }
      
      # Can't have a total access OR a registration ban with ip-address, so set those to 0 regardless
      $ban_access = 0;
      $ban_registration = 0;
    }
    
    # Now we've done the checks for a valid name, raise an error if the valid flag isn't set
    push(@{$response->{errors}}, $lang->maketext(sprintf("admin.bans.form.error.invalid-%s", $ban_type->id))) unless $banned_id_valid;
  } else {
    # Blank banned ID
    push(@{$response->{errors}}, $lang->maketext(sprintf("admin.bans.form.error.blank-%s", $ban_type->id)));
  }
  
  if ( defined($expires_date) ) {
    my $date_valid = 0;
    
    if ( ref($expires_date) eq "DateTime" ) {
      # Passed in as a DateTime, that's fine
      $date_valid = 1;
    } else {
      # Not a DateTime, try and parse the date
      my ( $day, $month, $year );
      
      if ( ref($expires_date) eq "HASH" ) {
        # Assign to the hash keys
        ( $day, $month, $year ) = ( $expires_date->{day}, $expires_date->{month}, $expires_date->{year} )
      } else {
        # Split and assign
        ( $day, $month, $year ) = split("/", $expires_date);
      }
      
      # Make sure the date is valid
      try {
        # Set the timezone to default if it's invalid
        $expires_timezone = "Europe/London" unless defined($expires_timezone) and DateTime::TimeZone->is_valid_name($expires_timezone);
        $expires_date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
          time_zone => $expires_timezone,
        );
      } catch {
        push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.expiry-date-invalid"));
        undef($expires_date);
      } finally {
        $date_valid = 1 if defined($expires_date);
      };
    }
    
    my $time_valid = 1; # Default to true, set to false if either hour or minute are invalid
    
    # If neither hour or minute are defined, we won't try and set a time, or return an error, assume we want to expire at midnight
    if ( defined($expires_hour) or defined($expires_minute) ) {
      if ( !defined( $expires_hour ) or $expires_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
        # Error, invalid hour passed
        push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.expires-hour-invalid"));
        $time_valid = 0;
      }
      
      if ( !defined($expires_minute) or $expires_minute !~ m/^(?:[0-5][0-9])$/ ) {
        # Error, invalid minute passed
        push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.expires-minute-invalid"));
        $time_valid = 0;
      }
      
      $expires_date->set(hour => $expires_hour, minute => $expires_minute) if $time_valid;
    }
    
    push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.expires-date-in-past")) if $date_valid and $expires_date->subtract_datetime(DateTime->now(time_zone => $expires_timezone))->is_negative;
  } else {
    # Check we don't have a time without a date
    push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.expires-time-passed-without-date")) if defined($expires_hour) or defined($expires_minute); 
  }
  
  # Sanitise the ban levels to 1 (1 if defined and returning a true value, or 0 for anything else).  Ban levels that are invalid for the current ban type have already been set to 0 by now, so no need to do that here
  $ban_access = $ban_access ? 1 : 0;
  $ban_registration = $ban_registration ? 1 : 0;
  $ban_login = $ban_login ? 1 : 0;
  $ban_contact = $ban_contact ? 1 : 0;
  $response->{fields}{ban_access} = $ban_access;
  $response->{fields}{ban_registration} = $ban_registration;
  $response->{fields}{ban_login} = $ban_login;
  $response->{fields}{ban_contact} = $ban_contact;
  
  # Make sure we have at least one ban level
  push(@{$response->{errors}}, $lang->maketext("admin.bans.form.error.no-levels-selected")) unless $ban_access or $ban_registration or $ban_login or $ban_contact;
  
  # Error checking done, create the ban if we don't have any errors
  if ( scalar(@{$response->{errors}}) == 0 ) {
    if ( $action eq "create" ) {
      # Setup the inital ban data
      my $ban_data = {
        banned_id => $banned_id,
        expires => $expires_date,
        banned_by => $banning_user->id,
        banned_by_name => $banning_user->username,
        ban_access => $ban_access,
        ban_registration => $ban_registration,
        ban_login => $ban_login,
        ban_contact => $ban_contact,
      };
      
      if ( $ban_type->id eq "username" ) {
        # No type needed, create the ban in the banned users table
        $ban = $class->result_source->schema->resultset("BannedUser")->create($ban_data);
      } else {
        # Add the type and create the data in the main table
        $ban_data->{type} = $ban_type->id;
        $ban = $class->create($ban_data);
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.bans.form.success", encode_entities($ban->banned_id), $lang->maketext("admin.message.created")));
    } else {
      $ban->update({
        banned_id => $banned_id,
        expires => $expires_date,
        ban_access => $ban_access,
        ban_registration => $ban_registration,
        ban_login => $ban_login,
        ban_contact => $ban_contact,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.bans.form.success", encode_entities($ban->banned_id), $lang->maketext("admin.message.edited")));
    }
    
    $response->{ban} = $ban;
  }
  
  return $response;
}

=head2 delete_expired_bans

Get all of the expired bans and them.

=cut

sub delete_expired_bans {
  my $class = shift;
  my $now = DateTime->now(time_zone => "UTC");
  
  # Password reset keys
  $class->search({}, {
    where => {
      expires => {"<=" => sprintf("%s %s", $now->ymd, $now->hms)}
    }
  })->delete;
  
  # Also do the same for banned users
  $class->result_source->schema->resultset("BannedUser")->search({}, {
    where => {
      expires => {"<=" => sprintf("%s %s", $now->ymd, $now->hms)}
    }
  })->delete;
}

=head2 is_banned

Determine if the given IP address, email address or user is banned for the given level (access, registration, login or contact).  If all three (IP, email and username) are given, check all three.  Return a simple true or false. 

=cut

sub is_banned {
  my $class = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $ip_address = $params->{ip_address} || undef;
  my $email_address = $params->{email_address} || undef;
  my $user = $params->{user} || undef;
  my $user_id = $params->{user_id} || undef;
  my $level = $params->{level};
  my $log_allowed = $params->{log_allowed} || 0;
  my $log_banned = $params->{log_banned} || 0;
  my $is_banned = 0; # Default to not banned
  my $now = DateTime->now( time_zone => "UTC" ); # Check we're not returning expired bans
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {level => $level},
    is_banned => $is_banned,
  };
  
  if ( defined($level) and $level ) {
    # We have a level, check it's valid
    if ( $level ne "access" and $level ne "registration" and $level ne "login" and $level ne "contact" ) {
      $response->{is_banned} = $is_banned;
      push(@{$response->{errors}}, $lang->maketext("admin.bans.lookup.invalid-level", $level));
      return $response;
    }
  } else {
    # Level not passed in
    $response->{is_banned} = $is_banned;
    push(@{$response->{errors}}, $lang->maketext("admin.bans.lookup.level-not-given"));
    return $response;
  }
  
  if ( defined($ip_address) ) {
    my $ip_banned = $class->search({
      type => "ip",
      banned_id => $ip_address,
      "ban_$level" => 1,
      expires => [ -or => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }, {
        "=" => undef,
      }]
    })->count;
    
    if ( $ip_banned ) {
      # Banned by IP
      $is_banned = 1;
      push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.banned", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.ip"), $ip_address)) if $log_banned;
    } else {
      # Allowed by IP
      push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.allowed", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.ip"), $ip_address)) if $log_allowed;
    }
  }
  
  if ( defined($email_address) ) {
    my $email_banned = $class->search({
      type => "email",
      banned_id => $email_address,
      "ban_$level" => 1,
      expires => [ -or => {
        "<=" => sprintf("%s %s", $now->ymd, $now->hms),
      }, {
        "=" => undef,
      }]
    })->count;
    
    if ( $email_banned ) {
      # Banned by email
      $is_banned = 1;
      push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.banned", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.email"), $email_address)) if $log_banned;
    } else {
      # Allowed by email
      push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.allowed", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.email"), $email_address)) if $log_allowed;
    }
  }
  
  if ( defined($user) or defined($user_id) ) {
    if ( defined($user) and ref($user) eq "TopTable::Model::DB::User" or ref($user) eq "Catalyst::Authentication::Store::DBIx::Class::User" ) {
      # Use the user object that's been passed in - user is already set, so do nothing here, this just ensures that if both are passed, $user_id is lower
      # than $user in the precedence (which prevents an unncessary lookup).
    } elsif ( defined($user_id) ) {
      # Lookup from the ID
      $user = $class->result_source->schema->resultset("User")->find_id_or_url_key($user_id);
    }
    
    if ( defined($user) ) {
      my $user_banned = $class->result_source->schema->resultset("BannedUser")->search({
        banned_id => $user->id,
        "ban_$level" => 1,
        expires => [ -or => {
          "<=" => sprintf("%s %s", $now->ymd, $now->hms),
        }, {
          "=" => undef,
        }]
      })->count;
      
      if ( $user_banned ) {
        # Banned by IP
        $is_banned = 1;
        push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.banned", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.username"), $user->username)) if $log_banned;
      } else {
        # Allowed by IP
        push(@{$response->{info}}, $lang->maketext("admin.bans.lookup.allowed", $lang->maketext("admin.bans.lookup.level.$level"), $lang->maketext("admin.bans.lookup.type.username"), $user->username)) if $log_allowed;
      }
    } else {
      # Invalid user passed
      push(@{$response->{warnings}}, $lang->("admin.bans.lookup-allowed.username", $user->username)) if $log_allowed;
    }
  }
  
  $response->{is_banned} = $is_banned;
  return $response;
}

1;
