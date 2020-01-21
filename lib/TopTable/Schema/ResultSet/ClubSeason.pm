package TopTable::Schema::ResultSet::ClubSeason;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper;

=head2 get_all_seasons_club_entered

Gets a list of seasons that a club has entered teams in.

=cut

sub get_all_seasons_club_entered {
  my ( $self, $club ) = @_;
  
  return $self->search({
    club   => $club->id
  }, {
    prefetch => "season",
    order_by => [{
      -asc => [
        qw( season.complete )
      ]}, {
      -desc => [
        qw( season.start_date season.end_date )
      ]}
    ],
  });
}

1;