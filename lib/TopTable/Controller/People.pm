package TopTable::Controller::People;
use Moose;
use namespace::autoclean;
use JSON;
use MIME::Types;
use Text::CSV;
use HTML::Entities;
use JSON;

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
  $c->stash({subtitle1 => $c->maketext("menu.text.person")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    # Listing
    path => $c->uri_for("/people"),
    label => $c->maketext("menu.text.person"),
  });
}

=head2 base

Chain base for getting the person ID and checking it.

=cut

sub base :Chained("/") PathPart("people") CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  my $person = $c->model("DB::Person")->find_id_or_url_key($id_or_url_key);
  
  if ( defined($person) ) {
    my $enc_first_name = encode_entities($person->first_name);
    my $enc_display_name = encode_entities($person->display_name);
    
    $c->stash({
      person => $person,
      enc_first_name => $enc_first_name,
      enc_display_name => $enc_display_name,
      subtitle1 => $enc_display_name,
    });
    
    $c->stash->{noindex} = 1 if $person->noindex;
    
    # Push the people list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/people/view_current_season", [$person->url_key]),
      label => $enc_display_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of people.  Matches /people

=cut

sub base_list :Chained("/") :PathPart("people") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  
  # Check the authorisation to edit people we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( person_edit person_delete person_create)], "", 0]);
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.people.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the people on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach("retrieve_paged", [1]);
  $c->stash({canonical_uri => $c->uri_for_action("/people/list_first_page")});
}

=head2 list_specific_page

List the people on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined($page_number) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/people/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/people/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for people with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  my $person = $c->stash->{person};
  
  my $people = $c->model("DB::Person")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $noindex_count = $people->noindex_set_paged_count(1);
  
  my $page_info = $people->pager;
  my $page_links  = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/people/list_first_page",
    specific_page_action => "/people/list_specific_page",
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/people/list.ttkt",
    view_online_display => "Viewing people",
    view_online_link => 1,
    people => $people,
    page_info => $page_info,
    page_links => $page_links,
  });
  
  $c->stash->{noindex} = 1 if $noindex_count;
}

=head2 base_no_object_specified

Base URL matcher with no person specified (use in the create routines).  Doesn't actually do anything other than the URL matching.

=cut

sub base_no_object_specified :Chained("/") :PathPart("people") :CaptureArgs(0) {}

=head2 view

View a person's details.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view teams
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( person_edit person_create person_delete person_contact_view )], "", 0]);
}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $person_name = $c->stash->{enc_display_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.people.view-current", $person_name, $site_name),
    });
    
    # Forward to the routine that stashes the person's season
    $c->forward("get_person_season");
  }
  
  # Finalise the view routine
  $c->detach("view_finalise") unless exists ($c->stash->{delete_screen});
}

=head2 view_specific_season

