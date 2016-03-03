package TopTable::Controller::Templates::Match::Team;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Templates::Match::Team - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.templates-team-match")});
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match/team"),
    label => $c->maketext("menu.text.templates-team-match-breadcrumbs"),
  });
}

=head2 base

Chain base for getting the first argument (is it a team or individual template?) and then checking the ID.

=cut

sub base :Chained('/') PathPart('templates/match/team') CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $tt_template = $c->model("DB::TemplateMatchTeam")->find_id_or_url_key( $id_or_key );
  
  if ( defined($tt_template) ) {
    my $encoded_name = encode_entities( $tt_template->name );
    
    $c->stash({
      tt_template   => $tt_template,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Breadcrumbs
    push(@{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key]),
      label => $encoded_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of ranking.  Matches /templates/league-table-ranking

=cut

sub base_list :Chained("/") :PathPart("templates/match/team") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( template_edit template_delete template_create) ], "", 0] );
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/templates/match/team/list_first_page")});
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/templates/match/team/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/templates/match/team/list_specific_page", [$page_number])});
  }
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $match_templates = $c->model("DB::TemplateMatchTeam")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $match_templates->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/templates/match/team/list_first_page",
    specific_page_action  => "/templates/match/team/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/templates/match/team/list.ttkt",
    view_online_display => "Viewing team match templates",
    view_online_link    => 1,
    match_templates     => $match_templates,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template   = $c->stash->{tt_template};
  my $encoded_name  = $c->stash->{encoded_name};
  
  # Check that we are authorised to view
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_view", $c->maketext("user.auth.view-templates"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( template_edit template_delete ) ], "", 0] );
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.edit-object", $encoded_name),
      link_uri  => $c->uri_for_action("/templates/match/team/edit", [$tt_template->url_key]),
    }) if $c->stash->{authorisation}{template_edit} and $tt_template->can_edit_or_delete;
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $encoded_name),
      link_uri  => $c->uri_for_action("/templates/match/team/delete", [$tt_template->url_key]),
    }) if $c->stash->{authorisation}{template_delete} and $tt_template->can_edit_or_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/templates/match/team/view.ttkt",
    title_links         => \@title_links,
    view_online_display => sprintf( "Viewing match template: %s", $encoded_name ),
    view_online_link    => 0,
    tt_template_games   => [ $c->model("DB::TemplateMatchTeamGame")->individual_game_templates( $c->stash->{tt_template} ) ],
  });
}

=head2 create

Display a form to collect information for creating a match template.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1] );
  
  my $individual_match_templates = $c->model("DB::TemplateMatchIndividual")->search->count;
  
  unless ( $individual_match_templates ) {
      $c->response->redirect( $c->uri_for("/templates/match/individual/create",
                                  {mid => $c->set_status_msg( {error => $c->maketext("templates.team-match.form.error.no-individual-templates")} ) }) );
      $c->detach;
      return;
  }
  
  # Get venues and people to list
  $c->stash({
    template            => "html/templates/match/team/create-edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/templates/match/team/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating team match templates",
    view_online_link    => 0,
    winner_types        => [ $c->model("DB::LookupWinnerType")->search ],
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match/team/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing a team match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_edit",  $c->maketext("user.auth.edit-templates"), 1] );
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("templates.edit.error.not-allowed", $tt_template->name)} ) }) );
    $c->detach;
    return;
  }
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Get venues to list
  $c->stash({
    template            => "html/templates/match/team/create-edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/templates/match/team/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    subtitle2           => $c->maketext("admin.edit"),
    form_action         => $c->uri_for_action("/templates/match/team/do_edit", [$tt_template->url_key]),
    view_online_display => "Editing team match template " . $tt_template->name,
    view_online_link    => 0,
    winner_types        => [ $c->model("DB::LookupWinnerType")->search ],
  });
  
  $c->flash->{winner_type} = $tt_template->winner_type->id;
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match/team/edit", [$tt_template->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_delete", $c->maketext("user.auth.delete-templates"), 1] );
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("templates.delete.error.not-allowed", $tt_template->name)} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/templates/match/team/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $tt_template->name ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match/team/delete", [$tt_template->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a team match template.

=cut

sub do_create :Path("do-create") {
  my ($self, $c, $template_id) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1] );
  
  # Forward to the creation routine
  $c->detach( "setup_template", ["create"] );
}

=head2 do_edit

