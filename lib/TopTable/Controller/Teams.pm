package TopTable::Controller::Teams;
use Moose;
use namespace::autoclean;
use JSON;
use HTML::Entities;
use DateTime::Format::DateParse;
use DDP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Teams - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.team")});
   
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/teams"),
    label => $c->maketext("menu.text.team"),
  });
}


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;

  # Retrieve all of the clubs to display
  $c->forward("list");
}

=head2 base_by_id

Chain base for getting the team ID and checking it.

=cut

sub base_by_id :Chained("/") :PathPart("teams") :CaptureArgs(1) {
  my ($self, $c, $team_id) = @_;
  
  $c->stash({team => $c->model("DB::Team")->find_with_prefetches($team_id)});
  $c->forward("base_check_team");
}

=head2 base_by_url_key

Chain base for getting the club / team URL key and checking it.

=cut

sub base_by_url_key :Chained("/") :PathPart("teams") :CaptureArgs(2) {
  my ( $self, $c, $club_url_key, $team_url_key ) = @_;
  
  $c->stash({team => $c->model("DB::Team")->find_url_keys($club_url_key, $team_url_key)});
  $c->forward("base_check_team");
}

=head2 base_check_team

Private function forwarded from base_by_id and base_by_url_key - once the team has been stashed, this does the rest of the common bits from those functions/

=cut

sub base_check_team :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  if ( defined($team) ) {
    my $enc_name = encode_entities(sprintf("%s %s", $team->club->short_name, $team->name));
    
    $c->stash({
      team => $team,
      enc_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_create

Base URL matcher with no team specified (used in the create routines).  Doesn't actually do anything other than the URL matching.

=cut

sub base_create :Chained("/") :PathPart("teams") :CaptureArgs(0) {}

=head2 list

List the clubs that match the criteria offered in the provided arguments.

=cut

sub list :Local {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1]);
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( team_create team_edit team_delete )], "", 0]);
  
  # Set up the template to use
  $c->stash({
    template => "html/teams/list.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/standard/accordion.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    view_online_display => "Viewing teams",
    view_online_link => 1,
    teams => scalar $c->model("DB::Team")->all_teams_by_club_by_team_name,
    page_description => $c->maketext("description.teams.list", $site_name),
  });
}

=head2 view_by_id

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_id :Chained("base_by_id") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->forward("view");
}

=head2 view_by_url_key

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_url_key :Chained("base_by_url_key") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  $c->forward("view");
}

=head2 view

Private function to check we have permissions to view teams (forwarded from the view_by_id and view_by_url_key routines).

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view teams
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( team_create team_edit team_delete person_create ) ], "", 0]);
}

=head2 view_current_season_by_id

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season_by_id :Chained("view_by_id") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("view_current_season");
}

=head2 view_current_season_by_url_key

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season_by_url_key :Chained("view_by_url_key") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_current_season");
}

=head2 view_current_season

Private function to grab the current (or last complete) season for viewing the team.  Forward from view_current_season_by_id and view_current_season_by_url_key.

=cut

sub view_current_season :Private {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # No season ID, try to find the current season (or the last completed season if there is no current season)
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined($season);
    
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    # Check authorisation to update / cancel matches.  Only do this for 'view current season' (and even then only if it's not complete)
    # because nobody can update or cancel matches once the season is complete.
    $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( match_update match_cancel )], "", 0]) unless $season->complete;
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.teams.view-current", $enc_name, $site_name),
    });
  } else {
    # There is no current season, so this page is invalid for now.
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Get the team's details for the season.
  $c->forward("get_team_season");
  
  # Finalise the view routine
  $c->detach("view_finalise") unless exists($c->stash->{delete_screen});
}

=head2 view_specific_season_by_id

View a team with a specific season's details.

=cut

sub view_specific_season_by_id :Chained("view_by_id") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  $c->forward("view_specific_season", [$season_id_or_url_key]);
}

=head2 view_specific_season_by_url_key

View a team with a specific season's details.

=cut

sub view_specific_season_by_url_key :Chained("view_by_url_key") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  $c->forward("view_specific_season", [$season_id_or_url_key]);
}

