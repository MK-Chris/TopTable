package TopTable::Controller::Doubles;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Doubles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

Performed by all methods in this controller.  Load the status messages and stash a subtitle

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.doubles")});
   
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/doubles"),
    label => $c->maketext("menu.text.doubles"),
  });
}

=head2 base

Chain base for getting two people (a person ID or URL key in any order) and finding them.

=cut

sub base :Chained("/") PathPart("doubles") CaptureArgs(2) {
  my ( $self, $c, @ids ) = @_;
  my $pairs = $c->model("DB::DoublesPair")->find_pair({people => \@ids});
  
  if ( $pairs->count ) {
    # Encode our names and stash them
    my $pair = $pairs->first;
    
    my @enc_first_names = (encode_entities($pair->person_season_person1_season_team->first_name), encode_entities($pair->person_season_person2_season_team->first_name));
    my @enc_surnames = (encode_entities($pair->person_season_person1_season_team->surname), encode_entities($pair->person_season_person2_season_team->surname));
    my @enc_display_names = (sprintf("%s %s", $enc_first_names[0], $enc_surnames[0]), sprintf("%s %s", $enc_first_names[1], $enc_surnames[1]));
    
    my %enc_names = (
      first_names => \@enc_first_names,
      surnames => \@enc_surnames,
      display_names => \@enc_display_names,
      pair_display_names => $c->maketext("doubles.pair.display_names", $enc_display_names[0], $enc_display_names[1]),
      pair_sort_names => $c->maketext("doubles.pair.sort_names", $enc_surnames[0], $enc_first_names[0], $enc_surnames[1], $enc_first_names[1]),
    );
    
    $c->stash({
      pairs => $pairs,
      pair => $pair, # First record in the resultset
      people => [$pair->person_season_person1_season_team->person, $pair->person_season_person2_season_team->person],
      enc_names => \%enc_names,
    });
    
    $c->stash->{noindex} = 1 if $pairs->noindex_set(1)->count;
    
    # Push the people list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/doubles/view_current_season", $pair->url_keys),
      label => $enc_names{pair_display_names},
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 view

View a person's details.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( person_edit )], "", 0]);
}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $pairs = $c->stash->{pairs};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    my %enc_names = %{$c->stash->{enc_names}};
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.doubles.view-current", $enc_names{display_names}[0], $enc_names{display_names}[1], $site_name),
    });
    
    # Forward to the routine that stashes the person's season
    $c->forward("get_season");
  }
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 view_specific_season

View a team with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $pairs = $c->stash->{pairs};
  my $site_name = $c->stash->{enc_site_name};
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  my %enc_names = %{$c->stash->{enc_names}};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.doubles.view-specific", $enc_names{display_names}[0], $enc_names{display_names}[1], $enc_season_name, $site_name),
    });
  } else {
    # Invalid season
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_season");
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/doubles/view_seasons", [$person1->url_key, $person2->url_key]),
    label => $c->maketext("menu.text.season"),
  }, {
    path => $c->uri_for_action("/people/view_specific_season", [$person1->url_key, $person2->url_key, $season->url_key]),
    label => $season->name,
  });
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_season

Obtain a doubles's pair's details for a given season.

=cut

