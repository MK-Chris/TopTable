package TopTable::Schema::ResultSet::LookupWeekday;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_days

A predefined search for all days of the week returned in day order.

=cut

sub all_days {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {
      -asc => "weekday_number",
    },
  });
}

1;