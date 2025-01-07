package TopTable::Schema::ResultSet::TournamentPerson;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 noindex_set

Check noindex flag on the related person record.

=cut

sub noindex_set {
  my $class = shift;
  my ( $on ) = @_;
  
  # Sanity check - all true values are 1, all false are 0
  $on = $on ? 1 : 0;
  
  return $class->search({"person.noindex" => $on});
}

1;