=head2 view_specific_season

Private function to retrieve the specific season that for viewing a team.  Forwarded from view_specific_season_by_id and view_specific_season_by_url_key

=cut

sub view_specific_season :Private {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $team = $c->stash->{team};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.teams.view-specific", $enc_name, $site_name, $enc_season_name),
    });
    
    # Breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/teams/view_seasons_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/teams/view_specific_season_by_url_key", [$team->club->url_key, $team->url_key, $season->url_key]),
      label => $enc_season_name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg( {error => "seasons.invalid-find-current"} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_team_season");
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_team_season

Obtain a team's details for a given season.

=cut

sub get_team_season :Private {
  my ( $self, $c ) = @_;
  my ( $team, $season ) = ( $c->stash->{team}, $c->stash->{season} );
  my $specific_season = $c->stash->{specific_season};
  
  # If we've found a season, try and find the team's statistics and players from it
  my $team_season = $team->get_season($season);
  
  # Check if we have a team season - if so, the team has entered this season
  my $entered = defined($team_season) ? 1 : 0;
  
  # Check if the name has changed since the season we're viewing
  if ( $specific_season and $entered ) {
    # Get the club_season too
    my $club_season = $team_season->club_season;
    my $team_season_name = sprintf("%s %s", $club_season->short_name, $team_season->name);
    my $enc_team_season_name = encode_entities($team_season_name);
    my $team_current_name = sprintf("%s %s", $team->club->short_name, $team->name);
    
    $c->add_status_messages({info => $c->maketext("teams.club.changed-notice", $enc_team_season_name, encode_entities($team->club->full_name), $c->uri_for_action("/clubs/view_current_season", [$team->club->url_key]))}) unless $club_season->club->id == $team->club->id;
    $c->add_status_messages({info => $c->maketext("teams.name.changed-notice", $enc_team_season_name, encode_entities($team_current_name))}) unless $team_season->name eq $team->name;
    $c->add_status_messages({info => $c->maketext("clubs.name.changed-notice", encode_entities($club_season->full_name), encode_entities($club_season->short_name), encode_entities($club_season->club->full_name), encode_entities($club_season->club->short_name))}) if $club_season->full_name ne $club_season->club->full_name or $club_season->short_name ne $club_season->club->short_name;
    
    $c->stash({subtitle1 => $enc_team_season_name});
  }
  
  # $team_players is called averages in the stash so we can include the team averages table
  $c->stash({
    team_season => $team_season,
    singles_last_updated => $c->model("DB::PersonSeason")->get_tables_last_updated_timestamp({season => $season, team => $team}),
    doubles_ind_last_updated => $c->model("DB::PersonSeason")->get_tables_last_updated_timestamp({season => $season, team => $team}),
    doubles_pairs_last_updated => $c->model("DB::DoublesPair")->get_tables_last_updated_timestamp({season => $season, team => $team}),
    averages_team_page => 1,
    season => $season,
  });
  
  if ( defined($team_season) ) {
    $c->stash({
      singles_averages => scalar $c->model("DB::PersonSeason")->get_people_in_division_in_singles_averages_order({
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        season => $season,
        division => $team_season->division_season->division,
        team => $team,
      }),
      doubles_individual_averages => scalar $c->model("DB::PersonSeason")->get_people_in_division_in_doubles_individual_averages_order({
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        season => $season,
        division => $team_season->division_season->division,
        team => $team,
        criteria_field => "played",
        operator => ">",
        criteria => 0,
      }),
      doubles_pair_averages => scalar $c->model("DB::DoublesPair")->get_doubles_pairs_in_division_in_averages_order({
        logger => sub{ my $level = shift; $c->log->$level( @_ ); },
        season => $season,
        division => $team_season->division_season->division,
        team => $team,
        criteria_field => "played",
        operator => ">",
        criteria => 0,
      }),
    });
  }
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  my $season = $c->stash->{season};
  my $enc_season_name = $c->stash->{enc_season_name};
  my $team_season = $c->stash->{team_season};
  my $specific_season = $c->stash->{specific_season};
  my $enc_name = $c->stash->{enc_name};
  
  # Check authorisation for editing and deleting people, so we can display those links if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( person_edit person_delete ) ], "", 0]) unless $season->complete;
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/teams/view_specific_season_by_url_key", [$team->club->url_key, $team->url_key, $season->url_key])
    : $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key]);
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.edit-object", $enc_name),
    link_uri => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
  }) if $c->stash->{authorisation}{team_edit};
  
  # Push a delete link if we're authorised and the club can be deleted
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text => $c->maketext("admin.delete-object", $enc_name),
    link_uri => $c->uri_for_action("/teams/delete_by_url_key", [$team->club->url_key, $team->url_key]),
  }) if $c->stash->{authorisation}{team_delete} and $team->can_delete;
  
  # Get the matches for the fixtures tab
  my $matches = $c->model("DB::TeamMatch")->matches_for_team({
    team => $team,
    season => $season,
  });
  
  my $team_view_js_suffix = ( $c->stash->{authorisation}{match_update} or $c->stash->{authorisation}{match_cancel} ) ? "-with-actions" : "";
  
  # Set up the template to use
  $c->stash({
    template => "html/teams/view.ttkt",
    title_links => \@title_links,
    subtitle2 => $enc_season_name,
    canonical_uri => $canonical_uri,
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
      $c->uri_for(sprintf("/static/script/teams/view%s.js", $team_view_js_suffix), {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    view_online_display => sprintf("Viewing %s", $enc_name),
    view_online_link => 1,
    no_filter => 1, # Don't include the averages filter form on a team averages view
    matches => $matches,
    seasons => $team->team_seasons->count,
  });
}

=head2 contact_captain_by_id

Mechanism to forward to contact_captain chained to base_by_id.

=cut

sub contact_captain_by_id :Chained("base_by_id"): PathPart("contact-captain") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("contact_captain");
}

