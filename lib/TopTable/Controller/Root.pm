package TopTable::Controller::Root;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::TimeZone;
use LWP::UserAgent;
use JSON;
use Data::Printer;
use List::Util qw( min max );
use Time::HiRes qw( gettimeofday tv_interval );
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller' }

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in TopTable.pm
__PACKAGE__->config(namespace => "");

=encoding utf-8

=head1 NAME

TopTable::Controller::Root - Root Controller for TopTable

=head1 DESCRIPTION

This module contains all the methods that are either used commonly in all / from multiple controllers, and / or on the main index page.

=head1 METHODS

=head2 auto



=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Stash the correct timezone
  # Only do timezone stuff if we're not processing a js file
  $c->stash({
    timezone => $c->timezone,
    enc_site_name => encode_entities($c->config->{name}),
  });
}

=head2 begin

Routines to run on every page load.

=cut

sub begin :Private {
  my ( $self, $c ) = @_;
  
  # Get and stash cookie preferences
  my $cookie_settings = "[]";
  $cookie_settings = $c->req->cookie("cookieControlPrefs")->value if defined( $c->req->cookie("cookieControlPrefs") );
  $cookie_settings = ( defined($cookie_settings) ) ? decode_json($cookie_settings) : [];
  $c->stash({cookie_settings => {map{ $_ => 1} @{$cookie_settings}}});
  
  # Get the locale - check URI and cookie settings first
  my $locale = $c->get_locale_with_uri;
  
  # Only do session stuff if we're not processing a js file
  unless ( $c->req->path =~ /\.js$/ ) {
    # Delete the current session if there is one and it's expired
    $c->session_expires;
    
    # Delete all expired sessions
    $c->delete_expired_sessions;
    
    # Create a session if none exists.
    $c->session;
    
    # Update user IP / browser combination; we do this here so we can stash and use the user agent later on if needed
    my $user_agent = $c->model("DB::UserAgent")->update_user_agents($c->req->browser_detect->user_agent, $c->user, $c->req->address);
    
    # Stash the user agent object for later on
    $c->stash({user_agent => $user_agent});
    
    # Set up breadcrumbs as an empty array to begin with
    my @breadcrumbs = ();
    
    # Push the home element on to it if we're configured to
    push(@breadcrumbs, {
      path => "/",
      label => $c->maketext("menu.text.home"),
    }) unless $c->config->{breadcrumbs}{hide_home};
    
    # Stash what we have of the breadcrumbs so far (which will either be 'Home' or just an empty array ready for pushing)
    $c->stash({breadcrumbs => \@breadcrumbs});
  }
  
  Log::Log4perl::MDC->put("ip", $c->req->address);
  
  if ( defined( $c->user ) ) {
    Log::Log4perl::MDC->put("user", $c->user->username);
  } else {
    Log::Log4perl::MDC->put("user", "(Guest)");
  }
  
  # Housekeeping - unpin news articles where the pin expiry has passed, delete expired password reset / activation keys and cleanup invalid logins, delete expired bans
  $c->model("DB::NewsArticle")->unpin_expired_pins;
  $c->model("DB::InvalidLogin")->reset_expired_counts($c->config->{Google}{reCAPTCHA}{invalid_login_time_threshold});
  $c->model("DB::User")->reset_expired_invalid_login_counts($c->config->{Google}{reCAPTCHA}{invalid_login_time_threshold});
  $c->model("DB::Session")->reset_expired_invalid_login_counts($c->config->{Google}{reCAPTCHA}{invalid_login_time_threshold});
  $c->model("DB::User")->delete_expired_keys;
  $c->model("DB::Ban")->delete_expired_bans;
  
  # Check we're not banned from accessing the site; if we are, go straight for the forbidden page
  my $banned = $c->model("DB::Ban")->is_banned({
    ip_address => $c->req->address,
    level => "access",
    log_allowed => 0,
    log_banned => 1,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    line => __LINE__,
    caller => __PACKAGE__,
  });
  
  # Log our responses
  $c->log->error($_) foreach @{$banned->{errors}};
  $c->log->warning($_) foreach @{$banned->{warnings}};
  $c->log->info($_) foreach @{$banned->{info}};
  
  if ( $banned->{is_banned} ) {
    $c->detach("forbidden");
    return;
  }
}

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( index_edit match_update match_cancel news_create news_edit_all news_delete_all )], "", 0]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_own", "", 0]) if $c->user_exists and !$c->stash->{authorisation}{news_edit_all}; # Only do this if the user is logged in and we can't edit all articles
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_own", "", 0]) if $c->user_exists and !$c->stash->{authorisation}{news_delete_all}; # Only do this if the user is logged in and we can't delete all articles
  
  # Set up the title links if we need them
  my @title_links = ();
  
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.edit.index"),
    link_uri => $c->uri_for_action("/index_edit"),
  }) if $c->stash->{authorisation}{index_edit};
  
  # Recent events
  my $events_to_show = $c->config->{Index}{recent_updates_visible};
  $events_to_show = 5 if !defined($events_to_show) or $events_to_show !~ m/^\d+$/;
  
  my @events = $c->model("DB::SystemEventLog")->page_records({
    public_only => 1,
    page => 1,
    page_length => $events_to_show,
    order_col => "me.log_updated",
    order_dir => "desc",
  });
  
  # Today's matches (if there's a current season)
  my $current_season = $c->model("DB::Season")->get_current;
  my $online_users_last_active_limit = $c->datetime_tz({time_zone => "UTC"})->subtract(minutes => 15);
  my $online_user_count = $c->model("DB::Session")->get_online_users({datetime_limit => $online_users_last_active_limit})->count;
  
  my ( $matches, $matches_to_show, $matches_started, $next_match_date );
  
  if ( defined($current_season) ) {
    $matches = $c->model("DB::TeamMatch")->matches_on_date({
      season => $current_season,
      date => $c->datetime,
    });
    
    $matches_started = $matches->matches_started->count;
    $matches_to_show = $matches->count;
    
    if ( !$matches_to_show ) {
      # No matches today, find the next match date
      $next_match_date = $c->model("DB::TeamMatch")->next_match_date;
      $matches = $c->model("DB::TeamMatch")->matches_on_date({
        season => $current_season,
        date => $next_match_date,
      });
      
      $matches_to_show = $matches->count;
    }
  } else {
    $matches_started = 0;
    $matches_to_show = 0;
  }
  
  my $news_articles_to_show = $c->config->{Index}{news_articles_visible};
  $news_articles_to_show = 10 if !defined( $news_articles_to_show ) or $news_articles_to_show !~ m/^\d+$/;
  
  my $articles = $c->model("DB::NewsArticle")->page_records({
    page_number => 1,
    results_per_page => $news_articles_to_show,
  });
  
  # A 0 online user count is nonsensical to the user, as they are on the website, so there must be at least one; this can happen, however, if this is the first page view for them
  # and no one else is viewing the site, as the sessions are yet to initialise, so we'll fix this by just setting to 1 (if they go straight to the online users page, we can't help
  # them, as we need to display the data which we haven't got yet.
  $online_user_count = 1 if $online_user_count == 0;
  
  $c->stash({
    template => "html/index.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/qtip/jquery.qtip.min.js"),
      $c->uri_for("/static/script/standard/qtip.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/event-viewer/view-home.js", {v => 2}),
      $c->uri_for("/static/script/fixtures-results/view-group-divisions-no-date-no-score.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/qtip/jquery.qtip.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
    subtitle1 => $c->maketext("home-page.welcome"),
    title_links => \@title_links,
    no_subtitles_in_title => 1,
    view_online_display => "Home Page",
    view_online_link => 1,
    events => \@events,
    exclude_event_user => 1,
    matches => $matches,
    matches_to_show => $matches_to_show,
    matches_started => $matches_started,
    next_match_date => $next_match_date,
    articles => $articles,
    online_user_count => $online_user_count,
    index_text => $c->model("DB::PageText")->get_text("index"),
    hide_breadcrumbs => 1, # Hide the breadcrumbs
  });
}

