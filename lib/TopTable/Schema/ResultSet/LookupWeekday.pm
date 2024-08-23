package TopTable::Schema::ResultSet::LookupWeekday;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 all_days

A predefined search for all days of the week returned in day order.

=cut

sub all_days {
  my $class = shift;
  
  return $class->search({}, {
    order_by => {-asc => qw( weekday_number )},
  });
}

1;