=head2 contact_captain_by_url_key

Mechanism to forward to contact_captain chained to base_by_url_key.

=cut

sub contact_captain_by_url_key :Chained("base_by_url_key"): PathPart("contact-captain") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("contact_captain");
}

=head2 contact_captain

Display a form to email the captain of this team.

=cut

sub contact_captain :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  # Check we can send the captain email - any error will detach / redirect from the routine, so if we get past here, we're okay
  $c->forward("can_send_captain_email", [$team]);
  
  # Grab the stashed values from the previous checks
  my $season = $c->stash->{season};
  my $team_season = $c->stash->{team_season};
  my $team_name = $c->stash->{team_name};
  my $enc_team_name = $c->stash->{enc_team_name};
  my $captain = $c->stash->{captain};
  my $enc_captain_display = $c->stash->{enc_captain_display};
  
  # Stash our template / form information
  $c->stash({
    template => "html/teams/contact-captain/form.ttkt",
    subtitle2 => $c->maketext("teams.captain.contact", $enc_captain_display),
    form_action => $c->uri_for_action("/teams/send_email_captain_by_url_key", [$team->club->url_key, $team->url_key]),
    view_online_display => "Sending an email to a team captain",
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/autogrow/jquery.ns-autogrow.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/autogrow.js"),
      $c->uri_for("/static/script/teams/contact-captain.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    page_description => $c->maketext("description.contact", $enc_captain_display),
  });
  
  if ( !$c->user_exists and $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
    my $locale_code = $c->locale;
    $locale_code =~ s/_/-/;
    push(@{$c->stash->{external_scripts}}, sprintf("https://www.google.com/recaptcha/api.js?hl=%s", $locale_code));
    $c->stash({reCAPTCHA => 1});
  }
  
  # Store current date/time in the session so we can retrieve it and work out how long it took to fill out the form
  $c->session->{form_time_contact_captain} = $c->datetime_tz({time_zone => "UTC"});
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/teams/contact_captain_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("menu.title.contact"),
  });
}

=head2 send_email_captain_by_id

Mechanism to forward to send_email_captain chained to base_by_id.

=cut

sub send_email_captain_by_id :Chained("base_by_id"): PathPart("send-captain-email") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("send_email_captain");
}

=head2 send_email_captain_by_url_key

