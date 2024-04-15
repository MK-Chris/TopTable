package TopTable::Controller::Info;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use Email::Valid;
use DateTime::Format::DateParse;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Info - Catalyst Controller for displaying information - rules, officials, contact forms, etc.  Mainly static.

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.title.info") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info"),
    label => $c->maketext("menu.title.info"),
  });
}


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({
    template => "html/info/options.ttkt",
    view_online_display => "Viewing league information",
    view_online_link => 1,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 contact

Display a contact form.  If the user is logged in, use their user information, otherwise display fields to fill out.

=cut

sub contact :Local {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  my $banned = $c->model("DB::Ban")->is_banned({
    ip_address => $c->req->address,
    user => $c->user,
    level => "contact",
    log_allowed => 0,
    log_banned => 1,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
  });
  
  # Log our responses
  $c->log->error($_) foreach @{$banned->{errors}};
  $c->log->warning($_) foreach @{$banned->{warnings}};
  $c->log->info($_) foreach @{$banned->{info}};
  
  if ( $banned->{is_banned} ) {
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {error => $c->maketext("contact.form.error.banned")} )}));
    $c->detach;
    return;
  }
  
  my $reasons = $c->model("DB::ContactReason")->all_reasons;
  
  $c->stash({
    template => "html/info/contact/form.ttkt",
    subtitle1 => $c->maketext("menu.title.contact"),
    form_action => $c->uri_for_action("/info/do_contact"),
    view_online_display => "Sending an email",
    view_online_link => 1,
    reasons => $reasons,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/autogrow/jquery.ns-autogrow.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/autogrow.js"),
      $c->uri_for("/static/script/info/contact.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    page_description => $c->maketext("description.contact", $site_name),
  });
  
  if ( !$c->user_exists and $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
    my $locale_code = $c->locale;
    $locale_code =~ s/_/-/;
    push(@{$c->stash->{external_scripts}}, sprintf("https://www.google.com/recaptcha/api.js?hl=%s", $locale_code));
    $c->stash({reCAPTCHA => 1});
  }
  
  # Store current date/time in the session so we can retrieve it and work out how long it took to fill out the form
  $c->session->{form_load_time_contact} = $c->datetime_tz({time_zone => "UTC"});
}

=head2 do_contact

Send the email from someone sending the contact form.

=cut

sub do_contact :Path("send-email") {
  my ( $self, $c ) = @_;
  my ( $first_name, $surname, $name, $email_address, $user );
  my @errors = ();
  my $jtest = $c->req->params->{jtest};
  my $time = $c->session->{form_load_time_contact};
  delete $c->session->{form_load_time_contact};
  
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
          push(@errors, sprintf("%s\n", $c->maketext($_) )) foreach @{$captcha_result->{response_content}{"error-codes"}};
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
  
  my $reason = $c->model("DB::ContactReason")->check($c->req->params->{reason});
  my $message = $c->req->params->{message};
  
  push(@errors, $c->maketext("contact.form.error.reason-invalid")) unless defined($reason);
  push(@errors, $c->maketext("contact.form.error.no-message")) unless $message;
  
  # Check Cleantalk
  if ( $c->config->{"Model::Cleantalk::Contact"}{args}{auth_key} ) {
    $time = DateTime::Format::DateParse->parse_datetime($time, "UTC");
    
    if ( defined($time) ) {
      my $delta = $time->delta_ms($c->datetime_tz({time_zone => "UTC"}));
      my $seconds = ($delta->{minutes} * 60) + $delta->{seconds};
      
      my %headers = %{$c->req->headers};
      my $sender_info = encode_json({
        REFFERRER => $c->req->referer,
        USER_AGENT => $c->req->user_agent,
      });
      
      my $response = $c->model("Cleantalk::Contact")->request({
        method_name => "check_message",
        message => $message,
        sender_ip => $c->req->address,
        sender_email => $email_address, # Email IP of the visitor
        sender_nickname => $name, # Nickname of the visitor
        submit_time => $seconds, # The time taken to fill the comment form in seconds
        js_on => ($jtest) ? 1 : 0, # The presence of JavaScript for the site visitor, 0|1
        all_headers => \%headers,
        sender_info => $sender_info,
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
    $c->flash->{reason} = $reason->id if defined($reason);
    $c->flash->{message} = $message;
    
    $c->response->redirect($c->uri_for("/info/contact",
            {mid => $c->set_status_msg({error => \@errors})}));
    $c->detach;
    return;
  } else {
    # No errors, send the email.
    # Get the recipients
    my $reason_recipients = $reason->contact_reason_recipients;
    my $recipients = [];
    while ( my $recipient = $reason_recipients->next ) {
      push(@{ $recipients }, [ $recipient->person->email_address, $recipient->person->display_name ]);
    }
    
    # Prepare values for HTML email
    my $html_site_name = encode_entities($c->config->{name});
    my $html_name = encode_entities($name);
    my $html_reason = encode_entities($reason->name);
    my $html_email = encode_entities($email_address);
    my $html_message = encode_entities($message);
    
    # Line breaks in HTML message
    $html_message =~ s|(\r?\n)|<br />$1|g;
    
    $c->model("Email")->send({
      to => $recipients,
      reply => [$email_address, $name],
      image => [$c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo"],
      subject => $c->maketext("email.subject.contact-form", $c->config->{name}, $name, $reason->name),
      plaintext => $c->maketext("email.plain-text.contact-form", $c->config->{name}, $name, $email_address, $message, $c->req->address),
      htmltext => [qw( html/generic/generic-message.ttkt :TT )],
      template_vars => {
        name => $html_site_name,
        home_uri => $c->uri_for("/"),
        email_subject => $c->maketext("email.subject.contact-form", $html_site_name, $html_name, $html_reason),
        email_html_message => $c->maketext("email.html.contact-form", $html_site_name, $html_name, $html_email, $html_message, $c->req->address),
      },
    });
    
    $c->stash({
      template => "html/info/contact/thank-you.ttkt",
      subtitle1 => $c->maketext("contact.thank-you.header", $html_name),
      user_name => $html_name,
    });
    
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["contact-form", "submit", {id => $reason->id}, $reason->name]);
    
    # Breadcrumbs links
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for("/info/contact"),
      label => $c->maketext("menu.title.contact"),
    });
  }
}

=head2 team_captains

Retrieve all captains and their contact details.  Group either by division or team, depending on the argument passed in.

=cut

sub team_captains :Path("team-captains") :Args(1) {
  my ( $self, $c, $view_by ) = @_;
  
  # Check there's a current season, otherwise we'll error
  my $season = $c->model("DB::Season")->get_current;
  
  unless ( defined($season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("team-captains.view.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  if ( $view_by ne "by-club" and $view_by ne "by-division" ) {
    # Invalid grouping, just throw a 404
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Check the auth for edit / delete links
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( club_edit club_delete team_edit team_delete person_edit person_delete )], "", 0]);
  
  $c->stash({
    template => sprintf("html/info/team-captains/view-%s.ttkt", $view_by),
    subtitle1 => $c->maketext("menu.text.captains"),
    teams => scalar $c->model("DB::Team")->get_teams_with_captains_in_season({season => $season, view_by => $view_by}),
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for(sprintf("/static/script/info/team-captains/view-%s.js", $view_by)),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
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
