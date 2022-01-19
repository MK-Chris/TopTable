package TopTable::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Admin - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

Automatically called whenever the path starts /admin.  Check we're authorised to do any of the admin functions, stash the admin title.

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.admin.text.title") });
  
  # Breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/admin"),
    label => $c->maketext("menu.admin.text.title"),
  });
}

=head2 index

Show the admin index - just a list of links to various admin functions.

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to use the admin section at all
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( match_update user_approve_new admin_issue_bans ) ], $c->maketext("user.auth.admin"), 1] );
  
  my $ban_types = $c->model("DB::LookupBanType")->all_types;
  
  $c->stash({
    template => "html/admin/options.ttkt",
    view_online_display => "Home",
    view_online_link => 0,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    ban_types => $ban_types,
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
