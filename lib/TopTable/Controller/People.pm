package TopTable::Controller::People;
use Moose;
use namespace::autoclean;
use JSON;
use Data::Dumper::Concise;
use MIME::Types;
use Text::CSV;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::People - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to create, edit view and delete people.  The people created here can be players, league officials, captains and / or secretaries.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.people")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    # Listing
    path  => $c->uri_for("/people"),
    label => $c->maketext("menu.text.people"),
  });
}

=head2 base

Chain base for getting the person ID and checking it.

=cut

sub base :Chained("/") PathPart("people") CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  my $person = $c->model("DB::Person")->find_with_user( $id_or_url_key );
  
  if ( defined($person) ) {
    my $encoded_first_name    = encode_entities( $person->first_name );
    my $encoded_display_name  = encode_entities( $person->display_name );
    
    $c->stash({
      person                => $person,
      encoded_first_name    => $encoded_first_name,
      encoded_display_name  => $encoded_display_name,
      subtitle1             => $encoded_display_name,
    });
    
    # Push the people list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      # View page (current season)
      path  => $c->uri_for_action("/people/view_current_season", [$person->url_key]),
      label => $encoded_display_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of people.  Matches /people

=cut

sub base_list :Chained("/") :PathPart("people") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1] );
  
  # Check the authorisation to edit people we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( person_edit person_delete person_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description  => $c->maketext("description.people.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the people on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/people/list_first_page")});
}

=head2 list_specific_page

List the people on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/people/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/people/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for people with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  my $person = $c->stash->{person};
  
  my $people = $c->model("DB::Person")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $people->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/people/list_first_page",
    specific_page_action  => "/people/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/people/list.ttkt",
    view_online_display => "Viewing people",
    view_online_link    => 1,
    people              => $people,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 base_no_object_specified

Base URL matcher with no person specified (use in the create routines).  Doesn't actually do anything other than the URL matching and loading status messages.

=cut

sub base_no_object_specified :Chained("/") :PathPart("people") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 view

View a person's details.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view teams
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( person_edit person_create person_delete person_contact_view ) ], "", 0] );
}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name   = $c->stash->{encoded_site_name};
  my $person_name = $c->stash->{encoded_display_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season if !defined($season); # No current season season, try and find the last season.
  
  if ( defined( $season ) ) {
    my $encoded_season_name = encode_entities( $season->name );
    
    $c->stash({
      season              => $season,
      encoded_season_name => $encoded_season_name,
      page_description    => $c->maketext("description.people.view-current", $person_name, $site_name),
    });
    
    # Forward to the routine that stashes the person's season
    $c->forward("get_person_season");
  }
  
  # Finalise the view routine
  $c->detach("view_finalise") unless exists ( $c->stash->{delete_screen} );
}

=head2 view_specific_season

View a team with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $person      = $c->stash->{person};
  my $site_name   = $c->stash->{encoded_site_name};
  my $person_name = $c->stash->{encoded_display_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key );
    
  if ( defined( $season ) ) {
    my $encoded_season_name = encode_entities( $season->name );
    
    $c->stash({
      season              => $season,
      specific_season     => 1,
      subtitle2           => $encoded_season_name,
      encoded_season_name => $encoded_season_name,
      page_description    => $c->maketext("description.people.view-specific", $person_name, $encoded_season_name, $site_name),
    });
  } else {
    # Invalid season
    $c->detach( /TopTable::Controller::Root default/ );
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_person_season");
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/people/view_seasons", [$person->url_key]),
    label => $c->maketext("menu.text.seasons"),
  }, {
    path  => $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key]),
    label => $season->name,
  });
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_person_season

Obtain a person's details for a given season.

=cut