Process the form for editing a team match template.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ($self, $c, $template_id) = @_;
  
  # Check that we are authorised to edit templates
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_edit", $c->maketext("user.auth.edit-templates"), 1] );
  my $tt_template = $c->stash->{tt_template};
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("templates.edit.error.not-allowed", $tt_template->name)} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the editing routine
  $c->detach( "setup_template", ["edit"] );
}

=head2 do_delete

Processes the deletion of the template.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template   = $c->stash->{tt_template};
  my $encoded_name  = $c->stash->{encoded_name};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_delete", $c->maketext("user.auth.delete-templates"), 1] );
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("templates.delete.error.not-allowed", $tt_template->name)} ) }) );
    $c->detach;
    return;
  }
  
  # Save away the venue name, as if there are no errors and it can be deleted, we will need to
  # reference the name in the message back to the user.
  my $tt_template_name = $tt_template->name;
  
  # Attempt the delete
  my $error = $tt_template->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting, go back to deletion page
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success, log a deletion and return to the venue list
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["template-match-team", "delete", {id => undef}, $tt_template_name] );
    $c->response->redirect( $c->uri_for("/templates/match/team",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_template

Forwarded from docreate and doedit to do the template creation / edit.

=cut

sub setup_template :Private {
  my ( $self, $c, $action ) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  my $winner_type = $c->model("DB::LookupWinnerType")->find( $c->request->parameters->{winner_type} ) if $c->request->parameters->{winner_type};
  
  # The rest of the error checking is done in the Club model
  my $details = $c->model("DB::TemplateMatchTeam")->create_or_edit($action, {
    tt_template               => $tt_template,
    name                      => $c->request->parameters->{name},
    singles_players_per_team  => $c->request->parameters->{singles_players_per_team},
    winner_type               => $winner_type,
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{name}                     = $c->request->parameters->{name};
    $c->flash->{singles_players_per_team} = $c->request->parameters->{singles_players_per_team};
    $c->flash->{winner_type}              = $c->request->parameters->{winner_type};
    
    # Set the redirect URI based on whether we're creating or editing (and if we're editing, based on whether we were supplied with a valid template)
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/templates/match/team/create",
                          {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined($details->{tt_template}) ) {
        $redirect_uri = $c->uri_for("/templates/match/team/edit", [ $details->{tt_template}->url_key ],
                            {mid => $c->set_status_msg( {error => $error} ) });
      } else {
        $redirect_uri = $c->uri_for("/templates/match/team",
                            {mid => $c->set_status_msg( {error => $error} ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $tt_template   = $details->{tt_template};
    my $encoded_name  = encode_entities( $tt_template->name );
    my $action_description = ( $action eq "create" ) ? $c->maketext("admin.message.created") : $c->maketext("admin.message.edited");
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["template-match-team", $action, {id => $tt_template->id}, $tt_template->name] );
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $action_description )} ) }) );
    $c->detach;
    return;
  }
}

=head2 games

Display the form to create the games for the team match template.

=cut

sub games :Chained("base") :PathPart("games") :Args(0) {
  my ( $self, $c ) = @_;
  my ( @team_match_template_games );
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1] );
  
  unless ( $tt_template->can_edit_or_delete ) {
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [$tt_template->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext("templates.edit.error.not-allowed", $tt_template->name)} ) }) );
    $c->detach;
    return;
  }
  
  # Default to one game if number is not specified
  my $number_of_games = $c->request->parameters->{games};
  $number_of_games = 1 if !$number_of_games or $number_of_games !~ m/\d{1,2}/;
  
  # Create an array with the number of specified games in
  push ( @team_match_template_games, { game_number  => $_, } ) foreach ( 1 .. $number_of_games );
  
  # Get venues and people to list
  $c->stash({
    template            => "html/templates/match/team/game/create-edit.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for_action("/templates/match/team/games_js", [$tt_template->url_key]),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action                 => $c->uri_for_action("/templates/match/team/set_games", [$tt_template->url_key]),
    subtitle2                   => $c->maketext("menu.text.templates-team-match-games"),
    view_online_display         => "Creating team match template games",
    view_online_link            => 0,
    team_match_template_games   => \@team_match_template_games,
    individual_match_templates  => [$c->model("DB::TemplateMatchIndividual")->all_templates],
    team_match_template         => $tt_template,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/templates/match/team/games", [$tt_template->url_key]),
    label => $c->maketext("menu.text.templates-team-match-games"),
  });
}

