package TopTable::Controller::Users;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use HTML::Entities;
use Data::Dumper::Concise;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to manage users, including registration and logging in.

=head1 METHODS

=cut

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.users")});
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/users"),
    label => $c->maketext("menu.text.users"),
  });
}

=head2 base

Chain base for getting the club ID and checking it.

=cut

sub base :Chained("/") :PathPart("users") :CaptureArgs(1) {
  my ($self, $c, $user_id) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to view users
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_view", $c->maketext("user.auth.view-users"), 1] );
  
  # user is logged in, they'll automatically get the link for their own username anyway
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( user_edit_all user_delete_all ) ], "", 0] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_own", "", 0] ) if $c->user_exists and !$c->stash->{authorisation}{news_article_edit_all}; # Only do this if the user is logged in and we can't edit all articles
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_delete_own", "", 0] ) if $c->user_exists and !$c->stash->{authorisation}{news_article_delete_all}; # Only do this if the user is logged in and we can't delete all articles
  
  my $user = $c->model("DB::User")->find_id_or_url_key($user_id);
  
  if ( defined( $user ) ) {
    my $encoded_username = encode_entities( $user->username );
    $c->stash({
      user              => $user,
      encoded_username  => $encoded_username,
      subtitle1         => $encoded_username,
    });
    
    # Breadcrumbs
    push(@{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/users/view", [$user->url_key]),
      label => $encoded_username,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of clubs.  Matches /clubs

=cut

sub base_list :Chained("/") :PathPart("users") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view users
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_view", $c->maketext("user.auth.view-users"), 1] );
  
  # Check the authorisation to edit / delete users so we can display the links if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( user_edit_all user_delete_all ) ], "", 0] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_own", "", 0] ) if $c->user_exists and !$c->stash->{authorisation}{news_article_edit_all}; # Only do this if the user is logged in and we can't edit all articles
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_delete_own", "", 0] ) if $c->user_exists and !$c->stash->{authorisation}{news_article_delete_all}; # Only do this if the user is logged in and we can't delete all articles
  
  # Page description
  $c->stash({
    page_description  => $c->maketext("description.users.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the clubs on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/users/list_first_page")});
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  $c->detach( "retrieve_paged", [$page_number] );
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/users/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/users/list_specific_page", [$page_number])});
  }
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $users = $c->model("DB::User")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $users->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/users/list_first_page",
    specific_page_action  => "/users/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/users/list.ttkt",
    view_online_display => "Viewing users",
    view_online_link    => 1,
    users               => $users,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

View a user's profile.

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $user              = $c->stash->{user};
  my $encoded_username  = $c->stash->{encoded_username};
  my $site_name         = $c->stash->{encoded_site_name};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push a delete link if we're authorised to eidt all or to edit our own user and are logged in as the user we're viewing
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text      => $c->maketext("admin.edit-object", $encoded_username),
    link_uri  => $c->uri_for_action("/users/edit", [$user->url_key]),
  }) if $c->stash->{authorisation}{user_edit_all} or ( $c->stash->{authorisation}{user_edit_own} and $c->user_exists and $c->user->id == $user->id );
  
  # Push a delete link if we're authorised to delete all or to delete our own user and are logged in as the user we're viewing
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text      => $c->maketext("admin.delete-object", $encoded_username),
    link_uri  => $c->uri_for_action("/users/delete", [$user->url_key]),
  }) if $c->stash->{authorisation}{user_delete_all} or ( $c->stash->{authorisation}{user_delete_own} and $c->user_exists and $c->user->id == $user->id );
  
  $c->stash({
    template          => "html/users/view.ttkt",
    title_links       => \@title_links,
    canonical_uri     => $c->uri_for_action("/users/view", [$user->url_key]),
    page_description  => $c->maketext("description.users.view", $encoded_username, $site_name),
  });
}

=head2 edit

Edit a user's profile.

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $user = $c->stash->{user};
  
  # Check that we are authorised to edit this user
  my $redirect_on_fail = 1 unless $c->user_exists;
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_all", "edit this user", $redirect_on_fail] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_own", "edit this user", 1] ) if !$c->stash->{authorisation}{user_edit_all} and $c->user_exists and $c->user->id == $user->id;
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_edit", "", 0] );
  
  # Get the timezone categories, then map each timezone in that category with the category as the key to a hashref, value is an arrayref of countries
  my @tz_categories = DateTime::TimeZone->categories;
  my $timezones     = {};
  $timezones->{$_} = DateTime::TimeZone->names_in_category( $_ ) foreach @tz_categories;
  
  $c->stash({
    template          => "html/users/edit.ttkt",
    form_action       => $c->uri_for_action("/users/do_edit", [$user->url_key]),
    external_scripts  => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
    ],
    external_styles   => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    subtitle2         => $c->maketext("admin.edit"),
    languages         => $c->config->{I18N}{locales},
    timezones         => $timezones,
  });
  
  $c->stash({roles => [ $c->model("DB::Role")->all_roles ]}) if $c->stash->{authorisation}{role_edit};
  
  $c->warn_on_non_https;
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/users/edit", [$user->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Edit a user's profile.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $user = $c->stash->{user};
  
  $c->stash({
    template  => "html/users/delete.ttkt",
    subtitle2 => $c->maketext("admin.delete"),
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/users/delete", [$user->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 register

Display a form for users to register.

=cut

sub register :Global {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  if ( $c->user_exists ) {
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {info => $c->maketext("user.login.error.already-logged-in")} )}));
    $c->detach;
    return;
  } else {
    # Get the timezone categories, then map each timezone in that category with the category as the key to a hashref, value is an arrayref of countries
    my @tz_categories = DateTime::TimeZone->categories;
    my $timezones = {};
    $timezones->{$_} = DateTime::TimeZone->names_in_category( $_ ) foreach @tz_categories;
    
    # Set up external scripts
    my @external_scripts = (
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
    );
    
    # Push recaptcha script and set the flag if we need to
    my $recaptcha = 0;
    if ( $c->config->{Google}{reCAPTCHA}{validate_on_register} ) {
      my $locale_code = $c->locale;
      $locale_code =~ s/_/-/;
      push(@external_scripts, sprintf( "https://www.google.com/recaptcha/api.js?hl=%s", $locale_code ));
      $recaptcha = 1;
    }
    
    $c->stash({
      template          => "html/users/register.ttkt",
      external_scripts  => \@external_scripts,
      external_styles     => [
        $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
        $c->uri_for("/static/css/chosen/chosen.min.css"),
      ],
      subtitle1         => $c->maketext("user.register"),
      reCAPTCHA         => $recaptcha,
      timezones         => $timezones,
      languages         => $c->config->{I18N}{locales},
    });
  }
  
  $c->warn_on_non_https;
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/register"),
    label => $c->maketext("user.register"),
  });
}

