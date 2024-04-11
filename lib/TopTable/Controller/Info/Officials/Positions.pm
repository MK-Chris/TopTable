package TopTable::Controller::Info::Officials::Positions;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;
use DateTime::Format::DateParse;
use DDP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Info::Officials::Positions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 base

Chain base for getting the committee position ID and checking it.

=cut

sub base :Chained("/") :PathPart("info/officials/positions") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $position = $c->model("DB::Official")->find_id_or_url_key($id_or_key);
  
  if ( defined($position) ) {
    # Position found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    my $enc_name = encode_entities($position->position_name);
    $c->stash({
      position => $position,
      enc_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Club view page (current season)
      path => $c->uri_for_action("/info/officials/positions/view", [$position->url_key]),
      label => $enc_name,
    });
  } else {
    # 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 view

View the position.

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to view
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_view", $c->maketext("user.auth.view-officials"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( committee_edit committee_delete ) ], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists($c->stash->{delete_screen}) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/info/officials/positions/edit", [$position->url_key]),
    }) if $c->stash->{authorisation}{committee_edit};
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_name),
      link_uri => $c->uri_for_action("/info/officials/positions/delete", [$position->url_key]),
    }) if $c->stash->{authorisation}{committee_delete};
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/info/officials/positions/view.ttkt",
    title_links => \@title_links,
    view_online_display => sprintf("Viewing league official: %s", $enc_name),
    view_online_link => 0,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/info/officials/positions/view.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
}

=head2 create

Create an official / committee member position.  The display order can be edited afterwards, but the new position will be placed after all existing ones.  There is also an option to assign at this stage, although this option is also given in the 'assign_position' option.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_create", $c->maketext("user.auth.create-officials"), 1]);
  
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.create.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, we can't show the assignment field.
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_search",
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed
    my $holders = $c->flash->{holders};
    
    $tokeninput_options->{prePopulate} = [map({
      id => $_->id,
      name => encode_entities($_->display_name),
    }, @{$holders})] if ref($holders) eq "ARRAY" and scalar(@{$holders});
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json($tokeninput_options),
      selector => "holders",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/info/officials/positions/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/info/officials/positions/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating league officials",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/info/officials/positions/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Edit an official / committee member position.  This takes effect for the current season (and is used as the basis for the position in future seasons); if there is no current season, an error is thrown.

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_edit", $c->maketext("user.auth.edit-officials"), 1]);
  
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, we can't show the assignment field.
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_search",
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => $c->maketext("tokeninput.text.no-results"),
      searchingText => $c->maketext("tokeninput.text.searching"),
    };
    
    # Add the pre-population if needed
    my $holders;
    if ( $c->flash->{show_flashed} ) {
      $holders = $c->flash->{holders};
    } else {
      $holders = [$position->get_holders({season => $current_season})];
    }
    
    $tokeninput_options->{prePopulate} = [map({
      id => $_->id,
      name => encode_entities($_->display_name),
    }, @{$holders})] if ref($holders) eq "ARRAY" and scalar(@{$holders});
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json($tokeninput_options),
      selector => "holders",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/info/officials/positions/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/info/officials/positions/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt2.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for_action("/info/officials/positions/do_edit", [$position->url_key]),
    subtitle2 => $c->maketext("admin.edit"),
    view_online_display => "Editing league officials",
    view_online_link => 0,
    season => $current_season,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/info/officials/positions/edit"),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Delete an official / committee member position.  This can only be done if the position hasn't been used for any season.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_delete", $c->maketext("user.auth.delete-officials"), 1]);
  
  unless ( $position->can_delete ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season", [$position->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("officials.delete.error.cannot-delete", $enc_name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle1 => $enc_name,
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/info/officials/positions/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $position->position_name),
    view_online_link => 0,
  });
}

=head2 do_create

