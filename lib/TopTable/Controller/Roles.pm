package TopTable::Controller::Roles;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Roles - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.roles")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/roles"),
    label => $c->maketext("menu.text.roles"),
  });
}

=head2 base

Chain base for getting the role ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("roles") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $role = $c->model("DB::Role")->find_id_or_url_key( $id_or_key );
  
  if ( defined( $role ) ) {
    # System roles are in the language pack; otherwise we HTML encode it.
    my $encoded_name = ( $role->system ) ? $c->maketext( sprintf( "roles.name.%s", $role->name ) ) : encode_entities( $role->name );
    
    $c->stash({
      role          => $role,
      encoded_name  => $encoded_name,
      subtitle1     => $encoded_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/roles/view", [$role->url_key]),
      label => $encoded_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of roles.

=cut

sub base_list :Chained("/") :PathPart("roles") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_view", $c->maketext("user.auth.view-roles"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( role_create role_edit role_delete ) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.roles.list", $site_name)},
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  );
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the roles on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/roles/list_first_page")});
  $c->detach( "retrieve_paged", [1] );
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/roles/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/roles/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for meeting types with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $roles = $c->model("DB::Role")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $roles->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/roles/list_first_page",
    specific_page_action  => "/roles/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/roles/list.ttkt",
    view_online_display => "Viewing roles",
    view_online_link    => 0,
    roles               => $roles,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

View the role (i.e., name, permissions and  members).

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  my $site_name = $c->stash->{encoded_site_name};
  my $role_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to view
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_view", $c->maketext("user.auth.view-roles"), 1] );
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ qw( role_edit role_delete ) ], "", 0] );
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $role_name),
      link_uri  => $c->uri_for_action("/roles/edit", [$role->url_key]),
    }) if $c->stash->{authorisation}{role_edit};
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $role_name),
      link_uri  => $c->uri_for_action("/roles/delete", [$role->url_key]),
    }) if $c->stash->{authorisation}{role_delete};
  }
  
  # Set up the template to use
  $c->stash({
    template            => "html/roles/view.ttkt",
    title_links         => \@title_links,
    view_online_display => sprintf( "Viewing role: %s", $role_name ),
    view_online_link    => 0,
    page_description    => $c->maketext("description.roles.view", $role_name, $site_name),
  });
}

=head2 create

