package TopTable::Controller::LeagueAverages::Filters;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered league-averages/filters, so the URLs start /league-averages/filters.
__PACKAGE__->config(namespace => "league-averages/filters");

=head1 NAME

TopTable::Controller::LeagueAverages::Filters - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.average-filters")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/league-averages/filters"),
    label => $c->maketext("menu.text.average-filters"),
  });
}

=head2 base

Chain base for getting the filter ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("league-averages/filters") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $filter = $c->model("DB::AverageFilter")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $filter ) ) {
    my $encoded_name = encode_entities( $filter->name );
    
    $c->stash({
      filter        => $filter,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/league-averages/filters/view", [$filter->url_key]),
      label => encode_entities( $encoded_name ),
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of filters.

=cut

sub base_list :Chained("/") :PathPart("league-averages/filters") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( average_filter_create_public average_filter_edit_public average_filter_delete_public average_filter_view_all average_filter_edit_all average_filter_delete_all ) ], "", 0] );
  
  $c->stash({
    external_scripts      => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the filters on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/league-averages/filters/list_first_page")});
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
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/filters/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/filters/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for meeting types with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $page_config = {
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  };
  
  if ( $c->stash->{authorisation}{average_filter_view_all} and $c->request->parameters->{view} eq "all" ) {
    # If we've requested to view all and we're authorised to do so, show all
    $page_config->{view_all} = 1;
  } elsif ( $c->user_exists ) {
    $page_config->{user} = $c->user;
  }
  
  my $filters = $c->model("DB::AverageFilter")->page_records( $page_config );
  
  my $page_info   = $filters->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/league-averages/filters/list_first_page",
    specific_page_action  => "/league-averages/filters/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-averages/filters/list.ttkt",
    view_online_display => "Viewing average filters",
    view_online_link    => 0,
    filters             => $filters,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

View the filter.

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $filter = $c->stash->{filter};
  my $encoded_name = $c->stash->{encoded_name};
  
  if ( defined( $filter->user ) ) {
    # Filter is for a specific user - we either need to be that user, or we need to be able to view all filters
    unless ( $c->user_exists and $c->user->id == $filter->user->id ) {
      # We are logged in, but not as the user who owns this filter - check permissions
      $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_view_all", $c->maketext("user.auth.view-average-filter"), 1] );
    }
  }
  
  # Check authorisation for editing / deleting
  my ( $can_edit, $can_delete );
  if ( defined( $filter->user ) ) {
    # Belongs to a user, is the user the same as 
    if ( $c->user_exists and $c->user->id == $filter->user->id ) {
      # User is logged in and viewing their own filter - they can edit and delete it
      $can_edit   = 1;
      $can_delete = 1;
    } else {
      # User is not logged in or not viewing their own filter - check whether they can edit / delete all.
      $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( average_filter_edit_all average_filter_delete_all ) ], "", 0] );
      $can_edit   = $c->stash->{authorisation}{average_filter_edit_all};
      $can_delete = $c->stash->{authorisation}{average_filter_delete_all};
    }
  } else {
    # This is a public filter, not belonging to a specific user, check whether we can edit or delete public filters
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( average_filter_edit_public average_filter_delete_public ) ], "", 0] );
    $can_edit   = $c->stash->{authorisation}{average_filter_edit_public};
    $can_delete = $c->stash->{authorisation}{average_filter_delete_public};
  }
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $encoded_name),
      link_uri  => $c->uri_for_action("/league-averages/filters/edit", [$filter->url_key]),
    }) if $can_edit;
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $encoded_name),
      link_uri  => $c->uri_for_action("/league-averages/filters/delete", [$filter->url_key]),
    }) if $can_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-averages/filters/view.ttkt",
    title_links         => \@title_links,
    can_edit            => $can_edit,
    can_delete          => $can_delete,
    view_online_display => sprintf( "Viewing average filter: %s", $encoded_name ),
    view_online_link    => 0,
  });
}

=head2 create