sub get_person_season :Private {
  my ( $self, $c ) = @_;
  my ( $person, $season ) = ( $c->stash->{person}, $c->stash->{season} );
  
  my $teams = $c->model("DB::PersonSeason")->get_person_season_and_teams_and_divisions({
    person  => $person,
    season  => $season,
  });
  my $types = $c->model("DB::PersonSeason")->get_team_membership_types_for_person_in_season({
    person  => $person,
    season  => $season,
  });
  my $games = $person->games_played_in_season({season => $season});
  my ( $person_name, $person_season_name ) = ( encode_entities( $person->display_name ), encode_entities( $teams->first->display_name ) );
  
  # If the name has changed, we need to display a notice
  $c->add_status_message( "info", $c->maketext("people.name.changed-notice", $person_season_name, $person_name ) ) unless $person_name eq $person_season_name;
  
  $c->stash({
    subtitle1 => $person_season_name,
    teams => $teams,
    types => $types,
    games => $games,
    season => $season,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $person  = $c->stash->{person};
  my $season  = $c->stash->{season};
  my $encoded_display_name = $c->stash->{encoded_display_name};
  
  # Get the list of seasons they have played in
  my $person_seasons = $c->model("DB::PersonSeason")->get_all_seasons_a_person_played_in( $person );
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text      => $c->maketext( "admin.edit-object", $encoded_display_name ),
    link_uri  => $c->uri_for_action("/people/edit", [$person->url_key]),
  }) if $c->stash->{authorisation}{person_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text      => $c->maketext( "admin.delete-object", $encoded_display_name ),
    link_uri  => $c->uri_for_action("/people/delete", [$person->url_key]),
  }) if $c->stash->{authorisation}{person_delete} and $person->can_delete;
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key])
    : $c->uri_for_action("/people/view_current_season", [$person->url_key]);
  
  my $scripts           = [];
  my $tokeninput_confs  = [];
  my $external_styles   = [
    $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
    $c->uri_for("/static/css/chosen/chosen.min.css"),
    $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
  ];
  my $external_scripts  = [
    $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
    $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
    $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
    $c->uri_for("/static/script/people/view.js", {v => 2}),
    $c->uri_for("/static/script/standard/option-list.js"),
    $c->uri_for("/static/script/standard/vertical-table.js"),
  ];
  
  if ( $c->stash->{authorisation}{person_edit} ) {
    my $tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit    => 1,
      hintText      => $c->maketext("person.tokeninput.type"),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Add the pre-population if required
    $tokeninput_options->{prePopulate} = [{id => $c->flash->{to}->id, name => encode_entities( $c->flash->{to}->display_name ) }] if defined( $c->flash->{to} );
    
    $scripts          = ["tokeninput-standard"];
    $tokeninput_confs = [{
      script    => $c->uri_for("/people/search"),
      options   => encode_json( $tokeninput_options ),
      selector  => "to"
    }];
    
    push( @{ $external_styles }, $c->uri_for("/static/css/tokeninput/token-input-tt.css") );
    push( @{ $external_scripts }, $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}) );
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/people/view.ttkt",
    scripts             => $scripts,
    external_scripts    => $external_scripts,
    external_styles     => $external_styles,
    tokeninput_confs    => $tokeninput_confs,
    title_links         => \@title_links,
    view_online_display => sprintf( "Viewing %s", $encoded_display_name ),
    view_online_link    => 1,
    person_seasons      => $person_seasons,
    seasons             => $person_seasons->count,
    canonical_uri       => $canonical_uri,
  });
}

=head2 transfer

Transfer the current season (including all team associations) to another person.  The person chosen to transfer to must have no team associations already of any sort for the season that you're transferring data for.

This function is chained to "base", so that the "from" person is already obtained.

=cut