=head2 do_edit

Process the form for editing a user.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $user = $c->stash->{user};
  
  # Check that we are authorised to edit this user - the function will won't redirect
  # if we are logged in and the current user matches the user we're editing (in this
  # case an additional lookup is required to see if the user can edit their own profile)
  my $redirect_on_fail = ( $c->user_exists and $c->user->id == $user->id ) ? 0 : 1;
  
  # Only call localize on this string once
  my $lang_edit_user = $c->maketext("user.auth.edit-user");
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_all", $lang_edit_user, $redirect_on_fail] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["user_edit_own", $lang_edit_user, 1] ) if !$c->stash->{authorisation}{user_edit_all} and $c->user_exists and $c->user->id == $user->id;
  
  # Detach to the setup routine
  $c->detach( "setup_user", ["edit"] );
}

=head2 create

Process the user registration form.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  if ( $c->user_exists ) {
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {info => $c->maketext("user.login.error.already-logged-in")} )}));
    $c->detach;
    return;
  }
  
  # Detach to the setup routine
  $c->detach( "setup_user", ["register"] );
}

=head2 setup_user

Process the registration / user edit form.

=cut

sub setup_user :Private {
  my ( $self, $c, $action ) = @_;
  my $user                  = $c->stash->{user};
  my $username              = $c->request->parameters->{username};
  my $email_address         = $c->request->parameters->{email_address};
  my $confirm_email_address = $c->request->parameters->{confirm_email_address};
  my $password              = $c->request->parameters->{password};
  my $confirm_password      = $c->request->parameters->{confirm_password};
  my $current_password      = $c->request->parameters->{current_password};
  my $language              = $c->request->parameters->{language};
  my $timezone              = $c->request->parameters->{timezone};
  my $html_emails           = $c->request->parameters->{html_emails};
  my $facebook              = $c->request->parameters->{facebook};
  my $twitter               = $c->request->parameters->{twitter};
  my $aim                   = $c->request->parameters->{aim};
  my $jabber                = $c->request->parameters->{jabber};
  my $website               = $c->request->parameters->{website};
  my $interests             = $c->request->parameters->{interests};
  my $occupation            = $c->request->parameters->{occupation};
  my $location              = $c->request->parameters->{location};
  my $hide_online           = $c->request->parameters->{hide_online};
  my $roles                 = $c->request->parameters->{roles};
  my $error;
  
  if ( $action eq "register" and $c->config->{Google}{reCAPTCHA}{validate_on_register} ) {
    my $captcha_result = $c->forward( "TopTable::Controller::Root", "recaptcha" );
    
    if ( $captcha_result->{request_success} ) {
      # Request to Google was successful
      if ( !$captcha_result->{response_content}{success} ) {
        # Error validating, get the response messages in the correct language
        $error .=  sprintf( "%s\n", $c->maketext( $_ ) ) foreach @{ $captcha_result->{response_content}{"error-codes"} };
      }
    } else {
      # Error requesting validation
      $error .= sprintf( "%s\n", $c->maketext("google.recaptcha.error-sending") );
    }
    
    if ( $error ) {
      # If we couldn't validate the CAPTCHA, we need to redirect to the error page straight away
      # Flash the values we've got so we can set them
      $c->flash->{username}               = $username;
      $c->flash->{email_address}          = $email_address;
      $c->flash->{confirm_email_address}  = $confirm_email_address;
      $c->flash->{timezone}               = $timezone;
      
      $c->response->redirect( $c->uri_for_action("/users/register",
                                  {mid => $c->set_status_msg( {error => $error} ) }) );
      $c->detach;
      return;
    }
  }
  
  # Can we change the username?
  my $username_editable;
  if ( $c->stash->{authorisation}{user_edit_all} or $c->stash->{config}{users}{allow_username_edit} ) {
    # If we can edit all users, not just our own, we allow changing of usernames anyway.  If we are
    # only authorised to edit our own user profile, we need to check the config setting.
    $username_editable = 1;
  } else {
    # In all other circumstances, the username is not editable
    $username_editable = 0;
  }
  
  # Send the form details to the model to do error checking and registration
  my $user_result = $c->model("DB::User")->create_or_edit({
    action                => $action,
    username_editable     => $username_editable,
    username              => $username,
    user                  => $user,
    email_address         => $email_address,
    confirm_email_address => $confirm_email_address,
    password              => $password,
    confirm_password      => $confirm_password,
    current_password      => $current_password,
    language              => $language,
    timezone              => $timezone,
    html_emails           => $html_emails,
    facebook              => $facebook,
    twitter               => $twitter,
    aim                   => $aim,
    jabber                => $jabber,
    website               => $website,
    interests             => $interests,
    occupation            => $occupation,
    location              => $location,
    hide_online           => $hide_online,
    ip_address            => $c->request->address,
    installed_languages   => $c->config->{I18N}{locales},
    roles                 => $roles,
    editing_user          => $c->user,
  });
  
  if ( scalar( @{ $user_result->{error} } ) ) {
    # If there are errors, redirect back to the registration form with errors
    my $error = $c->build_message( $user_result->{error} );
    
    # Flash the values we've got so we can set them back to the form
    $c->flash->{username}               = $username;
    $c->flash->{email_address}          = $email_address;
    $c->flash->{confirm_email_address}  = $confirm_email_address;
    $c->flash->{language}               = $language;
    $c->flash->{html_emails}            = $html_emails;
    $c->flash->{timezone}               = $timezone;
    $c->flash->{facebook}               = $facebook;
    $c->flash->{twitter}                = $twitter;
    $c->flash->{aim}                    = $aim;
    $c->flash->{jabber}                 = $jabber;
    $c->flash->{website}                = $website;
    $c->flash->{interests}              = $interests;
    $c->flash->{occupation}             = $occupation;
    $c->flash->{location}               = $location;
    $c->flash->{hide_online}            = $hide_online;
    
    # If we're editing, the URI to redirect to is different
    my $redirect_uri;
    if ( $action eq "register" ) {
      $redirect_uri = $c->uri_for("/register",
                                {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      $redirect_uri = $c->uri_for_action("/users/edit", [$user->url_key],
                                {mid => $c->set_status_msg( {error => $error} ) });
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Success
    $user = $user_result->{user} if $action eq "register";
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", $action, {id => $user->id}, $user->username] );
    
    my $html_username = encode_entities( $username );
    if ( $action eq "register" ) {
      # Stash the confirmation screen details
      $c->stash({
        username            => $username,
        email_address       => $email_address,
        view_online_display => "Registering",
        view_online_link    => 0,
      });
      
      # Set the locale before getting the email message text
      $c->locale( $language );
      
      # Do the encoding - these do it once for each element here, as this is quite an expensive task
      my $subject = $c->maketext("email.subject.users.activate-user", $c->config->{name}, $username);
      
      # Set up the email send hash; we'll add to this if we're sending a HTML email
      my $send_options = {
        to            => [ $email_address, $username ],
        image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
        subject       => $subject,
        plaintext     => $c->maketext("email.plain-text.users.activate-user", $username, $c->config->{name}, $c->uri_for_action("/users/activate", [$user->activation_key])),
      };
      
      if ( $html_emails ) {
        # Encode the HTML bits
        my $html_site_name  = encode_entities( $c->config->{name} );
        my $html_subject    = $c->maketext("email.subject.users.activate-user", $html_site_name, $html_username);
        
        # Add the HTML parts of the email
        $send_options->{htmltext}       = [ qw( html/generic/generic-message.ttkt :TT ) ];
        $send_options->{template_vars}  = {
          name                => $html_site_name,
          home_uri            => $c->uri_for("/"),
          email_subject       => $html_subject,
          email_html_message  => $c->maketext("email.html.users.activate-user", $html_username, $html_site_name, $c->uri_for_action("/users/activate", [$user->activation_key])),
        };
      }
      
      # Email the user
      $c->model("Email")->send( $send_options );
      
      $c->stash({
        template  => "html/users/created.ttkt",
        subtitle2 => $c->maketext("user.registration.success-header"),
        user      => $user,
      });
    } else {
      $c->locale( $language ) if $user_result->{set_locale};
      
      my $warnings = $user_result->{warning};
      
      if ( scalar @$warnings ) {
        $warnings = $c->build_message( $warnings );
        $c->response->redirect( $c->uri_for_action("/users/view", [$user->url_key],
                                    {mid => $c->set_status_msg( {success  => $c->maketext("user.edit.success-with-warnings", $html_username),
                                                                warning   => $warnings} ) }) );
      } else {
        $c->response->redirect( $c->uri_for_action("/users/view", [$user->url_key],
                                    {mid => $c->set_status_msg( {success => $c->maketext("user.edit.success", $html_username) } ) }) );
      }
      
      $c->detach;
      return;
    }
  }
}

=head2 ajax_search

Handle search requests and return the data in JSON.

=cut

sub ajax_search :Path('ajax-search') :Args(0) {
  my ( $self, $c ) = @_;
  
  if (defined($c->request->parameters->{q})) {
    # Perform the search
    my @users       = $c->model("DB::User")->search_by_name( $c->request->parameters->{q} );
    my $json_users  = [];
    
    # Loop through and concatenate the short club name and team name, then push it on to the $json_teams arrayref
    foreach my $user (@users) {
      push( @{$json_users}, {id => $user->id, name => $user->username} );
    }
    
    # Set up the stash
    $c->stash({ json_users => $json_users,});;
    
    # Detach to the JSON view
    $c->detach( $c->view("JSON") );
  }
  
  # Don't alter the view who's online activity
  $c->stash->{skip_view_online} = 1;
}

=head2 resend_activation

Resend the email with the activation key.

=cut

sub resend_activation :Chained("base") :PathPart("resend-activation") :Args(0) {
  my ( $self, $c ) = @_;
  my $user = $c->stash->{user};
  
  # Check the user hasn't been activated yet
  if ( $user->activated ) {
    # User is already activated; error and show the login page.
    $c->response->redirect( $c->uri_for_action("/login",
                                {mid => $c->set_status_msg( {error => $c->maketext("user.activation.error-already-activated")} ) }) );
    $c->detach;
    return;
  } else {
    # Send the activation code
    
    # Stash the confirmation screen details
    $c->stash({
      username        => $user->username,
      activation_key  => $user->activation_key,
    });
      
    # Set the locale before getting the email message text, but save the current locale so we can set it back afterwards
    my $original_locale = $c->locale;
    $c->locale( $user->locale ) if $user->locale ne $c->locale;
    
    # Do the encoding - these do it once for each element here, as this is quite an expensive task
    my $subject = $c->maketext("email.subject.users.resend-activation", $c->config->{name}, $user->username);
    
    # Set up the email send hash; we'll add to this if we're sending a HTML email
    my $send_options = {
      to            => [ $user->email_address, $user->username ],
      image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
      subject       => $subject,
      plaintext     => $c->maketext("email.plain-text.users.resend-activation", $user->username, $c->uri_for_action("/users/activate", [$user->activation_key]), $c->config->{name}),
    };
    
    if ( $user->html_emails ) {
      # Encode the HTML bits
      my $html_site_name  = encode_entities( $c->config->{name} );
      my $html_username   = encode_entities( $user->username );
      my $html_subject    = $c->maketext("email.subject.users.activate-user", $html_site_name, $html_username);
      
      # Add the HTML parts of the email
      $send_options->{htmltext}       = [ qw( html/generic/generic-message.ttkt :TT ) ];
      $send_options->{template_vars}  = {
        name                => $html_site_name,
        home_uri            => $c->uri_for("/"),
        email_subject       => $html_subject,
        email_html_message  => $c->maketext("email.html.users.resend-activation", $html_username, $c->uri_for_action("/users/activate", [$user->activation_key]), $html_site_name),
      };
    }
    
    # Email the user
    $c->model("Email")->send( $send_options );
    
    # Set the locale back if we changed it
    $c->locale( $original_locale ) if $original_locale ne $user->locale;
    
    $c->stash({
      template            => "html/users/activation-resend.ttkt",
      subtitle2           => $c->maketext("user.activation.email-resent-header"),
      view_online_display => "Activating account",
      view_online_link    => 0,
      hide_breadcrumbs    => 1,
    });
  }
}

sub activate :Local :Args(1) {
  my ( $self, $c, $activation_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  if ( $c->user_exists ) {
    # We're logged in, so can't activate anything, as we must already be activated
    $c->response->redirect($c->uri_for("/",
        {mid => $c->set_status_msg( {info => $c->maketext("user.login.error.already-logged-in")} )}) );
    $c->detach;
    return;
  } else {
    # ID specified, process it
    my $user = $c->model("DB::User")->find({activation_key => $activation_key});
    
    if ( defined( $user ) ) {
      # Activation key found, check the user hasn't yet been activated
      if ( $user->activated ) {
        # User already activated
        $c->response->redirect( $c->uri_for_action("/login",
                                    {mid => $c->set_status_msg( {info => $c->maketext("user.activation.already-activated")} ) }) );
        $c->detach;
        return;
      } else {
        # Not activated yet, activate it.
        
        # First, try to find a 'Person' with the same email address
        my $person = $c->model("DB::Person")->find({email_address => $user->email_address});
        my $errors = $user->activate( $person );
        
        if ( scalar( @{ $errors } ) ) {
          $errors = $c->build_message( $errors );
          
          # Errors, return with them
          $c->response->redirect( $c->uri_for("/",
                                      {mid => $c->set_status_msg( {error => $errors} ) }) );
          $c->detach;
          return;
        } else {
          # Log the activation
          $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "activate", {id => $user->id}, $user->username] );
          
          # Email the user to tell them their account has been activated.
          # Stash the email details
          $c->stash({username => $user->username});
          
          # Set the locale before getting the email message text, but save the current locale so we can set it back afterwards
          my $original_locale = $c->locale;
          $c->locale( $user->locale ) if $user->locale ne $c->locale;
          
          # Do the encoding - these do it once for each element here, as this is quite an expensive task
          my $subject = $c->maketext("email.subject.users.activated", $c->config->{name}, $user->username);
          
          # Set up the email send hash; we'll add to this if we're sending a HTML email
          my $send_options = {
            to            => [ $user->email_address, $user->username ],
            image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
            subject       => $subject,
            plaintext     => $c->maketext("email.plain-text.users.activated", $user->username, $c->config->{name}, $c->uri_for("/login")),
          };
          
          if ( $user->html_emails ) {
            # Encode the HTML bits
            my $html_site_name  = encode_entities( $c->config->{name} );
            my $html_username   = encode_entities( $user->username );
            my $html_subject    = $c->maketext("email.subject.users.activated", $html_username, $html_site_name, $c->uri_for("/login"));
            
            # Add the HTML parts of the email
            $send_options->{htmltext}       = [ qw( html/generic/generic-message.ttkt :TT ) ];
            $send_options->{template_vars}  = {
              name                => $html_site_name,
              home_uri            => $c->uri_for("/"),
              email_subject       => $html_subject,
              email_html_message  => $c->maketext("email.html.users.activated", $html_username, $html_site_name, $c->uri_for("/login")),
            };
          }
          
          # Email the user
          $c->model("Email")->send( $send_options );
          
          # Set the locale back if we changed it
          $c->locale( $original_locale ) if $original_locale ne $user->locale;
          
          $c->response->redirect( $c->uri_for("/login",
                                      {mid => $c->set_status_msg( {success => $c->maketext("user.activation.success")} ) }) );
          $c->detach;
          return;
        }
      }
    } else {
      # Activation key not recognised, error
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "activate-fail", {id => undef}, undef] );
      $c->response->redirect( $c->uri_for_action("/users/activate",
                                  {mid => $c->set_status_msg( {error => $c->maketext("user.activation.error.key-incorrect")} ) }) );
      $c->detach;
      return;
    }
  }
}

