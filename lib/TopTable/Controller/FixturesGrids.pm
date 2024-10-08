package TopTable::Controller::FixturesGrids;
use Moose;
use namespace::autoclean;
use Data::Printer;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered fixtures-grids, so the URLs start /fixtures-grids.
__PACKAGE__->config(namespace => "fixtures-grids");

=head1 NAME

TopTable::Controller::FixturesGrid - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller for fixtures grids; handles viewing, editing, creating and deleting, as well as assigning teams to their position numbers, setting the matches per week and creating the fixtures themselves.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.fixtures-grid")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    # Listing
    path => $c->uri_for("/fixtures-grids"),
    label => $c->maketext("menu.text.fixtures-grid"),
  });
}

=head2 base

Chain base for getting the fixtures grid ID and checking it.

=cut

sub base :Chained("/") :PathPart("fixtures-grids") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $grid = $c->model("DB::FixturesGrid")->find_id_or_url_key($id_or_key);
  
  if ( defined($grid) ) {
    # Encode the name for future use later in the chain (saves encoding multiple times, which is expensive)
    my $enc_name = encode_entities($grid->name);
    
    $c->stash({
      grid => $grid,
      enc_name => $enc_name,
    });
    
    # Push the list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs} }, {
      # View page (current season)
      path => $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}


=head2 base_list

Chain base for the list of fixtures grids.  Matches /fixtures-grids

=cut

sub base_list :Chained("/") :PathPart("fixtures-grids") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures-grids"), 1]);
  
  # Check the authorisation to edit fixtures so we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( fixtures_edit fixtures_delete fixtures_create)], "", 0]);
  
  $c->add_status_messages({info => $c->maketext("fixtures-grids.info")});
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.fixtures-grids.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the fixtures grids on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/list_first_page")});
  $c->detach("retrieve_paged", [1]);
}

=head2 list_specific_page

List the fixtures grids on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for fixtures grids with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $grids = $c->model("DB::FixturesGrid")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $grids->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/fixtures-grids/list_first_page",
    specific_page_action => "/fixtures-grids/list_specific_page",
    current_page => $page_number
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-grids/list.ttkt",
    view_online_display => "Viewing fixtures grids",
    view_online_link => 1,
    grids => $grids,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  # Check that we are authorised to view fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures-grids"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( fixtures_edit fixtures_delete ) ], "", 0]);
}


=head2 view_current_season

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      view_online_display => sprintf("Viewing %s", $enc_name),
      view_online_link => 1,
      page_description => $c->maketext("description.fixtures-grids.view-current", $enc_name, $site_name),
    });
  } else {
    $c->stash({
      view_online_display => sprintf("Viewing %s", $enc_name),
      view_online_link => 1,
    });
  }
  
  # Finalise the view routine
  $c->forward("view_finalise");
}

=head2 view_specific_season

View a fixtures grid with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $grid = $c->stash->{grid};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to view teams
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures-grids"), 1]);
    
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      view_online_display => sprintf("Viewing %s for %s", $grid->name, $season->name),
      view_online_link => 1,
      page_description => $c->maketext("description.fixtures-grids.view-specific", $enc_name, $site_name, $enc_season_name),
    });
    
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/fixtures-grids/view_seasons_first_page", [$grid->url_key]),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/fixtures-grids/view_specific_season", [$grid->url_key, $season->url_key]),
      label => $enc_season_name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("seasons.invalid-find-current", $season_id_or_url_key)})}));
    $c->detach;
    return;
  }
  
  # Finalise the view routine
  $c->forward("view_finalise");
}



