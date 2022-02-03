package TopTable::Controller::Seasons;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper::Concise;
use DateTime::TimeZone;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Season - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.seasons")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/seasons"),
    label => $c->maketext("menu.text.seasons"),
  });
}

=head2 base

Chain base for getting the season ID and checking it.

=cut

sub base :Chained("/") :PathPart("seasons") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $season = $c->model("DB::Season")->find_id_or_url_key( $id_or_key );
  
  if ( defined($season) ) {
    my $encoded_name = encode_entities( $season->name );
    
    $c->stash({
      season        => $season,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/seasons/view", [$season->url_key]),
      label => $season->name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of seasons.  Matches /seasons

=cut

sub base_list :Chained("/") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check the authorisation to edit seasons we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( season_edit season_delete season_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description  => $c->maketext("description.seasons.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the seasons on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/seasons/list_first_page")});
}

=head2 list_specific_page

List the seasons on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/seasons/view_seasons_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/seasons/view_seasons_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for seasons with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $seasons = $c->model("DB::Season")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/seasons/list_first_page",
    specific_page_action  => "/seasons/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/seasons/list.ttkt",
    view_online_display => "Viewing seasons",
    view_online_link    => 1,
    seasons             => $seasons,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $season        = $c->stash->{season};
  my $encoded_name  = $c->stash->{encoded_name};
  my $site_name     = $c->stash->{encoded_site_name};
  my $edit_teams_allowed;
  
  # Check that we are authorised to view seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_view", $c->maketext("user.auth.view-seasons"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( season_edit season_delete ) ], "", 0] );
  
  # Get the divisions that are being used for this season
  my $divisions = [$c->model("DB::Division")->divisions_in_season( $season )];
    
  # To find out if we can show the 'edit entered teams' link, we need to know:
  #  * If this is the current season
  #  * If the matches for the season have yet to be created
  # If both of the above are true (and the user is authorised to edit seasons) we will display the link.
  $edit_teams_allowed = 1 if $c->model("DB::TeamMatch")->season_matches( $season )->count == 0 and !$season->complete;
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit link if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.edit-object", $encoded_name),
      link_uri  => $c->uri_for_action("/seasons/edit", [$season->url_key]),
    }) if $c->stash->{authorisation}{season_edit} and !$season->complete;
    
    # Push a delete link if we're authorised and the club can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0043-Safe-icon-32.png"),
      text      => $c->maketext("admin.archive-object", $encoded_name),
      link_uri  => $c->uri_for_action("/seasons/archive", [$season->url_key]),
    }) if $c->stash->{authorisation}{season_edit} and $season->can_complete;
    
    # Push a delete link if we're authorised and the club can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $encoded_name),
      link_uri  => $c->uri_for_action("/seasons/delete", [$season->url_key]),
    }) if $c->stash->{authorisation}{season_delete} and $season->can_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/seasons/view.ttkt",
    title_links         => \@title_links,
    subtitle1           => $encoded_name,
    view_online_display => sprintf( "Viewing %s", $encoded_name ),
    view_online_link    => 1,
    divisions           => $divisions,
    edit_teams_allowed  => $edit_teams_allowed,
    canonical_uri       => $c->uri_for_action("/seasons/view", [$season->url_key]),
    page_description    => $c->maketext("description.seasons.view", $encoded_name, $site_name),
    external_scripts    => [
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/seasons/view.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    
    # Statistics
    clubs                         => $season->all_clubs->count,
    teams                         => $season->all_teams->count,
    players                       => $season->all_players->count,
    league_matches                => $season->league_matches->count,
    rearranged_matches            => $season->league_matches({mode => "rearranged"})->count,
    cancelled_matches             => $season->league_matches({mode => "cancelled"})->count,
    matches_with_incomplete_teams => $season->league_matches({mode => "incomplete-teams"})->count,
    matches_with_loan_players     => $season->league_matches({mode => "loan-players"})->count,
  });
}