=head2 login

Display a form for users to login.

=cut

sub login :Global {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  if ( $c->user_exists ) {
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {info => $c->maketext("user.login.error.already-logged-in")} )}));
    $c->detach;
    return;
  } else {
    $c->stash({
      template            => "html/users/login.ttkt",
      external_scripts    => [
        $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
        $c->uri_for("/static/script/standard/prettycheckable.js"),
        $c->uri_for("/static/script/users/login.js"),
      ],
      external_styles     => [
        $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      ],
      form_action         => "login",
      subtitle2           => $c->maketext("user.login"),
      view_online_display => "Logging in",
      view_online_link    => 0,
    });
    
    # reCAPTCHA if we've had lots of invalid login attempts either on the user, IP address or session
    if ( $c->forward( "invalid_login_attempts" ) > $c->config->{Google}{reCAPTCHA}{invalid_login_threshold} ) {
      push( @{ $c->stash->{external_scripts} }, sprintf( "https://www.google.com/recaptcha/api.js?hl=%s", $c->locale ) );
      $c->stash({reCAPTCHA => 1});
    }
  }
  
  $c->warn_on_non_https;
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/login"),
    label => $c->maketext("user.login"),
  });
}


=head2 do_login

Process the login request.

=cut

sub do_login :Path("authenticate") {
  my ( $self, $c ) = @_;
  my $username      = $c->request->parameters->{username};
  my $password      = $c->request->parameters->{password};
  my $redirect_uri  = $c->request->parameters->{redirect_uri};
  my $remember_user = ( exists( $c->stash->{cookie_settings}{preferences} ) and $c->stash->{cookie_settings}{preferences} ) ? $c->request->parameters->{remember_username} : 0;
  my $from_menu     = $c->request->parameters->{from_menu};
  my ( $user );
  my $error = [];
  
  $c->log->debug( Dumper( $c->stash->{cookie_settings} ) );
  
  if ( $c->user_exists ) {
    # Logged in already
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {info => $c->maketext("user.login.error.already-logged-in")} )}));
    $c->detach;
    return;
  } else {
    # Work out the redirect URI - we will either redirect to this or flash it
    my $base_uri = $c->request->base;
    if ( !$redirect_uri or $redirect_uri !~ m/^$base_uri/ ) {
      # No redirect URI, or the URI doesn't redirect to this site, work it out from the referer or just set to the home page
      if ( $c->request->headers->referer =~ m/^$base_uri/ and $c->request->headers->referer ne $c->uri_for("/login") ) {
        # We have come directly from one of our own pages, go back there 
        $redirect_uri = $c->request->headers->referer;
      } else {
        # Logged in from somewhere else, just go back to home
        $redirect_uri = "/";
      }
    }
    
    # First check the invalid login attempts and see if we needed to validate the CAPTCHA
    if ( $c->forward( "invalid_login_attempts" ) > $c->config->{Google}{reCAPTCHA}{invalid_login_threshold} ) {
      my $captcha_result = $c->forward( "TopTable::Controller::Root", "recaptcha" );
      
      if ( $captcha_result->{request_success} ) {
        # Request to Google was successful
        if ( !$captcha_result->{response_content}{success} ) {
          # Error validating
          if ( defined( $captcha_result->{response_content}{google_error_responses} ) ) {
            push( @{ $error }, $captcha_result->{response_content}{google_error_responses} );
          } else {
            push( @{ $error }, $c->maketext("google.recaptcha.error") );
          }
        }
      } else {
        # Error requesting validation
        push( @{ $error }, $c->maketext("google.recaptcha.request-failed"));
      }
      
      if ( scalar( @{ $error } ) ) {
        # Increment the invalid logins count for this IP
        $c->model("DB::InvalidLogin")->increment_count( $c->request->address );
        
        # Stash that this is an invalid login attempt so that when we update the session information, this can be updated too
        $c->stash->{invalid_login_attempt} = 1;
        
        # Log a failed login attempt
        $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "login-fail", {id => undef}, $username] );
        
        # If we couldn't validate the CAPTCHA, we need to redirect to the error page straight away
        # Flash the values we've got so we can set them
        $c->flash->{username}     = $username;
        $c->flash->{redirect_uri} = $redirect_uri;
        $c->response->redirect( $c->uri_for("/login",
                                    {mid => $c->set_status_msg( {error => $c->build_message( $error )} ) }) );
        $c->detach;
        return;
      }
    }
    
    # Not already logged in
    # Check for a blank username
    push( @{ $error }, $c->maketext("user.form.error.username-blank") ) unless $username;
    
    # Check for a blank username
    push( @{ $error }, $c->maketext("user.form.error.password-blank") ) unless $password;
    
    if ( scalar( @{ $error } ) ) {
      # If there are errors, redirect back to the registration form with errors
      # Increment the invalid logins count for this IP
      $c->model("DB::InvalidLogin")->increment_count( $c->request->address );
      
      # Stash that this is an invalid login attempt so that when we update the session information, this can be updated too
      $c->stash->{invalid_login_attempt} = 1;
      
      # Log a failed login attempt
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "login-fail", {id => undef}, $username] );
      
      # Stash the values we've got so we can set them
      $c->flash->{username}     = $username;
      $c->flash->{redirect_uri} = $redirect_uri;
      $c->response->redirect( $c->uri_for("/login",
                                  {mid => $c->set_status_msg( {error => $c->build_message( $error )} ) }) );
      $c->detach;
      return;
    } else {
      # No errors so far, check the user exists and is activated
      $user = $c->model("DB::User")->find({username => $username});
      
      if ( defined( $user ) ) {
        # User exists, check they're activated
        if ( $user->activated ) {
          # They are activated; process the login request.
          # Attempt to log the user in
          if ( $c->authenticate({username => $username, password => $password} ) ) {
            # Be a bit paranoid about security and force a change in the session ID straight after login
            $c->change_session_id;
            
            # Update user last visit data and reset invalid logins
            my $last_visited_date = $c->datetime_tz({time_zone => "UTC"});
            $c->user->update({
              last_visit_date     => sprintf("%s %s", $last_visited_date->ymd, $last_visited_date->hms),
              last_visit_ip       => $c->request->address,
              invalid_logins      => 0,
              last_invalid_login  => undef,
            });
            
            # Change the locale
            $c->locale( $c->user->locale ) if $c->locale ne $c->user->locale and $c->check_locale( $c->user->locale );
            
            # Stash that this is a successful login so we can reset the invalid login count in the session when we update it in the /end routine
            $c->stash->{successful_login} = 1;
            
            # See if we need to reset the invalid logins count for this IP
            $c->model("DB::InvalidLogin")->reset_count( $c->request->address );
            
            if ( $remember_user or ( $from_menu and defined( $c->request->cookie("toptable_username") ) and $c->request->cookie("toptable_username")->value ) ) {
              # If the user wants us to remember the username, set the cookie; if they've come from the menu and there's already a cookie set, we'll
              # assume we need to keep it.
              $c->response->cookies->{toptable_username} = {
                value     => $c->user->username,
                expires   => "+3M",
                httponly  => 1,
              };
            } else {
              # Otherwise, get rid of the cookie if it exists
              $c->response->cookies->{toptable_username} = {
                value   => "",
                expires => "-1d",
              };
            }
            
            # Log a valid login
            $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "login", {id => $c->user->id}, $c->user->display_name] );
            
            # If successful, then let them use the application
            # Redirect to wherever we earlier worked out we needed to go
            $c->stash({
              template            => "html/users/logged-in-notice.ttkt",
              subtitle2           => $c->maketext("user.login.success.header"),
              view_online_display => "Logging in",
              view_online_link    => 0,
              meta_refresh        => {
                time              => 5,
                url               => $redirect_uri,
              },
              status_msg          => {
                success           => $c->maketext("user.login.success.status-message"),
              },
              hide_breadcrumbs    => 1,
            });
          } else {
            # Username or password incorrect
            # Log a failed login attempt
            # Increment the invalid logins count for this IP / user
            $c->model("DB::InvalidLogin")->increment_count( $c->request->address );
            $user->update({
              invalid_logins      => $user->invalid_logins + 1,
              last_invalid_login  => $c->datetime_tz({time_zone => "UTC"}),
            });
            
            # Stash that this is an invalid login attempt so that when we update the session information, this can be updated too
            $c->stash->{invalid_login_attempt} = 1;
            
            $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "login-fail", {id => undef}, $username] );
            
            $c->flash->{username}     = $username;
            $c->flash->{redirect_uri} = $redirect_uri;
            $c->response->redirect( $c->uri_for("/login",
                                        {mid => $c->set_status_msg( {error => $c->maketext("user.login.error.authentication-failed")} ) }) );
            $c->detach;
            return;
          }
        } else {
          # Not yet activated; error
          
          # Stash the values we've got so we can set them
          $c->flash->{username}     = $username;
          $c->flash->{redirect_uri} = $redirect_uri;
          $c->response->redirect( $c->uri_for("/login",
                                      {mid => $c->set_status_msg( {error => $c->maketext("user.login.error.user-not-activated", $c->uri_for_action("/users/resend_activation", [$user->url_key]))} ) }) );
          $c->detach;
          return;
        }
      } else {
        # User doesn't exist; don't tell them that, just tell them the username or password
        # is wrong.
        # Increment the invalid logins count for this IP
        $c->model("DB::InvalidLogin")->increment_count( $c->request->address );
        
        # Stash that this is an invalid login attempt so that when we update the session information, this can be updated too
        $c->stash->{invalid_login_attempt} = 1;
        
        # Log a failed login attempt
        $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "login-fail", {id => undef}, $username] );
        
        # Stash the values we've got so we can set them
        $c->flash->{username}     = $username;
        $c->flash->{redirect_uri} = $redirect_uri;
        $c->response->redirect( $c->uri_for("/login",
                {mid => $c->set_status_msg( {error => $c->maketext("user.login.error.authentication-failed")} )} ));
        $c->detach;
        return;
      }
    }
  }
}