View a team with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $person = $c->stash->{person};
  my $site_name = $c->stash->{enc_site_name};
  my $person_name = $c->stash->{enc_display_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.people.view-specific", $person_name, $enc_season_name, $site_name),
    });
  } else {
    # Invalid season
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_person_season");
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/people/view_seasons", [$person->url_key]),
    label => $c->maketext("menu.text.season"),
  }, {
    path => $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key]),
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
  my ( $person, $season, $person_name ) = ( $c->stash->{person}, $c->stash->{season}, $c->stash->{enc_display_name} );
  
  my $teams = $c->model("DB::PersonSeason")->get_person_season_and_teams_and_divisions({
    person => $person,
    season => $season,
  });
  
  my $team_season = $teams->first;
  my $person_season_name = encode_entities($team_season->display_name) if defined($team_season);
  
  # If the name has changed, we need to display a notice
  $c->add_status_messages({info => $c->maketext("people.name.changed-notice", $person_season_name, $person_name)}) if defined($person_season_name) and $person_name ne $person_season_name;
  
  # Grab the games
  my $singles_games = $person->singles_games_played_in_season({season => $season});
  my $doubles_games = $person->doubles_games_played_in_season({season => $season});
  
  if ( !exists($c->stash->{noindex}) or !$c->stash->{noindex} ) {
    # If this person isn't set to 'noindex', check if any of the people they've played in this season are - no point in doing this expensive query if the person is already
    # set to noindex
    my $noindex = $doubles_games->noindex_set(1)->count;
    $noindex = $singles_games->noindex_set(1)->count unless $noindex; # Only do this one if the doubles games don't show up anything
    
    $c->stash->{noindex} = 1 if $noindex;
  }
  
  $c->stash({
    subtitle1 => $person_season_name || $person_name,
    teams => $teams,
    types => scalar $c->model("DB::PersonSeason")->get_team_membership_types_for_person_in_season({
      person => $person,
      season => $season,
    }),
    singles_games => $singles_games,
    doubles_games => $doubles_games,
    season => $season,
    loan_matches => scalar $person->matches_on_loan({season => $season}),
    inactive_memberships => scalar $person->inactive_memberships({season => $season}),
    captaincies => scalar $person->captaincies({season => $season}),
    secretaryships => scalar $person->secretaryships({season => $season}),
    officialdoms => scalar $person->officialdoms({season => $season}),
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $season = $c->stash->{season};
  my $enc_display_name = $c->stash->{enc_display_name};
  
  # Get the list of seasons they have played in
  my $person_seasons = $c->model("DB::PersonSeason")->get_all_seasons_a_person_played_in($person);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext( "admin.edit-object", $enc_display_name ),
    link_uri => $c->uri_for_action("/people/edit", [$person->url_key]),
  }) if $c->stash->{authorisation}{person_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text => $c->maketext("admin.delete-object", $enc_display_name),
    link_uri => $c->uri_for_action("/people/delete", [$person->url_key]),
  }) if $c->stash->{authorisation}{person_delete} and $person->can_delete;
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key])
    : $c->uri_for_action("/people/view_current_season", [$person->url_key]);
  
  my @tokeninput_confs = ();
  my @scripts = ("tokeninput-head-to-head-singles");
  
  my @head_to_heads;
  if ( my $opponent = $c->req->params->{opponent} ) {
    # Add the pre-population if required
    $opponent = $c->model("DB::Person")->find_id_or_url_key($opponent);
    
    if ( defined($opponent) ) {
      $c->stash({opposition_ti_prepopulate => encode_json([{id => $opponent->url_key, name => encode_entities($opponent->display_name)}])});
      
      # We need this as an array to A) suppress the eager slurp due to order criteria warning and B) so we can map each row and format some dates into a hashref
      @head_to_heads = $person->head_to_heads({opponent => $opponent})->all;
    }
  }
  
  if ( $c->stash->{authorisation}{person_edit} and $c->config->{Players}{show_transfer_form} ) {
    my $transfer_tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => encode_entities($c->maketext("tokeninput.text.no-results")),
      searchingText => encode_entities($c->maketext("tokeninput.text.searching")),
    };
    
    # Add the pre-population if required
    $transfer_tokeninput_options->{prePopulate} = [{id => $c->flash->{to}->id, name => encode_entities($c->flash->{to}->display_name) }] if defined($c->flash->{to});
    
    push(@tokeninput_confs, {
      script => $c->uri_for("/people/search"),
      options => encode_json($transfer_tokeninput_options),
      selector => "to",
    });
    
    push(@scripts, "tokeninput-standard");
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/people/view.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing %s", $enc_display_name),
    view_online_link => 1,
    person_seasons => $person_seasons,
    seasons => $person_seasons->count,
    head_to_heads => \@head_to_heads,
    canonical_uri => $canonical_uri,
    scripts => \@scripts,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.select.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.searchPanes.min.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/messages.js"),
      $c->uri_for("/static/script/people/view.js", {v => 3}),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/select.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/searchPanes.dataTables.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
    ],
    tokeninput_confs => \@tokeninput_confs,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this person has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $site_name = $c->stash->{enc_site_name};
  my $person_name = $c->stash->{enc_display_name};
  
  my $seasons = $person->get_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/people/seasons.js"),
    ];
    $ext_styles = [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ];
  } else {
    $ext_scripts = [$c->uri_for("/static/script/standard/option-list.js")];
    $ext_styles = [];
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/people/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.season"),
    page_description => $c->maketext("description.people.list-seasons", $person_name, $site_name),
    view_online_display => sprintf("Viewing seasons for %s", $person->display_name),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/people/view_seasons", [$person->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 head_to_head

Head-to-head form processing, routed to a form submission, or an AJAX query.

=cut

sub head_to_head :Chained("base") :PathPart("head-to-head") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $opponent = $c->req->params->{opponent};
  
  my @errors = ();
  if ( defined($opponent) ) {
    # Validate the opponent is valid
    $opponent = $c->model("DB::Person")->find_id_or_url_key($opponent);
    
    if ( defined($opponent) ) {
      # Valid person - simple check that they're not the same as the other person
      push(@errors, $c->maketext("people.head-to-head.error.same-opponent-as-person", $c->stash->{enc_display_name})) if $person->id == $opponent->id;
    } else {
      # Invalid person
      push(@errors, $c->maketext("people.head-to-head.error.invalid-person"));
    }
  } else {
    # Nobody specified, error
    push(@errors, $c->maketext("people.head-to-head.error.nobody-specified"));
  }
  
  if ( $c->is_ajax ) {
    # Do the query,rReturn with JSON
    if ( scalar(@errors) ) {
      # Stash the messages
      $c->stash({json_data => {messages => {error => \@errors}}});
      
      # Change the response code if we didn't complete
      $c->res->status(400);
      
      # Detach to the JSON view
      $c->detach($c->view("JSON"));
      return;
    }
    
    my @head_to_heads = $person->head_to_heads({opponent => $opponent})->all;
    
    # Maps into a hashref, keys: db, table (table of data we need to populate with DataTables)
    # This is bad and probably needs to be improved, as it makes the controller very fat, but
    # I'm struggling to work out another way at the moment.
    @head_to_heads = map{
      # Map our variables into the hash
      my $game = $_;
      my ( $for_team, $against_team, $for_team_name, $against_team_name );
      
      # Grah the match / teams
      my $match = $game->team_match;
      my $home_team = $match->team_season_home_team_season;
      my $away_team = $match->team_season_away_team_season;
      
      # Set the dates
      my $date = $match->actual_date;
      $date->set_locale($c->locale);
      my $location = $game->home_player->id == $person->id ? "home" : "away";
      
      if ( $location eq "home" ) {
        $for_team = $home_team;
        $against_team = $away_team;
      } else {
        $for_team = $away_team;
        $against_team = $home_team;
      }
      
      my ( $score, $leg_scores, $leg_number, $result );
      if ( $game->started ) {
        $leg_scores = "";
        my $detailed_scores = $game->detailed_scores;
        
        $leg_number = 1;
        
        foreach my $leg_score ( @{$detailed_scores} ) {
          if ( $leg_number > 1 ) {
            $leg_scores .= ", ";
          }
          
          $leg_scores .= $leg_score->{home} . '-' . $leg_score->{away};
          $leg_number++;
        }
        
        $score = $game->summary_score;
        $score = sprintf("%s-%s", $score->{home}, $score->{away});
      } else {
        # The game is marked as complete, but not started - score is not applicable, as it's been awarded
        $leg_scores = $c->maketext("msg.not-applicable");
        $score = $c->maketext("msg.not-applicable");
      }
      
      if ( $game->winner->id == $for_team->id ) { 
        $result = $c->maketext("matches.result.win");
      } elsif ( $game->winner->id == $against_team->id ) {
        $result = $c->maketext("matches.result.loss");
      } else {
        $result = $c->maketext("matches.result.draw");
      }
      
      my $season = $match->season;
      
      # Return the hashref
      {
        season => {
          display => encode_entities($season->name),
          uri => $c->uri_for_action("/seasons/view", [$season->url_key])->as_string,
        },
        date => {display => $c->i18n_datetime_format_date->format_datetime($date)},
        "date-sort" => {display => $date->ymd},
        division => {
          display => encode_entities($match->division_season->name),
          uri => $c->uri_for_action("/league-averages/view_specific_season", ["singles", $match->division_season->division->url_key, $season->url_key])->as_string,
        },
        "division-rank" => {display => $match->division_season->division->rank},
        "for-team" => {
          display => encode_entities(sprintf("%s %s", $for_team->club_season->short_name, $for_team->name)),
          uri => $c->uri_for_action("/teams/view_specific_season_by_url_key", [$for_team->club_season->club->url_key, $for_team->team->url_key, $season->url_key])->as_string,
        },
        "against-team" => {
          display => encode_entities(sprintf("%s %s", $against_team->club_season->short_name, $against_team->name)),
          uri => $c->uri_for_action("/teams/view_specific_season_by_url_key", [$against_team->club_season->club->url_key, $against_team->team->url_key, $season->url_key])->as_string,
        },
        "game-score" => {display => $score},
        scores => $game->detailed_scores,
        result => {
          display => $result,
          uri => $c->uri_for_action("/matches/team/view_by_url_keys", $match->url_keys)->as_string,
        },
        venue => {
          display => encode_entities($match->venue->name),
          uri => $c->uri_for_action("/venues/view", [$match->venue->url_key])->as_string,
        },
      }
    } @head_to_heads;
    
    # No errors, get the data
    $c->stash({
      json_data => {
        table => \@head_to_heads,
      }
    });
    
    # Detach to the JSON view
    $c->detach($c->view("JSON"));
  } else {
    # Redirect to the person view page, which will perform the query and display the data
    # Figure out if it's a specific season or not from form data
    my $season = $c->model("DB::Season")->find_id_or_url_key($c->req->params->{season}) if exists($c->req->params->{season});
    
    if ( scalar(@errors) ) {
      my $mid = {mid => $c->set_status_msg({error => \@errors})};
      my $redirect_uri = defined($season)
        ? $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key], $mid, \"head-to-head")
        : $c->uri_for_action("/people/view_current_season", [$person->url_key], $mid, \"head-to-head");
      
      $c->res->redirect($redirect_uri);
      $c->detach;
      return;
    }
    
    my $query_data = {opponent => $opponent->url_key};
    my $redirect_uri = defined($season)
      ? $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key], $query_data, \"head-to-head")
      : $c->uri_for_action("/people/view_current_season", [$person->url_key], $query_data, \"head-to-head");
    
    # Redirect - no need for a status message
    $c->res->redirect($redirect_uri);
    $c->detach;
    return;
  }
}

