package TopTable::Controller::MeetingTypes;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered meeting-types, so the URLs start /meeting-types.
__PACKAGE__->config(namespace => "meeting-types");

=head1 NAME

TopTable::Controller::MeetingTypes - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.meeting-types")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/meeting-types"),
    label => $c->maketext("menu.text.meeting-types"),
  });
}

=head2 base

Chain base for getting the meeting type ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("meeting-types") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $meeting_type = $c->model("DB::MeetingType")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $meeting_type ) ) {
    my $encoded_type = encode_entities( $meeting_type->name );
    
    $c->stash({
      meeting_type  => $meeting_type,
      encoded_type  => $encoded_type,
      subtitle1     => $encoded_type,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/meeting-types/view_first_page", [$meeting_type->url_key]),
      label => $encoded_type,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of meeting types.

=cut

sub base_list :Chained("/") :PathPart("meeting-types") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_view", $c->maketext("user.auth.view-meetings"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( meeting_type_edit meeting_type_delete meeting_type_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.meeting-types.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/list_first_page")});
  $c->detach( "retrieve_paged", [1] );
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for meeting types with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $meeting_types = $c->model("DB::MeetingType")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $meeting_types->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/meeting-types/list_first_page",
    specific_page_action  => "/meeting-types/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/meeting-types/list.ttkt",
    view_online_display => "Viewing meeting types",
    view_online_link    => 1,
    meeting_types       => $meeting_types,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view_first_page

View the first page of meetings for the specified meeting type.

=cut

sub view_first_page :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/view_first_page", [$meeting_type->url_key])});
  $c->forward( "retrieve_paged_meetings", [1] );
}

=head2 view_specific_page

View the specified page of meetings for the specified meeting type.

=cut

sub view_specific_page :Chained("base") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/view_first_page", [$meeting_type->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/meeting-types/view_specific_page", [$meeting_type->url_key, $page_number])});
  }
  
  $c->detach( "retrieve_paged_meetings", [$page_number] );
}

=head2 retrieve_paged_meetings

Retrieve the meetings for the specified page number.

=cut

sub retrieve_paged_meetings :Private {
  my ( $self, $c, $page_number ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_view", $c->maketext("user.auth.view-meetings"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( meeting_type_edit meeting_type_delete ) ], "", 0] );
  
  my $meetings = $c->model("DB::Meeting")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
    meeting_type      => $meeting_type,
  });
  
  my $page_info   = $meetings->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/meeting-types/view_first_page",
    page1_action_arguments          => [$meeting_type->url_key],
    specific_page_action            => "/meeting-types/view_specific_page",
    specific_page_action_arguments  => [$meeting_type->url_key],
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    view_online_display => "Viewing meeting types",
    view_online_link    => 1,
    meetings            => $meetings,
    page_info           => $page_info,
    page_links          => $page_links,
  });
  
  $c->detach("view_finalise") unless exists( $c->stash->{delete_screen} );
}

=head2 view_finalise

Finalise the view, having retrieved the meetings for this meeting type.

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $meeting_type  = $c->stash->{meeting_type};
  my $encoded_type  = $c->stash->{encoded_type};
  my $site_name     = $c->stash->{encoded_site_name};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit link if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.edit-object", $encoded_type),
      link_uri  => $c->uri_for_action("/meeting-types/edit", [$meeting_type->url_key]),
    }) if $c->stash->{authorisation}{meeting_type_edit};
    
    # Push a delete link if we're authorised and the club can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $encoded_type),
      link_uri  => $c->uri_for_action("/meeting-types/delete", [$meeting_type->url_key]),
    }) if $c->stash->{authorisation}{meeting_type_delete} and $meeting_type->can_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/meeting-types/view.ttkt",
    title_links         => \@title_links,
    subtitle1           => $meeting_type->name,
    view_online_display => sprintf( "Viewing %s", $encoded_type ),
    view_online_link    => 0,
    page_description    => $c->maketext("description.meeting-types.view", $encoded_type, $site_name),
  });
}

