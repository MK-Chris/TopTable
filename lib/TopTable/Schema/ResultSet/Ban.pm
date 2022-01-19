package TopTable::Schema::ResultSet::Ban;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use Try::Tiny;
use Data::Dumper::Concise;

=head2 get_by_id_and_type

Get a specific ban by ID and type.

=cut

sub get_by_id_and_type {
  my ( $self, $params ) = @_;
  my $type = delete $params->{type};
  my $id = delete $params->{id};
  
  if ( $type->id eq "username" ) {
    # Return from BannedUser instead
    $self->result_source->schema->resultset("BannedUser")->find({id => $id}, {
      prefetch => [ qw( banned_by banned ) ],
    });
  } else {
    # Search for this type in the main bans table
    return $self->search({
      "me.type" => $type->id,
      "me.id" => $id,
    }, {
      prefetch => [ qw( banned_by type ) ],
      rows => 1,
    })->single;
  }
}

=head2 get_bans

Return either all bans, or all bans with a specific type.

=cut

sub get_bans {
  my ( $self, $params ) = @_;
  my $type = $params->{type};
  
  if ( $type->id eq "username" ) {
    # Return from BannedUser instead
    $self->result_source->schema->resultset("BannedUser")->search(undef, {
      prefetch => [ qw( banned_by banned ) ],
    });
  } else {
    # Search for this type
    return $self->search({type => $type->id}, {
      prefetch => [ qw( banned_by type ) ],
    });
  }
}

=head2 create_or_edit

Create or edit a ban, with error checking beforehand.

=cut