=head2 forgot_password

Show the form to enter a username and have the user's password reset link emailed to them.

=cut

sub forgot_password :Path("forgot-password") {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Set up reCAPTCHA if required
  my @external_scripts = ();
  my $recaptcha = 0;
  
  if ( $c->config->{Google}{reCAPTCHA}{validate_on_password_forget} ) {
    my $locale_code = $c->locale;
    $locale_code =~ s/_/-/;
    push(@external_scripts, sprintf( "https://www.google.com/recaptcha/api.js?hl=%s", $locale_code ));
    $recaptcha = 1;
  }
  
  $c->stash({
    template          => "html/users/forgot-password.ttkt",
    subtitle1 => $c->maketext("user.forgot-password"),
    form_action       => $c->uri_for_action("/users/send_reset_link"),
    subtitle          => $c->maketext("user.retrieve-username"),
    external_scripts  => \@external_scripts,
    reCAPTCHA         => $recaptcha,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/users/forgot-password"),
    label => $c->maketext("user.forgot-password"),
  });
}

=head2 send_reset_link

Process the form and send the user's username if the email address is registered.

=cut

sub send_reset_link :Path("send-reset-link") {
  my ( $self, $c ) = @_;
  
  my $email_address = $c->request->parameters->{email_address} || undef;
  
  # Search the users database for the given email address
  if ( defined( $email_address ) ) {
    my $user = $c->model("DB::User")->find({email_address => $email_address});
    
    if ( defined( $user ) ) {
      # User found, send an email with the username
      if ( $c->config->{Google}{reCAPTCHA}{validate_on_username_forget} ) {
        # Validate the CAPTCHA
        my $captcha_result = $c->forward( "TopTable::Controller::Root", "recaptcha" );
        
        my $error;
        if ( $captcha_result->{request_success} ) {
          # Request to Google was successful
          if ( !$captcha_result->{response_content}{success} ) {
            # Error validating, get the response messages in the correct language
            $error .= sprintf( "%s\n", $c->maketext( $_ ) ) foreach @{ $captcha_result->{response_content}{"error-codes"} };
          }
        } else {
          # Error requesting validation
          $error .= sprintf( "%s\n", $c->maketext("google.recaptcha.error-sending") );
        }
        
        if ( $error ) {
          # If we couldn't validate the CAPTCHA, we need to redirect to the error page straight away
          # Flash the values we've got so we can set them
          $c->flash->{email_address} = $email_address;
          
          $c->response->redirect( $c->uri_for_action("/users/forgot_password",
                                      {mid => $c->set_status_msg( {error => $error} ) }) );
          $c->detach;
          return;
        }
      }
      
      # If we've got this far, we've passed the CAPTCHA (or it was disabled), so we set a password reset link
      my $errors = $user->set_password_reset_key;
      
      if ( scalar( @{ $errors } ) ) {
        $errors = $c->build_message( $errors );
        $c->flash->{email_address} = $email_address;
        
        $c->response->redirect( $c->uri_for_action("/users/forgot_password",
                                    {mid => $c->set_status_msg( {error => $errors} ) }) );
        $c->detach;
        return;
      } else {
        # No errors if we get here, so just send the link
        
        # Set the locale before getting the email message text, but save the current locale so we can set it back afterwards
        my $original_locale = $c->locale;
        $c->locale( $user->locale ) if $user->locale ne $c->locale;
        
        # Do the encoding - these do it once for each element here, as this is quite an expensive task
        my $subject = $c->maketext("email.subject.users.password-reset", $c->config->{name}, $user->username);
        
        # Set up the email send hash; we'll add to this if we're sending a HTML email
        my $send_options = {
          to            => [ $user->email_address, $user->username ],
          image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
          subject       => $subject,
          plaintext     => $c->maketext("email.plain-text.users.password-reset", $user->username, $c->config->{name}, $c->uri_for_action("/users/reset_password", [$user->password_reset_key]), $c->request->address),
        };
        
        if ( $user->html_emails ) {
          # Encode the HTML bits
          my $html_site_name  = encode_entities( $c->config->{name} );
          my $html_username   = encode_entities( $user->username );
          my $html_subject    = $c->maketext("email.subject.users.username-retrieval", $html_site_name, $html_username);
          
          # Add the HTML parts of the email
          $send_options->{htmltext}       = [ qw( html/generic/generic-message.ttkt :TT ) ];
          $send_options->{template_vars}  = {
            name                => $html_site_name,
            home_uri            => $c->uri_for("/"),
            email_subject       => $html_subject,
            email_html_message  => $c->maketext("email.html.users.password-reset", $html_username, $html_site_name, $c->uri_for_action("/users/reset_password", [$user->password_reset_key]), $c->request->address),
          };
        }
        
        # Email the user
        $c->model("Email")->send( $send_options );
        
        # Set the locale back if we changed it
        $c->locale( $original_locale ) if $original_locale ne $user->locale;
        
        # Log that we've sent a reset link
        $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "forgot-password", {id => $user->id}, $user->username] );
      }
    } else {
      # User not found - do not raise an error, but email the address entered, informing them.  Raising an error can inform a malicious user that the email address wasn't found
      # Do the encoding - these do it once for each element here, as this is quite an expensive task
      my $subject = $c->maketext("email.subject.users.password-reset.user-not-found", $c->config->{name});
      
      # Encode the HTML bits
      my $html_site_name  = encode_entities( $c->config->{name} );
      my $html_subject    = $c->maketext("email.subject.users.password-reset.user-not-found", $html_site_name);
      
      # Email the user
      $c->model("Email")->send({
        to            => [ $email_address ],
        image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
        subject       => $subject,
        plaintext     => $c->maketext("email.plain-text.users.password-reset.user-not-found", $c->config->{name}, $c->request->address),
        htmltext      => [ qw( html/generic/generic-message.ttkt :TT ) ],
        template_vars => {
          name                => $html_site_name,
          home_uri            => $c->uri_for("/"),
          email_subject       => $html_subject,
          email_html_message  => $c->maketext("email.html.users.password-reset.user-not-found", $html_site_name, $c->request->address),
        },
      });
      
      # Log that we've had a request to reset an invalid account
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "password-reset-invalid", {id => undef}, ""] );
    }
  } else {
    # Email aaddress not supplied
    $c->response->redirect( $c->uri_for_action("/users/forgot_password",
            {mid => $c->set_status_msg( {error => $c->maketext("user.forgot-password.error.username-missing", $c->uri_for_action("/users/forgot_username"))} )} ));
    $c->detach;
    return;
  }
  
  # If we get this far we need to display a notice back to the user that a link to reset their password will be emailed to them if they're registered
  $c->stash({
    template  => "html/users/reset-password-link-sent.ttkt",
    subtitle1 => $c->maketext("user.forgot-password"),
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/users/forgot-password"),
    label => $c->maketext("user.forgot-password"),
  });
}