sub index_edit :Path("index-edit") {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["index_edit", $c->maketext("user.auth.edit-index"), 1]);
  
  $c->stash({
    template => "html/page-text/edit.ttkt",
    scripts => [qw( ckeditor-iframely-standard )],
    ckeditor_selectors => [qw( page_text )],
    external_scripts => [
      $c->uri_for("/static/script/plugins/ckeditor5/ckeditor.js"),
      $c->uri_for("/static/script/page_text/edit.js"),
    ],
    subtitle1 => $c->maketext("menu.text.index"),
    edit_text => $c->model("DB::PageText")->get_text("index"),
    form_action => $c->uri_for_action("/do_index_edit"),
  });
}

=head2 do_index_edit

Process the privacy policy edit form.

=cut

sub do_index_edit :Path("do-index-edit") :Args(0) {
  my ( $self, $c ) = @_;
  my $page_text = $c->req->params->{page_text};
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["index_edit", $c->maketext("user.auth.edit-index"), 1]);
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $response = $c->model("DB::PageText")->edit({
    page_key => "index",
    page_text => $page_text,
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
    $redirect_uri = $c->uri_for("/", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["index", "edit"]);
  } else {
    # Flash the entered values we've got so we can set them into the form
    $redirect_uri = $c->uri_for_action("/index_edit", {mid => $mid});
    $c->flash->{show_flashed} = 1;
    $c->flash->{page_text} = $page_text;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 forbidden

403 forbidden error page.

=cut

sub forbidden :Path {
  my ( $self, $c ) = @_;
  
  # Set up the template to use
  $c->stash({
    template => "html/error/403.ttkt",
    view_online_display => "Home",
    view_online_link => 0,
    subtitle1 => $c->maketext("page.error.heading"),
    subtitle2 => $c->maketext("page.error.forbidden.heading"),
    hide_breadcrumbs => 1, # Hide the breadcrumbs
    no_menu => 1,
  });
  
  $c->response->status(403);
}

=head2 default

Standard 404 error page.

=cut

sub default :Path {
  my ( $self, $c ) = @_;
  
  # Set up the template to use
  $c->stash({
    template => "html/error/404.ttkt",
    view_online_display => "Home",
    view_online_link => 0,
    subtitle1 => $c->maketext("page.error.heading"),
    subtitle2 => $c->maketext("page.error.not-found.heading"),
    hide_breadcrumbs => 1, # Hide the breadcrumbs
  });
  
  $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end :ActionClass("RenderView") {
  my ( $self, $c ) = @_;
  $c->res->header("X-Robots-Tag" => "noindex") if exists($c->stash->{noindex}) and $c->stash->{noindex};
  
  if ( !$c->stash->{no_wrapper} and !$c->is_ajax ) {
    ## Nav drop down menus
    # Current season, clubs in current season, archived seasons
    my $current_season = $c->model("DB::Season")->get_current;
    my $clubs = [$c->model("DB::Club")->clubs_with_teams_in_season({
      season => $current_season,
      get_teams => $c->config->{Menu}{show_teams} || 0,
      get_players => $c->config->{Menu}{show_players} || 0,
    })] if defined($current_season);
    my $events = [$c->model("DB::Event")->events_in_season({
      season => $current_season,
    })] if defined($current_season);
    my $venues = [$c->model("DB::Venue")->active_venues];
    
    # Check admin authorisation for showing an admin menu
    $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( match_update user_approve_new admin_issue_bans template_view person_create person_view role_create role_edit role_delete )], "", 0]);
    
    my $nav_ban_types = $c->model("DB::LookupBanType")->all_types if $c->stash->{authorisation}{admin_issue_bans};
    
    # See if we need to stash the search script; first grab the external scripts
    my $scripts = $c->stash->{scripts} || [];
    my $external_scripts = $c->stash->{external_scripts} || [];
    my $external_styles = $c->stash->{external_styles} || [];
    
    if ( $c->config->{Search}{enable_search_bar} ) {
      # Add the site search autocomplete script, as this is only added here, so we don't need to check we've not already added it
      push(@{$scripts}, "site-search-autocomplete");
      
      unless ($c->stash->{search_scripts_added}) {
        # Add the search scripts and tyles if they're not already stashed (we don't want to include them twice)
        push(@{$external_scripts}, $c->uri_for("/static/script/plugins/uri/URI.js"));
        push(@{$external_scripts}, $c->uri_for("/static/script/plugins/autocomplete/jquery.easy-autocomplete.js"));
        
        push(@{$external_styles}, $c->uri_for("/static/css/autocomplete/easy-autocomplete.min.css"));
        push(@{$external_styles}, $c->uri_for("/static/css/autocomplete/easy-autocomplete.themes.min.css"));
        
        $c->stash({autocomplete_list => "json_search"});
      }
    }
    
    $c->stash({
      # Set the first part of the title and the wrapper
      title => encode_entities( $c->config->{name} ),
      wrapper => "html/wrappers/responsive.ttkt",
      
      # Nav elements
      nav_current_season => $current_season,
      archived_seasons => [$c->model("DB::Season")->get_archived],
      archived_seasons_count => $c->model("DB::Season")->get_archived->count,
      nav_clubs => $clubs,
      nav_venues => $venues,
      nav_events => $events,
      nav_ban_types => $nav_ban_types,
      
      # Stash the new external scripts (everything previously stashed should be preserved)
      scripts => $scripts,
      external_scripts => $external_scripts,
      external_styles => $external_styles,
    });
    
    # Check the authorisation for showing / creating clubs, events, seasons, venues, meetings, teams and people.
    $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( club_view club_create event_view event_create season_view season_create venue_view venue_create meeting_view meetingtype_view meetingtype_create team_create team_view fixtures_create contactreason_create )], "", 0]);
    
    # If we can view meeting types, get the meeting types to show
    if ( $c->stash->{authorisation}{meetingtype_view} ) {
      $c->stash({nav_meeting_types => [$c->model("DB::MeetingType")->all_meeting_types]});
    }
    
    if ( $c->stash->{authorisation}{fixtures_create} ) {
      $c->stash({nav_fixtures_grids => [$c->model("DB::FixturesGrid")->all_grids]});
    }
    
    if ( $c->stash->{authorisation}{contactreason_create} ) {
      $c->stash({nav_contact_reasons => [$c->model("DB::ContactReason")->all_reasons]});
    }
  }
  
  unless ( $c->stash->{no_wrapper} or $c->is_ajax ) {
    # Additional session / user functionality
    my $last_active_datetime = $c->datetime_tz({time_zone => "UTC"});
    my ( $session, $user, $hide_online );
    
    $session = $c->model("DB::Session")->find({id => sprintf( "session:%s", $c->sessionid )});
    
    # Set up the session update / create data
    # Check if we have a user
    if ( $c->user_exists ) {
      # User logged in, use the values from the user record
      $user = $c->user->id;
      $hide_online = $c->user->hide_online;
      
      # User last active stuff
      $c->user->update({last_active_date => sprintf("%s %s", $last_active_datetime->ymd, $last_active_datetime->hms) });
    } else {
      # Not logged in, user ID is null, view online is true
      $user = undef;
      $hide_online = 0;
    }
    
    my $session_data = {};
    my ( $invalid_logins, $invalid_login_date );
    if ( exists( $c->stash->{invalid_login_attempt} ) ) {
      $session_data->{invalid_logins}     = $session->invalid_logins + 1;
      $session_data->{last_invalid_login} = sprintf( "%s %s", $last_active_datetime->ymd, $last_active_datetime->hms );
    } elsif ( exists( $c->stash->{successful_login} ) ) {
      $session_data->{invalid_logins}     = 0;
      $session_data->{last_invalid_login} = undef;
    }
    
    if ( !exists( $c->stash->{skip_view_online} ) and exists( $c->stash->{view_online_display} ) and $c->req->path !~ /\.js$/ ) {
      # The title bar will always have
      # Set last active date to UTC
      $session_data->{user} = $user;
      $session_data->{ip_address} = $c->req->address;
      $session_data->{user_agent} = $c->stash->{user_agent}->id;
      $session_data->{locale} = $c->locale;
      $session_data->{path} = $c->req->path;
      $session_data->{view_online_display} = $c->stash->{view_online_display};
      $session_data->{view_online_link} = $c->stash->{view_online_link};
      $session_data->{hide_online} = $hide_online;
      $session_data->{secure} = $c->req->secure;
      $session_data->{query_string} = $c->req->uri->query;
      $session_data->{client_hostname} = $c->req->hostname;
      $session_data->{referrer} = $c->req->referer;
    }
    
    $session_data->{last_active} = sprintf("%s %s", $last_active_datetime->ymd, $last_active_datetime->hms);
    
    # Check a session exists
    if ( defined($session) ) {
      # If it does update it
      $session->update($session_data);
    } elsif ( $c->sessionid ) {
      # If not, create it - we need the session ID to be added to the hash for this
      $session_data->{id} = "session:" . $c->sessionid;
      $c->model("DB::Session")->create($session_data);
    }
    
    # Add IE rendering header
    $c->res->header("X-UA-Compatible", "IE=edge,chrome=1");
    
    # Add X-Frame-Options header to avoid clickjacking - https://www.owasp.org/index.php/Clickjacking_Defense_Cheat_Sheet
    $c->res->header("X-Frame-Options", "SAMEORIGIN");
    
    # Filter meta description for HTML
    $c->stash({meta_description => $c->model("FilterHTML")->filter($c->stash->{page_description})}) if exists($c->stash->{page_description}) and defined($c->stash->{page_description});
    
    # Error handling
    if ( scalar @{$c->error} ) {
      # Errors, make sure we print a prettier page

      # Set up the template to use
      $c->stash({
        template => "html/error/500.ttkt",
        external_scripts => [
          $c->uri_for("/static/script/standard/vertical-table.js"),
        ],
        view_online_display => "Home",
        view_online_link => 0,
        subtitle1 => $c->maketext("page.error.heading"),
        subtitle2 => $c->maketext("page.error.internal.heading"),
        hide_breadcrumbs => 1, # Hide the breadcrumbs
        errors => $c->error,
      });
      
      # Log the errors, then clear them
      $c->log->error($_) foreach @{$c->error};
      $c->clear_errors;
    }
    
    # Join our title and subtitled elements
    my $page_title;
    if ( $c->stash->{no_subtitles_in_title} ) {
      # Some pages (i.e., the index page) we may only want the site title to show in the title bar
      $page_title = encode_entities($c->config->{name});
    } else {
      # Define an array for page title bits and push on the various subtitles we have if we have them
      my @page_title_bits = ();
      push(@page_title_bits, $c->stash->{subtitle1} ) if $c->stash->{subtitle1};
      push(@page_title_bits, $c->stash->{subtitle2} ) if $c->stash->{subtitle2};
      push(@page_title_bits, $c->stash->{subtitle3} ) if $c->stash->{subtitle3};
      
      push(@page_title_bits, encode_entities($c->config->{name}));
      
      # Now join them up for the title bar text
      $page_title = join(" &#8226; ", @page_title_bits);
    }
    
    # Stash it for use in the web page title bar
    $c->stash({page_title => $page_title});
  }
}