sub create_or_edit {
  my ( $self, $params ) = @_;
  my $action = delete $params->{action};
  my $ban = delete $params->{ban} || undef;
  my $ban_id = delete $params->{ban_id} || undef;
  my $ban_type = delete $params->{ban_type} || undef;
  my $ban_type_id = delete $params->{ban_type_id} || undef;
  my $banned_id = delete $params->{banned_id} || undef;
  my $expires_date = delete $params->{expires_date} || undef;
  my $expires_hour = delete $params->{expires_hour} || undef;
  my $expires_minute = delete $params->{expires_minute} || undef;
  my $expires_timezone = delete $params->{expires_timezone} || undef;
  my $ban_access = delete $params->{ban_access} || 0;
  my $ban_registration = delete $params->{ban_registration} || 0;
  my $ban_login = delete $params->{ban_login} || 0;
  my $ban_contact = delete $params->{ban_contact} || 0;
  my $banning_user = delete $params->{banning_user} || undef;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $response = {error => [], warning => []}; # Initial response
  my $banned_id_valid;
  
  # Check the passed in user
  push( @{$response->{error}}, {id => "admin.performing-user-invalid"}) unless ref( $banning_user ) eq "Catalyst::Authentication::Store::DBIx::Class::User";
  
  if ( $action ne "create" and $action ne "edit" ) {
    push(@{ $response->{error} }, {
      id => "admin.form.invalid-action",
      parameters => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    my $valid_ban = 0;
    
    # Check the ban passed is valid
    if ( defined( $ban ) and ( ref( $ban ) eq "TopTable::Model::DB::Ban" ) or ref( $ban ) eq "TopTable::Model::DB::BannedUser" ) {
      # Valid ban
      $valid_ban = 1;
      $logger->( "debug", sprintf( "valid ban passed as object: %s", ref( $ban ) ) );
    } elsif ( defined( $ban_id ) ) {
      # Ban ID passed, check it's valid
      $ban = $ban_type->id eq "username" ? $self->result_source->schema->resultset("BannedUser")->find( $ban_id ) : $self->find( $ban_id );
      $valid_ban = 1 if defined( $ban );
      
      if ( defined( $ban ) ) {
        $logger->( "debug", sprintf( "valid %s ban passed as id: %s", $ban_type->id, $ban_id ) );
      } else {
        $logger->( "debug", sprintf( "invalid %s ban passed as id: %s", $ban_type->id, $ban_id ) );
      }
    }
    
    unless( $valid_ban ) {
      push(@{ $response->{error} }, {id => "admin.bans.form.error.ban-invalid"});
      
      # Another fatal error
      return $response;
    }
  }
  
  # Check we have a valid ban type
  if ( defined( $ban_type ) and ref( $ban_type ) eq "TopTable::Model::DB::LookupBanType" ) {
    # Just use the ID if it's passed, it tells us all we need to know
    $ban_type = $ban_type->id;
  } elsif ( defined( $ban_type_id ) ) {
    # Lookup the ban type ID and make sure it's valid
    $ban_type = $self->result_source->schema->resultset("LookupBanType")->find( $ban_type_id );
  }
  
  push( @{$response->{error}}, {id => "admin.bans.form.error.no-ban-type-given"} ) unless defined( $ban_type );
  
  # If there's no ban type or no authenticated user, it's fatal and we can't continue
  return $response if scalar( @{$response->{error}} );
  
  # Now check the other data.  banned_id is the actual value of what we want to ban,
  # so how we check depends on the ban type
  if ( $ban_type eq "ip" ) {
    # IP address, check validity against a regex
    $banned_id_valid = $banned_id =~ /^((25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])$/ ? 1 : 0;
  } elsif ( $ban_type eq "email" ) {
    $banned_id_valid = $banned_id =~ /^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i ? 1 : 0;
    
    # Can't have a total access ban with email-address, so set that to 0 regardless
    $ban_access = 0;
  } elsif ( $ban_type eq "username" ) {
    if ( $banned_id =~ /^\d+$/ ) {
      # Number passed in, check it's a valid user ID
      $banned_id = $self->result_source->schema->resultset("User")->find( $banned_id );
      
      if ( defined( $banned_id ) ) {
        # Because the banned id is now an object, we need to set it back to the ID if it's been validated successfully.
        $response->{banned_user} = $banned_id;
        $banned_id = $banned_id->id;
        $banned_id_valid = 1;
      } else {
        $banned_id_valid = 0;
      }
    } elsif ( ref( $banned_id ) eq "TopTable::Model::DB::User" ) {
      # User object passed in
      $banned_id_valid = 1;
    } else {
      # Something else, invalid
      $banned_id_valid = 0;
    }
    
    # Can't have a total access OR a registration ban with ip-address, so set those to 0 regardless
    $ban_access = 0;
    $ban_registration = 0;
  }
  
  # Now we've done the checks for a valid name, raise an error if the valid flag isn't set
  push( @{$response->{error}}, {id => "admin.bans.form.error.invalid-$ban_type"} ) unless $banned_id_valid;
  
  if ( defined( $expires_date ) ) {
    # Check the expiry date - split into parts and then try creating a new DatTime out of them
    my ($expires_day, $expires_month, $expires_year) = split("/", $expires_date);
    my $date_valid = 0;
    my $time_valid = 1; # Default to true, set to false if either hour or minute are invalid
    
    # Set the timezone to default if it's invalid
    $expires_timezone = "Europe/London" unless defined( $expires_timezone ) and DateTime::TimeZone->is_valid_name( $expires_timezone );
    
    try {
      $expires_date = DateTime->new(
        year => $expires_year,
        month => $expires_month,
        day => $expires_day,
        time_zone => $expires_timezone,
      );
    } catch {
      push(@{ $response->{error} }, {id => "admin.bans.form.error.expiry-date-invalid"});
      undef( $expires_date );
    } finally {
      $date_valid = 1 if defined( $expires_date );
    };
    
    # If neither hour or minute are defined, we won't try and set a time, or return an error, assume we want to expire at midnight
    if ( ( defined( $expires_hour ) and $expires_hour ) or ( defined( $expires_minute ) and $expires_minute ) ) {
      if ( !defined( $expires_hour ) or $expires_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
        # Error, invalid hour passed
        push(@{ $response->{error} }, {id => "admin.bans.form.error.expires-hour-invalid"});
        $time_valid = 0;
      }
      
      if ( !defined( $expires_minute ) or $expires_minute !~ m/^(?:[0-5][0-9])$/ ) {
        # Error, invalid minute passed
        push(@{ $response->{error} }, {id => "admin.bans.form.error.expires-minute-invalid"});
        $time_valid = 0;
      }
      
      $expires_date->set( hour => $expires_hour, minute => $expires_minute ) if $time_valid;
    }
    
    push(@{ $response->{error} }, {id => "admin.bans.form.error.expires-date-in-past"}) if $date_valid and $expires_date->subtract_datetime( DateTime->now( time_zone => $expires_timezone ) )->is_negative;
  } else {
    # Check we don't have a time without a date
    push(@{ $response->{error} }, {id => "admin.bans.form.error.expires-time-passed-without-date"}) if defined( $expires_hour ) or defined( $expires_minute ); 
  }
  
  # Sanitise the ban levels to 1 (1 if defined and returning a true value, or 0 for anything else).  Ban levels that are invalid for the current ban type have already been set to 0 by now, so no need to do that here
  if ( defined( $ban_access ) and $ban_access ) {
    $ban_access = 1;
  } else {
    $ban_access = 0;
  }
  
  if ( defined( $ban_registration ) and $ban_registration ) {
    $ban_registration = 1;
  } else {
    $ban_registration = 0;
  }
  
  if ( defined( $ban_login ) and $ban_login ) {
    $ban_login = 1;
  } else {
    $ban_login = 0;
  }
  
  if ( defined( $ban_contact ) and $ban_contact ) {
    $ban_contact = 1;
  } else {
    $ban_contact = 0;
  }
  
  # Make sure we have at least one ban level
  push(@{ $response->{error} }, {id => "admin.bans.form.error.no-levels-selected"}) unless $ban_access or $ban_registration or $ban_login or $ban_contact;
  
  # Error checking done, create the ban if we don't have any errors
  if ( scalar( @{$response->{error}} ) == 0 ) {
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
      
      if ( $ban_type eq "username" ) {
        # No type needed, create the ban in the banned users table
        $ban = $self->result_source->schema->resultset("BannedUser")->create( $ban_data );
      } else {
        # Add the type and create the data in the main table
        $ban_data->{type} = $ban_type;
        $ban = $self->create( $ban_data );
      }
      
      $response->{ban} = $ban;
    } else {
      $ban->update({
        banned_id => $banned_id,
        expires => $expires_date,
        ban_access => $ban_access,
        ban_registration => $ban_registration,
        ban_login => $ban_login,
        ban_contact => $ban_contact,
      });
    }
  }
  
  return $response;
}

=head2 delete_expired_bans

Get all of the expired bans and delete them.

=cut

sub delete_expired_bans {
  my ( $self ) = @_;
  my $now = DateTime->now( time_zone => "UTC" );
  
  # Password reset keys
  $self->search({}, {
    where => {
      expires => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }
    }
  })->delete;
  
  # Also do the same for banned users
  $self->result_source->schema->resultset("BannedUser")->search({}, {
    where => {
      expires => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }
    }
  })->delete;
}

