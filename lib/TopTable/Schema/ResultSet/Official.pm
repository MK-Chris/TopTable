package TopTable::Schema::ResultSet::Official;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_officials_in_season

Returns all the officials for a given season.

=cut

sub all_officials_in_season {
  my ( $self, $season ) = @_;
  
  return $self->search({
    season    => $season->id,
  }, {
    prefetch  => "position_holder",
    order_by  => {
      -asc    => [ qw( position_order ) ],
    }
  });
}

1;