Display a form to collect information for creating an average filter.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create filters
  if ( $c->user_exists ) {
    # If we're logged in, we can definitely create user filters, but we need to know if we can create public ones, but just check, not redirect on failure
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_create_public", "", 0] );
  } else {
    # If we're not logged in, we need to do the same check but redirect on failure (in reality it is totally inadvisable to allow anonymous users to do this)
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_create_public", $c->maketext("user.auth.create-average-filters"), 1] );
  }
  
  # Stash information for the template
  $c->stash({
    template            => "html/league-averages/filters/create-edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/league-averages/filters/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating average filters",
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/league-averages/filters/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing an individual match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $filter = $c->stash->{filter};
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to create filters
  if ( !defined( $filter->user ) ) {
    # This is a public filter, so we need to check we can edit public filters
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_edit_public", $c->maketext("user.auth.edit-average-filter"), 1] );
  } elsif ( !$c->user_exists or $c->user->id != $filter->user->id ) {
    # If it's a user filter and we're not logged on as the owner, we need to check we can edit all
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_edit_all", $c->maketext("user.auth.edit-average-filter"), 1] );
  }
  
  # Stash information for the template
  $c->stash({
    template            => "html/league-averages/filters/create-edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/league-averages/filters/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating average filters",
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/league-averages/filters/edit", [$filter->url_key]),
    label => $c->maketext("admin.create"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $filter = $c->stash->{filter};
  my $encoded_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to delete venues
  if ( !defined( $filter->user ) ) {
    # This is a public filter, so we need to check we can delete public filters
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_delete_public", $c->maketext("user.auth.delete-average-filter"), 1] );
  } elsif ( !$c->user_exists or $c->user->id != $filter->user->id ) {
    # If it's a user filter and we're not logged on as the owner, we need to check we can delete all
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_delete_all", $c->maketext("user.auth.delete-average-filter"), 1] );
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/league-averages/filters/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $encoded_name ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/league-averages/filters/delete", [$filter->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a filter.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create filters
  if ( $c->user_exists ) {
    # If we're logged in, we can definitely create user filters, but we need to know if we can create public ones, but just check, not redirect on failure
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_create_public", "", 0] );
  } else {
    # If we're not logged in, we need to do the same check but redirect on failure (in reality it is totally inadvisable to allow anonymous users to do this)
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_create_public", "", 1] );
  }
  
  $c->detach( "setup_template", ["create"] );
}

=head2 do_edit

Process the form for editing a filter.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ($self, $c, $template_id) = @_;
  my $filter = $c->stash->{filter};
  
  # Check that we are authorised to create filters
  if ( !defined( $filter->user ) ) {
    # This is a public filter, so we need to check we can edit public filters
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_edit_public", $c->maketext("user.auth.edit-average-filter"), 1] );
  } elsif ( !$c->user_exists or $c->user->id != $filter->user->id ) {
    # If it's a user filter and we're not logged on as the owner, we need to check we can edit all
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_edit_all", $c->maketext("user.auth.edit-average-filter"), 1] );
  }
  
  $c->detach( "setup_template", ["edit"] );
}

=head2 do_delete

Processes the deletion of the filter.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $filter = $c->stash->{filter};
  my $encoded_name = $c->stash->{encoded_name};
    
  # Check that we are authorised to delete venues
  if ( !defined( $filter->user ) ) {
    # This is a public filter, so we need to check we can delete public filters
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_delete_public", $c->maketext("user.auth.delete-average-filter"), 1] );
  } elsif ( !$c->user_exists or $c->user->id != $filter->user->id ) {
    # If it's a user filter and we're not logged on as the owner, we need to check we can delete all
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["average_filter_delete_all", $c->maketext("user.auth.delete-average-filter"), 1] );
  }
  
  # Save the name so we can use it in the event log database after the item has been deleted
  my $filter_name = $filter->name;
  
  # Hand off to the model to do some checking
  my $error = $filter->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting, go back to deletion page
    $c->response->redirect( $c->uri_for_action("/league-averages/filters/view", [$filter->url_key],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success, log a deletion and return to the venue list
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["average-filter", "delete", {id => undef}, $filter_name] );
    $c->response->redirect( $c->uri_for("/league-averages/filters",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_template

Forwarded from docreate and doedit to do the filter creation / edit.

=cut

sub setup_template :Private {
  my ( $self, $c, $action ) = @_;
  my $filter = $c->stash->{filter};
  
  my $create_edit_criteria = {
    filter          => $filter,
    name            => $c->request->parameters->{name},
    player_types    => $c->request->parameters->{player_type},
    criteria_field  => $c->request->parameters->{criteria_field},
    operator        => $c->request->parameters->{operator},
    criteria        => $c->request->parameters->{criteria},
    criteria_type   => $c->request->parameters->{criteria_type},
  };
  
  # If we're creating a non-public filter, we need to pass the user in.
  # This is only done at creation; the 'public' status of the filter cannot be altered.
  $create_edit_criteria->{user} = $c->user if $action eq "create" and $c->user_exists and !$c->request->parameters->{public};
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $details = $c->model("DB::AverageFilter")->create_or_edit($action, $create_edit_criteria, $c);
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{name}           = $c->request->parameters->{name};
    $c->flash->{criteria_field} = $c->request->parameters->{criteria_field};
    $c->flash->{operator}       = $c->request->parameters->{operator};
    $c->flash->{criteria}       = $c->request->parameters->{criteria};
    $c->flash->{criteria_type}  = $c->request->parameters->{criteria_type};
    
    # Get the player types, turn it into an array if it's not already
    my $player_types = $c->request->parameters->{player_type};
    $player_types = [$player_types] unless ref( $player_types ) eq "ARRAY";
    
    foreach my $player_type ( @{ $player_types } ) {
      if ( $player_type eq "active" ) {
        $c->flash->{show_active} = 1;
      } elsif ( $player_type eq "loan" ) {
        $c->flash->{show_loan} = 1;
      } elsif ( $player_type eq "inactive" ) {
        $c->flash->{show_inactive} = 1;
      }
    }
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/league-averages/filters/create",
                          {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      $redirect_uri = $c->uri_for_action("/league-averages/filters/edit", [ $filter->url_key ],
                          {mid => $c->set_status_msg( {error => $error} ) });
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $filter = $details->{filter};
    my $encoded_name = encode_entities( $filter->name );
    my $action_description = ( $action eq "create" ) ? $c->maketext("admin.message.created") : $c->maketext("admin.message.edited");
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["average-filter", $action, {id => $filter->id}, $filter->name] );
    $c->response->redirect( $c->uri_for_action("/league-averages/filters/view", [$filter->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $action_description )}  ) }) );
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
