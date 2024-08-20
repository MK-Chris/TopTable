package TopTable::Schema::ResultSet::LookupGridTeamType;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 all_types

A predefined search for all days of the week returned in day order.

=cut

sub all_types {
  my ( $self ) = @_;
  
  return $self->search(undef, {
    order_by => {-asc => [qw( display_order )]},
  });
}

1;