=head2 create

Display a form to collect information for creating a club

=cut

sub create :Chained("base_no_object_specified") :PathPart("create") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1]);
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("people.create.no-season")})}));
    $c->detach;
    return;
  }
  
  # Set up the tokeninputs
  my ( $tokeninput_team_options, $tokeninput_captain_options, $tokeninput_secretary_options, $tokeninput_user_options );
  
  ## Team played for
  $tokeninput_team_options = {
    jsonContainer => "json_search",
    tokenLimit => 1,
    hintText => $c->maketext("teams.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Add the pre-population if required
  $tokeninput_team_options->{prePopulate} = [{id => $c->flash->{team}->id, name => encode_entities(sprintf("%s %s", $c->flash->{team}->club->short_name, $c->flash->{team}->name))}] if defined($c->flash->{team});
  
  ## Team(s) captained
  $tokeninput_captain_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("teams.tokeninput.type-captain"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Check if we have teams flashed to be captain for
  if ( defined( $c->flash->{captain_of} ) ) {
    # If so check if it's an arrayref
    if ( ref($c->flash->{captain_of}) eq "ARRAY" ) {
      # If so, just map the ID and name on to the prePopulate array
      $tokeninput_captain_options->{prePopulate} = [];
      push(@{$tokeninput_captain_options->{prePopulate}}, {id => $_->id, name => encode_entities(sprintf("%s %s", $_->club->short_name, $_->name))}) foreach @{$c->flash->{captain_of}};
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_captain_options->{prePopulate} = [{id => $c->flash->{captain_of}->id, name => encode_entities($c->flash->{captain_of}->name)}];
    }
  }
  
  ## Club(s) secretaried
  $tokeninput_secretary_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("clubs.tokeninput.type-secretary"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Check if we have clubs flashed to be secretary for
  if ( defined($c->flash->{secretary_of}) ) {
    # If so check if it's an arrayref
    if ( ref($c->flash->{secretary_of}) eq "ARRAY" ) {
      # If so, just push the ID and name on to the prePopulate array
      $tokeninput_secretary_options->{prePopulate} = [];
      push(@{$tokeninput_secretary_options->{prePopulate}}, {id => $_->id, name => encode_entities($_->full_name)} ) foreach @{$c->flash->{secretary_of}};
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_secretary_options->{prePopulate} = [{id => $c->flash->{secretary_of}->id, name => encode_entities($c->flash->{secretary_of}->full_name)}];
    }
  }
  
  ## Website users
  $tokeninput_user_options = {
    jsonContainer => "json_search",
    tokenLimit => 1,
    hintText => $c->maketext("user.tokeninput.type-person-association"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Add the pre-population if required
  $tokeninput_user_options->{prePopulate} = [{id => $c->flash->{user}->id, name => encode_entities($c->flash->{user}->username)}] if defined($c->flash->{user});
  
  # Stash the things we need to show the creation form
  $c->stash({
    template => "html/people/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/people/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    tokeninput_confs => [{
      script => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options => encode_json($tokeninput_team_options),
      selector => "team"
    }, {
      script => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options => encode_json($tokeninput_captain_options),
      selector => "captain_of"
    }, {
      script => $c->uri_for("/clubs/search"),
      options => encode_json($tokeninput_secretary_options),
      selector => "secretary_of"
    }, {
      script => $c->uri_for("/users/search"),
      options => encode_json($tokeninput_user_options),
      selector => "user",
    }],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating people",
    view_online_link => 0,
    genders => scalar $c->model("DB::LookupGender")->search,
    action => "create",
  });
  
  # Append an information notice to this page
  $c->add_status_messages({info => $c->maketext("people.create.form.import-notice", $c->uri_for("/people/import"))});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/people/create_no_team"),
    label => $c->maketext("admin.create"),
  });
}

=head2 create_with_team_by_url_key

Matches a URL to create a person with the team specified by URL key.

=cut

sub create_with_team_by_url_key :Chained("create") :PathPart("team") :Args(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  my $club = $c->model("DB::Club")->find_url_key($club_url_key);
  my $team = $c->model("DB::Team")->find_url_key($club, $team_url_key) if defined ($club);
  
  $c->stash->{team} = $team;
  $c->forward("create_with_team");
}

=head2 create_with_team_by_id

Matches a URL to create a person with the team specified by URL key.

=cut

sub create_with_team_by_id :Chained("create") :PathPart("team") :Args(1) {
  my ( $self, $c, $team_id ) = @_;
  
  my $team = $c->model("DB::Team")->find( $team_id );
  
  $c->stash->{team} = $team;
  $c->forward("create_with_team");
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
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("teams.tokeninput.type"),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
      prePopulate => [{id => $team->id, name => encode_entities(sprintf("%s %s", $team->club->short_name, $team->name))}],
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
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
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);

  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1]);
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("people.edit.no-season")})}));
    $c->detach;
    return;
  }
  
  # Get the season for this person
  my $person_season = $c->model("DB::PersonSeason")->get_active_person_season_and_team($person, $current_season);
  
  ### Set up the tokeninputs
  my ( $tokeninput_team_options, $tokeninput_captain_options, $tokeninput_secretary_options, $tokeninput_user_options );
  
  ## Team played for
  $tokeninput_team_options = {
    jsonContainer => "json_search",
    tokenLimit => 1,
    hintText => $c->maketext("teams.tokeninput.type"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Add the pre-population if required
  
  # If there's no flash value for team, set it to the person's current team.
  if ( !defined($c->flash->{teams}) ) {
    if ( defined($person_season) ) {
      $c->flash->{teams} = [$person_season->team];
    } else {
      $c->flash->{teams} = [];
    }
  }
  
  # Set up which pre-population to use - flash if it's defined, otherwise the team season
  my $pre_populate_team;
  if ( defined($c->flash->{team}) ) {
    $pre_populate_team = $c->flash->{team};
  } else {
    $pre_populate_team = $person_season->team_season->team if defined($person_season);
  }
  
  $tokeninput_team_options->{prePopulate} = [{id => $pre_populate_team->id, name => encode_entities(sprintf("%s %s", $pre_populate_team->club->short_name, $pre_populate_team->name))}] if defined($pre_populate_team);
  
  ## Team(s) captained
  $tokeninput_captain_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("teams.tokeninput.type-captain"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Prioritise flashed teams for the prepopulation
  my $captained_teams;
  if ( defined($c->flash->{captain_of}) ) {
    $captained_teams = $c->flash->{captain_of};
  } else {
    $captained_teams = [$c->model("DB::Team")->get_teams_with_specified_captain($person, $current_season)];
  }
  
  # Check if we have teams flashed to be captain for
  if ( defined($captained_teams) ) {
    # If so check if it's an arrayref
    if ( ref($captained_teams) eq "ARRAY" ) {
      # If so, just map the ID and name on to the prePopulate array
      $tokeninput_captain_options->{prePopulate} = [];
      push(@{$tokeninput_captain_options->{prePopulate}}, {id => $_->id, name => encode_entities( sprintf( "%s %s", $_->club->short_name, $_->name ) )} ) foreach ( @{$captained_teams} );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_captain_options->{prePopulate} = [{id => $captained_teams->id, name => encode_entities($captained_teams->name)}];
    }
  }
  
  ## Club(s) secretaried
  $tokeninput_secretary_options = {
    jsonContainer => "json_search",
    hintText => $c->maketext("clubs.tokeninput.type-secretary"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Prioritise flashed values
  my $secretaried_clubs;
  if ( defined( $c->flash->{secretary_of} ) ) {
    $secretaried_clubs = $c->flash->{secretary_of};
  } else {
    $secretaried_clubs = [$c->model("DB::Club")->with_secretary($person)];
  }
  
  # Check if we have clubs flashed to be secretary for
  if ( defined($secretaried_clubs) ) {
    # If so check if it's an arrayref
    if ( ref($secretaried_clubs) eq "ARRAY" ) {
      # If so, just push the ID and name on to the prePopulate array
      $tokeninput_secretary_options->{prePopulate} = [];
      push(@{$tokeninput_secretary_options->{prePopulate}}, {id => $_->id, name => encode_entities($_->full_name)} ) foreach ( @{$secretaried_clubs} );
    } else {
      # If not, there must only be one - set it in and enclose it in square brackets to make it an arrayref
      $tokeninput_secretary_options->{prePopulate} = [{id => $secretaried_clubs->id, name => encode_entities($secretaried_clubs->full_name)}];
    }
  }
  
  ## Website users
  $tokeninput_user_options = {
    jsonContainer => "json_search",
    tokenLimit => 1,
    hintText => $c->maketext("user.tokeninput.type-person-association"),
    noResultsText => $c->maketext("tokeninput.text.no-results"),
    searchingText => $c->maketext("tokeninput.text.searching"),
  };
  
  # Prioritise flashed values
  my $user = defined($c->flash->{user}) ? $c->flash->{user} : $person->user;
  
  # Add the pre-population if required
  $tokeninput_user_options->{prePopulate} = [{id => $user->id, name => encode_entities($user->username)}] if defined( $user );
  
  # Stash the things we need to show the creation form
  $c->stash({
    template => "html/people/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/people/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
    ],
    tokeninput_confs => [{
      script => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options => encode_json($tokeninput_team_options),
      selector => "team"
    }, {
      script => $c->uri_for("/teams/search", {season => $current_season->url_key}),
      options => encode_json($tokeninput_captain_options),
      selector => "captain_of"
    }, {
      script => $c->uri_for("/clubs/search"),
      options => encode_json($tokeninput_secretary_options),
      selector => "secretary_of"
    }, {
      script => $c->uri_for("/users/search"),
      options => encode_json($tokeninput_user_options),
      selector => "user",
    }],
    form_action => $c->uri_for_action("/people/do_edit", [$person->url_key]),
    person_season => $person_season,
    action => "edit",
    subtitle2 => "Edit",
    view_online_display => sprintf( "Editing %s", $person->display_name ),
    view_online_link => 0,
    genders => scalar $c->model("DB::LookupGender")->search,
    action => "edit",
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/people/edit", [$person->url_key]),
    label => "Edit",
  });
}

=head2 delete

Display the form for deleting the person.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $enc_display_name = $c->stash->{enc_display_name};
  
  # Check that we are authorised to delete people
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["person_delete", $c->maketext("user.auth.delete-people"), 1] );
  
  unless ( $person->can_delete ) {
    $c->response->redirect( $c->uri_for_action("/people/view_current_season", [$person->url_key],
                                {mid => $c->set_status_msg( {error => $c->maketext( "people.delete.error.played-matches", $enc_display_name )} ) }) );
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => $person->display_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/people/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $person->display_name),
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/people/delete", [$person->url_key]),
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
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1]);
  
  # Stash the current location
  $c->stash({
    view_online_display => "Creating people",
    view_online_link => 0,
  });
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a club. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to edit people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1]);
  
  # Stash the current location
  $c->stash({
    view_online_display => "Editing people",
    view_online_link => 0,
  });
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion of a person

