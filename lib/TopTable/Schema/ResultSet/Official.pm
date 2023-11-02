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

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      "me.id" => $id_or_url_key
    }, {
      "me.url_key" => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {"me.url_key" => $id_or_url_key};
  }
  
  return $self->search($where, {
    prefetch => [qw( official_seasons )],
    rows => 1,
  })->single;
}

1;