sub get_season :Private {
  my ( $self, $c ) = @_;
  my ( $pairs, $season, $enc_names ) = ( $c->stash->{pairs}, $c->stash->{season}, $c->stash->{enc_names} );
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  
  my $season_pairs = $pairs->get_season({season => $season});
  my $pair = $season_pairs->first;
  
  # Grab the games
  my $games = $season_pairs->get_games({season => $season});
  
  if ( !exists($c->stash->{noindex}) or !$c->stash->{noindex} ) {
    # If this pair isn't set to 'noindex', check if any of the people they've played in this season are - no point in doing this expensive query if the pair is already
    # set to noindex
    my $noindex = $games->noindex_set(1)->count;
    $c->stash->{noindex} = 1 if $noindex;
  }
  
  my $enc_season_name = encode_entities($season->name);
  
  # Overwrite display names with the current season
  my ( @enc_first_names, @enc_surnames );
  
  if ( defined($pair) ) {
    @enc_first_names = (encode_entities($pair->person_season_person1_season_team->first_name), encode_entities($pair->person_season_person2_season_team->first_name));
    @enc_surnames = (encode_entities($pair->person_season_person1_season_team->surname), encode_entities($pair->person_season_person2_season_team->surname));
  } else {
    @enc_first_names = (encode_entities($c->stash->{enc_names}{first_names}[0]), encode_entities($c->stash->{enc_names}{first_names}[1]));
    @enc_surnames = (encode_entities($c->stash->{enc_names}{surnames}[0]), encode_entities($c->stash->{enc_names}{surnames}[1]));
  }
  
  my @enc_display_names = (sprintf("%s %s", $enc_first_names[0], $enc_surnames[0]), sprintf("%s %s", $enc_first_names[1], $enc_surnames[1]));
  
  my %enc_names = (
    first_names => \@enc_first_names,
    surnames => \@enc_first_names,
    display_names => \@enc_display_names,
    pair_display_names => $c->maketext("doubles.pair.display_names", $enc_display_names[0], $enc_display_names[1]),
    pair_sort_names => $c->maketext("doubles.pair.sort_names", $enc_surnames[0], $enc_first_names[0], $enc_surnames[1], $enc_first_names[1]),
  );
  
  # Add info messages if names have changed
  $c->add_status_messages({info => $c->maketext("people.name.changed-notice", $enc_names{display_names}[0], encode_entities($person1->display_name))}) if defined($pair) and $person1->display_name ne $pair->person_season_person1_season_team->display_name;
  $c->add_status_messages({info => $c->maketext("people.name.changed-notice", $enc_names{display_names}[1], encode_entities($person2->display_name))}) if defined($pair) and $person2->display_name ne $pair->person_season_person2_season_team->display_name;
  
  $c->stash->{subtitle1} = $enc_names{pair_display_names};
  
  $c->stash({
    season => $season,
    season_pairs => $season_pairs,
    games => $games,
    pair => $pair,
    enc_names => \%enc_names,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my ( $pairs, $pair, $season, $enc_names ) = ( $c->stash->{pairs}, $c->stash->{pair}, $c->stash->{season}, $c->stash->{enc_names} );
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  my $enc_display_name = $enc_names->{pair_display_names};
  my @opponents = ();
  
  # Get the list of seasons they have played in
  my $pair_seasons = $pairs->get_all_seasons;
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("/doubles/view_specific_season", [$person1->url_key, $person2->url_key, $season->url_key])
    : $c->uri_for_action("/doubles/view_current_season", [$person1->url_key, $person2->url_key]);
  
  # Handle head-to-heads data provided in request parameters
  if ( exists($c->req->params->{opponents}) ) {
    if ( ref($c->req->params->{opponents}) eq "ARRAY" ) {
      # Already passed as an array
      @opponents = @{$c->req->params->{opponents}};
    } elsif ( $c->req->params->{opponents} =~ m/,/ ) {
      # Has commas, split into array
      @opponents = split(",", $c->req->params->{opponents});
    } else {
      # Neither, just do an array with a single element, the opponent passed in
      @opponents = ($c->req->params->{opponents});
    }
  }
  
  my @head_to_heads;
  my @errors = ();
  my ( $opponent_pair, $opponent_pairs );
  if ( scalar(@opponents) == 2 ) {
    # Validate the opponent is valid
    $opponent_pairs = $c->model("DB::DoublesPair")->find_pair({people => \@opponents});
    $opponent_pair = $opponent_pairs->first if $opponent_pairs->count;
  }
  
  if ( defined($opponent_pair) ) {
    # Add the pre-population if required
    $c->stash({opposition_ti_prepopulate => encode_json([{
      id => $opponent_pair->person_season_person1_season_team->person->url_key, name => encode_entities($opponent_pair->person_season_person1_season_team->person->display_name)
    }, {
      id => $opponent_pair->person_season_person2_season_team->person->url_key, name => encode_entities($opponent_pair->person_season_person2_season_team->person->display_name)
    }])});
    
    # We need this as an array to A) suppress the eager slurp due to order criteria warning and B) so we can map each row and format some dates into a hashref
    @head_to_heads = $pair->head_to_heads({opponents => [$opponent_pair->person1, $opponent_pair->person2]})->all;
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/doubles/view.ttkt",
    scripts => ["tokeninput-head-to-head-doubles"],
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.select.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.searchPanes.min.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/messages.js"),
      $c->uri_for("/static/script/doubles/view.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/select.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/searchPanes.dataTables.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
    ],
    view_online_display => sprintf("Viewing %s", $enc_display_name),
    view_online_link => 1,
    head_to_heads => \@head_to_heads,
    pair_seasons => $pair_seasons,
    seasons => $pair_seasons->count,
    canonical_uri => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this doubles pair has played together in.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my ( $pairs, $pair, $season, $enc_names, $site_name ) = ( $c->stash->{pairs}, $c->stash->{pair}, $c->stash->{season}, $c->stash->{enc_names}, $c->stash->{enc_site_name} );
  my $seasons = $pairs->get_all_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/doubles/seasons.js"),
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
    template => "html/doubles/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.season"),
    page_description => $c->maketext("description.doubles.list-seasons", $enc_names->{display_names}[0], $enc_names->{display_names}[1], $site_name),
    view_online_display => sprintf("Viewing seasons for %s", $enc_names->{pair_display_names}),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/doubles/view_seasons", $pair->url_keys),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 head_to_head

Head-to-head form processing, routed to a form submission, or an AJAX query.

=cut

sub head_to_head :Chained("base") :PathPart("head-to-head") :Args(0) {
  my ( $self, $c ) = @_;
  my ( $pairs, $pair, $season, $enc_names ) = ( $c->stash->{pairs}, $c->stash->{pair}, $c->stash->{season}, $c->stash->{enc_names} );
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  my $enc_display_name = $enc_names->{pair_display_names};
  my $site_name = $c->stash->{enc_site_name};
  my %enc_names = %{$c->stash->{enc_names}};
  my @opponents = ();
  my $opponents = $c->req->params->{"opponents[]"} || $c->req->params->{opponents};
  
  if ( defined($opponents) ) {
    if ( ref($opponents) eq "ARRAY" ) {
      # Already passed as an array
      @opponents = @{$opponents};
    } elsif ( $opponents =~ m/,/ ) {
      # Has commas, split into array
      @opponents = split(",", $opponents);
    } else {
      # Neither, just do an array with a single element, the opponent passed in
      @opponents = ($opponents);
    }
  }
  
  my $person;
  my @errors = ();
  
  if ( scalar(@opponents) == 2 ) {
    # Validate the opponents are both valid
    my $invalid = 0;
    @opponents = map{
      my $opponent = $c->model("DB::Person")->find_id_or_url_key($_);
      
      $invalid++ unless defined($opponent);
      
      $opponent;
    } @opponents;
    
    my ( $opponent_pairs, $opponent_pair );
    if ( !$invalid ) {
      $opponent_pairs = $c->model("DB::DoublesPair")->find_pair({people => \@opponents});
      $opponent_pair = $opponent_pairs->first if $opponent_pairs->count;
    }
    
    if ( defined($opponent_pair) ) {
      # Valid person - simple check that they're not the same as the other person
      if ( $pair->eq($opponent_pair) ) {
        push(@errors, $c->maketext("people.head-to-head.doubles.error.same-opponent-as-pair", encode_entities($pair->person_season_person1_season_team->display_name), encode_entities($pair->person_season_person2_season_team->display_name)));
      } elsif ( $pair->contains($opponent_pair->person_season_person1_season_team->person) ) {
        push(@errors, $c->maketext("people.head-to-head.doubles.error.person-in-both-pairs", encode_entities($opponent_pair->person_season_person1_season_team->display_name)));
      } elsif ( $pair->contains($opponent_pair->person_season_person2_season_team->person) ) {
        push(@errors, $c->maketext("people.head-to-head.doubles.error.person-in-both-pairs", encode_entities($opponent_pair->person_season_person2_season_team->display_name)));
      }
    } else {
      # Pair is invalid
      if ( $invalid == 1 ) {
        # One person invalid
        push(@errors, $c->maketext("people.head-to-head.doubles.error.person-invalid"));
      } elsif ( $invalid == 2 ) {
        # Both people invalid
        push(@errors, $c->maketext("people.head-to-head.doubles.error.people-invalid"));
      } else {
        push(@errors, $c->maketext("people.head-to-head.doubles.error.invalid-pair", encode_entities($opponents[0]->display_name), encode_entities($opponents[1]->display_name)));
      }
    }
  } else {
    # All people valid, but an invalid pair (they've not played together)
    push(@errors, $c->maketext("people.head-to-head.doubles.error.two-people-not-entered"));
  }
  
  if ( $c->is_ajax ) {
    # Do the query,return with JSON
    if ( scalar(@errors) ) {
      # Stash the messages
      $c->stash({json_data => {messages => {error => \@errors}}});
      $c->log->error($_) foreach @errors;
      
      # Change the response code if we didn't complete
      $c->res->status(400);
      
      # Detach to the JSON view
      $c->detach($c->view("JSON"));
      return;
    }
    
    my @head_to_heads = $pair->head_to_heads({opponents => \@opponents})->all;
    
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
      my $location = $pair->eq($game->home_doubles_pair) ? "home" : "away";
      
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
    
    my $query_data = {opponent => sprintf("%s,%s", $opponents[0]->url_key, $opponents[1]->url_key)};
    my $redirect_uri = defined($season)
      ? $c->uri_for_action("/people/view_specific_season", [$person->url_key, $season->url_key], $query_data, \"head-to-head")
      : $c->uri_for_action("/people/view_current_season", [$person->url_key], $query_data, \"head-to-head");
    
    # Redirect - no need for a status message
    $c->res->redirect($redirect_uri);
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
