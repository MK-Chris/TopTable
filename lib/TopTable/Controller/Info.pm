package TopTable::Controller::Info;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use Email::Valid;

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
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.title.info") });
  
  # Breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    # Clubs listing
    path  => $c->uri_for("/info"),
    label => $c->maketext("menu.title.info"),
  });
}


=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({
    template            => "html/info/options.ttkt",
    view_online_display => "Viewing league information",
    view_online_link    => 1,
    external_scripts      => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 contact

Display a contact form.  If the user is logged in, use their user information, otherwise display fields to fill out.

=cut

sub contact :Local {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  $c->load_status_msgs;
  
  my $reasons = $c->model("DB::ContactReason")->all_reasons;
  
  $c->stash({
    template            => "html/info/contact/form.ttkt",
    subtitle1           => $c->maketext("menu.title.contact"),
    form_action         => $c->uri_for_action("/info/do_contact"),
    view_online_display => "Sending an email",
    view_online_link    => 1,
    reasons             => [ $c->model("DB::ContactReason")->all_reasons ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/autogrow/jquery.ns-autogrow.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/autogrow.js"),
      $c->uri_for("/static/script/info/contact.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    page_description    => $c->maketext("description.contact", $site_name),
  });
  
  if ( !$c->user_exists and $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
    my $locale_code = $c->locale;
    $locale_code =~ s/_/-/;
    push( @{ $c->stash->{external_scripts} }, sprintf( "https://www.google.com/recaptcha/api.js?hl=%s", $locale_code ) );
    $c->stash({reCAPTCHA => 1});
  }
  
  # Breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    # Clubs listing
    path  => $c->uri_for("/info/contact"),
    label => $c->maketext("menu.title.contact"),
  });
}

=head2 do_contact

Send the email from someone sending the contact form.

=cut

sub do_contact :Path("send-email") {
  my ( $self, $c ) = @_;
  my ( $first_name, $surname, $name, $email_address );
  my @errors = ();
  
  # Handle the contact form and send the email if there are no errors.
  if ( $c->user_exists ) {
    # The user is logged in, take their details from their login.
    $name           = $c->user->display_name;
    $email_address  = $c->user->email_address;
  } else {
    # Not logged on, check we have the required form fields.
    $first_name     = $c->request->parameters->{first_name};
    $surname        = $c->request->parameters->{surname};
    $email_address  = $c->request->parameters->{email_address};
    
    if ( !$c->user_exists and $c->config->{Google}{reCAPTCHA}{validate_on_contact} and $c->config->{Google}{reCAPTCHA}{site_key} and $c->config->{Google}{reCAPTCHA}{secret_key} ) {
      my $captcha_result = $c->forward( "TopTable::Controller::Root", "recaptcha" );
      
      if ( $captcha_result->{request_success} ) {
        # Request to Google was successful
        if ( !$captcha_result->{response_content}{success} ) {
          # Error validating, get the response messages in the correct language
          push(@errors, sprintf( "%s\n", $c->maketext( $_ ) )) foreach @{ $captcha_result->{response_content}{"error-codes"} };
        }
      } else {
        # Error requesting validation
        push(@errors, sprintf( "%s\n", $c->maketext("google.recaptcha.error-sending") ));
      }
    }
    
    if ( $first_name ) {
      if ( $first_name and $surname ) {
        # Name is made up of first and surnames
        $name = sprintf( "%s %s", $first_name, $surname );
      } else {
        # Name is just first name
        $name = $first_name;
      }
    } else {
      push(@errors, {id => "contact.form.error.no-first-name"});
    }
    
    if ( $email_address ) {
      # Email is filled out, check it
      
    } else {
      # Email missing
      push(@errors, {id => "contact.form.error.no-email-address"});
    }
  }
  
  my $reason  = $c->model("DB::ContactReason")->check( $c->request->parameters->{reason} );
  my $message = $c->request->parameters->{message};
  
  push(@errors, {id => "contact.form.error.reason-invalid"}) unless defined( $reason );
  push(@errors, {id => "contact.form.error.no-message"}) unless $message;
  
  if ( scalar( @errors ) ) {
    # Errors, flash the values and redirect back to the form
    $c->flash->{first_name}     = $first_name;
    $c->flash->{surname}        = $surname;
    $c->flash->{email_address}  = $email_address;
    $c->flash->{reason}         = $reason->id if defined( $reason );
    $c->flash->{message}        = $message;
    
    $c->response->redirect( $c->uri_for("/info/contact",
            {mid => $c->set_status_msg( {error => $c->build_message( \@errors ) } )}));
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
    my $html_site_name  = encode_entities( $c->config->{name} );
    my $html_name       = encode_entities( $name );
    my $html_reason     = encode_entities( $reason->name );
    my $html_email      = encode_entities( $email_address );
    my $html_message    = encode_entities( $message );
    
    # Line breaks in HTML message
    $html_message       =~ s|(\r?\n)|<br />$1|g;
    
    $c->model("Email")->send({
      to            => $recipients,
      reply         => [ $email_address, $name ],
      image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
      subject       => $c->maketext("email.subject.contact-form", $c->config->{name}, $name, $reason->name),
      plaintext     => $c->maketext("email.plain-text.contact-form", $c->config->{name}, $name, $email_address, $message),
      htmltext      => [ qw( html/generic/generic-message.ttkt :TT ) ],
      template_vars => {
        name                => $html_site_name,
        home_uri            => $c->uri_for("/"),
        email_subject       => $c->maketext("email.subject.contact-form", $html_site_name, $html_name, $html_reason),
        email_html_message  => $c->maketext("email.html.contact-form", $html_site_name, $html_name, $html_email, $html_message),
      },
    });
    
    $c->stash({
      template  => "html/info/contact/thank-you.ttkt",
      subtitle1 => $c->maketext("contact.thank-you.header", $html_name),
      user_name => $html_name,
    });
    
    # Breadcrumbs links
    push( @{ $c->stash->{breadcrumbs} }, {
      # Clubs listing
      path  => $c->uri_for("/info/contact"),
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
