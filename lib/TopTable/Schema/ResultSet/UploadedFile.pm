package TopTable::Schema::ResultSet::UploadedFile;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 find_non_deleted

Find a file with a given ID as long as it's not been deleted.

=cut

sub find_non_deleted {
  my ( $self, $id ) = @_;
  
  return $self->find({
    id      => $id,
    deleted => 0,
  });
}

1;