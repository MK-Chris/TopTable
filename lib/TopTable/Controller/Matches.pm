package TopTable::Controller::Matches;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Matches - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

Things to run automatically with any path that starts /matches. 

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/fixtures-results/root_current_season"),
    label => $c->maketext("menu.text.matches"),
  });
}

=head2 index

All the matches stuff is in the FixturesResults class, so we just need to detach off to that.

=cut

sub index :Path {
  my ( $self, $c ) = @_;
  $c->response->redirect( $c->uri_for_action("/fixtures-results/root_current_season") );
  $c->detach;
  return;
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
