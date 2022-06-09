package TopTable::Controller::Roles;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Roles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.role")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/roles"),
    label => $c->maketext("menu.text.role"),
  });
}

=head2 base

Chain base for getting the role ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("roles") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $role = $c->model("DB::Role")->find_id_or_url_key($id_or_key);
  
  if ( defined($role) ) {
    # System roles are in the language pack; otherwise we HTML encode it.
    my $enc_name = $role->system ? $c->maketext(sprintf("roles.name.%s", $role->name)) : encode_entities($role->name);
    
    $c->stash({
      role => $role,
      encoded_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/roles/view", [$role->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of roles.

=cut

sub base_list :Chained("/") :PathPart("roles") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["role_view", $c->maketext("user.auth.view-roles"), 1]);
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( role_create role_edit role_delete ) ], "", 0]);
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.roles.list", $site_name)},
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  );
}

=head2 list_first_page

List the roles on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/roles/list_first_page")});
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
    $c->stash({canonical_uri => $c->uri_for_action("/roles/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/roles/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for meeting types with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $roles = $c->model("DB::Role")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $roles->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/roles/list_first_page",
    specific_page_action => "/roles/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/roles/list.ttkt",
    view_online_display => "Viewing roles",
    view_online_link => 0,
    roles => $roles,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

View the role (i.e., name, permissions and  members).

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  my $site_name = $c->stash->{enc_site_name};
  my $role_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["role_view", $c->maketext("user.auth.view-roles"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( role_edit role_delete )], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists($c->stash->{delete_screen}) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.delete-object", $role_name),
      link_uri => $c->uri_for_action("/roles/edit", [$role->url_key]),
    }) if $c->stash->{authorisation}{role_edit};
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $role_name),
      link_uri => $c->uri_for_action("/roles/delete", [$role->url_key]),
    }) if $c->stash->{authorisation}{role_delete};
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/roles/view.ttkt",
    title_links => \@title_links,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/roles/view.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
    view_online_display => sprintf("Viewing role: %s", $role_name),
    view_online_link => 0,
    page_description => $c->maketext("description.roles.view", $role_name, $site_name),
    members => scalar $role->members,
  });
  
  $c->forward("get_perm_fields", [qw( view )]);
}

=head2 create