=head2 recaptcha

Sends the CAPTCHA response to Google and verifies the success.

=cut

sub recaptcha :Private {
  my ( $self, $c ) = @_;
  my ( $error );
  
  # First verify that we're dealing with a human if we need to
  my $recaptcha_data = $c->req->params->{"g-recaptcha-response"} || "";
  my $secret_key = $c->config->{Google}{reCAPTCHA}{secret_key};
  
  # Create the user agent
  my $ua = LWP::UserAgent->new;
  $ua->agent("TopTable/" . $c->toptable_version);
  
  # Create the request object
  my $request = HTTP::Request->new(POST => $c->config->{Google}{reCAPTCHA}{verify_uri});
  $request->content_type("application/x-www-form-urlencoded");
  #$request->content("secret=$secret_key&response=$recaptcha_data&remoteip=" . $c->req->address);
  $request->content("secret=$secret_key&response=$recaptcha_data");
  
  my $response = $ua->request($request);
  my $response_content = decode_json($response->content);
  
  return {
    request_success => $response->is_success,
    response_content => $response_content,
  };
}

=head2 generate_pagination_links

Handles pagination given parameters of a number of items, number of items per page.  This works with pagination via an action for, e.g., /page/2.  Use generate_pagination_links_qs if using query strings

=cut

