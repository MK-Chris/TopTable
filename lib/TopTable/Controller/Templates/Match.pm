package TopTable::Controller::Templates::Match;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Templates::Match - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.templates-match")});
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match"),
    label => $c->maketext("menu.text.templates-match-breadcrumbs"),
  });
}

=cut

=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to view
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_view", "view templates", 1] );
  
  # Retrieve all of the match templates to display
  $c->stash({
    template            => "html/templates/match/options.ttkt",
    view_online_display => "Viewing match templates",
    view_online_link    => 0,
    external_scripts    => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
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
