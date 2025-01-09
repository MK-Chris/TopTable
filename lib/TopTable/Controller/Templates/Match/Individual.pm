package TopTable::Controller::Templates::Match::Individual;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Templates::Match::Individual - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.template-invididual-match")});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/templates/match/individual"),
    label => $c->maketext("menu.text.template-invididual-match-breadcrumbs-nav"),
  });
}

=head2 base

Chain base sub for checking the ID.

=cut

sub base :Chained("/") PathPart("templates/match/individual") CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $tt_template = $c->model("DB::TemplateMatchIndividual")->find_id_or_url_key($id_or_key);
  
  if ( defined($tt_template) ) {
    my $enc_name = encode_entities($tt_template->name);
    
    $c->stash({
      tt_template => $tt_template,
      enc_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of ranking.  Matches /templates/league-table-ranking

=cut

sub base_list :Chained("/") :PathPart("templates/match/individual") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view templates
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1]);
  
  # Check the authorisation to edit templates we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( template_edit template_delete template_create)], "", 0]);
  
  $c->stash({
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the templates on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/templates/match/individual/list_first_page")});
}

=head2 list_specific_page

List the templates on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # Check that we are authorised to view templates
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1]);
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/templates/match/individual/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/templates/match/individual/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for templates with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $match_templates = $c->model("DB::TemplateMatchIndividual")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $match_templates->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/templates/match/individual/list_first_page",
    specific_page_action => "/templates/match/individual/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/templates/match/individual/list.ttkt",
    view_online_display => "Viewing individual match templates",
    view_online_link => 1,
    match_templates => $match_templates,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

View the individual match template's rules.

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( template_create template_edit template_delete )], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists($c->stash->{delete_screen}) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_name),
      link_uri => $c->uri_for_action("/templates/match/individual/edit", [$tt_template->url_key]),
    }) if $c->stash->{authorisation}{template_edit} and $tt_template->can_edit_or_delete;
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/templates/match/individual/delete", [$tt_template->url_key]),
    }) if $c->stash->{authorisation}{template_delete} and $tt_template->can_edit_or_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/templates/match/individual/view.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing match template: %s", $enc_name),
    view_online_link => 0,
    external_scripts => [
      $c->uri_for("/static/script/standard/vertical-table.js"),
    ],
  });
}

=head2 create

Display a form to collect information for creating a match template.  Unlike other controllers, this create method is private and is accessed via $c->detach() in the base chained method, so we can still access the template type before getting here.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1]);
  
  # Get venues and people to list
  $c->stash({
    template => "html/templates/match/individual/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/templates/match/individual/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating individual match templates",
    view_online_link => 0,
    game_types => [$c->model("DB::LookupGameType")->search],
    serve_types => [$c->model("DB::LookupServeType")->search],
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/templates/match/individual/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing an individual match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_edit", $c->maketext("user.auth.edit-templates"), 1]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect($c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("templates.edit.error.not-allowed", $tt_template->name)})}));
    $c->detach;
    return;
  }
  
  # Get venues to list
  $c->stash({
    template => "html/templates/match/individual/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/templates/match/individual/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for_action("/templates/match/individual/do_edit", [$tt_template->url_key]),
    view_online_display => sprintf("Editing individual match template %s", $tt_template->name),
    view_online_link => 0,
    game_types => [$c->model("DB::LookupGameType")->search],
    serve_types => [$c->model("DB::LookupServeType")->search],
    subtitle2 => $c->maketext("admin.edit"),
  });
  
  $c->flash->{game_type} = $tt_template->game_type->id;
  $c->flash->{serve_type} = $tt_template->serve_type->id;
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/templates/match/individual/edit", [$tt_template->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_delete", $c->maketext("user.auth.delete-templates"), 1]);
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect($c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("templates.delete.error.not-allowed", $tt_template->name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/templates/match/individual/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $enc_name),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/templates/match/individual/delete", [$tt_template->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating an individual match template.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1]);
  
  # Forward to the creation routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing an individual match template.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to edit templates
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_edit", $c->maketext("user.auth.edit-templates"), 1]);
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect($c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("templates.edit.error.not-allowed", $tt_template->name)})}));
    $c->detach;
    return;
  }
  
  # Forward to the edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Processes the deletion of the template.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_delete", $c->maketext("user.auth.delete-templates"), 1]);
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect($c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("templates.delete.error.not-allowed", $tt_template->name)})}));
    $c->detach;
    return;
  }
  
  # Save away the venue name, as if there are no errors and it can be deleted, we will need to
  # reference the name in the message back to the user.
  my $tt_template_name = $tt_template->name;
  
  # Hand off to the model to do some checking
  #my $deletion_result = $c->model("DB::Venue")->check_and_delete( $venue );
  my $response = $tt_template->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/templates/match/individual", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["template-match-individual", "delete", {id => undef}, $tt_template_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Forwarded from docreate and doedit to do the template creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $tt_template = $c->stash->{tt_template};
  my @field_names = qw( name game_type legs_per_game minimum_points_win clear_points_win serve_type serves serves_deuce  handicapped );
  
  # The rest of the error checking is done in the Club model
  my $response = $c->model("DB::TemplateMatchIndividual")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    tt_template => $tt_template, # This will be undef if we're creating.
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
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
    $tt_template = $response->{tt_template};
    $redirect_uri = $c->uri_for_action("/templates/match/individual/view", [$tt_template->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["template-match-individual", $action, {id => $tt_template->id}, $tt_template->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/templates/match/individual/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/templates/match/individual/edit", [$tt_template->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    $c->flash->{$_} = $response->{fields}{$_} foreach @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view templates
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1]);
  
  $c->stash({
    db_resultset => "TemplateMatchIndividual",
    query_params => {q => $c->req->param("q")},
    view_action => "/templates/match/individual/view",
    search_action => "/templates/match/individual/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.templates.match-individual") ),
  });
  
  # Do the search
  $c->forward("TopTable::Controller::Search", "do_search");
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