Display a form to collect information for creating a role.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_create", $c->maketext("user.auth.create-roles"), 1] );
  
  my $member_tokeninput_options = {
    jsonContainer => "json_users",
    hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  if ( exists( $c->flash->{members} ) and ref( $c->flash->{members} ) eq "ARRAY" ) {
    foreach my $person ( @{ $c->flash->{members} } ) {
      push(@{ $member_tokeninput_options->{prePopulate} }, {
        id    => $person->id,
        name  => encode_entities( $person->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script    => $c->uri_for("/users/search"),
    options   => encode_json( $member_tokeninput_options ),
    selector  => "members",
  }];
  
  # Stash information for the template
  $c->stash({
    template            => "html/roles/create-edit.ttkt",
    tokeninput_confs    => $tokeninput_confs,
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles     => [
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    view_online_display => "Creating roles",
    view_online_link    => 0,
  });
  
  # Stash flashed values if we have any
  $c->stash({
    # Average filters
    average_filter_create_public  => $c->flash->{average_filter_create_public},
    average_filter_edit_public    => $c->flash->{average_filter_edit_public},
    average_filter_delete_public  => $c->flash->{average_filter_delete_public},
    average_filter_view_all       => $c->flash->{average_filter_view_all},
    average_filter_edit_all       => $c->flash->{average_filter_edit_all},
    average_filter_delete_all     => $c->flash->{average_filter_delete_all},
    
    # Clubs
    club_view   => $c->flash->{club_view},
    club_create => $c->flash->{club_create},
    club_edit   => $c->flash->{club_edit},
    club_delete => $c->flash->{club_delete},
    
    # Committee
    committee_view    => $c->flash->{committee_view},
    committee_create  => $c->flash->{committee_create},
    committee_edit    => $c->flash->{committee_edit},
    committee_delete  => $c->flash->{committee_delete},
    
    # Contact reasons
    contact_reason_view   => $c->flash->{contact_reason_view},
    contact_reason_create => $c->flash->{contact_reason_create},
    contact_reason_edit   => $c->flash->{contact_reason_edit},
    contact_reason_delete => $c->flash->{contact_reason_delete},
    
    # Events
    event_view    => $c->flash->{event_view},
    event_create  => $c->flash->{event_create},
    event_edit    => $c->flash->{event_edit},
    event_delete  => $c->flash->{event_delete},
    
    # Fixtures
    fixtures_view   => $c->flash->{fixtures_view},
    fixtures_create => $c->flash->{fixtures_create},
    fixtures_edit   => $c->flash->{fixtures_edit},
    fixtures_delete => $c->flash->{fixtures_delete},
    
    # Matches
    match_view    => $c->flash->{match_view},
    match_update  => $c->flash->{match_update},
    match_cancel  => $c->flash->{match_cancel},
    
    # Match reports
    match_report_create             => $c->flash->{match_report_create},
    match_report_create_associated  => $c->flash->{match_report_create_associated},
    match_report_edit_own           => $c->flash->{match_report_edit_own},
    match_report_edit_all           => $c->flash->{match_report_edit_all},
    match_report_delete_own         => $c->flash->{match_report_delete_own},
    match_report_delete_all         => $c->flash->{match_report_delete_all},
    
    # Meetings
    meeting_view    => $c->flash->{meeting_view},
    meeting_create  => $c->flash->{meeting_create},
    meeting_edit    => $c->flash->{meeting_edit},
    meeting_delete  => $c->flash->{meeting_delete},
    
    # Meeting types
    meeting_type_view   => $c->flash->{meeting_type_view},
    meeting_type_create => $c->flash->{meeting_type_create},
    meeting_type_edit   => $c->flash->{meeting_type_edit},
    meeting_type_delete => $c->flash->{meeting_type_delete},
    
    # News
    news_article_view       => $c->flash->{news_article_view},
    news_article_create     => $c->flash->{news_article_create},
    news_article_edit_own   => $c->flash->{news_article_edit_own},
    news_article_edit_all   => $c->flash->{news_article_edit_all},
    news_article_delete_own => $c->flash->{news_article_delete_own},
    news_article_delete_all => $c->flash->{news_article_delete_all},
    
    # Online users
    online_users_view           => $c->flash->{online_users_view},
    anonymous_online_users_view => $c->flash->{anonymous_online_users_view},
    view_users_ip               => $c->flash->{view_users_ip},
    view_users_user_agent       => $c->flash->{view_users_user_agent},
    
    # People
    person_view         => $c->flash->{person_view},
    person_contact_view => $c->flash->{person_contact_view},
    person_create       => $c->flash->{person_create},
    person_edit         => $c->flash->{person_edit},
    person_delete       => $c->flash->{person_delete},
    
    # Roles
    role_view   => $c->flash->{role_view},
    role_create => $c->flash->{role_create},
    role_edit   => $c->flash->{role_edit},
    role_delete => $c->flash->{role_delete},
    
    # Seasons
    season_view     => $c->flash->{season_view},
    season_create   => $c->flash->{season_create},
    season_edit     => $c->flash->{season_edit},
    season_delete   => $c->flash->{season_delete},
    season_archive  => $c->flash->{season_archive},
    
    # Sessions
    session_delete  => $c->flash->{session_delete},
    
    # Event log
    system_event_log_view_all => $c->flash->{system_event_log_view_all},
    
    # Teams
    team_view   => $c->flash->{team_view},
    team_create => $c->flash->{team_create},
    team_edit   => $c->flash->{team_edit},
    team_delete => $c->flash->{team_delete},
    
    # Templates
    template_view   => $c->flash->{template_view},
    template_create => $c->flash->{template_create},
    template_edit   => $c->flash->{template_edit},
    template_delete => $c->flash->{template_delete},
    
    # Tournaments
    tournament_view   => $c->flash->{tournament_view},
    tournament_create => $c->flash->{tournament_create},
    tournament_edit   => $c->flash->{tournament_edit},
    tournament_delete => $c->flash->{tournament_delete},
    
    # Users
    user_view       => $c->flash->{user_view},
    user_edit_all   => $c->flash->{user_edit_all},
    user_edit_own   => $c->flash->{user_edit_own},
    user_delete_all => $c->flash->{user_delete_all},
    user_delete_own => $c->flash->{user_delete_own},
    
    # Venues
    venue_view   => $c->flash->{venue_view},
    venue_create => $c->flash->{venue_create},
    venue_edit   => $c->flash->{venue_edit},
    venue_delete => $c->flash->{venue_delete},
  }) if $c->flash->{form_errored};
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/roles/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form with the existing information for editing an individual match template

=cut

sub edit :Chained("base") :PathPart("edit") :Args(0) {
  my ($self, $c) = @_;
  my $role = $c->stash->{role};
  
  # Don't cache this page.
  $c->response->header("Cache-Control"  => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma"         => "no-cache");
  $c->response->header("Expires"        => 0);
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_edit", $c->maketext("user.auth.edit-roles"), 1] );
  
  my $member_tokeninput_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  my $members = ( defined( $c->flash->{members} ) and ref( $c->flash->{members} ) eq "ARRAY" ) ? $c->flash->{members} : [ $role->members ];
  
  if ( defined( $members ) and ref( $members ) eq "ARRAY" ) {
    foreach my $member ( @$members ) {
      # If this is flashed it will be the person directly referenced; if we've retrieved from the database it'll be the member user,
      # from which we need to get the person.
      my $person = ( ref( $member ) eq "TopTable::DB::Model::User" ) ? $member : $member->user;
      
      push(@{ $member_tokeninput_options->{prePopulate} }, {
        id    => $person->id,
        name  => encode_entities( $person->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $member_tokeninput_options ),
    selector  => "recipients",
  }];
  
  # Stash information for the template
  $c->stash({
    template            => "html/roles/create-edit.ttkt",
    tokeninput_confs    => $tokeninput_confs,
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
    ],
    external_styles     => [
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    form_action         => $c->uri_for_action("/roles/do_edit", [$role->url_key]),
    subtitle2           => $c->maketext("admin.edit"),
    view_online_display => "Editing roles",
    view_online_link    => 0,
  });
  
  # Stash permission fields based on whether it's an errored form or not
  if ( $c->flash->{form_errored} ) {
    $c->stash({
      # Average filters
      average_filter_create_public  => $c->flash->{average_filter_create_public},
      average_filter_edit_public    => $c->flash->{average_filter_edit_public},
      average_filter_delete_public  => $c->flash->{average_filter_delete_public},
      average_filter_view_all       => $c->flash->{average_filter_view_all},
      average_filter_edit_all       => $c->flash->{average_filter_edit_all},
      average_filter_delete_all     => $c->flash->{average_filter_delete_all},
      
      # Clubs
      club_view   => $c->flash->{club_view},
      club_create => $c->flash->{club_create},
      club_edit   => $c->flash->{club_edit},
      club_delete => $c->flash->{club_delete},
      
      # Committee
      committee_view    => $c->flash->{committee_view},
      committee_create  => $c->flash->{committee_create},
      committee_edit    => $c->flash->{committee_edit},
      committee_delete  => $c->flash->{committee_delete},
      
      # Contact reasons
      contact_reason_view   => $c->flash->{contact_reason_view},
      contact_reason_create => $c->flash->{contact_reason_create},
      contact_reason_edit   => $c->flash->{contact_reason_edit},
      contact_reason_delete => $c->flash->{contact_reason_delete},
      
      # Events
      event_view    => $c->flash->{event_view},
      event_create  => $c->flash->{event_create},
      event_edit    => $c->flash->{event_edit},
      event_delete  => $c->flash->{event_delete},
      
      # Fixtures
      fixtures_view   => $c->flash->{fixtures_view},
      fixtures_create => $c->flash->{fixtures_create},
      fixtures_edit   => $c->flash->{fixtures_edit},
      fixtures_delete => $c->flash->{fixtures_delete},
      
      # Matches
      match_view    => $c->flash->{match_view},
      match_update  => $c->flash->{match_update},
      match_cancel  => $c->flash->{match_cancel},
      
      # Match reports
      match_report_create             => $c->flash->{match_report_create},
      match_report_create_associated  => $c->flash->{match_report_create_associated},
      match_report_edit_own           => $c->flash->{match_report_edit_own},
      match_report_edit_all           => $c->flash->{match_report_edit_all},
      match_report_delete_own         => $c->flash->{match_report_delete_own},
      match_report_delete_all         => $c->flash->{match_report_delete_all},
      
      # Meetings
      meeting_view    => $c->flash->{meeting_view},
      meeting_create  => $c->flash->{meeting_create},
      meeting_edit    => $c->flash->{meeting_edit},
      meeting_delete  => $c->flash->{meeting_delete},
      
      # Meeting types
      meeting_type_view   => $c->flash->{meeting_type_view},
      meeting_type_create => $c->flash->{meeting_type_create},
      meeting_type_edit   => $c->flash->{meeting_type_edit},
      meeting_type_delete => $c->flash->{meeting_type_delete},
      
      # News
      news_article_view       => $c->flash->{news_article_view},
      news_article_create     => $c->flash->{news_article_create},
      news_article_edit_own   => $c->flash->{news_article_edit_own},
      news_article_edit_all   => $c->flash->{news_article_edit_all},
      news_article_delete_own => $c->flash->{news_article_delete_own},
      news_article_delete_all => $c->flash->{news_article_delete_all},
      
      # Online users
      online_users_view           => $c->flash->{online_users_view},
      anonymous_online_users_view => $c->flash->{anonymous_online_users_view},
      view_users_ip               => $c->flash->{view_users_ip},
      view_users_user_agent       => $c->flash->{view_users_user_agent},
      
      # People
      person_view         => $c->flash->{person_view},
      person_contact_view => $c->flash->{person_contact_view},
      person_create       => $c->flash->{person_create},
      person_edit         => $c->flash->{person_edit},
      person_delete       => $c->flash->{person_delete},
      
      # Roles
      role_view   => $c->flash->{role_view},
      role_create => $c->flash->{role_create},
      role_edit   => $c->flash->{role_edit},
      role_delete => $c->flash->{role_delete},
      
      # Seasons
      season_view     => $c->flash->{season_view},
      season_create   => $c->flash->{season_create},
      season_edit     => $c->flash->{season_edit},
      season_delete   => $c->flash->{season_delete},
      season_archive  => $c->flash->{season_archive},
      
      # Sessions
      session_delete  => $c->flash->{session_delete},
      
      # Event log
      system_event_log_view_all => $c->flash->{system_event_log_view_all},
      
      # Teams
      team_view   => $c->flash->{team_view},
      team_create => $c->flash->{team_create},
      team_edit   => $c->flash->{team_edit},
      team_delete => $c->flash->{team_delete},
      
      # Templates
      template_view   => $c->flash->{template_view},
      template_create => $c->flash->{template_create},
      template_edit   => $c->flash->{template_edit},
      template_delete => $c->flash->{template_delete},
      
      # Tournaments
      tournament_view   => $c->flash->{tournament_view},
      tournament_create => $c->flash->{tournament_create},
      tournament_edit   => $c->flash->{tournament_edit},
      tournament_delete => $c->flash->{tournament_delete},
      
      # Users
      user_view       => $c->flash->{user_view},
      user_edit_all   => $c->flash->{user_edit_all},
      user_edit_own   => $c->flash->{user_edit_own},
      user_delete_all => $c->flash->{user_delete_all},
      user_delete_own => $c->flash->{user_delete_own},
      
      # Venues
      venue_view   => $c->flash->{venue_view},
      venue_create => $c->flash->{venue_create},
      venue_edit   => $c->flash->{venue_edit},
      venue_delete => $c->flash->{venue_delete},
    });
  } else {
    # Not errored, use the DB value
    $c->stash({
      # Average filters
      average_filter_create_public  => $role->average_filter_create_public,
      average_filter_edit_public    => $role->average_filter_edit_public,
      average_filter_delete_public  => $role->average_filter_delete_public,
      average_filter_view_all       => $role->average_filter_view_all,
      average_filter_edit_all       => $role->average_filter_edit_all,
      average_filter_delete_all     => $role->average_filter_delete_all,
      
      # Clubs
      club_view   => $role->club_view,
      club_create => $role->club_create,
      club_edit   => $role->club_edit,
      club_delete => $role->club_delete,
      
      # Committee
      committee_view    => $role->committee_view,
      committee_create  => $role->committee_create,
      committee_edit    => $role->committee_edit,
      committee_delete  => $role->committee_delete,
      
      # Contact reasons
      contact_reason_view   => $role->contact_reason_view,
      contact_reason_create => $role->contact_reason_create,
      contact_reason_edit   => $role->contact_reason_edit,
      contact_reason_delete => $role->contact_reason_delete,
      
      # Events
      event_view    => $role->event_view,
      event_create  => $role->event_create,
      event_edit    => $role->event_edit,
      event_delete  => $role->event_delete,
      
      # Fixtures
      fixtures_view   => $role->fixtures_view,
      fixtures_create => $role->fixtures_create,
      fixtures_edit   => $role->fixtures_edit,
      fixtures_delete => $role->fixtures_delete,
      
      # Matches
      match_view    => $role->match_view,
      match_update  => $role->match_update,
      match_cancel  => $role->match_cancel,
      
      # Match reports
      match_report_create             => $role->match_report_create,
      match_report_create_associated  => $role->match_report_create_associated,
      match_report_edit_own           => $role->match_report_edit_own,
      match_report_edit_all           => $role->match_report_edit_all,
      match_report_delete_own         => $role->match_report_delete_own,
      match_report_delete_all         => $role->match_report_delete_all,
      
      # Meetings
      meeting_view    => $role->meeting_view,
      meeting_create  => $role->meeting_create,
      meeting_edit    => $role->meeting_edit,
      meeting_delete  => $role->meeting_delete,
      
      # Meeting types
      meeting_type_view   => $role->meeting_type_view,
      meeting_type_create => $role->meeting_type_create,
      meeting_type_edit   => $role->meeting_type_edit,
      meeting_type_delete => $role->meeting_type_delete,
      
      # News
      news_article_view       => $role->news_article_view,
      news_article_create     => $role->news_article_create,
      news_article_edit_own   => $role->news_article_edit_own,
      news_article_edit_all   => $role->news_article_edit_all,
      news_article_delete_own => $role->news_article_delete_own,
      news_article_delete_all => $role->news_article_delete_all,
      
      # Online users
      online_users_view           => $role->online_users_view,
      anonymous_online_users_view => $role->anonymous_online_users_view,
      view_users_ip               => $role->view_users_ip,
      view_users_user_agent       => $role->view_users_user_agent,
      
      # People
      person_view         => $role->person_view,
      person_contact_view => $role->person_contact_view,
      person_create       => $role->person_create,
      person_edit         => $role->person_edit,
      person_delete       => $role->person_delete,
      
      # Roles
      role_view   => $role->role_view,
      role_create => $role->role_create,
      role_edit   => $role->role_edit,
      role_delete => $role->role_delete,
      
      # Seasons
      season_view     => $role->season_view,
      season_create   => $role->season_create,
      season_edit     => $role->season_edit,
      season_delete   => $role->season_delete,
      season_archive  => $role->season_archive,
      
      # Sessions
      session_delete  => $role->session_delete,
      
      # Event log
      system_event_log_view_all => $role->system_event_log_view_all,
      
      # Teams
      team_view   => $role->team_view,
      team_create => $role->team_create,
      team_edit   => $role->team_edit,
      team_delete => $role->team_delete,
      
      # Templates
      template_view   => $role->template_view,
      template_create => $role->template_create,
      template_edit   => $role->template_edit,
      template_delete => $role->template_delete,
      
      # Tournaments
      tournament_view   => $role->tournament_view,
      tournament_create => $role->tournament_create,
      tournament_edit   => $role->tournament_edit,
      tournament_delete => $role->tournament_delete,
      
      # Users
      user_view       => $role->user_view,
      user_edit_all   => $role->user_edit_all,
      user_edit_own   => $role->user_edit_own,
      user_delete_all => $role->user_delete_all,
      user_delete_own => $role->user_delete_own,
      
      # Venues
      venue_view   => $role->venue_view,
      venue_create => $role->venue_create,
      venue_edit   => $role->venue_edit,
      venue_delete => $role->venue_delete,
    });
  }
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/roles/edit", [$role->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete

Display the form to delete a template.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_delete", $c->maketext("user.auth.delete-roles"), 1] );
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/roles/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", encode_entities( $role->name ) ),
    view_online_link    => 0,
  });
  
  # Breadcrumbs
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/roles/delete", [$role->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a role.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create roles
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_create", $c->maketext("user.auth.create-roles"), 1] );
  
  $c->detach( "setup_role", ["create"] );
}

=head2 do_edit

Process the form for editing a role.

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ($self, $c, $template_id) = @_;
  my $role = $c->stash->{role};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_edit", $c->maketext("user.auth.edit-roles"), 1] );
  $c->detach( "setup_role", ["edit"] );
}

=head2 do_delete

Processes the deletion of the role.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $role = $c->stash->{role};
  my $encoded_name = $c->stash->{encoded_name};
  
  # Check that we are authorised to delete venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["role_delete", $c->maketext("user.auth.delete-roles"), 1] );
  
  # We need to store the name so we can insert it into the event log database after the item has been deleted
  my $role_name = $role->name;
  
  # Hand off to the model to do some checking
  #my $deletion_result = $c->model("DB::Venue")->check_and_delete( $venue );
  my $error = $role->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting, go back to deletion page
    $c->response->redirect( $c->uri_for_action("/roles/view", [$role->url_key],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success, log a deletion and return to the venue list
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["role", "delete", {id => undef}, $role->name] );
    $c->response->redirect( $c->uri_for("/roles",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_reason

Forwarded from docreate and doedit to do the reason creation / edit.

=cut

sub setup_role :Private {
  my ( $self, $c, $action ) = @_;
  my $role = $c->stash->{role};
  
  # Set up the permissions fields
  my @permissions_fields = $c->model("DB::Role")->result_source->columns;
  
  # The error checking and creation is done in the TemplateLeagueTableRanking model
  my $details = $c->model("DB::Role")->create_or_edit($action, {
    role    => $role,
    members => delete $c->request->parameters->{members},
    name    => delete $c->request->parameters->{name},
    fields  => $c->request->parameters, # Contains all permissions fields
  }, $c);
  
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{name}     = $c->request->parameters->{name};
    #$c->flash->{members}  = \@recipients;
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/roles/create",
                          {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      $redirect_uri = $c->uri_for_action("/roles/edit", [ $role->url_key ],
                          {mid => $c->set_status_msg( {error => $error} ) });
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $role = $details->{role};
    my $action_description = ( $action eq "create" ) ? $c->maketext("admin.message.created") : $c->maketext("admin.message.edited");
    my $encoded_name = ( $role->system ) ? $c->maketext( sprintf( "roles.name.%s", $role->name ) ) : encode_entities( $role->name );
    
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["role", $action, {id => $role->id}, $role->name] );
    $c->response->redirect( $c->uri_for_action("/roles/view", [$role->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_name, $action_description )}  ) }) );
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