Mechanism to forward to send_email_captain chained to base_by_id.

=cut

sub send_email_captain_by_url_key :Chained("base_by_url_key"): PathPart("send-captain-email") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("send_email_captain");
}

=head2 send_email_captain

Process the captain email form.

=cut

sub send_email_captain :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  my $jtest = $c->req->params->{jtest};
  my $time = $c->session->{form_time_contact_captain};
  delete $c->session->{form_time_contact_captain};
  
  # Check we can send the captain email - any error will detach / redirect from the routine, so if we get past here, we're okay
  $c->forward("can_send_captain_email", [$team]);
  
  # Grab the stashed values from the previous checks
  my $season = $c->stash->{season};
  my $team_season = $c->stash->{team_season};
  my $team_name = $c->stash->{team_name};
  my $enc_team_name = $c->stash->{enc_team_name};
  my $captain = $c->stash->{captain};
  my $enc_captain_display = $c->stash->{enc_captain_display};
  my ( $first_name, $surname, $name, $email_address, $user );
  my @errors = ();
  
  # Handle the contact form and send the email if there are no errors.
  if ( $c->user_exists ) {
    # The user is logged in, take their details from their login.
    $user = $c->user;
    $name = $user->display_name;
    $email_address = $user->email_address;
  } else {
    # Not logged on, check we have the required form fields.
    $first_name = $c->req->params->{first_name} || undef;
    $surname = $c->req->params->{surname} || undef;
    $email_address = $c->req->params->{email_address} || undef;
    
    if ( $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
      my $captcha_result = $c->forward("TopTable::Controller::Root", "recaptcha");
      
      if ( $captcha_result->{request_success} ) {
        # Request to Google was successful
        if ( !$captcha_result->{response_content}{success} ) {
          # Error validating, get the response messages in the correct language
          push(@errors, sprintf("%s\n", $c->maketext($_))) foreach @{$captcha_result->{response_content}{"error-codes"}};
        }
      } else {
        # Error requesting validation
        push(@errors, sprintf("%s\n", $c->maketext("google.recaptcha.error-sending")));
      }
    }
    
    if ( defined($first_name) ) {
      if ( defined($first_name) and defined($surname) ) {
        # Name is made up of first and surnames
        $name = sprintf("%s %s", $first_name, $surname);
      } else {
        # Name is just first name
        $name = $first_name;
      }
    } else {
      push(@errors, $c->maketext("contact.form.error.no-first-name"));
    }
    
    if ( defined($email_address) ) {
      # Email is filled out, check it
      $email_address = Email::Valid->address($email_address);
      push(@errors, $c->maketext("contact.form.error.invalid-email")) unless defined($email_address);
    } else {
      # Email missing
      push(@errors, $c->maketext("contact.form.error.no-email"));
    }
  }
  
  my $banned = $c->model("DB::Ban")->is_banned({
    ip_address => $c->req->address,
    email_address => $email_address,
    user => $user,
    level => "contact",
    log_allowed => 0,
    log_banned => 1,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    language => sub{ $c->maketext( @_ ); },
  });
  
  # Log our responses
  $c->log->error($_) foreach @{$banned->{errors}};
  $c->log->warning($_) foreach @{$banned->{warnings}};
  $c->log->info($_) foreach @{$banned->{info}};
  
  if ( $banned->{is_banned} ) {
    $c->response->redirect($c->uri_for("/",
            {mid => $c->set_status_msg({error => $c->maketext("contact.form.error.banned")})}));
    $c->detach;
    return;
  }
  
  my $message = $c->req->params->{message};
  
  push(@errors, $c->maketext("contact.form.error.no-message")) unless $message;
  
  # Check Cleantalk
  if ( $c->config->{"Model::Cleantalk::Contact"}{args}{auth_key} ) {
    $time = DateTime::Format::DateParse->parse_datetime($time, "UTC");
    
    if ( defined($time) ) {
      my $delta = $time->delta_ms($c->datetime_tz({time_zone => "UTC"}));
      my $seconds = ($delta->{minutes} * 60) + $delta->{seconds};
      
      my %headers = %{$c->req->headers};
      my $response = $c->model("Cleantalk::Contact")->request({
        message => $message,
        sender_ip => $c->req->address,
        sender_email => $email_address, # Email IP of the visitor
        sender_nickname => $name, # Nickname of the visitor
        submit_time => $seconds, # The time taken to fill the comment form in seconds
        js_on => ($jtest) ? 1 : 0, # The presence of JavaScript for the site visitor, 0|1
        all_headers => \%headers,
        sender_info => {
          REFERRER => $c->req->referer,
          USER_AGENT => $c->req->user_agent,
        }
      });
      
      unless ( $response->{allow} ) {
        # Not allowed, why?
        if ( $response->{codes} ) {
          push(@errors, sprintf("%s\n", $c->maketext("cleantalk.response.codes." . $_))) foreach split(" ", $response->{codes});
        } else {
          # No codes, but not allowed
          push(@errors, $c->maketext("cleantalk.error.generic"));
        }
      }
    } else {
      # Time not defined, redirect back to the form
      push(@errors, $c->maketext("contact.form.error.page-refreshed-resubmit"));
    }
  }
  
  if ( scalar @errors ) {
    # Errors, flash the values and redirect back to the form
    $c->flash->{first_name} = $first_name;
    $c->flash->{surname} = $surname;
    $c->flash->{email_address} = $email_address;
    $c->flash->{message} = $message;
    
    $c->response->redirect($c->uri_for_action("/teams/contact_captain_by_url_key", [$team->club->url_key, $team->url_key],
            {mid => $c->set_status_msg({error => \@errors})}));
    $c->detach;
    return;
  } else {
    # No errors, send the email.
    # Get the recipients
    my $recipients = [$captain->email_address, $captain->display_name];
    
    # Prepare values for HTML email
    my $html_site_name = encode_entities($c->config->{name});
    my $html_name = encode_entities($name);
    my $html_email = encode_entities($email_address);
    my $html_recp_name = encode_entities($captain->first_name);
    my $html_message = encode_entities($message);
    
    # Line breaks in HTML message
    $html_message =~ s|(\r?\n)|<br />$1|g;
    
    $c->model("Email")->send({
      to => $recipients,
      reply => [$email_address, $name],
      image => [$c->path_to(qw( root static images banner-logo-player-small.png ))->stringify, "logo"],
      subject => $c->maketext("email.subject.contact-captain", $name, $c->config->{name}),
      plaintext => $c->maketext("email.plain-text.contact-captain", $captain->first_name, $name, $team_name, $c->config->{name}, $email_address, $message, $c->req->address),
      htmltext => [qw( html/generic/generic-message.ttkt :TT )],
      template_vars => {
        name => $html_site_name,
        home_uri => $c->uri_for("/"),
        email_subject => $c->maketext("email.subject.contact-captain", $html_name, $html_site_name),
        email_html_message => $c->maketext("email.html.contact-captain", $html_recp_name, $html_name, $enc_team_name, $html_site_name, $html_email, $html_message, $c->req->address),
      },
    });
    
    $c->stash({
      template => "html/teams/contact-captain/thank-you.ttkt",
      subtitle1 => $c->maketext("contact.thank-you.header", $html_name),
      user => $name,
    });
    
    #$c->forward("TopTable::Controller::SystemEventLog", "add_event", ["contact-form", "submit", {id => $reason->id}, $reason->name]);
    
    # Breadcrumbs links
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/teams/contact_captain_by_url_key", [$team->club->url_key, $team->url_key]),
      label => $c->maketext("menu.title.contact"),
    });
  }
}