=head2 games_js

Generate the javascript file for setting team match games.

=cut

sub games_js :Chained("base") :PathPart("games.js") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # This will be a javascript file, not a HTML
  $c->response->headers->header("Content-type" => "text/javascript");
  
  # Stash no wrapper and the template
  $c->stash({
    template                    => "scripts/templates/match/team/games.ttjs",
    no_wrapper                  => 1,
    individual_match_templates  => [$c->model("DB::TemplateMatchIndividual")->all_templates],
    team_match_template         => $tt_template,
  });
  
  $c->detach( $c->view("HTML") );
}

=head2 set_games

Processes the submitted games form to create (after, if necessary, deleting the already existing ones) the games for this team match template.

=cut

sub set_games :Chained("base") :PathPart("set-games") :Args(0) {
  my ( $self, $c ) = @_;
  my $tt_template = $c->stash->{tt_template};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["template_create", $c->maketext("user.auth.create-templates"), 1] );
  
  # Need to work out how many of these we have, as they only come through if ticked / singles players select boxes only if enabled
  # (which they're not if the 'doubles game' checkbox is ticked)
  my ( $doubles_game, $singles_home_player_number, $singles_away_player_number );
  
  # Do a find against the individual match template(s)
  my $individual_match_template;
  if ( ref( $c->request->parameters->{individual_match_template} ) eq "ARRAY" ) {
    # We push it on to an arrayref to be consistent with the other passed values if there's more than one game
    $individual_match_template  = [];
    $doubles_game               = [];
    $singles_home_player_number = [];
    $singles_away_player_number = [];
    my $i = 1;
    foreach my $template ( @{ $c->request->parameters->{individual_match_template} } ) {
      my $template_check = $c->model("DB::TemplateMatchIndividual")->find( $template );
      push( @{ $individual_match_template }, $template_check );
      
      # Use this loop to collect doubles game values too
      push( @{ $doubles_game }, $c->request->parameters->{"doubles_game" . $i} );
      push( @{ $singles_home_player_number }, $c->request->parameters->{"singles_home_player_number" . $i} );
      push( @{ $singles_away_player_number }, $c->request->parameters->{"singles_away_player_number" . $i} );
      $i++;
    }
  } else {
    # Otherwise, we do a straight find into the variable
    $individual_match_template  = $c->model("DB::TemplateMatchIndividual")->find( $c->request->parameters->{individual_match_template} );
    $doubles_game               = $c->request->parameters->{doubles_game1};
    $singles_home_player_number = $c->request->parameters->{singles_home_player_number1};
    $singles_away_player_number = $c->request->parameters->{singles_away_player_number1};
  }
  
  my $details = $c->model("DB::TemplateMatchTeamGame")->create_or_edit("create", {
    tt_template                 => $tt_template,
    individual_match_template   => $individual_match_template,
    doubles_game                => $doubles_game,
    singles_home_player_number  => $singles_home_player_number,
    singles_away_player_number  => $singles_away_player_number,
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $redirect_uri;
    # Flash the values back
    $c->flash->{individual_match_template}  = $details->{flash}{individual_match_template};
    $c->flash->{doubles_game}               = $details->{flash}{doubles_game};
    $c->flash->{singles_home_player_number} = $details->{flash}{singles_home_player_number};
    $c->flash->{singles_away_player_number} = $details->{flash}{singles_away_player_number};
    
    $redirect_uri = $c->uri_for_action("/templates/match/team/games", [ $tt_template->url_key ],
                        {mid  => $c->set_status_msg( {error => $c->build_message($details->{error})} ),
                        games => $details->{number_of_games},});
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Finally, redirect to the team match template, which should now show you the new games
    ## DELETE DETECTION DOESN'T WORK PROPERLY
    #$c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["template-match-team-game", "delete", {id => $team_match_template->id}, $team_match_template->name] ) if $details->{previous_games_deleted};
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["template-match-team-game", "create", {id => $tt_template->id}, $tt_template->name] );
    
    $c->response->redirect( $c->uri_for_action("/templates/match/team/view", [ $tt_template->url_key ],
                              {mid  => $c->set_status_msg( {success => $c->maketext("templates.team-match.games.success", $details->{number_of_games}, $tt_template->name)} ),
                              games => $details->{number_of_games},}) );
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
