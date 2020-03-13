package TopTable::Controller::Info::Privacy;
use Moose;
use namespace::autoclean;
use Data::Dumper;

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
  push( @{ $c->stash->{breadcrumbs} }, {
    # Clubs listing
    path  => $c->uri_for("/info/privacy"),
    label => $c->maketext("menu.text.privacy"),
  });
}

=head2 view

View the privacy policy.

=cut

sub view :Path("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["privacy_view", $c->maketext("user.auth.view-privacy"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["privacy_edit", "", 0] );
  
  my $privacy = $c->model("DB::PageText")->get_text("privacy");
  
  # Set up the title links if we need them
  my @title_links = ();
  
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text      => $c->maketext("admin.edit.privacy"),
    link_uri  => $c->uri_for_action("/info/privacy/edit"),
  }) if $c->stash->{authorisation}{privacy_edit};
  
  $c->stash({
    template    => "html/info/privacy/view.ttkt",
    title_links => \@title_links,
    subtitle1   => $c->maketext("menu.text.privacy"),
    privacy     => $privacy,
  });
}

=head2 edit

Edit the privacy policy.

=cut

sub edit :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["privacy_edit", $c->maketext("user.auth.edit-privacy"), 1] );
  
  $c->stash({
    template    => "html/page-text/edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/page_text/edit.js"),
    ],
    subtitle1   => $c->maketext("menu.text.privacy"),
    edit_text   => $c->model("DB::PageText")->get_text("privacy"),
    form_action => $c->uri_for_action("/info/privacy/do_edit"),
  });
}

=head2 do_edit

Process the privacy policy edit form.

=cut

sub do_edit :Path("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["privacy_edit", $c->maketext("user.auth.edit-privacy"), 1] );
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $details = $c->model("DB::PageText")->edit({
    page_key    => "privacy",
    page_text   => $c->request->parameters->{page_text},
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{page_text}  = $c->request->parameters->{page_text};
    
    $c->response->redirect( $c->uri_for("/info/privacy/edit",
                          {mid => $c->set_status_msg( {error => $error} ) }) );
    $c->detach;
    return;
  } else {
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["privacy", "edit"] );
    $c->response->redirect( $c->uri_for_action("/info/privacy/view",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $c->maketext("menu.text.privacy"), $c->maketext("admin.message.edited") )}  ) }) );
    $c->detach;
    return;
  }
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
