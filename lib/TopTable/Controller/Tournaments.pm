package TopTable::Controller::Tournaments;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Tournaments - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to handle tournaments; these methods are all private and forwarded from the Events controller, since to all intents and purposes a tournament is just a type of event.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach(qw(TopTable::Controller::Root default));
}



=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