=head2 create

Display a form to collect information for creating a season.

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_create", $c->maketext("user.auth.create-seasons"), 1] );
  
  # Find an incomplete season; if there is one, we can' create a new one
  my $incomplete_season = $c->model("DB::Season")->get_current;
  
  if ( defined($incomplete_season) ) {
    # Now redirect to view the season
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$incomplete_season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.current-season-exists")} ) }) );
    $c->detach;
    return;
  } else {
    # Find all the divisions to list in select boxes
    my $divisions = [ $c->model("DB::Division")->all_divisions ];
    
    # Create an empty division if there are none, with a display order of 1
    $divisions = [{rank  => 1,}] if scalar @{ $divisions } == 0;
    
    # Check we have all the information we need
    my $match_templates   = [$c->model("DB::TemplateMatchTeam")->all_templates];
    my $ranking_templates = [$c->model("DB::TemplateLeagueTableRanking")->all_templates];
    my $fixtures_grids    = [$c->model("DB::FixturesGrid")->all_grids];
    
    # First check we have some individual match templates - we need these in order to create
    # a team match template, which is required in the setup of a season.
    my $individual_match_templates = $c->model("DB::TemplateMatchIndividual")->search->count;
    
    if ( !$individual_match_templates ) {
        $c->response->redirect( $c->uri_for("/templates/match/individual/create",
                                    {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.no-individual-match-templates") } ) }) );
        $c->detach;
        return;
    } elsif ( !scalar( @{$match_templates} ) ) {
      $c->response->redirect( $c->uri_for("/templates/match/team/create",
                                  {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.no-team-match-templates")} ) }) );
      $c->detach;
      return;
    } elsif ( !scalar( @{$ranking_templates} ) ) {
      $c->response->redirect( $c->uri_for("/templates/league-table-ranking/create",
                                  {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.no-ranking-templates")} ) }) );
      $c->detach;
      return;
    } elsif ( !scalar( @{$fixtures_grids} ) ) {
      $c->response->redirect( $c->uri_for("/fixtures-grids/create",
                                  {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.no-fixtures-grids")} ) }) );
      $c->detach;
      return;
    }
    
    # Get the timezone categories, then map each timezone in that category with the category as the key to a hashref, value is an arrayref of countries
    my @tz_categories = DateTime::TimeZone->categories;
    my $timezones = {};
    $timezones->{$_} = DateTime::TimeZone->names_in_category( $_ ) foreach @tz_categories;
    
    # Stash everything we need in the template
    $c->stash({
      template            => "html/seasons/create-edit.ttkt",
      external_scripts    => [
        $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
        $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
        $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
        $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
        $c->uri_for("/static/script/standard/chosen.js"),
        $c->uri_for("/static/script/standard/prettycheckable.js"),
        $c->uri_for_action("/seasons/create_edit_js"),
      ],
      external_styles     => [
        $c->uri_for("/static/css/chosen/chosen.min.css"),
        $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      ],
      match_templates     => $match_templates,
      ranking_templates   => $ranking_templates,
      fixtures_grids      => $fixtures_grids,
      divisions           => $divisions,
      form_action         => $c->uri_for("do-create"),
      action              => "create",
      subtitle2           => "Create",
      view_online_display => "Creating seasons",
      view_online_link    => 0,
      timezones           => $timezones,
    });
  }
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/seasons/create"),
    label => $c->maketext("admin.create"),
  })
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
  
  # Editing is restricted to certain fields mid-season.
  my $restricted_edit;
  
  if ( $season->complete ) {
    # Season is complete, unable to edit.
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.edit-season-complete")} ) }) );
    $c->detach;
    return;
  } else {
    # Don't cache this page.
    $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
    $c->response->header("Pragma"         => "no-cache");
    $c->response->header("Expires"        => 0);
    
    # Find out if we can edit the dates for this season; otherwise we'll have to disable the date inputs
    my $league_matches = $c->model("DB::TeamMatch")->season_matches( $season )->count;
    
    # Check if we have any rows
    $restricted_edit = 1 if $league_matches > 0;
    
    # Find all the divisions to list in select boxes
    my $divisions = [ $c->model("DB::Division")->all_divisions ];
    
    # Create an empty division if there are none, with a display order of 1
    $divisions = [{rank  => 1,}] if scalar @{ $divisions } == 0;
    
    # Get the timezone categories, then map each timezone in that category with the category as the key to a hashref, value is an arrayref of countries
    my @tz_categories = DateTime::TimeZone->categories;
    my $timezones = {};
    $timezones->{$_} = DateTime::TimeZone->names_in_category( $_ ) foreach @tz_categories;
    
    # Stash values for the form
    $c->stash({
      template            => "html/seasons/create-edit.ttkt",
      external_scripts    => [
        $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
        $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
        $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
        $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
        $c->uri_for("/static/script/standard/chosen.js"),
        $c->uri_for("/static/script/standard/prettycheckable.js"),
        $c->uri_for_action("/seasons/create_edit_js"),
      ],
      external_styles     => [
        $c->uri_for("/static/css/chosen/chosen.min.css"),
        $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      ],
      match_templates     => [$c->model("DB::TemplateMatchTeam")->all_templates],
      ranking_templates   => [$c->model("DB::TemplateLeagueTableRanking")->all_templates],
      divisions           => $divisions,
      fixtures_grids      => [$c->model("DB::FixturesGrid")->all_grids],
      form_action         => $c->uri_for_action("/seasons/do_edit", [$season->url_key]),
      action              => "edit",
      view_online_display => "Editing " . $c->stash->{season}->name,
      view_online_link    => 0,
      restricted_edit     => $restricted_edit,
      timezones           => $timezones,
      subtitle2           => $c->maketext("admin.edit")
    });
    
    # Flash the current club's data to display
    # Split the time up.
    my @time_bits = split(":", $season->default_match_start);
    
    $c->flash->{start_date}               = $season->start_date->dmy("/") unless $c->flash->{start_date};
    $c->flash->{end_date}                 = $season->end_date->dmy("/")   unless $c->flash->{end_date};
    $c->flash->{start_hour}               = $time_bits[0]                 unless $c->flash->{start_hour};
    $c->flash->{start_minute}             = $time_bits[1]                 unless $c->flash->{start_minute};
    
    # Flash all the division fields unless we've flashed it all already
    if ( scalar( @{ $divisions } ) and !exists( $c->flash->{divisions} ) ) {
      $c->flash->{divisions} = [];
      foreach my $division ( @{ $divisions } ) {
        my $division_season = $division->find_related("division_seasons", {season => $season->id}) if defined( $division ) and ref( $division ) ne "HASH";
        
        # Flash the divisions
        # Make sure we set up a blank flashed value if the grid wasn't specified, otherwise we'll have the wrong
        # number of elements in that array
        my $use_division            = ( defined( $division_season ) ) ? 1 : 0;
        my $flash_grid              = ( defined( $division_season ) ) ? $division_season->fixtures_grid : undef;
        my $flash_match_template    = ( defined( $division_season ) ) ? $division_season->league_match_template : undef;
        my $flash_ranking_template  = ( defined( $division_season ) ) ? $division_season->league_table_ranking_template : undef;
        
        push( @{ $c->flash->{divisions} }, {
          use_division                  => $use_division,
          fixtures_grid                 => $flash_grid,
          league_match_template         => $flash_match_template,
          league_table_ranking_template => $flash_ranking_template,
        });
      }
    }
  }
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/seasons/edit", [$season->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 create_edit_js

Generate the external javascript file to use when editing or creating a seasons

=cut

sub create_edit_js :Path("create-edit.js") {
  my ( $self, $c ) = @_;
  
  # This will be a javascript file, not a HTML
  $c->response->headers->header("Content-type" => "text/javascript");
  
  # Stash no wrapper and the template
  $c->stash({
    template            => "scripts/seasons/create-edit.ttjs",
    no_wrapper          => 1,
    match_templates     => [$c->model("DB::TemplateMatchTeam")->all_templates],
    ranking_templates   => [$c->model("DB::TemplateLeagueTableRanking")->all_templates],
    fixtures_grids      => [$c->model("DB::FixturesGrid")->all_grids],
  });
  
  $c->detach( $c->view("HTML") );
}

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_delete", $c->maketext("user.auth.delete-seasons"), 1] );
  
  unless ( $season->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "seasons.delete.error.matches-exist", $season->name )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2           => "Delete",
    template            => "html/seasons/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $season->name ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/seasons/delete", [$season->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a season.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_create", $c->maketext("user.auth.create-seasons"), 1] );
  
  # Find an incomplete season; if there is one, we can' create a new one
  my $incomplete_season = $c->model("DB::Season")->get_current;
  
  if ( defined( $incomplete_season ) ) {
    # Now redirect to view the season
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$incomplete_season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.create.error.incomplete-season-exists")} ) }) );
    $c->detach;
    return;
  } else {
    $c->detach( "setup_season_and_divisions", ["create"] );
  }
}

=head2 do_edit

Process the form for editing an individual match template.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c, $template_id ) = @_;
  my ( $season, $divisions );
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
  $c->detach( "setup_season_and_divisions", ["edit"] );
}

=head2 do_delete

Processes the season deletion after the user has submitted the form.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $season      = $c->stash->{season};
  my $season_name = $season->name;
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_delete", $c->maketext("user.auth.delete-seasons"), 1] );
  
  my $error = $season->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/seasons/view", [ $season->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["season", "delete", {id => undef}, $season_name] );
    $c->response->redirect( $c->uri_for("/seasons",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $season_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_season_and_divisions

Take the entered season / division data from the create / edit form and put them into the database.

=cut

sub setup_season_and_divisions :Private {
  my ( $self, $c, $action ) = @_;
  my $season = $c->stash->{season};
  
  # Call the create / edit routine, which also does the error checking
  my $returned = $c->model("DB::Season")->create_or_edit($action, {
    season    => $season,
    language  => sub{ $c->maketext( @_ ); },
    logger    => sub{ my $level = shift; $c->log->$level( @_ ); },
    %{ $c->request->parameters },
  });
  
  my $warning = $c->build_message( $returned->{warning} ) if scalar( @{ $returned->{warning} } );
  if ( scalar( @{ $returned->{error} } ) ) {
    my $error   = $c->build_message( $returned->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    map {$c->flash->{$_} = $returned->{sanitised_fields}{$_} } %{ $returned->{sanitised_fields} };
    $c->flash->{divisions} = $returned->{divisions_sanitised_fields};
    
    my $message_texts = {error => $error};
    $message_texts->{warning} = $warning if defined( $warning );
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/seasons/create",
                                  {mid => $c->set_status_msg( $message_texts ) });
    } else {
      if ( defined( $returned->{season} ) ) {
        $redirect_uri = $c->uri_for_action("/seasons/edit", [ $returned->{season}->url_key ],
                                  {mid => $c->set_status_msg( $message_texts ) });
      } else {
        $redirect_uri = $c->uri_for("/seasons",
                                  {mid => $c->set_status_msg( $message_texts ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Log an event because the season has been created
    $season = $returned->{season} if exists( $returned->{season} );
    my $season_name = encode_entities( $season->name );
    
    # Prefix an explanation to the error message
    my $action_text = ( $action eq "edit" ) ? $c->maketext("admin.message.edited", $season->name) : $c->maketext("admin.message.created", $season_name);
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["season", $action, {id => $season->id}, $season_name] );
    
    my $message_texts = {};
    my $redirect_action;
    
    if ( defined( $warning ) ) {
      # Warnings, so redirect to the error page
      $message_texts->{warning} = sprintf( "%s\n\n%s", $c->maketext("seasons.form.success-divisions-errored", $season_name, $action_text), $warning );
      $redirect_action = "edit";
    } else {
      # No warnings, go to view page
      $message_texts->{success} = $c->maketext( "admin.forms.success", $season->name, $action_text );
      $redirect_action = "view";
      
      unless ( $returned->{restricted_edit} ) {
        # Loop through collecting the names and IDs for the event log
        my ( @division_ids, @division_names );
        
        foreach my $division_data ( @{ $returned->{divisions} } ) {
          $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["division", $division_data->{action}, {id => $division_data->{db}->id}, $division_data->{db}->name] );
        }
      }
    }
    
    # Redirect to the season view or edit page
    $c->response->redirect( $c->uri_for_action("/seasons/$redirect_action", [ $season->url_key ],
                                {mid => $c->set_status_msg( $message_texts ) }) );
    $c->detach;
    return;
  }
}

=head2 archive

Display a tick box to complete a season.  Warn that it can't be undone.

=cut

sub archive :Chained("base") :PathPart("archive") :Args(0) {
  my ( $self, $c ) = @_;
  my $season      = $c->stash->{season};
  my $season_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
  
  # Check we can complete the season - there is a result class method for this (can_complete), but it only gives a true or false value, so we need to
  # do manual checks if we want proper error messages.
  if ( $season->complete ) {
    $c->response->redirect( $c->uri_for("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "seasons.complete.error.season-complete", $season_name )} ) }) );
    $c->detach;
    return;
  }
  
  if ( $c->model("DB::TeamMatch")->incomplete_and_not_cancelled({season => $season})->count > 0 ) {
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "seasons.complete.error.matches-incomplete", $season_name )} ) }) );
    $c->detach;
    return;
  }
  
  $c->stash({
    template  => "html/seasons/complete.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action         => $c->uri_for_action("/seasons/do_archive", [$season->url_key]),
    subtitle2           => $c->maketext("seasons.complete"),
    view_online_display => "Completing a season",
    view_online_link    => 0,
  });
  
  $c->add_status_message( "warning", $c->maketext("seasons.complete.warning.standard") );
}

=head2 do_archive

Process the completion form.

=cut

sub do_archive :Chained("base") :PathPart("do-archive") :Args(0) {
  my ( $self, $c ) = @_;
  my $season      = $c->stash->{season};
  my $season_name = $c->stash->{encoded_name};
  my $complete    = $c->request->parameters->{complete};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
  
  if ( $complete ) {
    my $error = $season->check_and_complete({lang => sub{ $c->maketext( @_ ) } });
    
    if ( scalar( @{ $error } ) ) {
      # Errors, display them
      $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                  {mid => $c->set_status_msg( {error => $c->build_message( $error )} ) }) );
      $c->detach;
      return;
    } else {
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["season", "archive", {id => $season->id}, $season->name] );
      $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                  {mid => $c->set_status_msg( {success => $c->maketext( "seasons.complete.success", $season_name )} ) }) );
      $c->detach;
      return;
    }
  } else {
    # Not ticked - eventually we may uncomplete the season (if it was previously completed) here, but that will come later.
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {info => $c->maketext( "seasons.complete.info.not-ticked" )} ) }) );
    $c->detach;
    return;
  }
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_view", $c->maketext("user.auth.view-seasons"), 1] );
  
  my $q = $c->req->param( "q" ) || undef;
  
  $c->stash({
    db_resultset => "Season",
    query_params => {q => $q},
    view_action => "/seasons/view",
    search_action => "/seasons/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.seasons") ),
  });
  
  # Do the search
  $c->forward( "TopTable::Controller::Search", "do_search" );
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