=head2 reset_password

Validate a password reset key, then display a form to reset the user's password.

=cut

sub reset_password :Path("reset-password") :Args(1) {
  my ( $self, $c, $password_reset_key ) = @_;
  
  # Validate the user from the password reset key
  my $user = $c->model("DB::User")->find({password_reset_key => $password_reset_key});
  
  if ( defined( $user ) ) {
    # Check the link hasn't expired
    my $current_time = $c->datetime_tz({time_zone => "UTC"});
    if ( $user->password_reset_expires->ymd("") . $user->password_reset_expires->hms("") > $current_time->ymd("") . $current_time->hms("") ) {
      # Still valid
      if ( $c->request->method eq "POST" ) {
        # Post request, process the form submission
        my $password          = $c->request->body_parameters->{password};
        my $confirm_password  = $c->request->body_parameters->{confirm_password};
        
        my $errors = $user->reset_password( $password, $confirm_password );
        
        if ( scalar( @{ $errors } ) ) {
          $errors = $c->build_message( $errors );
          $c->response->redirect( $c->uri_for_action("/users/reset_password", [$password_reset_key],
                                      {mid => $c->set_status_msg( {error => $errors} ) }) );
          $c->detach;
          return;
        } else {
          # No errors if we get here, so reset the password and notify the user
          $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "password-reset", {id => $user->id}, $user->username] );
          
          # Set the locale before getting the email message text, but save the current locale so we can set it back afterwards
          my $original_locale = $c->locale;
          $c->locale( $user->locale ) if $user->locale ne $c->locale;
          
          # Do the encoding - these do it once for each element here, as this is quite an expensive task
          my $subject = $c->maketext("email.subject.users.password-reset-confirm", $c->config->{name});
          
          # Set up the email send hash; we'll add to this if we're sending a HTML email
          my $send_options = {
            to            => [ $user->email_address, $user->username ],
            image         => [ $c->path_to( qw( root static images banner-logo-player-small.png ) )->stringify, "logo" ],
            subject       => $subject,
            plaintext     => $c->maketext("email.plain-text.users.password-reset-confirm", $user->username, $c->config->{name}, $c->uri_for("/login")),
          };
          
          if ( $user->html_emails ) {
            # Encode the HTML bits
            my $html_site_name  = encode_entities( $c->config->{name} );
            my $html_username   = encode_entities( $user->username );
            my $html_subject    = $c->maketext("email.subject.users.password-reset-confirm", $html_site_name, $html_username);
            
            # Add the HTML parts of the email
            $send_options->{htmltext}       = [ qw( html/generic/generic-message.ttkt :TT ) ];
            $send_options->{template_vars}  = {
              name                => $html_site_name,
              home_uri            => $c->uri_for("/"),
              email_subject       => $html_subject,
              email_html_message  => $c->maketext("email.html.users.password-reset-confirm", $html_username, $html_site_name, $c->uri_for("/login")),
            };
          }
          
          # Email the user
          $c->model("Email")->send( $send_options );
          
          # Set the locale back if we changed it
          $c->locale( $original_locale ) if $original_locale ne $user->locale;
        }
        
        # If we get this far, the password has changed, we just display a notice
        $c->stash({
          template  => "html/users/forgot-password-changed.ttkt",
          subtitle1 => $c->maketext("user.password-changed"),
          user      => $user,
        });
      } else {
        # Get request, display the form
        $c->stash({
          template    => "html/users/reset-password.ttkt",
          subtitle1   => $c->maketext("user.forgot-password"),
          form_action => $c->uri_for_action("/users/reset_password", [$password_reset_key]),
        });
        
        $c->warn_on_non_https;
      }
    } else {
      # Expired
      $c->detach( qw/ TopTable::Controller::Root default / );
    }
  } else {
    # Not found, just give a 404
    $c->detach( qw/ TopTable::Controller::Root default / );
  }
}

