package TopTable::Schema::ResultSet::Tournament;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use POSIX;
use Math::Complex;

=head2 calculate_ko_rounds

Takes a number of participants and calculates the number of knock-out rounds that will be needed to whittle it down to a two-participant final.  Also returns the number of byes in the first round required, if we can't have matches for everyone.

Returned as a hash (or hashref in scalar context): %response = (rounds => x, byes => y).

=cut

sub calculate_ko_rounds {
  my $class = shift;
  my ( $players ) = @_; # Could also be teams / pairs - we don't care, but easier to just say $players
  
  # Rounds is base 2 logarithm of the number of players, rounded up (ceil).
  my $rounds = ceil(logn($players, 2));
  
  # Byes is 2 to the power of the number of rounds, minus the number of players
  my $byes = (2 ** $rounds) - $players;
  
  # Return our values
  my %response = (rounds => $rounds, byes => $byes);
  return wantarray ? %response : \%response;
}

1;