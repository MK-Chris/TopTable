package TopTable::Schema::ResultSet::FixturesGridWeek;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 number_of_weeks

A predefined search to get the weeks for a grid in week number order.

=cut

sub number_of_weeks {
  my ( $self, $grid ) = @_;
  
  return $self->search({grid => $grid->id}, {})->count;
}

=head2 weeks_in_grid

A predefined search to return the weeks in one fixtures grid in week number order.

=cut

sub weeks_in_grid {
  my ( $self, $grid ) = @_;
  
  return $self->search({
    grid => $grid->id,
  }, {
    order_by  => {
      -asc => "week"
    }
  });
}

=head2 weeks_and_matches_in_grid

A predefined search to return the weeks and their respective matches in one fixtures grid in week number, then match number order.

=cut

sub weeks_and_matches_in_grid {
  my ( $self, $grid ) = @_;
  
  return $self->search( { grid      => $grid->id},
                        { prefetch  => "fixtures_grid_matches",
                          order_by  => {-asc => "week", "fixtures_grid_matches.match_number"}});
}

1;