Display a form to collect information for creating a role.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_create", $c->maketext("user.auth.create-roles"), 1] );
  
  my $member_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("person.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
    prePopulate => [],
  };
  
  # Add pre-population if we need it
  if ( exists($c->flash->{show_flashed}) and ref($c->flash->{members}) eq "ARRAY" ) {
    foreach my $person ( @{$c->flash->{members}} ) {
      push(@{$member_tokeninput_options->{prePopulate}}, {
        id => $person->id,
        name => encode_entities($person->username),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/users/search"),
    options => encode_json($member_tokeninput_options),
    selector => "members",
  }];
  
  # Stash information for the template
  $c->stash({
    template => "html/roles/create-edit.ttkt",
    tokeninput_confs => $tokeninput_confs,
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating roles",
    view_online_link => 0,
  });
  
  $c->forward("get_perm_fields", [qw( create )]);
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/roles/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing an individual match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $role = $c->stash->{role};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_edit", $c->maketext("user.auth.edit-roles"), 1] );
  
  # Add a notice if we're sysadmin or registered users
  $c->add_status_messages({info => $c->maketext("roles.form.notice-sysadmin-permissions")}) if $role->sysadmin;
  $c->add_status_messages({info => $c->maketext("roles.form.notice.cant-modify-registered-users-members")}) if $role->apply_on_registration;
  $c->add_status_messages({info => $c->maketext("roles.form.notice.cant-modify-anonymous-users-members")}) if $role->anonymous;
  
  my $member_tokeninput_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("person.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Add pre-population if we need it
  my $members = ( exists($c->flash->{show_flashed}) and ref($c->flash->{members}) eq "ARRAY" ) ? $c->flash->{members} : [$role->members];
  
  if ( defined($members) and ref($members) eq "ARRAY" ) {
    foreach my $member ( @$members ) {
      push(@{$member_tokeninput_options->{prePopulate}}, {
        id => $member->id,
        name => encode_entities($member->username),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script => $c->uri_for("/users/search"),
    options => encode_json($member_tokeninput_options),
    selector => "members",
  }];
  
  # Stash information for the template
  $c->stash({
    template => "html/roles/create-edit.ttkt",
    tokeninput_confs => $tokeninput_confs,
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for_action("/roles/do_edit", [$role->url_key]),
    subtitle2 => $c->maketext("admin.edit"),
    view_online_display => "Editing roles",
    view_online_link => 0,
  });
  
  $c->forward("get_perm_fields", [qw( edit )]);
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/roles/edit", [$role->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_delete", $c->maketext("user.auth.delete-roles"), 1] );
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/roles/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", encode_entities( $role->name ) ),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/roles/delete", [$role->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a role.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create roles
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_create", $c->maketext("user.auth.create-roles"), 1] );
  
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a role.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ($self, $c, $template_id) = @_;
  my $role = $c->stash->{role};
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["role_edit", $c->maketext("user.auth.edit-roles"), 1]);
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Processes the deletion of the role.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["role_delete", $c->maketext("user.auth.delete-roles"), 1]);
  
  # We need to store the name so we can insert it into the event log database after the item has been deleted
  my $role_name = $role->name;
  
  # Hand off to the model to do some checking
  #my $deletion_result = $c->model("DB::Venue")->check_and_delete( $venue );
  my $response = $role->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/roles", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["role", "delete", {id => undef}, $role_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/roles/view", [$role->url_key], {mid => $mid});
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
  my $role = $c->stash->{role};
  
  # Grab the all the column names and remove the fields we don't interact with: id, url_key, system, sysadmin, anonymous, apply_on_registration - this is easier than
  # listing them all in an array because there are so many fields (and this is the table that most often has columns added, so makes sense to get them dynamically).
  my $field_names = Set::Object->new($c->model("DB::Role")->result_source->columns);
  $field_names->delete(qw( id url_key system sysadmin anonymous apply_on_registration ));
  my @field_names = @$field_names;
  
  my $response = $c->model("DB::Role")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    role => $role,
    members => [split(",", $c->req->params->{members})],
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
  });
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $role = $response->{role};
    $redirect_uri = $c->uri_for_action("/roles/view", [$role->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["role", $action, {id => $role->id}, $role->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/roles/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/roles/edit", [$role->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    $c->flash->{members} = $response->{fields}{members};
    $c->flash->{$_} = $response->{fields}{$_} foreach @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 get_perm_fields

Get the permission fields and stash them, along with the correct order of categories (cats) and permission types (perm_types).

=cut

sub get_perm_fields :Private {
  my ( $self, $c, $action ) = @_;
  my $role = $c->stash->{role};
  
  # Set up the order in which we want to display categories - they only get shown if they exist in this list, so all categories must be added (new ones must be added to this list)
  my @cats = qw( season venue club team person fixtures match matchreport event meetingtype meeting tournament averagefilter news index privacy admin template eventlog user role session contactreason file image );
  
  # Setup the order in which we want to display individual permissions in categories - they only get shown if they exist in that category.  Every individual permission must
  # be added to this list
  my @perm_types = qw( view contact_view view_all online_view online_view_anonymous view_anonymous view_ip view_user_agent create create_associated create_public pin edit edit_own edit_all edit_public delete delete_own delete_all delete_public update cancel archive approve_new upload issue_bans );
  
  # Get the permissions field names - grab all columns, then use Set::Object to delete the non-permissions fields
  my $field_names = Set::Object->new($c->model("DB::Role")->result_source->columns);
  $field_names->delete(qw( id url_key name system sysadmin anonymous apply_on_registration ));
  
  my %perm_fields = ();
  foreach my $field ( @$field_names ) {
    my $perm_setting;
    
    if ( $action eq "view" ) {
      # Setting always comes from the DB field itself when viewing
      $perm_setting = $role->$field;
    } elsif ( $action eq "create" ) {
      # Setting will come from the flashed values, if we have them, or from the default value (1 for most view perms, 0 for everything else)
      if ( exists($c->flash->{show_flashed}) ) {
        # Use the flashed value
        $perm_setting = $c->flash->{$field} || 0;
      } else {
        # Not using flashed values, use the default we set here
        $perm_setting = ( $field =~ /view$/ ) ? 1 : 0; # Default to false (not allowed) unless the permission ends in "view"
        $perm_setting = 0 if $field eq "person_contact_view"; # person_contact_view is the exception, default to false (not allowed)
      }
    } elsif ( $action eq "edit" ) {
      # Setting will come from the flashed values, if we have them, otherwise the DB field
      $perm_setting = ( exists($c->flash->{show_flashed}) ) ? $c->flash->{$field} : $role->$field;
    }
    
    # Parse to get the category
    my @bits = split("_", $field);
    my $cat = shift @bits; # Category is the bit before the first underscore
    my $permission = join("_", @bits); # permission is the rest of it, so join back up after the first bit's removed
    
    if ( exists($perm_fields{$cat}) ) {
      # We already have a permission set in this category, add this key to the current hash
      $perm_fields{$cat}{$permission} = $perm_setting;
    } else {
      # This is the first permission for this category, set it up in a new hash
      $perm_fields{$cat} = {$permission => $perm_setting};
    }
  }
  
  # Stash categories, perm types and perm fields
  $c->stash({
    cats => \@cats,
    perm_types => \@perm_types,
    perm_fields => \%perm_fields,
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