=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $season = $c->stash->{season};
  my $enc_name = $c->stash->{enc_name};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists($c->stash->{delete_screen}) ) {
    # Push edit link if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_name),
      link_uri => $c->uri_for_action("/fixtures-grids/edit", [$grid->url_key]),
    }) if $c->stash->{authorisation}{fixtures_edit};
    
    # Set matches link
    if ( $c->stash->{authorisation}{fixtures_edit} ) {
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/edit-table-32.png"),
        text => $c->maketext("admin.fixtures-grid.set-matches", $enc_name),
        link_uri => $c->uri_for_action("/fixtures-grids/matches", [$grid->url_key]),
      });
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/reorder-32.png"),
        text => $c->maketext("admin.fixtures-grid.set-positions", $enc_name),
        link_uri => $c->uri_for_action("/fixtures-grids/teams", [$grid->url_key]),
      }) if !$season->complete and $grid->used_in_league_season($season);
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/fixtures-32.png"),
        text => $c->maketext("admin.fixtures-grid.create-fixtures", $enc_name),
        link_uri => $c->uri_for_action("/fixtures-grids/create_fixtures", [$grid->url_key]),
      }) if !$season->complete and $grid->can_create_matches;
      
      push(@title_links, {
        image_uri => $c->uri_for("/static/images/icons/fixturesdel-32.png"),
        text => $c->maketext("admin.fixtures-grid.delete-fixtures", $enc_name),
        link_uri => $c->uri_for_action("/fixtures-grids/delete_fixtures", [$grid->url_key]),
      }) if !$season->complete and $grid->can_delete_matches;
    }
    
    # Push a delete link if we're authorised and the grid can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/fixtures-grids/delete", [$grid->url_key]),
    }) if $c->stash->{authorisation}{fixtures_delete} and $grid->can_delete;
  }
  
  my $canonical_uri = ( defined($season) and $season->complete )
    ? $c->uri_for_action("/fixtures-grids/view_specific_season", [$grid->url_key, $season->url_key])
    : $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key]);
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-grids/view.ttkt",
    title_links => \@title_links,
    subtitle1 => $enc_name,
    weeks => scalar $grid->get_match_templates,
    divisions => scalar $grid->get_divisions($season),
    season => $season,
    view_online_display => sprintf("Viewing %s", $grid->name),
    view_online_link => 1,
    canonical_uri => $canonical_uri,
    seasons => $grid->get_seasons->count,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      #$c->uri_for("/static/script/standard/responsive-tabs.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/fixtures-grids/view.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
}


=head2 view_seasons

Retrieve and display a list of seasons that this fixtures grid has been used for.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template => "html/fixtures-grids/list-seasons.ttkt",
    subtitle1 => $enc_name,
    page_description => $c->maketext("description.fixtures-grids.list-seasons", $enc_name, $site_name),
    external_scripts => [$c->uri_for("/static/script/standard/option-list.js")],
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/view_seasons_first_page", [$grid->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the seasons on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/view_seasons_first_page", [$grid->url_key])});
  $c->detach("retrieve_paged_seasons", [1]);
}

=head2 view_seasons_specific_page

List the seasonss on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $grid = $c->stash->{grid};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/view_seasons_first_page", [$grid->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/view_seasons_specific_page", [$grid->url_key, $page_number])});
  }
  
  $c->stash({canonical_uri => $c->uri_for_action("/fixtures-grids/view_seasons_specific_page", [$page_number])});
  $c->detach("retrieve_paged_seasons", [$page_number]);
}

=head2 retrieve_paged_seasons