sub transfer :Chained("base") :PathPart("transfer") :Args(0) {
  my ( $self, $c ) = @_;
  my $from_person = $c->stash->{person};
  
  # Check that we are authorised to view teams
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1] );
  
  my $to_person = $c->model("DB::Person")->find( $c->request->parameters->{to} );
  my $season    = $c->model("DB::Season")->find( $c->request->parameters->{season} );
  
  my $result = $from_person->transfer_statistics({
    to_person => $to_person,
    season    => $season,
  });
  
  if ( scalar( @{ $result->{errors} } ) == 0 ) {
    # Success, redirect to the new person's view page and display a message.
    my $redirect_uri;
    
    if ( defined( $season ) ) {
      $redirect_uri = $c->uri_for_action("/people/view_specific_season",
          [$to_person->url_key, $season->url_key], {mid => $c->set_status_msg( {success => $c->maketext("people.transfer.success")} ) } );
    } else {
      $redirect_uri = $c->uri_for_action("/people/view_current_season",
          [$to_person->url_key], {mid => $c->set_status_msg( {success => $c->maketext("people.transfer.success")} ) } );
    }
    
    # Log an event for each
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["person", "transfer-from", {id => $from_person->id}, $from_person->display_name] );
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["person", "transfer-to", {id => $to_person->id}, $to_person->display_name] );
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Failure, redirect back to the "from" view page and display the error(s).
    my $error = $c->build_message( $result->{errors} );
    my $redirect_uri;
    
    if ( defined( $season ) ) {
      $redirect_uri = $c->uri_for_action("/people/view_specific_season",
          [$from_person->url_key, $season->url_key], {mid => $c->set_status_msg( {error => $error} ) } );
    } else {
      $redirect_uri = $c->uri_for_action("/people/view_current_season",
          [$from_person->url_key], {mid => $c->set_status_msg( {error => $error} ) } );
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  }
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my $person      = $c->stash->{person};
  my $site_name   = $c->stash->{encoded_site_name};
  my $person_name = $c->stash->{encoded_display_name};
  
  my $seasons = $person->get_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/people/seasons.js"),
    ];
    $ext_styles = [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ];
  } else {
    $ext_scripts = [ $c->uri_for("/static/script/standard/option-list.js") ];
    $ext_styles = [];
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/people/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.seasons"),
    page_description  => $c->maketext("description.people.list-seasons", $person_name, $site_name),
    view_online_display => sprintf( "Viewing seasons for %s", $person->display_name ),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path              => $c->uri_for_action("/people/view_seasons", [$person->url_key]),
    label             => $c->maketext("menu.text.seasons"),
  });
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Chained("base_no_object_specified") :PathPart("create") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my ( $team_tokeninput_options, $captain_tokeninput_options, $secretary_tokeninput_options, $user_tokeninput_options );
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1] );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.create.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  ### Set up the tokeninputs
  my ( $tokeninput_team_options, $tokeninput_captain_options, $tokeninput_secretary_options, $tokeninput_user_options );
  
  ## Team played for
  $tokeninput_team_options = {
    jsonContainer => "json_teams",
    tokenLimit    => 1,
    hintText      => $c->maketext("teams.tokeninput.type"),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add the pre-population if required
  $tokeninput_team_options->{prePopulate} = [{id => $c->flash->{team}->id, name => encode_entities( sprintf( "%s %s", $c->flash->{team}->club->short_name, $c->flash->{team}->name ) ) }] if defined( $c->flash->{team} );
  
  ## Team(s) captained
  $tokeninput_captain_options = {
    jsonContainer => "json_teams",
    hintText      => encode_entities( $c->maketext( "teams.tokeninput.type-captain" ) ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Check if we have teams flashed to be captain for
  if ( defined( $c->flash->{captains} ) ) {
    # If so check if it's an arrayref
    if ( ref( $c->flash->{captains} ) eq "ARRAY" ) {
      # If so, just map the ID and name on to the prePopulate array
      $tokeninput_captain_options->{prePopulate} = [];
      push( @{ $tokeninput_captain_options->{prePopulate} }, {id => $_->id, name => encode_entities( sprintf( "%s %s", $_->club->short_name, $_->name ) )} ) foreach ( @{ $c->flash->{captains} } );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_captain_options->{prePopulate} = [{id => $c->flash->{captains}->id, name => encode_entities( $c->flash->{captains}->name )}];
    }
  }
  
  ## Club(s) secretaried
  $tokeninput_secretary_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext( "clubs.tokeninput.type-secretary" ) ),
  };
  
  # Check if we have clubs flashed to be secretary for
  if ( defined( $c->flash->{secretaries} ) ) {
    # If so check if it's an arrayref
    if ( ref( $c->flash->{secretaries} ) eq "ARRAY" ) {
      # If so, just push the ID and name on to the prePopulate array
      $tokeninput_secretary_options->{prePopulate} = [];
      push( @{ $tokeninput_secretary_options->{prePopulate} }, {id => $_->id, name => encode_entities( $_->full_name )} ) foreach ( @{ $c->flash->{secretaries} } );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_secretary_options->{prePopulate} = [{id => $c->flash->{secretaries}->id, name => encode_entities( $c->flash->{secretaries}->full_name )}];
    }
  }
  
  ## Website users
  $tokeninput_user_options = {
    jsonContainer => "json_users",
    tokenLimit    => 1,
    hintText      => encode_entities( $c->maketext( "user.tokeninput.type-person-association" ) ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add the pre-population if required
  $tokeninput_user_options->{prePopulate} = [{id => $c->flash->{user}->id, name => $c->flash->{user}->username}] if defined( $c->flash->{user} );
  
  # Stash the things we need to show the creation form
  $c->stash({
    template            => "html/people/create-edit.ttkt",
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    tokeninput_confs    => [{
      script    => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options   => encode_json( $tokeninput_team_options ),
      selector  => "team"
    }, {
      script    => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options   => encode_json( $tokeninput_captain_options ),
      selector  => "captain"
    }, {
      script    => $c->uri_for("/clubs/search"),
      options   => encode_json( $tokeninput_secretary_options ),
      selector  => "secretary"
    }, {
      script    => $c->uri_for("/users/search"),
      options   => encode_json( $tokeninput_user_options ),
      selector  => "username",
    }],
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating people",
    view_online_link    => 0,
    genders             => [ $c->model("DB::LookupGender")->search ],
  });
  
  # Append an information notice to this page
  $c->add_status_message( "info", $c->maketext("people.create.form.import-notice", $c->uri_for( "/people/import" ) ) );
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/people/create_no_team"),
    label => $c->maketext("admin.create"),
  });
}

=head2 create_with_team_by_url_key

Matches a URL to create a person with the team specified by URL key.

=cut

sub create_with_team_by_url_key :Chained("create") :PathPart("team") :Args(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  my $club = $c->model("DB::Club")->find_url_key( $club_url_key );
  my $team = $c->model("DB::Team")->find_url_key( $club, $team_url_key ) if defined ( $club );
  
  $c->stash->{team} = $team;
  $c->forward( "create_with_team" );
}

=head2 create_with_team_by_id

Matches a URL to create a person with the team specified by URL key.

=cut

sub create_with_team_by_id :Chained("create") :PathPart("team") :Args(1) {
  my ( $self, $c, $team_id ) = @_;
  
  my $team = $c->model("DB::Team")->find( $team_id );
  
  $c->stash->{team} = $team;
  $c->forward( "create_with_team" );
}

=head2 create_with_team

Create URL with team specified for pre-selection.

=cut

