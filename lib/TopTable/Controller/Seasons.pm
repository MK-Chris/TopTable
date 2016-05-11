package TopTable::Controller::Seasons;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper;
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
  
  # Load the messages
  $c->load_status_msgs;
  
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
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_view", $c->maketext("user.auth.view-seasons"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( season_edit season_delete season_create) ], "", 0] );
  
  # Page description
  $c->stash({page_description => $c->maketext("description.seasons.list", $site_name)});
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/seasons/list_first_page")});
}

=head2 list_specific_page

List the clubs on the specified page.

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

Performs the lookups for clubs with the given page number.

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
  
  # Check that we are authorised to view clubs
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
    }) if $c->stash->{authorisation}{season_edit};
    
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
  
  # Editing is restricted to certain fields mid-season.
  my ( $restricted_edit );
  
  unless ( $season->complete ) {
    # Don't cache this page.
    $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
    $c->response->header("Pragma"         => "no-cache");
    $c->response->header("Expires"        => 0);
    
    # Check that we are authorised to create clubs
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
    
    # Find out if we can edit the dates for this season; otherwise we'll have to disable the date inputs
    my $league_matches = $c->model("DB::TeamMatch")->season_matches( $season )->count;
    
    # Check if we have any rows
    $restricted_edit = 1 if $league_matches > 0;
    
    # Find all the divisions to list in select boxes
    my $divisions = [ $c->model("DB::Division")->all_divisions( $season ) ];
    
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
      view_online_display => "Editing " . $c->stash->{season}->name,
      view_online_link    => 0,
      restricted_edit     => $restricted_edit,
      timezones           => $timezones,
    });
    
    # Flash the current club's data to display
    # Split the time up.
    my @time_bits = split(":", $season->default_match_start);
    
    $c->flash->{start_date}               = $season->start_date->dmy("/") unless $c->flash->{start_date};
    $c->flash->{end_date}                 = $season->end_date->dmy("/")   unless $c->flash->{end_date};
    $c->flash->{start_hour}               = $time_bits[0]                 unless $c->flash->{start_hour};
    $c->flash->{start_minute}             = $time_bits[1]                 unless $c->flash->{start_minute};
    
    # Flash all the division fields unless we've flashed it all already
    unless ( $c->flash->{use_division} ) {
      foreach my $division ( @{ $divisions } ) {
        my $division_season = $division->division_seasons->first;
        
        # Flash the divisions
        # Make sure we set up a blank flashed value if the grid wasn't specified, otherwise we'll have the wrong
        # number of elements in that array
        my $flash_grid              = ( defined( $division_season ) and defined( $division_season->fixtures_grid ) ) ? $division_season->fixtures_grid->id : "";
        my $flash_match_template    = ( defined( $division_season ) and defined( $division_season->league_match_template ) ) ? $division_season->league_match_template->id : "";
        my $flash_ranking_template  = ( defined( $division_season ) and defined( $division_season->league_table_ranking_template ) ) ? $division_season->league_table_ranking_template->id : "";
        push( @{ $c->flash->{use_division}            }, 1 ) if defined( $division_season );
        push( @{ $c->flash->{division_name}           }, $division->name );
        push( @{ $c->flash->{division_id}             }, $division->id );
        push( @{ $c->flash->{fixtures_grid}           }, $flash_grid );
        push( @{ $c->flash->{league_match_template}   }, $flash_match_template );
        push( @{ $c->flash->{league_ranking_template} }, $flash_ranking_template );
      }
    }
    
    $c->stash({subtitle2 => $c->maketext("admin.edit")});
  } else {
    # Season is complete, unable to edit.
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.error.edit-season-complete")} ) }) );
    $c->detach;
    return;
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
  my $divisions = [];
  my $season = $c->stash->{season};
  
  # Find out if we can edit the dates for this season; otherwise we'll have to disable the date inputs
  my $league_matches = ( defined( $season ) ) ? $c->model("DB::TeamMatch")->season_matches( $season )->count : 0;
  
  # Check if we have any rows
  my $restricted_edit = ( $league_matches ) ? 1 : 0;
  
  # Process the divisions - do that here so that we can flash them back if there are any errors doing the season creation.
  my ( $loop_end, $number_of_divisions );
  # Check if we have an array of values (multiple games) or not (just a single game).
  if ( ref($c->request->parameters->{division_name}) eq "ARRAY" ) {
    # Store the number of games we're trying to create
    $number_of_divisions = scalar @{ $c->request->parameters->{division_name} };
    $loop_end = $number_of_divisions - 1;
  } else {
    $number_of_divisions  = 1;
    $loop_end             = 0;
  }
  
  # Now loop through our divisions
  for my $i (0 .. $loop_end) {
    my $rank = $i + 1;
    
    # The first bit is easy; just take the entry from the original parameters
    # and assign it to the new destination.
    if ( $number_of_divisions == 1 ) {
      $divisions->[$i]{name}                    = $c->request->parameters->{division_name};
      
      # Check the external things are okay; templates, grids, etc.
      $divisions->[$i]{league_match_template}         = $c->model("DB::TemplateMatchTeam")->find( $c->request->parameters->{league_match_template} ) if $c->request->parameters->{league_match_template};
      $divisions->[$i]{league_table_ranking_template} = $c->model("DB::TemplateLeagueTableRanking")->find( $c->request->parameters->{league_table_ranking_template} ) if $c->request->parameters->{league_table_ranking_template};
      $divisions->[$i]{fixtures_grid}                 = $c->model("DB::FixturesGrid")->find_with_weeks( $c->request->parameters->{fixtures_grid} ) if $c->request->parameters->{fixtures_grid};
    } else {
      $divisions->[$i]{name}                          = $c->request->parameters->{division_name}[$i];
      $divisions->[$i]{league_match_template}         = $c->model("DB::TemplateMatchTeam")->find( $c->request->parameters->{league_match_template}[$i] ) if $c->request->parameters->{league_match_template}[$i];
      $divisions->[$i]{league_table_ranking_template} = $c->model("DB::TemplateLeagueTableRanking")->find( $c->request->parameters->{league_table_ranking_template}[$i] ) if $c->request->parameters->{league_table_ranking_template}[$i];
      $divisions->[$i]{fixtures_grid}                 = $c->model("DB::FixturesGrid")->find_with_weeks( $c->request->parameters->{fixtures_grid}[$i] ) if $c->request->parameters->{fixtures_grid}[$i];
    }
    
    # Store the ID if it's numeric and the database object that corresponds to that
    $divisions->[$i]{id} = $c->request->parameters->{"division_id" . $rank} if $c->request->parameters->{"division_id" . $rank} =~ m/\d+/;
    
    # The next bit is more tricky, because if it's not ticked to be 'used' this season,
    # the checkbox is not sent at all.
    if ( $c->request->parameters->{"use_division" . $rank} ) {
      # It's a doubles game, set that key to 1 and the home / away players to undef
      $divisions->[$i]{use_division} = 1;
    } else {
      # It's not a doubles game, set that key to 0 and the home / away players to the
      # submitted values
      $divisions->[$i]{use_division} = 0;
    }
  }
  
  # Call the create / edit routine, which also does the error checking
  my $season_details = $c->model("DB::Season")->create_or_edit($action, {
    season                                          => $season,
    name                                            => $c->request->parameters->{name},
    start_date                                      => $c->request->parameters->{start_date},
    end_date                                        => $c->request->parameters->{end_date},
    start_hour                                      => $c->request->parameters->{start_hour},
    start_minute                                    => $c->request->parameters->{start_minute},
    timezone                                        => $c->request->parameters->{timezone},
    allow_loan_players                              => $c->request->parameters->{allow_loan_players},
    allow_loan_players_above                        => $c->request->parameters->{allow_loan_players_above},
    allow_loan_players_below                        => $c->request->parameters->{allow_loan_players_below},
    allow_loan_players_across                       => $c->request->parameters->{allow_loan_players_across},
    allow_loan_players_same_club_only               => $c->request->parameters->{allow_loan_players_same_club_only},
    allow_loan_players_multiple_teams_per_division  => $c->request->parameters->{allow_loan_players_multiple_teams_per_division},
    loan_players_limit_per_player                   => $c->request->parameters->{loan_players_limit_per_player},
    loan_players_limit_per_player_per_team          => $c->request->parameters->{loan_players_limit_per_player_per_team},
    loan_players_limit_per_team                     => $c->request->parameters->{loan_players_limit_per_team},
    rules                                           => $c->request->parameters->{rules},
  });
  
  if ( scalar( @{ $season_details->{error} } ) ) {
    my $error = $c->build_message( $season_details->{error} );
    
    # We're checking this a few times, so save it away for easy access
    my $allow_loan_players = $c->request->parameters->{allow_loan_players};
    
    # Stash the values we've got so we can set them
    $c->flash->{season_errored_form}                    = 1; # Flash this value so we know to check flashed values for checkboxes, not DB values
    $c->flash->{name}                                   = $c->request->parameters->{name};
    $c->flash->{start_date}                             = $c->request->parameters->{start_date};
    $c->flash->{end_date}                               = $c->request->parameters->{end_date};
    $c->flash->{start_hour}                             = $c->request->parameters->{start_hour};
    $c->flash->{start_minute}                           = $c->request->parameters->{start_minute};
    $c->flash->{league_match_template}                  = $c->request->parameters->{league_match_template};
    $c->flash->{league_ranking_template}                = $c->request->parameters->{league_ranking_template};
    $c->flash->{allow_loan_players}                     = $c->request->parameters->{allow_loan_players};
    $c->flash->{rules}                                  = $c->request->parameters->{rules};
    
    # The below settings rely on 'allow loan players' having been ticked; if it wasn't, we'll untick / blank regardless of their value
    $c->flash->{allow_loan_players_above}               = $allow_loan_players ? $c->request->parameters->{allow_loan_players_above} : "0";
    $c->flash->{allow_loan_players_below}               = $allow_loan_players ? $c->request->parameters->{allow_loan_players_below} : "0";
    $c->flash->{allow_loan_players_across}              = $allow_loan_players ? $c->request->parameters->{allow_loan_players_across} : "0";
    $c->flash->{allow_loan_players_same_club_only}      = $allow_loan_players ? $c->request->parameters->{allow_loan_players_same_club_only} : "0";
    $c->flash->{loan_players_limit_per_player}          = $allow_loan_players ? $c->request->parameters->{loan_players_limit_per_player} : "0";
    $c->flash->{loan_players_limit_per_player_per_team} = $allow_loan_players ? $c->request->parameters->{loan_players_limit_per_player_per_team} : "0";
    $c->flash->{loan_players_limit_per_team}            = $allow_loan_players ? $c->request->parameters->{loan_players_limit_per_team} : "0";
    
    foreach my $division ( @{ $divisions } ) {
      # Flash the divisions
      # Make sure we set up a blank flashed value if the grid wasn't specified, otherwise we'll have the wrong
      # number of elements in that array
      my $flash_grid              = ( defined( $division->{fixtures_grid} ) ) ? $division->{fixtures_grid}->id : "";
      my $flash_match_template    = ( defined( $division->{league_match_template} ) ) ? $division->{league_match_template}->id : "";
      my $flash_ranking_template  = ( defined( $division->{league_ranking_template} ) ) ? $division->{league_ranking_template}->id : "";
      
      push( @{ $c->flash->{use_division}            }, $division->{use_division} );
      push( @{ $c->flash->{division_name}           }, $division->{name} );
      push( @{ $c->flash->{division_id}             }, $division->{id} );
      push( @{ $c->flash->{fixtures_grid}           }, $flash_grid );
      push( @{ $c->flash->{league_match_template}   }, $flash_match_template );
      push( @{ $c->flash->{league_ranking_template} }, $flash_ranking_template );
    }
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/seasons/create",
                                  {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined( $season_details->{season} ) ) {
        $redirect_uri = $c->uri_for_action("/seasons/edit", [ $season_details->{season}->url_key ],
                                  {mid => $c->set_status_msg( {error => $error} ) });
      } else {
        $redirect_uri = $c->uri_for("/seasons",
                                  {mid => $c->set_status_msg( {error => $error} ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Log an event because the season has been created
    $season = $season_details->{season} if exists( $season_details->{season} );
    
    # Prefix an explanation to the error message
    my $action_text = ( $action eq "edit" ) ? $c->maketext("admin.message.edited") : $c->maketext("admin.message.created");
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["season", $action, {id => $season->id}, $season->name] );
    
    if ( $restricted_edit ) {
      # Redirect to the season view page
      $c->response->redirect( $c->uri_for_action("/seasons/view", [ $season->url_key ],
                                  {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $season->name, $action_text )} ) }) );
      $c->detach;
      return;
    } else {
      # Do the division creation
      my $division_details = $c->model("DB::Division")->check_and_create({
        divisions => $divisions,
        season    => $season_details->{season},
      });
      
      my $encoded_name = $c->stash->{encoded_name};
      
      if ( scalar( @{ $division_details->{error} } ) ) {
        # Error creating / editing divisions; we have created the season by now, but we can redirect to the edit page so they can be re-tried from there
        # Flash the entered values
        foreach my $division ( @{ $divisions } ) {
          # Flash the divisions
          # Make sure we set up a blank flashed value if the grid wasn't specified, otherwise we'll have the wrong
          # number of elements in that array
          my $flash_grid              = ( defined( $division->{fixtures_grid} ) ) ? $division->{fixtures_grid}->id : "";
          my $flash_match_template    = ( defined( $division->{league_match_template} ) ) ? $division->{league_match_template}->id : "";
          my $flash_ranking_template  = ( defined( $division->{league_ranking_template} ) ) ? $division->{league_ranking_template}->id : "";
          
          push( @{ $c->flash->{use_division}            }, $division->{use_division} );
          push( @{ $c->flash->{division_name}           }, $division->{name} );
          push( @{ $c->flash->{division_id}             }, $division->{id} );
          push( @{ $c->flash->{fixtures_grid}           }, $flash_grid );
          push( @{ $c->flash->{league_match_template}   }, $flash_match_template );
          push( @{ $c->flash->{league_ranking_template} }, $flash_ranking_template );
        }
        
        $division_details->{error} = sprintf( "%s\n\n%s", $c->maketext("seasons.form.success-divisions-errored", $encoded_name, $action_text), $c->build_message( $division_details->{error} ) );
        
        $c->response->redirect( $c->uri_for_action("/seasons/edit", [ $season->url_key ],
                                    {mid => $c->set_status_msg( {warning => $division_details->{error}} ) }) );
        $c->detach;
        return;
      } else {
        # Loop through collecting the names and IDs for the event log
        my ( @division_ids, @division_names );
        foreach my $division_data ( @{ $division_details->{divisions} } ) {
          $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["division", $division_data->{action}, {id => $division_data->{db}->id}, $division_data->{db}->name] );
        }
        
        # Redirect to the season view page
        $c->response->redirect( $c->uri_for_action("/seasons/view", [ $season->url_key ],
                                    {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $action_text )} ) }) );
        $c->detach;
        return;
      }
    }
  }
}