sub generate_pagination_links :Private {
  my ( $self, $c, $parameters ) = @_;
  my $page_info = $parameters->{page_info};
  my $current_page = $parameters->{current_page}; # Page attempted by the user
  my $page1_action = $parameters->{page1_action};
  my $page1_action_arguments = $parameters->{page1_action_arguments};
  my $specific_page_action = $parameters->{specific_page_action};
  my $specific_page_action_arguments = $parameters->{specific_page_action_arguments};
  
  # Make our arguments arrayrefs if they're not already
  $page1_action_arguments = [] unless defined( $page1_action_arguments );
  $specific_page_action_arguments = [] unless defined( $specific_page_action_arguments );
  $page1_action_arguments = [ $page1_action_arguments ] if ref( $page1_action_arguments ) ne "ARRAY";
  $specific_page_action_arguments = [ $specific_page_action_arguments ] if ref( $specific_page_action_arguments ) ne "ARRAY";
  
  if ( ( $current_page > 1 and $page_info->last_page < $current_page ) or !defined( $current_page ) or !$current_page or $current_page !~ /^\d+$/ or $current_page < 1 ) {
    # Trying to access a page past the end or an invalid page number
    if ( $page1_action ) {
      if ( $page1_action_arguments ) {
        # Add arguments
        $c->response->redirect( $c->uri_for_action($page1_action, $page1_action_arguments,
                                    {mid => $c->set_status_msg( {warning => $c->maketext("pagination.page-invalid-redirect", $current_page)} ) }) );
      } else {
        # No arguments
        $c->response->redirect( $c->uri_for_action($page1_action,
                          {mid => $c->set_status_msg( {warning => $c->maketext("pagination.page-invalid-redirect", $current_page)} ) }) );
      }
      
      $c->detach;
      return;
    } else {
      $c->add_status_messages({error => $c->maketext("pagination.page-invalid-no-redirect", $current_page)});
    }
  }
  
  # Build the pagination
  my @page_links;
  if ( $page_info->last_page > 5 ) {
    # More than five pages, we'll display a subset
    
    # Work out the start and end page
    my $first_listed_page = min(max(1, $page_info->current_page - 4), $page_info->last_page - 5);
    my $last_listed_page  = max(min($page_info->last_page, $page_info->current_page + 4), 6);
    
    push(@page_links, $_) foreach ( $first_listed_page .. $last_listed_page - 1 );
    
    # If the first page number isn't one, we need to make sure it is now; similarly, if the last item is not the last page, we need to add it
    unshift(@page_links, 1) unless $page_links[0] == 1;
    push(@page_links, $page_info->last_page) unless $page_links[-1] == $page_info->last_page;
  } else {
    # All page numbers will go into the array if we have five or less
    @page_links = ( 1 .. $page_info->last_page );
  }
  
  # Now map the page numbers to their corresponding actions
  @page_links = map{
    # Set up the default action
    my $action = ( $_ == 1 ) ? $page1_action : $specific_page_action;
    my @arguments = ();
    
    # Check the page number to build our arguments
    if ( $_ == 1 ) {
      # Page 1, just add the page 1 action arguments that were passed in
      @arguments = @{ $page1_action_arguments };
    } else {
      # Specific page, add in our action arguments, then push the page number on to the end
      @arguments = @{ $specific_page_action_arguments };
      push(@arguments, $_);
    }
    
    # Return a hashref
    {
      number => $_,
      action => $action,
      arguments => \@arguments,
    };
  } @page_links;
  
  return \@page_links;
}