=cut

sub do_delete :Chained("base") :Path("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $person = $c->stash->{person};
  my $person_name = $person->display_name;
  
  # Check that we are authorised to delete people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_delete", $c->maketext("user.auth.delete-people"), 1]);
  
  # Attempt to delete the person
  my $response = $person->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/people", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["person", "delete", {id => undef}, $person_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/people/view_current_season", [$person->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

A private routine forwarded from the docreate and doedit routines to set up the person.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $person = $c->stash->{person};
  my @field_names = qw( first_name surname change_name_prev_seasons address1 address2 address3 address4 address5 postcode home_telephone mobile_telephone work_telephone email_address gender team fees_paid user noindex );
  my @processed_field_names = qw( first_name surname change_name_prev_seasons address1 address2 address3 address4 address5 postcode home_telephone mobile_telephone work_telephone email_address gender date_of_birth team captain_of secretary_of registration_date fees_paid user noindex );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined( $current_season ) ) {
    # Redirect and show the error
    $c->response->redirect( $c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.create.no-season")} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the model to do the error checking / creation / editing
  my $response = $c->model("DB::Person")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    person => $person, # This will be undef if we're creating.
    captain_of => [split(",", $c->req->params->{captain_of})],
    secretary_of => [split(",", $c->req->params->{secretary_of})],
    date_of_birth => $c->i18n_datetime_format_date->parse_datetime($c->req->params->{date_of_birth}),
    registration_date => $c->i18n_datetime_format_date->parse_datetime($c->req->params->{registration_date}),
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
    $person = $response->{person};
    $redirect_uri = $c->uri_for_action("/people/view_current_season", [$person->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["person", $action, {id => $person->id}, $person->display_name]);
    
    # See if we need to add events for adding / removing secretaries and captains with this person
    my @secretaries_removed = @{$response->{secretaries_removed}};
    my @captains_removed = @{$response->{captains_removed}};
    my @secretaries_added = @{$response->{secretaries_added}};
    my @captains_added = @{$response->{captains_added}};
    
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["club", "secretary-clear", {id => $_->id}, $_->full_name]) foreach @secretaries_removed;
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", "captain-clear", {id => $_->id}, sprintf("%s %s", $_->club->short_name, $_->name)]) foreach @captains_removed;
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["club", "secretary-change", {id => $_->id}, $_->full_name]) foreach @secretaries_added;
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", "captain-change", {id => $_->id}, sprintf("%s %s", $_->club->short_name, $_->name)]) foreach @captains_added;
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for_action("/people/create_no_team", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/people/edit", [$person->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    $c->flash->{$_} = $response->{fields}{$_} foreach @processed_field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 import

Display a file upload box to upload a CSV file.

=cut

sub import :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1]);
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  unless ( defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("people.import.no-season")})}));
    $c->detach;
    return;
  }
  
  # Stash the things we need to show the creation form
  $c->stash({
    template => "html/people/import.ttkt",
    form_action => "import-results",
    external_scripts => [
      $c->uri_for("/static/script/people/import.js"),
    ],
    subtitle2 => $c->maketext("admin.import"),
    view_online_display => "Importing people",
    view_online_link => 0,
  });
  
  $c->add_status_messages({warning => $c->maketext("people.form.import.warning")});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import"),
  });
}