=head2 teams

Add or remove teams from the current season.

=cut

sub teams :Local {
  my ( $self, $c ) = @_;
  
  $c->load_status_msgs;
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to edit seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
    
  # Make sure there's a current season
  my $current_season  = $c->model("DB::Season")->get_current;
  
  if ( defined( $current_season ) ) {
    my $league_matches = $c->model("DB::TeamMatch")->season_matches($current_season)->count;
    
    if ( $league_matches > 0 ) {
      $c->response->redirect( $c->uri_for_action("/seasons/view", [$current_season->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.teams.error.matches-exist")} ) }) );
      $c->detach;
      return;
    }
  } else {
    $c->response->redirect( $c->uri_for("/seasons",
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.teams.error.no-current-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Get the season we need to check
  my $check_season    = $c->model("DB::Season")->last_season_with_team_entries;
  my @teams           = $c->model("DB::Team")->all_teams_by_club_by_team_name_with_season({season => $check_season});
  my @clubs           = $c->model("DB::Club")->all_clubs_by_name;
  my @divisions       = $c->model("DB::Division")->divisions_in_season($current_season);
  
  if ( scalar(@teams) == 0 ) {
    # We need to redirect to the create teams page; check we're authorised to do so first
    $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_create", "", 0] );
    
    if ( $c->stash->{authorisation}{team_create} ) {
      $c->response->redirect( $c->uri_for("/teams/create",
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.teams.no-teams-create-yes")} ) }) );
    } else {
      $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.teams.no-teams-create-no")} ) }) );
    }
    $c->detach;
    return;
  }
  
  # Set up the arrayref for the tokeninput field configurations
  my $tokeninput_confs = [];
  
  # Set up the players / captains for each team
  foreach my $team ( @teams ) {
    # First setup the function arguments
    my $captain_tokeninput_options = {
      jsonContainer => "json_people",
      tokenLimit    => 1,
      hintText      => "Start typing a person's name",
    };
    
    # Add the pre-population if needed
    if ( $c->flash->{errored_form} ) {
      $captain_tokeninput_options->{prePopulate} = [{
        id    => $c->flash->{teams}{$team->id}{new_captain}->id,
        name  => encode_entities( $c->flash->{teams}{$team->id}{new_captain}->display_name ),
      }] if ( defined( $c->flash->{teams}{$team->id}{new_captain} ) and ref( $c->flash->{teams}{$team->id}{new_captain} ) eq "TopTable::Model::DB::Person" );
    } else {
      # Form hasn't errored, 
      $captain_tokeninput_options->{prePopulate} = [{
        id    => $team->team_seasons->first->captain->id,
        name  => encode_entities( $team->team_seasons->first->captain->display_name ),
      }] if defined( $team->team_seasons->first ) and defined( $team->team_seasons->first->captain );
    }
    
    # Now do the players
    my $players_tokeninput_options = {
      jsonContainer => "json_people",
      hintText      => $c->maketext("person.tokeninput.type"),
    };
    
    # Set up the arrayref for the pre-population
    $players_tokeninput_options->{prePopulate} = [];
    if ( $c->flash->{errored_form} ) {
      # Form has errored, use the flashed values
      if ( exists( $c->flash->{teams}{$team->id}{new_players} ) and ref( $c->flash->{teams}{$team->id}{new_players} ) eq "ARRAY" ) {
        foreach my $player ( @{ $c->flash->{teams}{$team->id}{new_players} } ) {
          push(@{ $players_tokeninput_options->{prePopulate} }, {
            id    => $player->id,
            name  => encode_entities( $player->display_name ),
          });
        }
      }
    } else {
      # Form hasn't errored, use the DB values
      if ( defined( $team->team_seasons->first ) and defined( $team->person_seasons ) ) {
        # Loop through the players for this person and add them into the pre-population
        $team->person_seasons->reset;
        my $person_seasons = $team->person_seasons;
        while ( my $person_season = $person_seasons->next ) {
          push(@{ $players_tokeninput_options->{prePopulate} }, {
            id    => $person_season->person->id,
            name  => encode_entities( $person_season->person->display_name ),
          });
        }
      }
    }
    
    # Push the players and captain tokeninputs on to the configurations
    push( @{ $tokeninput_confs }, {
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $captain_tokeninput_options ),
      selector  => "captain_" . $team->id,
    }, {
      script    => $c->uri_for("/people/ajax-search"),
      options   => encode_json( $players_tokeninput_options ),
      selector  => "players_" . $team->id,
    });
  }
  
  $c->stash({
    template            => "html/seasons/teams.ttkt",
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/seasons/teams.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    view_online_display => sprintf( "Selecting teams for %s", $current_season->name ),
    view_online_link    => 0,
    subtitle2           => $c->maketext( "seasons.set-teams.heading", $current_season->name ),
    divisions           => \@divisions,
    teams               => \@teams,
    clubs               => \@clubs,
    home_nights         => [ $c->model("DB::LookupWeekday")->all_days ],
    # The last season with any teams in will be the one we need to check against for active / inactive
    check_season        => $check_season,
    tokeninput_confs    => $tokeninput_confs,
  });
  
  if ( $c->stash->{status_msg}{info} ) {
    # Append the message
    $c->stash->{status_msg}{info} .= $c->maketext("seasons.set-teams.notice.name-changes");
  } else {
    $c->stash->{status_msg}{info} = $c->maketext("seasons.set-teams.notice.name-changes");
  }
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/seasons/teams"),
    label => $c->maketext("menu.text.teams"),
  });
}

=head2 set_teams

Add or remove teams from the current season.

=cut

sub set_teams :Path("set-teams") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to edit seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["season_edit", $c->maketext("user.auth.edit-seasons"), 1] );
  
  # Checked that we are okay to process the form; now process all the team data into a hashref
  my $teams = [];
  
  if ( exists( $c->request->parameters->{id} ) ) {
    if ( ref( $c->request->parameters->{id} ) ne "ARRAY" ) {
      # Turn it into an arrayref if it's not already, so we don't have to do lots of if statements checking in the next bit
      $c->request->parameters->{id} = [ $c->request->parameters->{id} ];
    }
  } else {
    $c->response->redirect( $c->uri_for("/seasons/teams",
                              {mid => $c->set_status_msg( {error => $c->maketext("seasons.form.teams.error.no-teams-submitted")} ) }) );
    $c->detach;
    return;
  }
  
  # Now prepare the data to send to the model for processing
  foreach my $team_id ( @{ $c->request->parameters->{id} } ) {
    # The captain will be blank if we don't have one specified (rather than undef); this is important, as undef will signify an unrecognised captain
    my $captain = "";
    $captain = $c->model("DB::Person")->find( $c->request->parameters->{"captain_" . $team_id} ) if $c->request->parameters->{"captain_" . $team_id};
    
    # Look up all the players first; these are submitted in a single field, comma separated
    my @player_ids = split( ",", $c->request->parameters->{"players_" . $team_id} );
    
    # Set up the arrayref that will hold the DB object for each player, then push the result of a find() on to it for each ID
    my $players = [];
    push( @{ $players }, $c->model("DB::Person")->find( $_ ) ) foreach ( @player_ids );
    
    # Set up the teams array
    push( @{ $teams }, {
      db              => $c->model("DB::Team")->find_with_prefetches( $team_id ), # Find the current team object
      id              => $team_id, # Pass the ID in
      entered         => $c->request->parameters->{$team_id . "_entered"},
      
      # Pass in the 'new' details for the team
      new_division    => $c->model("DB::Division")->find( $c->request->parameters->{"division_" . $team_id} ),
      new_club        => $c->model("DB::Club")->find( $c->request->parameters->{"club_" . $team_id} ),
      new_home_night  => $c->model("DB::LookupWeekday")->find( $c->request->parameters->{"home_night_" . $team_id} ),
      
      # Captain and players
      new_captain     => $captain,
      new_players     => $players,
    });
  }
  
  my $team_results = $c->model("DB::Season")->edit_teams_list({
    teams                   => $teams,
    reassign_active_players => $c->config->{Players}{reassign_active_on_team_season_create},
  });
  
  my ( $error, $warning, $current_season ) = ( $team_results->{error}, $team_results->{warning}, $team_results->{current_season} );
  
  if ( scalar( @{ $error } ) ) {
    $error = $c->build_message( $error );
    
    # If we've reached an error, flash the values...
    $c->flash->{teams}        = $team_results->{teams};
    $c->flash->{errored_form} = 1;
    
    # ...and redirect with an error message
    $c->response->redirect( $c->uri_for("/seasons/teams",
                              {mid => $c->set_status_msg( {error => $error} ) }) );
  } elsif ( scalar( @{ $warning } ) ) {
    $warning = $c->build_message( $warning );
    
    # Warnings, but we've done what we can; redirect to season view with the warnings.
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$current_season->url_key],
                              {mid => $c->set_status_msg( { success => $c->maketext("seasons.form.teams.success-with-warnings", $current_season->name),
                                                            warning => $warning } ) }) );
  } else {
    # No errors or warnings, back to the season view
    $c->response->redirect( $c->uri_for_action("/seasons/view", [$current_season->url_key],
                              {mid => $c->set_status_msg( {success => $c->maketext("seasons.form.teams.success", $current_season->name)} ) }) );
  }
  
  # We will have redirected in some way, so detach and return
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
