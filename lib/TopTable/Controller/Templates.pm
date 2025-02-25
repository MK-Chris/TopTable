package TopTable::Controller::Templates;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Templates - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.template")});
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates"),
    label => $c->maketext("menu.text.template"),
  });
}

=cut

=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_view", "view templates", 1] );
  
  # Display the types of options
  $c->stash({
    template => "html/templates/options.ttkt",
    view_online_display => "Viewing templates",
    view_online_link => 0,
    subtitle1 => $c->maketext("menu.text.template"),
    external_scripts => [
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