=head2 import_results

Validates an imported CSV file, displaying the contents back to the user so they can confirm that they wish to go ahead.

=cut

sub import_results :Path("import-results") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_create", $c->maketext("user.auth.create-people"), 1]);
  
  # Set up the allowed file types
  my @allowed_types = qw( text/plain text/csv );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  if ( defined($current_season) ) {
    # Stash the current season
    $c->stash({season => $current_season});
  } else {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg( {error => $c->maketext("people.import.no-season")})}));
    $c->detach;
    return;
  }
  
  # Check we have an upload
  if ( my $upload = $c->req->upload("import_file") ) {
    # File uploaded, get the MIME type
    my $filename = $upload->filename;
    my $mt = MIME::Types->new(only_complete => 1);
    my $mime_type = $mt->mimeTypeOf($filename)->type;
    if ( grep($_ eq $mime_type, @allowed_types) ) {
      # File is valid, pass the filehandle to the processing routine
      my $fh = $upload->fh;
      my $response = $c->model("DB::Person")->import({
        fh => $fh,
        date_format => $c->i18n_datetime_format_date->pattern,
      });
      
      my @errors = @{$response->{errors}};
      my @warnings = @{$response->{warnings}};
      my @info = @{$response->{info}};
      my @success = @{$response->{success}};
      my @successful_rows = @{$response->{successful_rows}};
      my @failed_rows = @{$response->{failed_rows}};
      my @ids = @{$response->{ids}};
      my @names = @{$response->{names}};
      
      # Add the messages
      $c->add_status_messages({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
      $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["person", "import", \@ids, \@names]);
      
      # Stash the template
      $c->stash({
        template => "html/people/import-results.ttkt",
        subtitle2 => $c->maketext("people.form.import-results.title"),
        view_online_display => "Importing people",
        external_scripts => [
          $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
          $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
          $c->uri_for("/static/script/people/import-results.js", {v => 2}),
        ],
        external_styles => [
          $c->uri_for("/static/css/chosen/chosen.min.css"),
          $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
          $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
        ],
        successful_rows => \@successful_rows,
        failed_rows => \@failed_rows,
      });
    } else {
      # File type not allowed
      $c->response->redirect($c->uri_for("/people/import",
                                  {mid => $c->set_status_msg({error => $c->maketext("people.form.import-results.invalid-file-type")})}));
      $c->detach;
      return;
    }
  } else {
    # No file uploaded
    $c->response->redirect($c->uri_for("/people/import",
                                {mid => $c->set_status_msg({error => $c->maketext("people.form.import-results.no-file-uploaded")})}));
    $c->detach;
    return;
  }
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import"),
  }, {
    path => $c->uri_for("/people/import"),
    label => $c->maketext("admin.import-results"),
  });
}