sub can_send_captain_email :Private {
  my ( $self, $c, $team ) = @_;
  
  # Check the season is current
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_compete_season unless defined($season);
  
  unless ( defined($season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.captains.contact.error.no-season")})}));
    $c->detach;
    return;
  }
  
  my $team_season = $team->get_season($season);
  my $team_name = sprintf("%s %s", $team->club->short_name, $team->name);
  my $enc_team_name = encode_entities($team_name);
  
  unless ( defined($team_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.captains.contact.error.team-not-in-season", $enc_team_name)})}));
    $c->detach;
    return;
  }
  
  my $captain = $team_season->captain;
  
  unless ( defined($captain) ) {
    # No captain listed
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.captains.contact.error.no-captain-listed", $enc_team_name)})}));
    $c->detach;
    return;
  }
  
  my $enc_captain_display = encode_entities($captain->display_name);
  
  unless ( defined($captain->email_address) and $captain->email_address ) {
    # No captain listed
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.captains.contact.error.no-email-address-listed", $enc_team_name, $enc_captain_display)})}));
    $c->detach;
    return;
  }
  
  # If we get this far, we can send (no need to return anything, if we can't send email we've spun out to an error message)
  # Stash the values we looked up for this
  $c->stash({
    season => $season,
    team_season => $team_season,
    team_name => $team_name,
    enc_team_name => $enc_team_name,
    captain => $captain,
    enc_captain_display => $enc_captain_display,
  });
}

=head2 view_seasons_by_url_key

Display the list of seasons when specifying the URL key in the URL

=cut

sub view_seasons_by_url_key :Chained("view_by_url_key") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_seasons");
}

=head2 view_seasons_by_id

Display the list of seasons when specifying the ID in the URL

=cut

sub view_seasons_by_id :Chained("view_by_id") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward("view_seasons");
}