Process the form for creating a committe position.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_create", $c->maketext("user.auth.create-officials"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a committee position.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_edit", $c->maketext("user.auth.edit-officials"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion form and delete a club (if possible).

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_delete", $c->maketext("user.auth.delete-officials"), 1]);
  
  unless ( $position->can_delete ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season", [$position->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("officials.delete.error.cannot-delete", $enc_name)})}));
    $c->detach;
    return;
  }
  
  my $response = $position->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/info/officials/view_current_season", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["official-position", "delete", {id => undef}, $enc_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/info/officials/view_current_season", {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Forwarded from docreate and doedit to do the reason creation / edit.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $position = $c->stash->{position};
  my @processed_field_names = qw( position_name holders );
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $response = $c->model("DB::Official")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    position => $position,
    position_name => $c->req->params->{position_name},
    holder_ids => [split(",", $c->req->params->{holders})],
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
    $position = $response->{position};
    $redirect_uri = $c->uri_for_action("/info/officials/view_current_season", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["official-position", $action, {id => $position->id}, $position->position_name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/info/officials/positions/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/info/officials/positions/edit", [$position->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{$_} = $response->{fields}{$_} foreach @processed_field_names;
    $c->flash->{show_flashed} = 1;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 holders

Chained to the base class, this gets a specific holder of the given position; this means we can chain specific actions to a position holder (like sending an email).

=cut

sub holders :Chained("base") :PathPart("holders") :CaptureArgs(1) {
  my ( $self, $c, $holder_id_or_url_key ) = @_;
  my $position = $c->stash->{position};
  my $enc_name = $c->stash->{enc_name};
  
  # Get and stash the current season, or last completed - we're only interested in current committee members for these actions
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined($season);
  
  # No need to check for a defined season - if we have a position / holder, there must be a season.
  # Check this position is in use for this season
  my $position_season = $position->get_season($season);
  
  unless ( defined($position_season) ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.positions.error.unused-in-season", $enc_name, encode_entities($season->name))})}));
    $c->detach;
    return;
  }
  
  my $person = $c->model("DB::Person")->find_id_or_url_key($holder_id_or_url_key);
  
  unless ( defined($person) ) {
    # Person doesn't exist, 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
  
  my $enc_person_name = encode_entities($person->display_name);
  
  # Check this person holds that position in this season
  my $person_valid = $position_season->check_holder($person);
  
  unless ( $person_valid ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.positions.error.person-not-in-position", $enc_name, encode_entities($season->name))})}));
    $c->detach;
    return;
  }
  
  # Finally stash our values for whatever action we're taking on this official position holder
  $c->stash({
    subtitle1 => $enc_name,
    subtitle2 => $enc_person_name,
    season => $season,
    position_season => $position_season,
    person => $person,
    enc_person_name => $enc_person_name,
  });
}

=head2 contact

Contact a league official by email (displays a contact form).

=cut

sub contact :Chained("holders") :PathPart("contact") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  my $person = $c->stash->{person};
  my $enc_person_name = $c->stash->{enc_person_name};
  
  unless ( defined($person->email_address) and $person->email_address ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.positions.error.no-email-address", $enc_person_name)})}));
    $c->detach;
    return;
  }
  
  # Stash our template / form information
  $c->stash({
    template => "html/info/officials/positions/contact/form.ttkt",
    subtitle3 => $c->maketext("menu.title.contact"),
    form_action => $c->uri_for_action("/info/officials/positions/send_email", [$position->url_key, $person->url_key]),
    view_online_display => "Sending an email",
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/autogrow/jquery.ns-autogrow.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/autogrow.js"),
      $c->uri_for("/static/script/info/officials/positions/contact.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    page_description => $c->maketext("description.contact", $enc_person_name),
  });
  
  if ( !$c->user_exists and $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
    my $locale_code = $c->locale;
    $locale_code =~ s/_/-/;
    push(@{$c->stash->{external_scripts}}, sprintf("https://www.google.com/recaptcha/api.js?hl=%s", $locale_code));
    $c->stash({reCAPTCHA => 1});
  }
  
  # Store current date/time in the session so we can retrieve it and work out how long it took to fill out the form
  $c->session->{form_time_contact_official} = $c->datetime_tz({time_zone => "UTC"});
}

=head2 send_email

Contact a league official by email (displays a contact form).

=cut

sub send_email :Chained("holders") :PathPart("send-email") :Args(0) {
  my ( $self, $c ) = @_;
  my $position = $c->stash->{position};
  my $person = $c->stash->{person};
  my $enc_name = $c->stash->{enc_name};
  my ( $first_name, $surname, $name, $email_address, $user );
  my $message = $c->req->params->{message};
  my $jtest = $c->req->params->{jtest};
  my $time = $c->session->{form_time_contact_official};
  delete $c->session->{form_time_contact_official};
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
    
    # Check recaptcha result if appropriate
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
  
  unless ( defined($person->email_address) ) {
    $c->response->redirect($c->uri_for_action("/info/officials/view_current_season",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.positions.error.no-email-address", $enc_name)})}));
    $c->detach;
    return;
  }
  
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
          REFFERRER => $c->req->referer,
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
    
    $c->response->redirect($c->uri_for_action("/info/officials/positions/contact", [$position->url_key, $person->url_key],
            {mid => $c->set_status_msg({error => \@errors})}));
    $c->detach;
    return;
  } else {
    # No errors, send the email.
    # Get the recipients
    my $recipients = [$person->email_address, $person->display_name];
    
    # Prepare values for HTML email
    my $html_site_name = encode_entities($c->config->{name});
    my $html_name = encode_entities($name);
    my $html_email = encode_entities($email_address);
    my $html_recp_name = encode_entities($person->first_name);
    my $html_message = encode_entities($message);
    
    # Line breaks in HTML message
    $html_message =~ s|(\r?\n)|<br />$1|g;
    
    $c->model("Email")->send({
      to => $recipients,
      reply => [$email_address, $name],
      image => [$c->path_to(qw( root static images banner-logo-player-small.png ))->stringify, "logo"],
      subject => $c->maketext("email.subject.contact-official", $name, $c->config->{name}),
      plaintext => $c->maketext("email.plain-text.contact-official", $person->first_name, $name, $position->position_name, $c->config->{name}, $email_address, $message, $c->req->address),
      htmltext => [qw( html/generic/generic-message.ttkt :TT )],
      template_vars => {
        name => $html_site_name,
        home_uri => $c->uri_for("/"),
        email_subject => $c->maketext("email.subject.contact-official", $html_name, $html_site_name),
        email_html_message => $c->maketext("email.html.contact-official", $html_recp_name, $html_name, $enc_name, $html_site_name, $html_email, $html_message, $c->req->address),
      },
    });
    
    $c->stash({
      template => "html/info/officials/positions/contact/thank-you.ttkt",
      subtitle1 => $c->maketext("contact.thank-you.header", $html_name),
      user => $name,
    });
    
    #$c->forward("TopTable::Controller::SystemEventLog", "add_event", ["contact-form", "submit", {id => $reason->id}, $reason->name]);
    
    # Breadcrumbs links
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/info/officials/positions/contact", [$position->url_key, $person->url_key]),
      label => $c->maketext("menu.title.contact"),
    });
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