sub create_with_team :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  if ( defined ( $team ) ) {
    # We just update the prePopulate first element of the tokenInput arrays, as this is the team
    $c->stash->{tokeninput_confs}[0]{options} = encode_json({
      jsonContainer => "json_teams",
      tokenLimit    => 1,
      hintText      => $c->maketext("teams.tokeninput.type"),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
      prePopulate   => [{id => $team->id, name => encode_entities( sprintf( "%s %s", $team->club->short_name, $team->name ) )}],
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 create_no_team

Create URL for create with no club specified.  This doesn't do anything other than specify the end of a chain.

=cut

sub create_no_team :Chained("create") :PathPart("") :Args(0) {}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);

  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1] );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined( $current_season ) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.edit.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Get the season for this person
  my $person_season = $c->model("DB::PersonSeason")->get_active_person_season_and_team( $person, $current_season );
  
  ### Set up the tokeninputs
  my ( $tokeninput_team_options, $tokeninput_captain_options, $tokeninput_secretary_options, $tokeninput_user_options );
  
  ## Team played for
  $tokeninput_team_options = {
    jsonContainer => "json_teams",
    tokenLimit    => 1,
    hintText      => $c->maketext("teams.tokeninput.type"),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add the pre-population if required
  
  # If there's no flash value for team, set it to the person's current team.
  if ( !defined( $c->flash->{teams} ) ) {
    if ( defined( $person_season ) ) {
      $c->flash->{teams} = [ $person_season->team ];
    } else {
      $c->flash->{teams} = [];
    }
  }
  
  # Set up which pre-population to use - flash if it's defined, otherwise the team season
  my $pre_populate_team;
  if ( defined( $c->flash->{team} ) ) {
    $pre_populate_team = $c->flash->{team};
  } else {
    $pre_populate_team = $person_season->team_season->team if defined( $person_season );
  }
  
  $tokeninput_team_options->{prePopulate} = [{id => $pre_populate_team->id, name => encode_entities( sprintf( "%s %s", $pre_populate_team->club->short_name, $pre_populate_team->name ) )}] if defined( $pre_populate_team );
  
  ## Team(s) captained
  $tokeninput_captain_options = {
    jsonContainer => "json_teams",
    hintText      => $c->maketext("teams.tokeninput.type-captain"),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Prioritise flashed teams for the prepopulation
  my $captained_teams;
  if ( defined( $c->flash->{captains} ) ) {
    $captained_teams = $c->flash->{captains};
  } else {
    $captained_teams = [ $c->model("DB::Team")->get_teams_with_specified_captain( $person, $current_season ) ];
  }
  
  # Check if we have teams flashed to be captain for
  if ( defined( $captained_teams ) ) {
    # If so check if it's an arrayref
    if ( ref( $captained_teams ) eq "ARRAY" ) {
      # If so, just map the ID and name on to the prePopulate array
      $tokeninput_captain_options->{prePopulate} = [];
      push( @{ $tokeninput_captain_options->{prePopulate} }, {id => $_->id, name => encode_entities( sprintf( "%s %s", $_->club->short_name, $_->name ) )} ) foreach ( @{ $captained_teams } );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_captain_options->{prePopulate} = [{id => $captained_teams->id, name => encode_entities( $captained_teams->name )}];
    }
  }
  
  ## Club(s) secretaried
  $tokeninput_secretary_options = {
    jsonContainer => "json_search",
    hintText      => $c->maketext("clubs.tokeninput.type-secretary"),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Prioritise flashed values
  my $secretaried_clubs;
  if ( defined( $c->flash->{secretaries} ) ) {
    $secretaried_clubs = $c->flash->{secretaries};
  } else {
    $secretaried_clubs = [ $c->model("DB::Club")->get_clubs_with_specified_secretary( $person ) ];
  }
  
  # Check if we have clubs flashed to be secretary for
  if ( defined( $secretaried_clubs ) ) {
    # If so check if it's an arrayref
    if ( ref( $secretaried_clubs ) eq "ARRAY" ) {
      # If so, just push the ID and name on to the prePopulate array
      $tokeninput_secretary_options->{prePopulate} = [];
      push( @{ $tokeninput_secretary_options->{prePopulate} }, {id => $_->id, name => encode_entities( $_->full_name )} ) foreach ( @{ $secretaried_clubs } );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_secretary_options->{prePopulate} = [{id => $secretaried_clubs->id, name => encode_entities( $secretaried_clubs->full_name )}];
    }
  }
  
  ## Website users
  $tokeninput_user_options = {
    jsonContainer => "json_users",
    tokenLimit    => 1,
    hintText      => $c->maketext("user.tokeninput.type-person-association"),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Prioritise flashed values
  my $user = defined( $c->flash->{user} ) ? $c->flash->{user} : $person->user;
  
  # Add the pre-population if required
  $tokeninput_user_options->{prePopulate} = [{id => $user->id, name => encode_entities( $user->username )}] if defined( $user );
  
  # Stash the things we need to show the creation form
  $c->stash({
    template            => "html/people/create-edit.ttkt",
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/people/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    tokeninput_confs    => [{
      script    => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options   => encode_json( $tokeninput_team_options ),
      selector  => "team"
    }, {
      script    => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options   => encode_json( $tokeninput_captain_options ),
      selector  => "captain"
    }, {
      script    => $c->uri_for("/clubs/search"),
      options   => encode_json( $tokeninput_secretary_options ),
      selector  => "secretary"
    }, {
      script    => $c->uri_for("/users/search"),
      options   => encode_json( $tokeninput_user_options ),
      selector  => "username",
    }],
    form_action         => $c->uri_for_action("/people/do_edit", [$person->url_key]),
    person_season       => $person_season,
    action              => "edit",
    subtitle2           => "Edit",
    view_online_display => sprintf( "Editing %s", $person->display_name ),
    view_online_link    => 0,
    genders             => [ $c->model("DB::LookupGender")->search ],
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/people/edit", [$person->url_key]),
    label => "Edit",
  });
}

=head2 delete

Display the form for deleting the person.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $encoded_display_name = $c->stash->{encoded_display_name};
  
  # Check that we are authorised to delete people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_delete", $c->maketext("user.auth.delete-people"), 1] );
  
  unless ( $person->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/people/view_current_season", [$person->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "people.delete.error.played-matches", $encoded_display_name )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1           => $person->display_name,
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/people/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $person->display_name ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/people/delete", [$person->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a club. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c, $club_id ) = @_;
  my ( $person );
  
  # Check that we are authorised to create people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1] );
  
  # Stash the current location
  $c->stash({
    view_online_display => "Creating people",
    view_online_link    => 0,
  });
  
  # Forward to the create / edit routine
  $c->detach( "setup_person", ["create"] );
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to edit people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1] );
  
  # Stash the current location
  $c->stash({
    view_online_display => "Editing people",
    view_online_link    => 0,
  });
  
  # Forward to the create / edit routine
  $c->detach( "setup_person", ["edit"] );
}

=head2 do_delete

Process the deletion of a person

=cut

sub do_delete :Chained("base") :Path("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $person      = $c->stash->{person};
  my $person_name = $person->display_name;
  
  # Check that we are authorised to delete people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_delete", $c->maketext("user.auth.delete-people"), 1] );
  
  # Attempt to delete the person
  my $error = $person->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/people/view_current_season", [ $person->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["person", "delete", {id => undef}, $person_name] );
    $c->response->redirect( $c->uri_for("/people",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $person_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_person

A private routine forwarded from the docreate and doedit routines to set up the person.

=cut

sub setup_person :Private {
  my ( $self, $c, $action ) = @_;
  my $person = $c->stash->{person};
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined( $current_season ) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.create.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Foreign key checks
  my $gender  = $c->model("DB::LookupGender")->find( $c->request->parameters->{gender} ) if $c->request->parameters->{gender};
  my $team    = $c->model("DB::Team")->find_with_prefetches( $c->request->parameters->{team} ) if $c->request->parameters->{team};
  my $user    = $c->model("DB::User")->find( $c->request->parameters->{username} ) if $c->request->parameters->{username};
  
  # A person can be a captain / secretary of multiple teams / clubs respectively
  my @captain_ids = split(",", $c->request->parameters->{captain});
  my @captains    = map( $c->model("DB::Team")->find_with_prefetches( $_ ), @captain_ids );
  
  my @secretary_ids = split(",", $c->request->parameters->{secretary});
  my @secretaries   = map( $c->model("DB::Club")->find( $_ ), @secretary_ids );
  
  # Forward to the model to do the error checking / creation / editing
  my $details = $c->model("DB::Person")->create_or_edit($action, {  
    person            => $person,
    first_name        => $c->request->parameters->{first_name},
    surname           => $c->request->parameters->{surname},
    address1          => $c->request->parameters->{address1},
    address2          => $c->request->parameters->{address2},
    address3          => $c->request->parameters->{address3},
    address4          => $c->request->parameters->{address4},
    address5          => $c->request->parameters->{address5},
    postcode          => $c->request->parameters->{postcode},
    home_telephone    => $c->request->parameters->{home_telephone},
    mobile_telephone  => $c->request->parameters->{mobile_telephone},
    work_telephone    => $c->request->parameters->{work_telephone},
    email_address     => $c->request->parameters->{email_address},
    gender            => $gender,
    date_of_birth     => $c->request->parameters->{date_of_birth},
    team              => $team,
    captains          => \@captains,
    secretaries       => \@secretaries,
    registration_date => $c->request->parameters->{registration_date},
    fees_paid         => $c->request->parameters->{fees_paid},
    user              => $user,
    season            => $current_season,
    logger            => sub{ my $level = shift; $c->log->$level( @_ ); },
  });
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    # Stash the values we've got so we can set them
    $c->flash->{first_name}         = $c->request->parameters->{first_name};
    $c->flash->{surname}            = $c->request->parameters->{surname};
    $c->flash->{address1}           = $c->request->parameters->{address1};
    $c->flash->{address2}           = $c->request->parameters->{address2};
    $c->flash->{address3}           = $c->request->parameters->{address3};
    $c->flash->{address4}           = $c->request->parameters->{address4};
    $c->flash->{postcode}           = $c->request->parameters->{postcode};
    $c->flash->{home_telephone}     = $c->request->parameters->{home_telephone};
    $c->flash->{mobile_telephone}   = $c->request->parameters->{mobile_telephone};
    $c->flash->{work_telephone}     = $c->request->parameters->{work_telephone};
    $c->flash->{email_address}      = $c->request->parameters->{email_address};
    $c->flash->{date_of_birth}      = $c->request->parameters->{date_of_birth};
    $c->flash->{gender}             = $c->request->parameters->{gender};
    $c->flash->{team}               = $team;
    $c->flash->{captains}           = \@captains;
    $c->flash->{secretaries}        = \@secretaries;
    $c->flash->{registration_date}  = $c->request->parameters->{registration_date};
    $c->flash->{fees_paid}          = $c->request->parameters->{fees_paid};
    $c->flash->{user}               = $user;
    $c->flash->{team_changed}       = $details->{team_changed};
    $c->flash->{form_errored}       = 1; # We need to be able to check this so we know whether to set the checkbox based on the flash or stash value
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      # If we're creating, we'll just redirect straight back to the create form
      $redirect_uri = $c->uri_for_action("/people/create_no_team",
                            {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined($details->{person}) ) {
        # If we're editing and we found an object to edit, we'll redirect to the edit form for that object
        $redirect_uri = $c->uri_for_action("/people/edit", [ $details->{person}->url_key ],
                            {mid => $c->set_status_msg( {error => $error} ) });
      } else {
        # If we're editing and we didn't an object to edit, we'll redirect to the list of objects
        $redirect_uri = $c->uri_for("/people",
                            {mid => $c->set_status_msg( {error => $error} ) });
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $person = $details->{person};
    
    my $action_description = ( $action eq "create" ) ? "created" : "edited";
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["person", $action, {id => $person->id}, $person->display_name] );
    $c->response->redirect( $c->uri_for_action("/people/view_current_season", [$person->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $person->display_name, $c->maketext("admin.message.$action_description") ) }) }) );
    $c->detach;
    return;
  }
}

=head2 import

Display a file upload box to upload a CSV file.

=cut

sub import :Local {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1] );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined( $current_season ) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.import.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Stash the things we need to show the creation form
  $c->stash({
    template            => "html/people/import.ttkt",
    form_action         => "import-results",
    external_scripts    => [
      $c->uri_for("/static/script/people/import.js"),
    ],
    subtitle2           => $c->maketext("admin.import"),
    view_online_display => "Importing people",
    view_online_link    => 0,
  });
  
  if ( exists( $c->stash->{status_msg}{warning} ) ) {
    $c->stash->{status_msg}{warning} .= sprintf( "\n%s", $c->maketext("people.form.import.warning") );
  } else {
    $c->stash->{status_msg}{warning} = $c->maketext("people.form.import.warning");
  }
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import"),
  });
}

