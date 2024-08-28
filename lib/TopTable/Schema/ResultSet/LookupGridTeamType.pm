package TopTable::Schema::ResultSet::LookupGridTeamType;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 all_types

A predefined search for all days of the week returned in day order.

=cut

sub all_types {
  my $class = shift;
  
  return $class->search({}, {
    order_by => {-asc => [qw( display_order )]},
  });
}

1;