=head2 invalid_login_attempts

Return the number of invalid login attempts from either the session or IP address, whichever is greater.

=cut

sub invalid_login_attempts :Private {
  my ( $self, $c ) = @_;
  
  # Work out the number of invalid login attempts for this IP / session
  my $ip_attempts       = $c->model("DB::InvalidLogin")->number_of_attempts( $c->request->address );
  my $session_attempts  = $c->model("DB::Session")->number_of_attempts( $c->sessionid );
  
  # Return IP attempts if it's bigger, otherwise session attempts
  return ( $ip_attempts > $session_attempts ) ? $ip_attempts : $session_attempts;
}


=head2 logout

Logout the active user.

=cut

sub logout :Global {
  my ( $self, $c ) = @_;
  
  if ( $c->user_exists ) {
    # Grab the user ID / name so we can log it after we've logged out - once we've logged out, we can't access these from $c->user
    my $user_id = $c->user->id;
    my $user_display_name = $c->user->display_name;
    
    # Log out
    $c->logout;
    
    # Log the logout action - this needs to be done before we log out so we have the user object.
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["user", "logout", {id => $user_id}, $user_display_name] );
    
    # Redirect to the home page
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {info => $c->maketext("user.logout.success")} )}));
  } else {
    # Not logged in, so can't log out
    $c->response->redirect( $c->uri_for("/",
            {mid => $c->set_status_msg( {error => $c->maketext("user.logout.error.not-logged-in")} )})); 
  }
}