=head2 import_results

Validates an imported CSV file, displaying the contents back to the user so they can confirm that they wish to go ahead.

=cut

sub import_results :Path("import-results") {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1] );
  
  # Set up the allowed file types
  my @allowed_types = qw( text/plain text/csv );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  if ( defined( $current_season ) ) {
    # Stash the current season
    $c->stash({season => $current_season});
  } else {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.import.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Check we have an upload
  if ( my $upload = $c->request->upload("import_file") ) {
    # File uploaded, get the MIME type
    my $filename  = $upload->filename;
    my $mt        = MIME::Types->new( only_complete => 1 );
    my $mime_type = $mt->mimeTypeOf($filename)->type;
    if ( grep( $_ eq $mime_type, @allowed_types ) ) {
      # File is valid, pass the filehandle to the processing routine
      $c->forward( "process_csv", [{filehandle => $upload->fh}] );
      
      # Add the messages
      $c->add_status_message( "success", $c->maketext("people.form.import-results.successfully-imported", scalar( @{ $c->flash->{successful_rows} } )) ) if exists( $c->flash->{successful_rows} ) and ref( $c->flash->{successful_rows} ) eq "ARRAY";
      $c->add_status_message( "error", $c->maketext("people.form.import-results.import-failures", scalar( @{ $c->flash->{failed_rows} } )) ) if exists( $c->flash->{failed_rows} ) and ref( $c->flash->{failed_rows} ) eq "ARRAY" and scalar( @{ $c->flash->{failed_rows} } ) > 0;
      
      # Stash the template
      $c->stash({
        template  => "html/people/import-results.ttkt",
        subtitle2           => $c->maketext("people.form.import-results.title"),
        view_online_display => "Importing people",
        external_scripts    => [
          $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
          $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
          $c->uri_for("/static/script/people/import-results.js", {v => 2}),
        ],
        external_styles     => [
          $c->uri_for("/static/css/chosen/chosen.min.css"),
          $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
        ],
      });
    } else {
      # File type not allowed
      $c->response->redirect( $c->uri_for("/people/import",
                                  {mid => $c->set_status_msg( {error => $c->maketext("people.form.import-results.invalid-file-type") } ) }) );
      $c->detach;
      return;
    }
  } else {
    # No file uploaded
    $c->response->redirect( $c->uri_for("/people/import",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.form.import-results.no-file-uploaded") } ) }) );
    $c->detach;
    return;
  }
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import"),
  }, {
    path  => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import-results"),
  });
}

