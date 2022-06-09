package TopTable::Schema::ResultSet::UserAgent;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use Digest::SHA qw( sha256_hex );

=head2 update_user

Determines whether or not this user agent has been seen before and if so updates the last_seen datetime value; if not, creates it.  Then (if a user is supplied) tries to find the combination of user / IP / browser has been seen before; if not, creates a new row, if so, updates the existing one.

A hash is used for the user agent finding, as this is quicker than searching a text field in the database.

=cut

sub update_user_agents {
  my ( $self, $user_agent_string, $user, $ip_address ) = @_;
  my $user_agent_hash = sha256_hex($user_agent_string);
  my $user_agent = $self->find({sha256_hash => $user_agent_hash});
  my $now = DateTime->now(time_zone => "UTC");
  
  if ( defined($user_agent) ) {
    # User agent has been seen before, update the last seen value
    $user_agent->update({last_seen => $now->ymd . " " . $now->hms});
    
    # If we have a user, check if this user has used this user agent / IP combination before
    if ( defined($user) and ref($user) eq "Catalyst::Authentication::Store::DBIx::Class::User" ) {
      my $user_ip_browser = $user_agent->find_related("user_ip_addresses_browsers", {
        user_id => $user->id,
        ip_address => $ip_address,
        user_agent => $user_agent,
      });
      
      if ( defined($user_ip_browser) ) {
        # We've seen this IP / user agent combination before, update the last_seen
        $user_ip_browser->update({last_seen => $now->ymd . " " . $now->hms});
      } else {
        # Not seen before, create a new row
        $user_agent->create_related("user_ip_addresses_browsers", {
          user_id => $user->id,
          ip_address => $ip_address,
          user_agent => $user_agent,
        });
      }
    }
  } else {
    # This is a new user agent we've not seen before, add it to the database
    my $create_hash = {
      string => $user_agent_string,
      sha256_hash => $user_agent_hash,
    };
    
    # If we have a user defined, we'll also create a row for that
    $create_hash->{user_ip_addresses_browsers} = [{
      user_id => $user->id,
      ip_address => $ip_address,
    }] if defined($user);
    
    $user_agent = $self->create($create_hash);
  }
  
  return $user_agent;
}

1;