=head2 transfer

Transfer the current season (including all team associations) to another person.  The person chosen to transfer to must have no team associations already of any sort for the season that you're transferring data for.

This function is chained to "base", so that the "from" person is already obtained.

=cut

sub transfer :Chained("base") :PathPart("transfer") :Args(0) {
  my ( $self, $c ) = @_;
  my @field_names = qw( to season );
  my $from_person = $c->stash->{person};
  
  # Check that we are authorised to view teams
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_edit", $c->maketext("user.auth.edit-people"), 1]);
  
  my $response = $from_person->transfer_statistics({
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
  });
  
  my $season = $response->{fields}{season};
  my $to_person = $response->{fields}{to_person};
  
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Failure, redirect back to the "from" view page and display the error(s).
    if ( defined($season) ) {
      $redirect_uri = $c->uri_for_action("/people/view_specific_season", [$from_person->url_key, $season->url_key], {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/people/view_current_season", [$from_person->url_key], {mid => $mid});
    }
  } else {
    # Success, redirect to the new person's view page and display a message.
    if ( defined($season) ) {
      $redirect_uri = $c->uri_for_action("/people/view_specific_season", [$to_person->url_key, $season->url_key], {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/people/view_current_season", [$to_person->url_key], {mid => $mid});
    }
    
    # Log an event for each
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["person", "transfer-from", {id => $from_person->id}, $from_person->display_name]);
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["person", "transfer-to", {id => $to_person->id}, $to_person->display_name]);
  }
  
  $c->res->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 search

Handle search requests and return the data in JSON.

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  
  $c->stash({
    db_resultset => "Person",
    query_params => {q => $c->req->param("q")},
    view_action => "/people/view_current_season",
    search_action => "/people/search",
    placeholder => $c->maketext("search.form.placeholder", $c->maketext("object.plural.people")),
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