=head2 is_banned

Determine if the given IP address, email address or user is banned for the given level (access, registration, login or contact).  If all three (IP, email and username) are given, check all three.  Return a simple true or false. 

=cut

sub is_banned {
  my ( $self, $params ) = @_;
  my $ip_address = delete $params->{ip_address} || undef;
  my $email_address = delete $params->{email_address} || undef;
  my $user = delete $params->{user} || undef;
  my $user_id = delete $params->{user_id} || undef;
  my $level = delete $params->{level};
  my $log_allowed = delete $params->{log_allowed} || 0;
  my $log_banned = delete $params->{log_banned} || 0;
  my $is_banned = 0; # Default to not banned
  my $now = DateTime->now( time_zone => "UTC" ); # Check we're not returning expired bans
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $lang = delete $params->{language} || sub { return wantarray ? @_ : "@_"; }; # Default to a sub that just returns everything, as we don't want errors if we haven't passed in a language sub.
  
  # Pass the level back in the response
  my $response = {level => $level};
  
  unless ( $level eq "access" or $level eq "registration" or $level eq "login" or $level eq "contact" ) {
    $response->{banned} = 0;
    $response->{log}{error} = "Can't check for ban, invalid level: $level";
    return $response;
  }
  
  my ( @log_error, @log_warning, @log_info );
  
  if ( defined( $ip_address ) ) {
    my $ip_banned = $self->search({
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
      push(@log_info, $lang->( "admin.bans.lookup.banned", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.ip" ), $ip_address )) if $log_banned;
    } else {
      # Allowed by IP
      push(@log_info, $lang->( "admin.bans.lookup.allowed", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.ip" ), $ip_address )) if $log_allowed;
    }
  }
  
  if ( defined( $email_address ) ) {
    my $email_banned = $self->search({
      type => "email",
      banned_id => $email_address,
      "ban_$level" => 1,
      expires => [ -or => {
        "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
      }, {
        "=" => undef,
      }]
    })->count;
    
    if ( $email_banned ) {
      # Banned by email
      $is_banned = 1;
      push(@log_info, $lang->( "admin.bans.lookup.banned", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.email" ), $email_address )) if $log_banned;
    } else {
      # Allowed by email
      push(@log_info, $lang->( "admin.bans.lookup.allowed", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.email" ), $email_address )) if $log_allowed;
    }
  }
  
  if ( defined( $user ) or defined( $user_id ) ) {
    if ( defined( $user ) and ref( $user ) eq "TopTable::Model::DB::User" or ref( $user ) eq "Catalyst::Authentication::Store::DBIx::Class::User" ) {
      # Use the user object that's been passed in - user is already set, so do nothing here, this just ensures that if both are passed, $user_id is lower
      # than $user in the precedence (which prevents an unncessary lookup).
    } elsif ( defined( $user_id ) ) {
      # Lookup from the ID
      $user = $self->result_source->schema->resultset("User")->find( $user_id );
    }
    
    if ( defined( $user ) ) {
      my $user_banned = $self->result_source->schema->resultset("BannedUser")->search({
        banned_id => $user->id,
        "ban_$level" => 1,
        expires => [ -or => {
          "<=" => sprintf( "%s %s", $now->ymd, $now->hms ),
        }, {
          "=" => undef,
        }]
      })->count;
      
      if ( $user_banned ) {
        # Banned by IP
        $is_banned = 1;
        push(@log_info, $lang->( "admin.bans.lookup.banned", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.username" ), $user->username )) if $log_banned;
      } else {
        # Allowed by IP
        push(@log_info, $lang->( "admin.bans.lookup.allowed", $lang->( "admin.bans.lookup.level.$level" ), $lang->( "admin.bans.lookup.type.username" ), $user->username )) if $log_allowed;
      }
    } else {
      # Invalid user passed
      push(@log_warning, $lang->( "admin.bans.lookup-allowed.username", $user->username )) if $log_allowed;
    }
  }
  
  $response->{log} = {error => \@log_error, warning => \@log_warning, info => \@log_info};
  $response->{is_banned} = $is_banned;
  return $response;
}

1;