=head2 process_csv

Process the CSV file, either passing the data off to setup the people if we've validated / confirmed it, or validate it for confirmation to the user.

=cut

sub process_csv :Private {
  my ( $self, $c, $parameters ) = @_;
  #my $parameters    = $c->request->arguments->[0];
  my $fh            = $parameters->{filehandle};
  my $validate      = $parameters->{validate};
  my $return_value  = {};
  my $csv           = Text::CSV->new or die "Cannot use CSV: " . Text::CSV->error_diag;
  
  # This will hold the data we read in.  It will largely resemble what should go into a ->populate command,
  # but not quite because we need the return values to potentially update clubs and teams with secretaries
  # and captains.
  my @people = ();
  
  # This holds the field position numbers for each field name (zero-based so we can use the array index without minusing the value)
  my @people_field_positions = ();
  
  # Loop through the file lines (one person per line)
  # Keep a line count so we know if we're on the first line (headings)
  my $i = 0;
  while ( my $line = $csv->getline( $fh ) ) {
    # Chomp the line to remove new lines at the end
    #chomp( $line );
    
    # Next line if this one is blank
    next if !scalar @{ $line };
    
    # Increase line number
    $i++;
    
    # Loop through the fields
    my $x = 0;
    foreach my $field ( @{ $line } ) {
      #chomp( $field );
      
      if ( $i == 1 ) {
        # First line: column headers; set them up as field names
        # We need to check the column exists or is one of our pre-defined 'other' columns
        if ( $c->model("DB")->schema->source("Person")->has_column( $field ) or $field eq "club" or $field eq "team" or $field eq "captain_club" or $field eq "captain_team" or $field eq "secretary_club" or $field eq "user" ) {
          # Field exists or is a special field to add some related data; save the field position number
          push( @people_field_positions, $field );
        } else {
          # Field not recognised
          $return_value->{error} .= $c->maketext("people.form.import-results.field-heading-invalid", $field);
        }
      } else {
        # Column data, push the value on to this field's column (or undef if it's blank)
        # First we need this column's name, which we can work out from the array we built
        # up on the first row
        my $field_name = $people_field_positions[$x] || undef;
        
        # Array index is the line number less 2 - this is because the first row is for headings and arrays are zero-based
        my $array_index = $i - 2;
        
        # Assign the field's value to a hashref with its name as the key
        $people[$array_index]{$field_name} = $field || undef;
      }
      
      # Increment column number so we can store where this field occurs when we come to find the data
      $x++;
    }
    
    if ( $i > 1 ) {
      my $array_index = $i - 2;
      $people[$array_index]{line} = $line;
    }
  }
  
  # Close the file after looping through
  $fh->close;
  
  # These arrays will hold the successful and failed rows for display and the event log details so we only need to call the system event log add once
  my ( @successful_rows, @failed_rows, @event_log_ids, @event_log_names );
  
  # End of loop through data, now loop through and do some sanity checks
  # We can't do a normal foreach, as we need to keep the index so we can splice if needed
  # Loop through in reverse so that when we splice, we don't end up missing rows
  # Because we're looping through in reverse, we will reverse it first so that we actually loop through in the right order
  @people = reverse @people;
  foreach my $i ( reverse 0 .. $#people ) {
    # The CSV file row will be $i + 2 (as arrays are zero-based and we allow one row for the heading)
    my $csv_row = $i + 2;
    
    # Save the names of fields that refer to foreign tables for displaying later and validate them
    $people[$i]{club_name}            = $people[$i]{club};
    $people[$i]{team_name}            = $people[$i]{team};
    $people[$i]{captain_club_name}    = $people[$i]{captain_club};
    $people[$i]{captain_team_name}    = $people[$i]{captain_team};
    $people[$i]{secretary_club_name}  = $people[$i]{secretary_club};
    $people[$i]{gender_name}          = $people[$i]{gender};
    
    # Validate the playing team if there is one
    my $returned_team = $c->forward( "validate_team_for_player", [ $people[$i]{club}, $people[$i]{team}, "playing" ] );
    $people[$i]{club} = $returned_team->{club};
    $people[$i]{team} = $returned_team->{team};
    $people[$i]{error} .= $returned_team->{error} if defined( $returned_team->{error} );
    
    # Validate the captained team if there is one
    my $returned_captain_team = $c->forward( "validate_team_for_player", [ $people[$i]{captain_club}, $people[$i]{captain_team}, "captained" ] );
    $people[$i]{captain_club} = $returned_captain_team->{club};
    $people[$i]{captain_team} = $returned_captain_team->{team};
    $people[$i]{error} .= $returned_captain_team->{error} if defined( $returned_captain_team->{error} );
    
    # Validate the club that this person secretaries if there is one
    if ( defined( $people[$i]{secretary_club} ) ) {
      $people[$i]{secretary_club} = $c->model("DB::Club")->find_by_short_name( $people[$i]{secretary_club} );
      $people[$i]{error} .= sprintf( "%s\n", $c->maketext("people.form.import-results.secretary-club-invalid") ) unless defined( $people[$i]{secretary_club} );
    }
    
    # Validate the gender if there is one
    if ( defined( $people[$i]{gender} ) ) {
      $people[$i]{gender} = $c->model("DB::LookupGender")->find({ id => $people[$i]{gender} });
      $people[$i]{error} .= sprintf( "%s\n", $c->maketext("people.form.import-results.gender-invalid") ) unless defined( $people[$i]{gender} );
    }
    
    # Validate the website user if there is one
    if ( defined( $people[$i]{user} ) ) {
      $people[$i]{user} = $c->model("DB::User")->find_by_name( $people[$i]{user} );
      $people[$i]{error} .= sprintf( "%s\n", $c->maketext("people.form.import-results.username-invalid") ) unless defined( $people[$i]{user} );
    }
    
    # The create / edit routine expects the captains and secretaries in an array
    if ( defined( $people[$i]{captain_team} ) ) {
      $people[$i]{captains} = [ $people[$i]{captain_team} ];
    } else {
      $people[$i]{captains} = [];
    }
    
    if ( defined ( $people[$i]{secretary_club} ) ) {
      $people[$i]{secretaries} = [ $people[$i]{secretary_club} ];
    } else {
      $people[$i]{secretaries} = [];
    }
    
    # If we had an (some) error(s) on this row, we'll need to splice it out and append it (them) to the main returned error
    if ( $people[$i]{error} ) {
      # Push our failed row on to the failed rows array
      push( @failed_rows, $people[$i] );
    } else {
      # Add the current season in so the create or edit routine can check it
      $people[$i]{season} = $c->stash->{season};
      
      # No error, pass on to the creation routine, which does the rest of the checking first
      my $create_result   = $c->model("DB::Person")->create_or_edit("create", $people[$i]);
      $people[$i]{person} = $create_result->{person};
      
      # Check for errors
      if ( scalar( @{ $create_result->{error} } ) ) {
        # If there are errors, we need to push this row on to the failed rows array after assigning the error in the array row
        $people[$i]{error} = $c->build_message( $create_result->{error} );
        push( @failed_rows, $people[$i] );
      } else {
        # Success, push the row on to the successful rows array after adding the new person object on to the hashref
        push( @successful_rows, $people[$i] );
        
        # Push the event log details we'll need
        push( @event_log_ids, {id => $people[$i]{person}->id} );
        push( @event_log_names, $people[$i]{person}->display_name );
      }
    }
    
    # Increment the index for the next iteration
    $i++;
  }
  
  # Add an event log for all the successful rows we had
  $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["person", "import", \@event_log_ids, \@event_log_names] ) if scalar( @successful_rows );
  
  # Flash the successful / failed rows
  $c->flash->{successful_rows}  = \@successful_rows;
  $c->flash->{failed_rows}      = \@failed_rows;
}