Performs the lookups for seasons with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $grid = $c->stash->{grid};
  
  my $seasons = $c->model("DB::Season")->page_records({
    fixutres_grid => $grid,
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/fixtures-grids/view_seasons_first_page",
    specific_page_action => "/fixtures-grids/view_seasons_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/fixtures-grids/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $grid->name ),
    view_online_link => 1,
    seasons => $seasons,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 create

Display a form to collect information for creating a fixtures grid.

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_create", $c->maketext("user.auth.create-fixtures-grids"), 1]);
  
  # Get venues and people to list
  $c->stash({
    template => "html/fixtures-grids/create-edit.ttkt",
    form_action => $c->uri_for("do-create"),
    external_scripts => [
      $c->uri_for("/static/script/fixtures-grids/create-edit.js"),
    ],
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating fixtures grids",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/fixtures-grids/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form to with the existing information for editing a fixtures grid.

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->res->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->res->header("Pragma" => "no-cache");
  $c->res->header("Expires" => 0);
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  
  # Get venues to list
  $c->stash({
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("admin.edit"),
    template => "html/fixtures-grids/create-edit.ttkt",
    form_action => $c->uri_for_action("/fixtures-grids/do_edit", [$grid->url_key]),
    external_scripts => [
      $c->uri_for("/static/script/fixtures-grids/create-edit.js"),
    ],
    view_online_display => sprintf("Editing %s", $enc_name),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/edit", [$grid->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form for deleting a fixtures grid.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_delete", $c->maketext("user.auth.delete-fixtures-grids"), 1]);
  
  unless ( $grid->can_delete ) {
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.delete.error.cant-delete", $grid->name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/fixtures-grids/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $enc_name),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/delete", [$grid->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process a submitted form to create a fixtures grid.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_create", $c->maketext("user.auth.create-fixtures-grids"), 1]);
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a fixtures grid.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion form.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $grid_name = $grid->name; # Unavailable after we delete, so save it away now
  
  # Check that we are authorised to delete grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_delete", $c->maketext("user.auth.delete-fixtures-grids"), 1]);
  
  # Hand off to the model to do some checking
  #my $deletion_result = $c->model("DB::Venue")->check_and_delete( $venue );
  my $response = $grid->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/fixtures-grids", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["fixtures-grid", "delete", {id => undef}, $grid_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
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
  my $grid = $c->stash->{grid};
  my @field_names = qw( name maximum_teams fixtures_repeated );
  
  # The rest of the error checking is done in the Club model
  my $response = $c->model("DB::FixturesGrid")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    grid => $grid, # This will be undef if we're creating.
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form
  });
  
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $grid = $response->{grid};
    $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["fixtures-grid", $action, {id => $grid->id}, $grid->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/fixtures-grids/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/fixtures-grids/edit", [$grid->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{$_} = $response->{fields}{$_} foreach @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 matches

Display a form to change the grid week details.

=cut

sub matches :Chained("base") :PathPart("matches") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  
  # Check the matches for this grid can be set
  if ( !$grid->can_edit_matches ) {
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.form.matches.cannot-edit")})}));
    $c->detach;
    return;
  }
  
  # Get venues to list
  $c->stash({
    template => "html/fixtures-grids/matches.ttkt",
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("fixtures-grids.matches"),
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/fixtures-grids/matches.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action => $c->uri_for_action("/fixtures-grids/set_matches", [$grid->url_key]),
    view_online_display => sprintf("Configuring weeks for %s", $enc_name),
    view_online_link => 0,
    weeks => scalar $grid->fixtures_grid_weeks,
    grid_team_types => [$c->model("DB::LookupGridTeamType")->all_types],
    flashed_weeks => $c->flash->{weeks},
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/matches", [$grid->url_key]),
    label => $c->maketext("fixtures-grids.matches"),
  });
}

=head2 set_matches

Process the form to change the team matches per week for a fixtures grid.

=cut

sub set_matches :Chained("base") :PathPart("set-matches") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  
  # Loop through and get our home / away hash keys for each match
  my %match_teams;
  foreach my $key ( keys %{$c->req->params} ) {
    # Check the key matches the name we're looking for: "week_[number]_match_[number]_home" or "week_[number]_match_[number]_away"
    # The resulting hash is made up of $fixtures_weeks{$week_number}{$match_number}{home} or $fixtures_weeks{$week_number}{$match_number}{away}
    # The value is a hashref consisting of team_grid_type (grid type ID - so 'static' or one of the dynamic types) and competitor (team number in the grid,
    # or match number from the previous round)
    
    # Split the value passed in into grid team type (first part before the _) and team / match number (second part)
    $match_teams{$1}{$2}{$3} = $c->req->params->{$key} if $key =~ /^week_(\d{1,2})_match_(\d{1,2})_(home|away)$/;
  }
  
  my $response = $grid->set_matches({
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    repeat_fixtures => $c->req->params->{repeat_fixtures},
    match_teams => \%match_teams,
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
    $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["fixtures-grid", "matches", {id => $grid->id}, $grid->name]);
  } else {
    # Not complete - redirect back to the matches page
    $redirect_uri = $c->uri_for_action("/fixtures-grids/matches", [$grid->url_key], {mid => $mid});
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash({
      repeat_fixtures => $response->{fields}{repeat_fixtures},
      weeks => $response->{fields}{weeks},
    });
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 teams

Display a form to change the team allocations for each division assigned to that grid.

=cut

sub teams :Chained("base") :PathPart("teams") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  
  # Get the current season, so we know which teams and divisions we have.
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->forward("TopTable::Controller::Users", "check_authorisation", ["season_create", "", 0]);
    
    # Generate error message
    my $mid = $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.no-current-season")});
    
    # Link to fixtures grid view or season create, depending on permissions
    my $redirect_uri = $c->stash->{authorisation}{season_create}
      ? $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid})
      : $c->uri_for("/seasons/create", {mid => $mid});
    
    $c->response->redirect($redirect_uri);
    $c->detach;
    return;
  }
  
  # Check the season hasn't had matches created already
  if ( $c->model("DB::TeamMatch")->season_matches($current_season, {grid => $grid})->count > 0 ) {
    # Error, matches set already
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.matches-already-set")})}));
    $c->detach;
    return;
  }
  
  unless ( $grid->used_in_league_season($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.no-divisions-using")})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/fixtures-grids/teams.ttkt",
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("fixtures-grids.allocate-teams"),
    external_scripts => [
      $c->uri_for("/static/script/fixtures-grids/teams.js"),
    ],
    form_action => $c->uri_for_action("/fixtures-grids/set_teams", [$grid->url_key]),
    view_online_display => "Allocating teams for fixtures grid " . $grid->name,
    view_online_link => 0,
    divisions => [$c->model("DB::DivisionSeason")->divisions_and_teams_in_season_by_grid_position($current_season, $grid)],
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/teams", [$grid->url_key]),
    label => $c->maketext("fixtures-grids.teams"),
  });
}

=head2 set_teams

Process the form to change the team allocations for each division assigned to that grid.

=cut

sub set_teams :Chained("base") :PathPart("set-teams") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_edit", $c->maketext("user.auth.edit-fixtures-grids"), 1]);
  
  # Get the current season, so we know which teams and divisions we have.
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Check the season hasn't had matches created already
  if ( $c->model("DB::TeamMatch")->season_matches($current_season, {grid => $grid})->count > 0 ) {
    # Error, matches set already
    $c->response->redirect($c->uri_for_action("/fixtures_grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.matches-already-set")})}));
    $c->detach;
    return;
  }
  
  unless ( $grid->used_in_league_season($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.teams.error.no-divisions-using")})}));
    $c->detach;
    return;
  }
  
  # Loop through all the request parameters and get all the divisions
  my %divisions;
  foreach my $key ( keys %{ $c->req->params } ) {
    $divisions{$key} = [split(",", $c->req->params->{$key})] if $key =~ /division-positions-\d+/;
  }
  
  my $response = $grid->set_teams({divisions => \%divisions});
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["fixtures-grid", "teams", {id => $grid->id}, $grid->name]);
  } else {
    # Not complete - redirect back to the matches page
    if ( $response->{can_complete} ) {
      # The errors given *don't* prevent us from setting teams for this grid, so redirect back to the form with the flashed values
      $redirect_uri = $c->uri_for_action("/fixtures-grids/teams", [$grid->url_key], {mid => $mid});
      
      # Flash the entered values we've got so we can set them into the form
      $c->flash({
        repeat_fixtures => $response->{fields}{repeat_fixtures},
        weeks => $response->{fields}{weeks},
      });
    } else {
      # The errors given *do* prevent us from setting teams for this grid, so redirect back to the grid view page
      $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
    }
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 create_fixtures

Display a list of teams and their grid positions along with a list of weeks with an actual week in the season that it will correspond to; the submitted form will be processed and fixtures created in the relevant weeks.

=cut

sub create_fixtures :Chained("base") :PathPart("create-fixtures") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create fixtures grids
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_create", $c->maketext("user.auth.create-fixtures"), 1]);
  
  # Get the current season, so we know which teams and divisions we have.
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect( $c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => "fixtures-grids.form.create-fixtures.error.no-current-season"})}));
    $c->detach;
    return;
  }
  
  # Check the season hasn't had matches created already.
  if ( $c->model("DB::TeamMatch")->season_matches($current_season, {grid => $grid})->count > 0 ) {
    # Error, matches set already
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg({error => "fixtures-grids.form.create-fixtures.error.fixtures-already-exist"})}));
    $c->detach;
    return;
  }
  
  if ( $c->model("DB::FixturesGrid")->incomplete_matches($grid)->count > 0 ) {
    # Error, matches set already
    $c->response->redirect($c->uri_for_action("/fixtures-grids/matches", [$grid->url_key],
                                {mid => $c->set_status_msg({error => "fixtures-grids.form.create-fixtures.error.matches-incomplete"})}));
    $c->detach;
    return;
  }
  
  # Get the list of teams who've entered - we need to make sure everything's been completed and ready for matches to be created.
  if ( $c->model("DB::FixturesGrid")->incomplete_grid_positions($grid, $current_season) > 0 ) {
    # Error, team positions incomplete
    $c->response->redirect( $c->uri_for_action("/fixtures-grids/teams", [$grid->url_key],
                                {mid => $c->set_status_msg( {error => "fixtures-grids.form.create-fixtures.error.teams-incomplete"})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/fixtures-grids/create-fixtures.ttkt",
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("fixtures-grids.create-fixtures"),
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/fixtures-grids/create-fixtures.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for_action("/fixtures-grids/do_create_fixtures", [$grid->url_key]),
    view_online_display => "Creating fixtures for grid " . $grid->name,
    view_online_link => 0,
    grid_weeks => [$grid->rounds],
    season_weeks => [$current_season->weeks],
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/create_fixtures", [$grid->url_key]),
    label => $c->maketext("fixtures-grids.create-fixtures"),
  });
  
  # Append a warning message that will always appear on this page
  $c->add_status_messages({warning => $c->maketext("fixtures-grids.form.create-fixtures.warning")});
}

=head2 do_create_fixtures

Process the form to change the team allocations for each division assigned to that grid.

=cut

sub do_create_fixtures :Chained("base") :PathPart("do-create-fixtures") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  # Check that we are authorised to create fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_create", $c->maketext("user.auth.create-fixtures"), 1]);
  
  # Check we have a current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => "fixtures-grids.form.create-fixtures.error.no-current-season"})}));
    $c->detach;
    return;
  }
  
  # Check the season hasn't had matches created already.
  if ( $c->model("DB::TeamMatch")->season_matches($current_season, {grid => $grid})->count > 0 ) {
    # Error, matches set already
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => "fixtures-grids.form.create-fixtures.error.fixtures-already-exist"})}));
    $c->detach;
    return;
  }
  
  # Get all the weeks submitted
  my %weeks = ();
  foreach ( keys %{$c->req->params } ) {
    $weeks{$_} = $c->req->params->{$_} if m/^week_\d{1,2}$/;
  }
  
  my $response = $grid->create_matches(undef, {
    weeks => \%weeks,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); }
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
    $redirect_uri = $c->uri_for_action("/fixtures-results/root_current_season", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "create", $response->{match_ids}, $response->{match_names}]);
  } else {
    # Not complete - redirect back to the matches page
    if ( $response->{can_complete} ) {
      # The errors given *don't* prevent us from setting teams for this grid, so redirect back to the form with the flashed values
      $redirect_uri = $c->uri_for_action("/fixtures-grids/create_fixtures", [$grid->url_key], {mid => $mid});
      
      # Flash the entered values we've got so we can set them into the form
      $c->flash({
        repeat_fixtures => $response->{fields}{repeat_fixtures},
        weeks => $response->{fields}{weeks},
      });
    } else {
      # The errors given *do* prevent us from setting teams for this grid, so redirect back to the grid view page
      $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
    }
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 delete_fixtures

Displays the form to delete fixtures that have been created for the grid in the current season.

=cut

sub delete_fixtures :Chained("base") :PathPart("delete-fixtures") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  
  # Check that we are authorised to delete fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_delete", $c->maketext("user.auth.delete-fixtures"), 1]);
  
  unless ( $grid->can_delete_matches ) {
    $c->response->redirect($c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("fixtures-grids.form.delete-fixtures.error.cant-delete", $grid->name)})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/fixtures-grids/delete-fixtures.ttkt",
    subtitle2 => $grid->name,
    subtitle3 => $c->maketext("fixtures-grids.delete-fixtures"),
    form_action => $c->uri_for_action("/fixtures-grids/do_delete_fixtures", [$grid->url_key]),
    view_online_display => sprintf( "Deleting fixtures for grid %s", $grid->name ),
    view_online_link => 0,
  });
  
  $c->add_status_messages({warning => $c->maketext("fixtures-grids.form.delete-fixtures.warning")});
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/fixtures-grids/delete_fixtures", [$grid->url_key]),
    label => $c->maketext("fixtures-grids.delete-fixtures"),
  });
}

=head2 do_delete_fixtures

Processes the deletion of fixtures that have been created for the grid in the current season.

=cut

sub do_delete_fixtures :Chained("base") :PathPart("do-delete-fixtures") :Args(0) {
  my ( $self, $c ) = @_;
  my $grid = $c->stash->{grid};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete fixtures
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["fixtures_delete", $c->maketext("user.auth.delete-fixtures"), 1]);
  
  my $response = $grid->delete_matches;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri = $c->uri_for_action("/fixtures-grids/view_current_season", [$grid->url_key], {mid => $mid});
  
  
  # If it was completed, we log an event
  $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team-match", "delete", $response->{match_ids}, $response->{match_names}]) if $response->{completed};
  
  # Redirect
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view fixtures grids
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["fixtures_view", $c->maketext("user.auth.view-fixtures-grids"), 1] );
  
  $c->stash({
    db_resultset => "FixturesGrid",
    query_params => {q => $c->req->params->{q}},
    view_action => "/fixtures-grids/view_current_season",
    search_action => "/fixtures-grids/search",
    placeholder => $c->maketext("search.form.placeholder", $c->maketext("object.plural.fixtures-grids")),
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