=head2 view_seasons

Retrieve and display a list of seasons that this team has entered teams into.

=cut

sub view_seasons :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  my $site_name = $c->stash->{enc_site_name};
  my $team_name = $c->stash->{enc_name};
  
  my $seasons = $team->get_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/teams/seasons.js"),
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
    template => "html/teams/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.season"),
    page_description  => $c->maketext("description.teams.list-seasons", $team_name, $site_name),
    view_online_display => sprintf( "Viewing seasons for %s %s", $team->club->short_name, $team->name ),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/teams/view_seasons_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 create

Display a form to collect information for creating a team.

=cut

sub create :Chained("base_create") :PathPart("create") :CaptureArgs(0) {
  my ($self, $c) = @_;
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["team_create", $c->maketext("user.auth.create-teams"), 1] );
  
  # Get the current season
  my $current_season = $c->model("DB::Season")->get_current;
  
  if ( defined($current_season) ) {
    # If there us a current season, we need to check we haven't progressed through
    # the season too much to add teams.
    # Check if we have any matches; if not, allow team creation
    if ( $c->model("DB::TeamMatch")->season_matches($current_season)->count > 0 ) {
      # Redirect and show the error
      $c->response->redirect($c->uri_for("/",
                                  {mid => $c->set_status_msg({error => $c->maketext("teams.form.error.matches-exist")})}));
      $c->detach;
      return;
    }
  } else {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.form.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, then we need to display a message; if there are some, we have to setup the tokeninput options
  if ( $c->model("DB::Person")->search->count ) {
    # First setup the function arguments
    my $captain_tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed
    my $captain = $c->flash->{captain} || undef;
    $captain_tokeninput_options->{prePopulate} = [{id => $captain->id, name => encode_entities( $captain->display_name )}] if defined($captain);
    
    my $players_tokeninput_options = {
      jsonContainer => "json_search",
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    my $players = $c->flash->{players};
    
    $players_tokeninput_options->{prePopulate} = [map({
      id => $_->id,
      name => encode_entities($_->display_name),
    }, @{$players})] if ref($players) eq "ARRAY" and scalar @{$players};
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json($captain_tokeninput_options),
      selector => "captain",
    }, {
      script => $c->uri_for("/people/search"),
      options => encode_json($players_tokeninput_options),
      selector => "players",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Stash the things we need to show the creation form
  $c->stash({
    template => "html/teams/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/teams/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    clubs => scalar $c->model("DB::Club")->all_clubs_by_name,
    divisions => scalar $current_season->divisions,
    home_nights => scalar $c->model("DB::LookupWeekday")->all_days,
    current_season => $current_season,
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating teams",
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/teams/create_no_club"),
    label => $c->maketext("admin.create"),
  });
}

=head2 create_with_club

Create URL with club specified for pre-selection.

=cut

sub create_with_club :Chained("create") :PathPart("club") :Args(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  # Flash the club with what's provided in the params if needed
  if ( defined (my $club = $c->model("DB::Club")->find_id_or_url_key($id_or_url_key)) ) {
    $c->stash->{preset_club} = $club;
  } else {
    $c->detach(qw( TopTable::Controller::Root default ));
  }
}

=head2 create_no_club

Create URL for create with no club specified.  This doesn't do anything other than specify the end of a chain.

=cut

sub create_no_club :Chained("create") :PathPart("") :Args(0) {}

=head2 edit_by_id

Handles an edit request by ID (forwards to the real edit routine)

=cut

sub edit_by_id :Chained("base_by_id") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("edit");
}

=head2 edit_by_url_key

Handles an edit request by URL key (forwards to the real edit routine)

=cut

sub edit_by_url_key :Chained("base_by_url_key") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("edit");
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Private {
  my ( $self, $c ) = @_;
  my ( $current_season, $team_season, $divisions, $last_team_season_changes );
  my $team = $c->stash->{team};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_edit", $c->maketext("user.auth.edit-teams"), 1]);
  
  # Get the current season
  $current_season = $c->model("DB::Season")->get_current;
  
  if ( !defined($current_season) ) {
    # Redirect and show the error
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("teams.form.error.no-current-season", $c->maketext("admin.message.edited"))})}));
    $c->detach;
    return;
  }
  
  # If there us a current season, we need to check we haven't progressed through
  # the season too much to edit some fields.
  my $league_matches = $c->model("DB::TeamMatch")->season_matches($current_season)->count;
  
  # Check if we have any rows; if so, we will disable some fields
  my $mid_season = $c->model("DB::TeamMatch")->season_matches($current_season)->count > 0 ? 1 : 0;
  
  # Get the team's season
  $team_season = $team->get_season($current_season);
  
  # Get divisions based on which divisions have an association with the current season.
  $divisions = $current_season->divisions;
  
  # Get the last team season
  my $last_team_season = $team->last_competed_season;
  
  my $home_night;
  if ( defined($team_season) ) {
    $home_night = $team_season->home_night->weekday_number;
  } elsif ( defined($last_team_season) ) {
    $home_night = $last_team_season->home_night->weekday_number;
  }
  
  # Get the number of people - if there are none, then we need to display a message
  if ( $c->model("DB::Person")->search->count ) {
    # First setup the function arguments
    my $captain_tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed - prioritise flashed values
    my $captain;
    if ( $c->flash->{show_flashed} ) {
      $captain = $c->flash->{captain};
    } else {
      if ( defined($team_season) ) {
        # If there's a currently defined team season, use the captain from that
        $captain = $team_season->captain;
      } else {
        # If not, use the captain from the last completed season this team entered
        $captain = $last_team_season->captain if defined($last_team_season);
      }
    }
    
    # Add the pre-population if needed
    $captain_tokeninput_options->{prePopulate} = [{id => $captain->id, name => encode_entities($captain->display_name)}] if defined($captain);
    
    # Players
    my $players_tokeninput_options = {
      jsonContainer => "json_search",
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    my $players;
    if ( $c->flash->{show_flashed} ) {
      $players = $c->flash->{players};
    } else {
      $players = [$team->get_players({season => $current_season})];
    }
    
    $players_tokeninput_options->{prePopulate} = [map({
      id => $_->id,
      name => encode_entities($_->display_name),
    }, @{$players})] if ref($players) eq "ARRAY" and scalar(@{$players});
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json( $captain_tokeninput_options ),
      selector => "captain",
    }, {
      script => $c->uri_for("/people/search"),
      options => encode_json( $players_tokeninput_options ),
      selector => "players",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues to list
  $c->stash({
    template => "html/teams/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/teams/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    clubs => scalar $c->model("DB::Club")->all_clubs_by_name,
    divisions => $divisions,
    home_nights => scalar $c->model("DB::LookupWeekday")->all_days,
    current_season => $current_season,
    team_season => $team_season,
    last_team_season => $last_team_season,
    form_action => $c->uri_for_action("/teams/do_edit_by_url_key", [$team->club->url_key, $team->url_key]),
    view_online_display => "Editing $enc_name",
    view_online_link => 0,
    subtitle2 => $c->maketext("admin.edit"),
    mid_season => $mid_season,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete_by_id

Display the form to delete a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub delete_by_id :Chained("base_by_id") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete_by_url_key

Display the form to delete a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub delete_by_url_key :Chained("base_by_url_key") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete

Forwarded from delete_by_id and delete_by_url_key.

=cut

sub delete :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_delete", $c->maketext("user.auth.delete-teams"), 1]);
  
  unless ( $team->can_delete ) {
    $c->response->redirect($c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("teams.delete.error.cannot-delete", $team->club->short_name, $team->name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view_current_season");
  
  $c->stash({
    subtitle1 => sprintf( "%s %s", $team->club->short_name, $team->name ),
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/teams/delete.ttkt",
    view_online_display => "Deleting $enc_name",
    view_online_link => 0,
  });
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key]),
    label => $c->maketext("admin.delete"),
  });
}


=head2 do_create

Process the form for creating a club. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_create", $c->maketext("user.auth.create-teams"), 1]);
  
  # Forward to the setup routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit_by_id

Process the form to edit the team.  This just does the URI matching, then forwards to do_edit.

=cut

sub do_edit_by_id :Chained("base_by_id") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit_by_url_key

Process the form to edit the team.  This just does the URI matching, then forwards to do_edit.

=cut

sub do_edit_by_url_key :Chained("base_by_url_key") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit

Forwarded from do_edit_by_id and do_edit_by_url_key. 

=cut

sub do_edit :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_edit", $c->maketext("user.auth.edit-teams"), 1]);
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete_by_id

Process the form for deleting a team.  This actually does the URI matching, then forwards to the do_delete routine.

=cut

sub do_delete_by_id :Chained("base_by_id") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete_by_url_key

Process the form for deleting a team.  This actually does the URI matching, then forwards to the delete routine.

=cut

sub do_delete_by_url_key :Chained("base_by_url_key") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete

Process the deletion of the team.

=cut

sub do_delete :Private {
  my ( $self, $c ) = @_;
  my $team = $c->stash->{team};
  
  # Save the team name so we can display it in a message after the deletion
  my $team_name = sprintf("%s %s", $team->club->short_name, $team->name);
  
  # Check that we are authorised to delete clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_delete", $c->maketext("user.auth.delete-teams"), 1]);
  
  my $response = $team->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/teams", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", "delete", {id => undef}, $team_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

A private routine forwarded from the docreate and doedit routines to set up the team.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $team = $c->stash->{team};
  my $enc_name = $c->stash->{enc_name};
  my @field_names = qw( name club division start_hour start_minute captain home_night );
  my @processed_field_names = qw( name club division start_hour start_minute captain home_night players );
  
  # Forward to the model to do the rest of the error checking.  The map MUST come last in this
  my $response = $c->model("DB::Team")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    reassign_active_players => $c->config->{Players}{reassign_active_on_team_season_create},
    team => $team,
    players => defined($c->req->params->{players}) ? [split(",", $c->req->params->{players})] : undef,
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
    $team = $response->{team};
    $redirect_uri = $c->uri_for_action("/teams/view_current_season_by_url_key", [$team->club->url_key, $team->url_key], {mid => $mid});
    my $team_name = sprintf("%s %s", $team->club->short_name, $team->name);
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", $action, {id => $team->id}, $team_name]);
    
    # Log the home night's changed if necessary
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", "update-home-night", {id => $team->id}, $team_name]) if $response->{home_night_changed};
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["team", "captain-change", {id => $team->id}, $team_name]) if $response->{captain_changed};
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for_action("/teams/create_no_club", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/teams/edit_by_url_key", [$team->club->url_key, $team->url_key], {mid => $mid});
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

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1]);
  
  $c->stash({
    db_resultset => "ClubTeamView",
    query_params => {q => $c->req->params->{q}},
    view_action => "/teams/view_current_season_by_url_key",
    search_action => "/teams/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.teams") ),
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