=head2 current_activity

Show the users currently online and what they're viewing / doing.

=cut

sub current_activity :Path("/users-online") {
  my ( $self, $c ) = @_;
  my ( $online_users );
  
  # Check that we are authorised to view clubs
  $c->forward( "check_authorisation", ["online_users_view", $c->maketext("user.auth.view-online-users"), 1] );
  $c->forward( "check_authorisation", [[ qw/ anonymous_online_users_view view_users_ip view_users_user_agent / ], "", 0] );
  
  my $online_users_last_active_limit = $c->datetime_tz({time_zone => "UTC"})->subtract(minutes => 15);
  if ( $c->stash->{authorisation}{anonymous_online_users_view} ) {
    # Can view everyone
    $online_users = [ $c->model("DB::Session")->get_all_online_users( $online_users_last_active_limit ) ];
  } else {
    # Can only view people who aren't hiding themselves
    $online_users = [ $c->model("DB::Session")->get_non_hidden_online_users( $online_users_last_active_limit ) ];
  }
  
  
  $c->log->debug( sprintf( "View IP: %d, view user agent: %d", $c->stash->{authorisation}{view_users_ip}, $c->stash->{authorisation}{view_users_user_agent} ) );
  
  $c->stash({
    template            => "html/users/online.ttkt",
    subtitle1           => $c->maketext("users.online-view-heading"),
    online_users        => $online_users,
    view_online_display => "Viewing online users",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/users/online.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/users-online"),
    label => $c->maketext("users.online-view-heading"),
  });
}

