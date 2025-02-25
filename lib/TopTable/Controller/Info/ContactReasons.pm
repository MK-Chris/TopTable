package TopTable::Controller::Info::ContactReasons;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;
use Data::Printer;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered info/contact-reasons, so the URLs start /info/contact-reasons.
__PACKAGE__->config(namespace => "info/contact-reasons");

=head1 NAME

TopTable::Controller::Info::ContactReasons - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.contactreason")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/contact-reasons"),
    label => $c->maketext("menu.text.contactreason"),
  });
}

=head2 base

Chain base for getting the contact reason ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("info/contact-reasons") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $reason = $c->model("DB::ContactReason")->find_id_or_url_key($id_or_key);
  
  if ( defined( $reason ) ) {
    my $enc_name = encode_entities($reason->name);
    
    $c->stash({
      reason => $reason,
      enc_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/info/contact-reasons/view", [$reason->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of contact reasons.

=cut

sub base_list :Chained("/") :PathPart("info/contact-reasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_view", $c->maketext("user.auth.view-contact-reasons"), 1]);
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( contactreason_edit contactreason_delete contactreason_create) ], "", 0]);
  
  # Page description
  $c->stash({
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the contact reasons on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/info/contact-reasons/list_first_page")});
  $c->detach("retrieve_paged", [1]);
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/info/contact-reasons/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/info/contact-reasons/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for meeting types with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $reasons = $c->model("DB::ContactReason")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $reasons->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/info/contact-reasons/list_first_page",
    specific_page_action => "/info/contact-reasons/list_specific_page",
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/info/contact-reasons/list.ttkt",
    view_online_display => "Viewing contact reasons",
    view_online_link => 0,
    reasons => $reasons,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

View the contact reason (i.e., name and recipient(s)).

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $reason = $c->stash->{reason};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_view", $c->maketext("user.auth.view-contact-reasons"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( contactreason_edit contactreason_delete ) ], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists($c->stash->{delete_screen}) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/info/contact-reasons/edit", [$reason->url_key]),
    }) if $c->stash->{authorisation}{contactreason_edit};
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $enc_name),
      link_uri  => $c->uri_for_action("/info/contact-reasons/delete", [$reason->url_key]),
    }) if $c->stash->{authorisation}{contactreason_delete};
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/info/contact-reasons/view.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing contact reason: %s", $enc_name),
    view_online_link => 0,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 create

Display a form to collect information for creating a contact reason.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["contactreason_create", $c->maketext("user.auth.create-contact-reason"), 1] );
  
  my $recipient_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  if ( exists($c->flash->{recipients}) and ref($c->flash->{recipients}) eq "ARRAY" ) {
    foreach my $person ( @{ $c->flash->{recipients} } ) {
      push(@{ $recipient_tokeninput_options->{prePopulate} }, {
        id => $person->id,
        name => encode_entities( $person->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/people/search"),
    options => encode_json( $recipient_tokeninput_options ),
    selector => "recipients",
  }];
  
  # Stash information for the template
  $c->stash({
    template => "html/info/contact-reasons/create-edit.ttkt",
    tokeninput_confs => $tokeninput_confs,
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating contact reasons",
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/contact-reasons/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing an individual match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $reason = $c->stash->{reason};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_edit", $c->maketext("user.auth.edit-contact-reasons"), 1]);
  
  my $recipient_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  my $recipients = ( defined($c->flash->{recipients}) and ref($c->flash->{recipients}) eq "ARRAY" ) ? $c->flash->{recipients} : [$reason->recipients];
  
  if ( defined($recipients) and ref($recipients) eq "ARRAY" ) {
    foreach my $recipient ( @$recipients ) {
      # If this is flashed it will be the person directly referenced; if we've retrieved from the database it'll be the contact reason recipient,
      # from which we need to get the person.
      my $person = ( ref($recipient) eq "TopTable::DB::Model::Person" ) ? $recipient : $recipient->person;
      
      push(@{ $recipient_tokeninput_options->{prePopulate} }, {
        id => $person->id,
        name => encode_entities( $person->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/people/search"),
    options => encode_json( $recipient_tokeninput_options ),
    selector => "recipients",
  }];
  
  # Stash information for the template
  $c->stash({
    template => "html/info/contact-reasons/create-edit.ttkt",
    tokeninput_confs => $tokeninput_confs,
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.edit"),
    view_online_display => "Editing contact reasons",
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/contact-reasons/edit", [$reason->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $reason = $c->stash->{reason};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["contactreason_delete", $c->maketext("user.auth.delete-contact-reasons"), 1] );
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/info/contact-reasons/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", encode_entities( $reason->name ) ),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/contact-reasons/delete", [$reason->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a contact reason.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create contact reasons
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_create", $c->maketext("user.auth.create-contact-reasons"), 1]);
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a contact reason.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ($self, $c, $template_id) = @_;
  my $reason = $c->stash->{reason};
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_edit", $c->maketext("user.auth.edit-contact-reasons"), 1]);
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Processes the deletion of the contact reason.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $reason = $c->stash->{reason};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["contactreason_delete", $c->maketext("user.auth.delete-contact-reasons"), 1]);
  
  # We need to store the name so we can insert it into the event log database after the item has been deleted
  my $name = $reason->name;
  
  # Hand off to the model to do some checking
  my $response = $reason->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/info/contact-reasons", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["contact-reason", "delete", {id => undef}, $name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/info/contact-reasons/view", [$reason->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Forwarded from docreate and doedit to do the reason creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $reason = $c->stash->{reason};
  my @processed_field_names = qw( name recipients );
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $response = $c->model("DB::ContactReason")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    reason => $reason,
    name => $c->req->params->{name},
    recipient_ids => [split(",", $c->req->params->{recipients})],
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
    $reason = $response->{reason};
    $redirect_uri = $c->uri_for_action("/info/contact-reasons/view", [$reason->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["contact-reason", $action, {id => $reason->id}, $reason->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/info/contact-reasons/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/info/contact-reasons/edit", [$reason->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{$_} = $response->{fields}{$_} foreach @processed_field_names;
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