=head2 validate_team_for_player

Validates that a player can be added to the specified team when importing from a CSV file.

=cut

sub validate_team_for_player :Private {
  my ( $self, $c, $club_short_name, $team_name, $type ) = @_;
  my ( $club, $team, $error );
  
  # Replace the foreign key fields with DB objects
  if ( defined( $club_short_name ) ) {
    # Save the club object to the club
    $club = $c->model("DB::Club")->find_by_short_name( $club_short_name );
    
    # If it's now undefined, we'll raise an error
    if ( defined( $club ) ) {
      # The club is valid; make sure we have a team supplied
      if ( defined( $team_name ) ) {
        # Ensure the team is valid in this club
        $team = $c->model("DB::Team")->find_by_name_in_club( $club, $team_name );
        
        $error .= sprintf( "%s\n", $c->maketext("people.form.import-results.team-not-in-club", $type, encode_entities( $club->full_name ) ) ) unless defined( $team );
      } else {
        # If there's a club but no team, that's an error
        $error .= sprintf("%s\n", $c->maketext("people.form.import-results.team-not-specified", $type));
      }
    } else {
      # Error, invalid club
      $error .= sprintf( "%s\n", $c->maketext("people.form.import-results.club-invalid", $type) );
    }
  } elsif ( defined( $team ) ) {
    # Specifying a team but no club is an error
    $error .= sprintf( "%s\n", $c->maketext("people.form.import-results.club-not-specified", $type) );
  }
  
  return {
    club  => $club,
    team  => $team,
    error => $error
  };
}

=head2 search

Handle search requests and return the data in JSON.

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1] );
  
  my $q = $c->req->param( "q" ) || undef;
  
  $c->stash({
    db_resultset => "Person",
    query_params => {q => $q},
    view_action => "/people/view_current_season",
    search_action => "/people/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.people") ),
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