=head2 check_authorisation

Check whether a user is authorised to perform a particular task.

=head3 Parameters

$action: the name of the action (must be the same as the DB column name we are checking).
$message_detail: the text we want to put in error messages.  This is only the detail of what we want to show; the "you must be logged in to ..." or "you are not authorised to..." text is prepended to $message_detail which should be set to something like "create clubs".
$redirect: if this is true, we will redirect to the appropriate page; otherwise we will just stash an 'authorised' value with 1 or 0.

=head3 Description

There are a number of outcomes from this action, which should be forwarded to from the method you wish to check authorisation against:

If anonymous users are allowed to perform the action in question, no further permissions checks are performed; it would be pointless, as if anonymous users have permission and a particular user role does not, all they would need to do is log out in order to perform it.

If anonymous users are not allowed to perform the action and the user is not logged in, they are redirected to the login page; once logged in, they are redirected back to the original page they were requesting.

If the user is logged in but does not have authorisation to view the page or perform the action, they are redirected to the home page with an error message informing them of this.

If the user is logged in and has authorisation, the page is displayed or action is performed.

Finally, if $redirect is set to a false value, the redirections that would happen in each of the scenarios above do not happen, but a value is stashed with a 1 if the user is authorised or 0 if the user is not.  This is useful for, say, deciding whether or not to display a link to create a club on the club list page.

For example, if $action was set to "club_create" and $redirect was set to 0, a stashed hashref of $stash->{authorisation}{club_create} = 1 would be stored if the user is authorised, or $stash->{authorisation}{club_create} = 0 if the user is not authorised.

=cut

sub check_authorisation :Private {
  my ( $self, $c, $actions, $message_detail, $redirect ) = @_;
  my ( @roles, @role_names ) = ();
  my ( $anonymous_permission, $authorised );
  my $content_type = $c->request->parameters->{content_type} || "html";
  
  # If the action is an array, we need to check for each
  if ( ref( $actions ) eq "ARRAY" ) {
    # It's an array - make sure $redirect is disabled (we can only check one permission with redirection on)
    if ( $redirect ) {
      # Redirection is on - turn it off and log an error
      $redirect = 0;
      $c->log->error( "Can't call check_authorisation with \$redirect turned on when \$action is passed as an arrayref.  \$redirect will be turned off." );
    }
  } else {
    # If it's not an array, turn it into one so we can avoid if statements with branches that essentially do the same thing
    $actions = [ $actions ];
  }
  
  foreach my $action ( @{ $actions } ) {
    # If we've already called this function for this authorisation level, just move to the next item as there's no point doing it again
    next if exists( $c->stash->{authorisation}{$action} ) and !$redirect;
    
    # First find out if we can do this anonymously
    $anonymous_permission = $c->model("DB::Role")->find({
      anonymous => 1,
      $action   => 1
    });
    
    if ( defined( $anonymous_permission ) ) {
      # Can view anonymously, no need to check any other permissions
      # Stash the auth value if we're not redirecting on error.
      $c->stash->{authorisation}{$action} = 1 if !$redirect;
    } elsif ( $c->user_exists ) {
      # We are logged in, so need to check we're in a user group that can view
      @roles = $c->model("DB::Role")->search({
        $action => 1
      }, {
        order_by => {
          -asc => [ qw( name ) ],
        },
      });
      
      # Extract the name column for each returned value
      @role_names = map( $_->name, @roles );
      
      if ( $c->check_any_user_role(@role_names) ) {
        # We are in one of the roles that is authorised, set allowed flag
        # Stash the auth value - we may not need this at the moment (if $redirect is
        # on, the application may assume that if we get any further it is authorised)
        # but it could be used in other areas (i.e., putting a create link on the nav
        # menu).
        $c->stash->{authorisation}{$action} = 1;
      } else {
        # Logged in, just error
        if ( $redirect ) {
          if ( $content_type eq "json" ) {
            $c->detach( "TopTable::Controller::Root", "json_error", [403, $c->maketext("user.auth.denied", $message_detail)] );
          } else {
            $c->response->status(403);
            $c->response->redirect($c->uri_for("/",
              {mid => $c->set_status_msg( {error => $c->maketext("user.auth.denied", $message_detail)} )}));
            $c->detach;
            return;
          }
        } else {
          # Stash the auth value if we're not redirecting on error.
          $c->stash->{authorisation}{$action} = 0;
        }
      }
    } else {
      # Not logged in and anonymous users are unauthorised; redirect to /login
      if ( $redirect ) {
        # Flash the requested page value, so we can return to the same page once the user has authenticated.
        $c->flash->{redirect_uri} = $c->request->uri;
        
        # Redirect to the login page
        # Logged in, just error
        if ( $content_type eq "json" ) {
          $c->response->headers->header("WWW-Authenticate" => "FormBased");
          $c->detach( "TopTable::Controller::Root", "json_error", [401, $c->maketext("user.auth.login", $message_detail)] );
        } else {
          $c->response->redirect($c->uri_for("/login",
            {mid => $c->set_status_msg( {info => $c->maketext("user.auth.login", $message_detail)} )}));
          $c->detach;
          return;
        }
      } else {
        # Stash the auth value if we're not redirecting on error.
        $c->stash->{authorisation}{$action} = 0;
      }
    }
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