=head2 generate_pagination_links_qs

Handles pagination given parameters of a number of items, number of items per page.  This works with pagination via a query string, e.g., ?page=2.  Use generate_pagination_links if using an action.

=cut

sub generate_pagination_links_qs :Private {
  my ( $self, $c, $params ) = @_;
  my $page_info = $params->{page_info};
  my $page = $params->{page}; # Page attempted by the user
  my $action = $params->{action};
  my $page1_arguments = $params->{page1_arguments};
  my $specific_page_arguments = $params->{specific_page_arguments};
  my $action_params = $params->{params};
  
  # Make our arguments arrayrefs if they're not already
  $page1_arguments = [] unless defined($page1_arguments);
  $specific_page_arguments = [] unless defined($specific_page_arguments);
  $page1_arguments = [$page1_arguments] if ref( $page1_arguments) ne "ARRAY";
  $specific_page_arguments = [$specific_page_arguments] if ref($specific_page_arguments) ne "ARRAY";
  
  if ( ( $page > 1 and $page_info->last_page < $page ) or !defined($page) or !$page or $page !~ /^\d+$/ or $page < 1 ) {
    # Trying to access a page past the end or an invalid page number
    if ( $action ) {
      if ( $page1_arguments ) {
        # Add arguments
        $action_params->{mid} = $c->set_status_msg({warning => $c->maketext("pagination.page-invalid-redirect", $page)});
        $c->response->redirect($c->uri_for_action($action, $page1_arguments, $action_params));
      } else {
        # No arguments
        $action_params->{mid} = $c->set_status_msg({warning => $c->maketext("pagination.page-invalid-redirect", $page)});
        $c->response->redirect($c->uri_for_action($action, undef, $action_params));
      }
      
      $c->detach;
      return;
    } else {
      $c->add_status_messages({error => $c->maketext("pagination.page-invalid-no-redirect", $page)});
    }
  }
  
  # Build the pagination
  my @page_links;
  if ( $page_info->last_page > 5 ) {
    # More than five pages, we'll display a subset
    
    # Work out the start and end page
    my $first_listed_page = min(max(1, $page_info->current_page - 4), $page_info->last_page - 5);
    my $last_listed_page  = max(min($page_info->last_page, $page_info->current_page + 4), 6);
    
    push(@page_links, $_) foreach ( $first_listed_page .. $last_listed_page - 1 );
    
    # If the first page number isn't one, we need to make sure it is now; similarly, if the last item is not the last page, we need to add it
    unshift(@page_links, 1) unless $page_links[0] == 1;
    push(@page_links, $page_info->last_page) unless $page_links[-1] == $page_info->last_page;
  } else {
    # All page numbers will go into the array if we have five or less
    @page_links = ( 1 .. $page_info->last_page );
  }
  
  # Now map the page numbers to their corresponding actions
  @page_links = map{
    # Set up the default action
    my @arguments = ();
    
    # Check the page number to build our arguments
    if ( $_ == 1 ) {
      # Page 1, just add the page 1 action arguments that were passed in
      @arguments = @{$page1_arguments};
    } else {
      # Specific page, add in our action arguments, then push the page number on to the end
      @arguments = @{$specific_page_arguments};
    }
    
    # Make sure we have a key for each page so the page number doesn't get trashed
    my %page_params = %{$action_params};
    $page_params{page} = $_;
    $page_params{results} = $page_info->entries_per_page unless $page_info->entries_per_page == $c->config->{Pagination}{default_page_size};
    
    # Return a hashref
    {
      number => $_,
      action => $action,
      arguments => \@arguments,
      params => \%page_params,
    };
  } @page_links;
  
  return \@page_links;
}

=head2 get_day_in_same_week

Takes as arguments:
 - The date
 - The target day (1 is Monday, 7 Sunday)
 - The day that we want to call the start of the week (1 is Monday, 7 Sunday) (optional)
NOTE: This may end up in a different month...
Taken from:
http://datetime.perl.org/wiki/datetime/page/FAQ%3A_Sample_Calculations#How_do_I_calculate_the_date_of_the_Wednesday_of_the_same_week_as_the_current_date_-5

=cut

sub get_day_in_same_week {
  #my ( $self, $c ) = @_;
  #my ( $dt, $target, $start_of_week )  = @{ $c->request->arguments };
  my ( $dt, $target, $start_of_week )  = @_;
  $start_of_week = 1 if !$start_of_week;

  # Work out what day the date is within the (corrected) week
  my $wday = ( $dt->day_of_week - $start_of_week + 7 ) % 7;

  # Correct the argument day to our week
  $target = ( $target - $start_of_week + 7 ) % 7;

  # Then adjust the current day
  return $dt->clone->add(days => $target - $wday);
}

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;