package TopTable::Schema::ResultSet::Session;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use DateTime;

=head2 get_online_users

A predefined search to get the weeks for a grid in week number order.

=cut

sub get_online_users {
  my $class = shift;
  my ( $params ) = @_;
  my $datetime_limit = $params->{datetime_limit} || undef;
  my $include_hidden = $params->{include_hidden} || 0;
  my $where = {};
  
  # Set the time limit if there is one
  $where->{last_active} = {">=" => sprintf("%s %s", $datetime_limit->ymd, $datetime_limit->hms)} if defined($datetime_limit);
  $where->{"me.hide_online"} = 0 unless $include_hidden;
  
  return $class->search($where, {
    prefetch  => [{
      user => "person",
    },
    qw( user_agent )],
    order_by  => {-desc => qw( last_active )},
  });
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

=head2 number_of_attempts

Return either the number of attempts for the given session ID or 0 if the row doesn't exist.

=cut

sub number_of_attempts {
  my $class = shift;
  my ( $session_id ) = @_;
  
  my $session_row = $class->find("session:$session_id");
  
  if ( defined($session_row) ) {
    return $session_row->invalid_logins;
  } else {
    return 0;
  }
}

1;