=head2 create

Display a form to collect information for creating a season.

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_create", $c->maketext("user.auth.create-meeting-types"), 1] );
  
  # Stash everything we need in the template
  $c->stash({
    template            => "html/meeting-types/create-edit.ttkt",
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating meeting types",
    view_online_link    => 0,
  });
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/meeting-types/create"),
    label => $c->maketext("admin.create"),
  })
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_edit", $c->maketext("user.auth.edit-meeting-types"), 1] );
  
  # Stash everything we need in the template
  $c->stash({
    template            => "html/meeting-types/create-edit.ttkt",
    form_action         => $c->uri_for_action("/meeting-types/do_edit", [$meeting_type->url_key]),
    subtitle2           => $c->maketext("admin.edit"),
    view_online_display => "Editing meeting types",
    view_online_link    => 0,
  });
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/meeting-types/create"),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the meeting type details and a button to delete.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_delete", $c->maketext("user.auth.delete-meeting-types"), 1] );
  
  unless ( $meeting_type->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/meeting-types/view_first_page", [$meeting_type->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "meeting-types.delete.error.cannot-delete", encode_entities($meeting_type->name) )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_first_page");
  
  $c->stash({
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/meeting-types/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $meeting_type->name ),
    view_online_link    => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/meeting-types/delete", [$meeting_type->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a season.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_create", $c->maketext("user.auth.create-meeting-types"), 1] );
  $c->detach( "setup_meeting_type", ["create"] );
}

=head2 do_edit

Process the form for editing an individual match template.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c, $template_id ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_edit", $c->maketext("user.auth.edit-meeting-types"), 1] );
  $c->detach( "setup_meeting_type", ["edit"] );
}

=head2 do_delete

Processes the season deletion after the user has submitted the form.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  my $meeting_type_name = $meeting_type->name;
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_delete", $c->maketext("user.auth.delete-meeting-types"), 1] );
  
  my $error = $meeting_type->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/meeting-type/view_first_page", [ $meeting_type->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["meeting-type", "delete", {id => undef}, $meeting_type_name] );
    $c->response->redirect( $c->uri_for("/meeting-types",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $meeting_type_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_meeting_type

Forwarded to from docreate / doedit - sets up the meeting type and adds / updates the database with the new details.

=cut

sub setup_meeting_type :Private {
  my ( $self, $c, $action ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  
  # Call the DB routine to do the error checking and creation
  my $details = $c->model("DB::MeetingType")->create_or_edit($action, {
    meeting_type          => $meeting_type,
    name                  => $c->request->parameters->{name},
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{name}           = $c->request->parameters->{name};
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      # If we're creating, we'll just redirect straight back to the create form
      $redirect_uri = $c->uri_for("/meeting-types/create",
                            {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined($details->{meeting_type}) ) {
        # If we're editing and we found an object to edit, we'll redirect to the edit form for that object
        $redirect_uri = $c->uri_for_action("/meeting-types/edit", [ $details->{meeting_type}->url_key ],
                              {mid => $c->set_status_msg( {error => $error} ) });
      } else {
        # If we're editing and we didn't an object to edit, we'll redirect to the list of objects
        $redirect_uri = $c->uri_for("/meeting-types",
                              {mid => $c->set_status_msg( {error => $error} ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $meeting_type  = $details->{meeting_type};
    my $encoded_type  = encode_entities( $meeting_type->name );
    my $action_description;
    
    if ( $action eq "create" ) {
      $meeting_type = $details->{meeting_type};
      $action_description = $c->maketext("admin.message.created");
    } else {
      $action_description = $c->maketext("admin.message.edited");
    }
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["meeting-type", $action, {id => $meeting_type->id}, $meeting_type->name] );
    $c->response->redirect( $c->uri_for_action("/meeting-types/view_first_page", [$meeting_type->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_type, $action_description )} ) }) );
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
