package TopTable::Schema::ResultSet::UploadedImage;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 find_non_deleted

Find a file with a given ID as long as it's not been deleted.

=cut

sub find_non_deleted {
  my $class = shift;
  my ( $id ) = @_;
  
  return $class->find({
    id => $id,
    deleted => 0,
  });
}

1;