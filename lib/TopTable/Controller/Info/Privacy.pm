package TopTable::Controller::Info::Privacy;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Info::Privacy - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.privacy") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/privacy"),
    label => $c->maketext("menu.text.privacy"),
  });
}

=head2 view

View the privacy policy.

=cut

sub view :Path("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["privacy_view", $c->maketext("user.auth.view-privacy"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["privacy_edit", "", 0]);
  
  my $privacy = $c->model("DB::PageText")->get_text("privacy");
  
  # Set up the title links if we need them
  my @title_links = ();
  
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.edit.privacy"),
    link_uri => $c->uri_for_action("/info/privacy/edit"),
  }) if $c->stash->{authorisation}{privacy_edit};
  
  $c->stash({
    template => "html/info/privacy/view.ttkt",
    title_links => \@title_links,
    subtitle1 => $c->maketext("menu.text.privacy"),
    privacy => $privacy,
  });
}

=head2 edit

Edit the privacy policy.

=cut

sub edit :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["privacy_edit", $c->maketext("user.auth.edit-privacy"), 1]);
  
  $c->stash({
    template => "html/page-text/edit.ttkt",
    scripts => [qw( ckeditor-iframely-standard )],
    ckeditor_selectors => [qw( page_text )],
    external_scripts => [
      $c->uri_for("/static/script/plugins/ckeditor5/ckeditor.js"),
      $c->uri_for("/static/script/page_text/edit.js"),
    ],
    subtitle1 => $c->maketext("menu.text.privacy"),
    edit_text => $c->model("DB::PageText")->get_text("privacy"),
    form_action => $c->uri_for_action("/info/privacy/do_edit"),
  });
}

=head2 do_edit

Process the privacy policy edit form.

=cut

sub do_edit :Path("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["privacy_edit", $c->maketext("user.auth.edit-privacy"), 1]);
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $response = $c->model("DB::PageText")->edit({
    page_key => "privacy",
    page_text => $c->req->param("page_text"),
  });
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $redirect_uri = $c->uri_for_action("/info/privacy/view", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["privacy", "edit"]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    $redirect_uri = $c->uri_for_action("/info/privacy/edit", {mid => $mid});
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{page_text} = $c->req->params->{page_text};
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
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
