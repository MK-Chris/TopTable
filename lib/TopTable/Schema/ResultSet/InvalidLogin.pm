package TopTable::Schema::ResultSet::InvalidLogin;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;

=head2 reset_count

Resets the invalid login count for a given IP address.

=cut

sub reset_count {
  my ( $self, $ip_address ) = @_;
  
  # Try to find the row
  my $ip_row = $self->find( $ip_address );
  
  # Delete the row if it exists
  $ip_row->delete if defined( $ip_row );
}

=head2 increment_count

Increases the invalid_logins value by 1 (or creates the row and sets the value to 1).

=cut

sub increment_count {
  my ( $self, $ip_address ) = @_;
  
  my $ip_row = $self->find( $ip_address );
  
  if ( defined( $ip_row ) ) {
    # Row exists, update it
    $ip_row->update({
      invalid_logins => $ip_row->invalid_logins + 1,
    });
  } else {
    $self->create({
      ip_address      => $ip_address,
      invalid_logins  => 1,
    });
  }
}

=head reset_expired_counts

Get all of the invalid login counts that have expired and delete them.

=cut

sub reset_expired_counts {
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
  })->delete;
}

=head2 number_of_attempts

Return either the number of attempts for the given IP address or 0 if the row doesn't exist.

=cut

sub number_of_attempts {
  my ( $self, $ip_address ) = @_;
  
  my $ip_row = $self->find( $ip_address );
  
  if ( defined( $ip_row ) ) {
    return $ip_row->invalid_logins;
  } else {
    return 0;
  }
}

1;