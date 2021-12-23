package TopTable::Controller::Meetings;
use Moose;
use namespace::autoclean;
use Try::Tiny;
use DateTime;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Meetings - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to handle meetings; these methods are NOT private, though can be forwarded from the Events controller; meetings can belong to an event (a public meeting that happens once a year, such as an AGM), or can be standalone (such as a committee meeting, which can happen multiple times in a season; in which case these methods are accessible directly via a URI).

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.meetings")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/meetings"),
    label => $c->maketext("menu.text.meetings"),
  });
}

=head2 base_by_type_and_date

Chain base for getting the meeting type and date and checking it.

=cut

sub base_by_type_and_date :Chained("/") :PathPart("meetings") :CaptureArgs(4) {
  my ( $self, $c, $type_id_or_key, $year, $month, $day ) = @_;
  my $meeting_date;
  
  # Make sure the date is valid
  try {
    $meeting_date = DateTime->new(
      year  => $year,
      month => $month,
      day   => $day,
    );
  } catch {
    $c->detach( qw/TopTable::Controller::Root default/ );
  };
  
  my $meeting = $c->model("DB::Meeting")->find_by_type_and_date( $type_id_or_key, $meeting_date );
  
  if ( defined( $meeting ) ) {
    my $encoded_meeting_type = encode_entities( $meeting->type->name );
    
    $c->stash({
      meeting               => $meeting,
      is_event              => $meeting->is_event,
      encoded_meeting_type  => $encoded_meeting_type,
      subtitle1             => $encoded_meeting_type,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/meetings/view_by_type_and_date", [ $meeting->type->url_key, $meeting->date_and_start_time->year, sprintf( "%02d", $meeting->date_and_start_time->month ), sprintf( "%02d", $meeting->date_and_start_time->day ) ]),
      label => $encoded_meeting_type,
    }) unless $meeting->is_event;
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_by_id

Chain base for getting the meeting ID and checking it.

=cut

sub base_by_id :Chained("/") :PathPart("meetings") :CaptureArgs(1) {
  my ( $self, $c, $id ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $meeting = $c->model("DB::Meeting")->find_by_id( $id );
  
  if ( defined( $meeting ) ) {
    my $encoded_meeting_type = encode_entities( $meeting->type->name );
    
    $c->stash({
      meeting               => $meeting,
      is_event              => $meeting->is_event,
      encoded_meeting_type  => $encoded_meeting_type,
      subtitle1             => $encoded_meeting_type,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/meetings/view_by_type_and_date", [ $meeting->type->url_key, $meeting->date_and_start_time->year, sprintf( "%02d", $meeting->date_and_start_time->month ), sprintf( "%02d", $meeting->date_and_start_time->day ) ]),
      label => encode_entities( $meeting->type->name ),
    }) unless $meeting->is_event;
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of seasons.  Matches /seasons

=cut

sub base_list :Chained("/") :PathPart("meetings") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_view", $c->maketext("user.auth.view-meetings"), 1] );
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( meeting_edit meeting_delete meeting_create) ], "", 0] );
  
  # Page description
  $c->stash({
    page_description  => $c->maketext("description.meetings.list", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the meetings on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/meetings/list_first_page")});
}

=head2 list_specific_page

List the meetings on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/meetings/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/meetings/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $meetings = $c->model("DB::Meeting")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $meetings->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/meetings/list_first_page",
    specific_page_action  => "/meetings/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/meetings/list.ttkt",
    view_online_display => "Viewing meeting types",
    view_online_link    => 1,
    meetings            => $meetings,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view_by_type_and_date

Chained to base_by_type_and_date.  Doesn't do any work except forwarding to the actual view routine.

=cut

sub view_by_type_and_date :Chained("base_by_type_and_date") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward( "view" );
}

=head2 view_by_id

Chained to base_by_type_and_date.  Doesn't do any work except forwarding to the actual view routine.

=cut

sub view_by_id :Chained("base_by_id") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward( "view" );
}

=head2 view

Private method forwarded to by view_by_id and view_by_type_and_date.  Does the actual work in the view routine.

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  my $delete_screen         = $c->stash->{delete_screen} || 0;
  my $is_event              = $c->stash->{is_event} || 0;
  my $event                 = $c->stash->{event};
  my $event_season          = $c->stash->{event_season};
  my $encoded_meeting_type  = $c->stash->{encoded_meeting_type};
  my $site_name             = $c->stash->{encoded_site_name};
  my ( $edit_uri, $delete_uri, $edit_auth_code, $delete_auth_code, $name, $meeting );
  
  if ( $is_event ) {
    $meeting = $event_season->event_detail if defined( $event_season );
    $c->stash({meeting => $meeting});
  } else {
    $meeting = $c->stash->{meeting};
  }
  
  my $canonical_uri = $c->stash->{canonical_uri};
  if ( $is_event ) {
    $edit_uri         = $c->uri_for_action("/events/edit", [$event->url_key]);
    $edit_auth_code   = "event_edit";
    $delete_uri       = $c->uri_for_action("/events/delete", [$event->url_key]);
    $delete_auth_code = "event_delete";
    $name             = encode_entities( $event_season->name );
  } else {
    $edit_uri         = $c->uri_for_action("/meetings/edit_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)]);
    $edit_auth_code   = "meeting_edit";
    $delete_uri       = $c->uri_for_action("/meetings/delete_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)]);
    $delete_auth_code = "meeting_delete";
    $name             = $encoded_meeting_type;
    $canonical_uri    = $c->uri_for_action("/meetings/view_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)]);
  }
  
  # Check that we are authorised to view meetings
  # Only do the view authorisation if it's not an event; if it is, we'll have checked the event view permissions already
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_view", $c->maketext("user.auth.view-meetings"), 1] ) unless $is_event;
  $c->forward( "TopTable::Controller::Users", "check_authorisation", [[ $edit_auth_code, $delete_auth_code ], "", 0] );
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( $delete_screen ) {
    # Push edit link if we are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text      => $c->maketext("admin.edit-object", $name),
      link_uri  => $edit_uri,
    }) if $c->stash->{authorisation}{$edit_auth_code};
    
    # Push a delete link if we're authorised and the club can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text      => $c->maketext("admin.delete-object", $name),
      link_uri  => $delete_uri,
    }) if $c->stash->{authorisation}{$delete_auth_code};
  }
  
  $c->stash({
    template            => "html/meetings/view.ttkt",
    external_scripts    => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/standard/responsive-tabs.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    ],
    title_links         => \@title_links,
    subtitle1           => $name,
    attendees           => [ $meeting->attendees ],
    apologies           => [ $meeting->apologies ],
    view_online_display => sprintf( "Viewing %s", $name ),
    view_online_link    => 0,
    canonical_uri       => $canonical_uri,
    page_description    => $c->maketext("description.meetings.view", $name, $site_name),
  });
}

=head2 create

Display a form to collect information for creating a season.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  my $event     = $c->stash->{event};
  my $is_event  = $c->stash->{is_event} || 0;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_create", $c->maketext("user.auth.create-meetings"), 1] );
  
  my @meeting_types = $c->model("DB::MeetingType")->all_meeting_types;
  
  if ( scalar( @meeting_types ) == 0 and !$is_event ) {
    $c->response->redirect( $c->uri_for("/meetings",
                                {mid => $c->set_status_msg( {error => $c->maketext("meetings.form.error.no-meeting-types", $c->uri_for("/meeting-types/create") ) } ) }) );
    $c->detach;
    return;
  }
  
  my @venues = $c->model("DB::Venue")->all_venues;
  
  if ( scalar( @venues ) == 0 and !$is_event ) {
    $c->response->redirect( $c->uri_for("/meetings",
                                {mid => $c->set_status_msg( {error => $c->maketext("meetings.form.error.no-venues", $c->uri_for("/venues/create") ) } ) }) );
    $c->detach;
    return;
  }
  
  # First setup the function arguments
  my $organiser_tokeninput_options = {
    jsonContainer => "json_search",
    tokenLimit    => 1,
    hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add the pre-population if needed
  $organiser_tokeninput_options->{prePopulate} = [{id => $c->flash->{organiser}->id, name => $c->flash->{organiser}->display_name}] if defined( $c->flash->{organiser} );
  
  # Attendee tokeninputs
  my $attendee_tokeninput_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext("meetings.field.attendees.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  if ( exists( $c->flash->{attendees} ) and ref( $c->flash->{attendees} ) eq "ARRAY" ) {
    foreach my $player ( @{ $c->flash->{attendees} } ) {
      push(@{ $attendee_tokeninput_options->{prePopulate} }, {
        id    => $player->id,
        name  => encode_entities( $player->display_name ),
      });
    }
  }
  
  # Apologies tokeninputs
  my $apologies_tokeninput_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext("meetings.field.apologies.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  if ( exists( $c->flash->{apologies} ) and ref( $c->flash->{apologies} ) eq "ARRAY" ) {
    foreach my $player ( @{ $c->flash->{apologies} } ) {
      push(@{ $apologies_tokeninput_options->{prePopulate} }, {
        id    => $player->id,
        name  => encode_entities( $player->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $organiser_tokeninput_options ),
    selector  => "organiser",
  }, {
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $attendee_tokeninput_options ),
    selector  => "attendees",
  }, {
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $apologies_tokeninput_options ),
    selector  => "apologies",
  }];
  
  # Stash everything we need in the template
  $c->stash({
    template            => "html/meetings/create-edit.ttkt",
    form_action         => $c->uri_for("do-create"),
    subtitle2           => $c->maketext("admin.create"),
    tokeninput_confs    => $tokeninput_confs,
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/standard/ckeditor.js"),
      $c->uri_for("/static/script/meetings/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    meeting_types       => \@meeting_types,
    venues              => \@venues,
    view_online_display => "Creating meeting types",
    view_online_link    => 0,
  });
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/meetings/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit_by_type_and_date

The action for editing chained to base_by_type_and_date; forwards to edit, which is the real edit routine. 

=cut

sub edit_by_type_and_date :Chained("base_by_type_and_date") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward( "edit" );
}

=head2 edit_by_id

The action for editing chained to base_by_id; forwards to edit, which is the real edit routine. 

=cut

sub edit_by_id :Chained("base_by_id") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward( "edit" );
}

=head2 edit

Display a form to with the existing information for editing a club

=cut

sub edit :Private {
  my ( $self, $c ) = @_;
  my $meeting       = $c->stash->{meeting};
  my $event         = $c->stash->{event};
  my $event_season  = $c->stash->{event_season};
  my $is_event      = $c->stash->{is_event};
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_edit", $c->maketext("user.auth.edit-meetings"), 1] ) unless $is_event;
  
  if ( $is_event ) {
    $meeting = $event_season->event_detail;
    $c->stash({meeting => $meeting});
  } else {
    $meeting = $c->stash->{meeting};
  }
  
  # Organiser token inputs
  my $organiser_tokeninput_options = {
    jsonContainer => "json_search",
    tokenLimit    => 1,
    hintText      => encode_entities( $c->maketext("person.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add the pre-population if needed
  my $organiser;
  if ( defined( $c->flash->{organiser} ) ) {
    $organiser = $c->flash->{organiser};
  } elsif ( $is_event ) {
    $organiser = $event_season->organiser;
  } else {
    $organiser = $meeting->organiser;
  }
  
  $organiser_tokeninput_options->{prePopulate} = [{id => $organiser->id, name => $organiser->display_name}] if defined( $organiser );
  
  # Attendee tokeninputs
  my $attendee_tokeninput_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext("meetings.field.attendees.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  my $attendees = ( exists( $c->flash->{attendees} ) and ref( $c->flash->{attendees} ) eq "ARRAY" ) ? $c->flash->{attendees} : [ $meeting->attendees ];
  
  if ( scalar( @{ $attendees } ) ) {
    foreach my $attendee ( @{ $attendees } ) {
      # Depending whether we've flashed the value or taken it from the database, this will be the person object directly
      # or the meeting attendee object, in which case we need to retrieve the person object.
      my $attendee_person = ( ref( $attendee ) eq "TopTable::DB::Model::Person" ) ? $attendee : $attendee->person;
      
      push(@{ $attendee_tokeninput_options->{prePopulate} }, {
        id    => $attendee_person->id,
        name  => encode_entities( $attendee_person->display_name ),
      });
    }
  }
  
  # Apologies tokeninputs
  my $apologies_tokeninput_options = {
    jsonContainer => "json_search",
    hintText      => encode_entities( $c->maketext("meetings.field.apologies.tokeninput.type") ),
    noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
    searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
  };
  
  # Add pre-population if we need it
  my $apologies = ( exists( $c->flash->{apologies} ) and ref( $c->flash->{apologies} ) eq "ARRAY" ) ? $c->flash->{apologies} : [ $meeting->apologies ];
  
  if ( scalar( @{ $apologies } ) ) {
    foreach my $apology ( @{ $apologies } ) {
      # Depending whether we've flashed the value or taken it from the database, this will be the person object directly
      # or the meeting attendee object, in which case we need to retrieve the person object.
      my $apology_person = ( ref( $apology ) eq "TopTable::DB::Model::Person" ) ? $apology : $apology->person;
      
      push(@{ $apologies_tokeninput_options->{prePopulate} }, {
        id    => $apology_person->id,
        name  => encode_entities( $apology_person->display_name ),
      });
    }
  }
  
  my $tokeninput_confs = [{
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $organiser_tokeninput_options ),
    selector  => "organiser",
  }, {
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $attendee_tokeninput_options ),
    selector  => "attendees",
  }, {
    script    => $c->uri_for("/people/search"),
    options   => encode_json( $apologies_tokeninput_options ),
    selector  => "apologies",
  }];
  
  # Stash everything we need in the template
  $c->stash({
    template            => "html/meetings/create-edit.ttkt",
    form_action         => $c->uri_for_action("/meetings/do_edit_by_id", [$meeting->id]),
    subtitle2           => $c->maketext("admin.edit"),
    tokeninput_confs    => $tokeninput_confs,
    scripts             => [
      "tokeninput-standard",
    ],
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/standard/ckeditor.js"),
      $c->uri_for("/static/script/meetings/create-edit.js"),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    meeting_types       => [ $c->model("DB::MeetingType")->all_meeting_types ],
    venues              => [ $c->model("DB::Venue")->all_venues ],
    view_online_display => "Editing a meeting",
    view_online_link    => 0,
  });
  
  my $page_uri = ( $is_event )
    ? $c->uri_for_action("/events/edit", [$event->url_key])
    : $c->uri_for_action("/meetings/edit_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)]);
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $page_uri,
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete_by_type_and_date

Delete action chained to base_by_type_and_date; does nothing but detach to the real delete action.

=cut

sub delete_by_type_and_date :Chained("base_by_type_and_date") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "delete" );
}

=head2 delete_by_id

Delete action chained to base_by_id; does nothing but detach to the real delete action.

=cut

sub delete_by_id :Chained("base_by_id") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "delete" );
}

=head2 delete

Shows the delete button.

=cut

sub delete :Private {
  my ( $self, $c ) = @_;
  my $meeting = $c->stash->{meeting};
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_delete", $c->maketext("user.auth.delete-meetings"), 1] );
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2           => $c->maketext("admin.delete"),
    template            => "html/meeting-types/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $meeting->type->name ),
    view_online_link    => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/meetings/delete_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process the form for creating a meeting.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create seasons
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_create", $c->maketext("user.auth.create-meeting-types"), 1] );
  $c->detach( "setup_meeting", ["create"] );
}

=head2 do_edit_by_type_and_date

Chained to base_by_type_and_date and detaches to the do_edit routine.

=cut

sub do_edit_by_type_and_date :Chained("base_by_type_and_date") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "do_edit" );
}

=head2 do_edit_by_id

Chained to base_by_id and detaches to the do_edit routine.

=cut

sub do_edit_by_id :Chained("base_by_id") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "do_edit" );
}

=head2 do_edit

Process the form for editing an individual match template.

=cut

sub do_edit :Private {
  my ( $self, $c, $template_id ) = @_;
  
  # Check that we are authorised to create clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_edit", $c->maketext("user.auth.edit-meeting-types"), 1] );
  $c->detach( "setup_meeting", ["edit"] );
}

=head2 do_delete_by_type_and_date

Chained to base_by_type_and_date; detaches to do_delete.

=cut

sub do_delete_by_type_and_date :Chained("base_by_type_and_date") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete_by_id

Chained to base_by_id; detaches to do_delete.

=cut

sub do_delete_by_id :Chained("base_by_id") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete

Processes the meeting deletion after the user has submitted the form.

=cut

sub do_delete :Private {
  my ( $self, $c ) = @_;
  my $meeting_type = $c->stash->{meeting_type};
  my $meeting_type_name = $meeting_type->name;
  
  # Check that we are authorised to delete clubs
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["meeting_type_delete", $c->maketext("user.auth.delete-meeting-types"), 1] );
  
  my $error = $meeting_type->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/meeting-type/view", [ $meeting_type->url_key ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["meeting-type", "delete", {id => undef}, $meeting_type_name] );
    $c->response->redirect( $c->uri_for("/seasons",
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $meeting_type_name, $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
}

=head2 setup_meeting

Forwarded to from docreate / doedit - sets up the meeting and adds / updates the database with the new details.

=cut

sub setup_meeting :Private {
  my ( $self, $c, $action ) = @_;
  my $meeting   = $c->stash->{meeting};
  my $is_event  = $c->stash->{is_event};
  my ( $season, $event, $event_season );
  
  # If it's an event, work out if we can edit (we must be editing, can't create through this method).
  if ( $is_event ) {
    $season       = $c->model("DB::Season")->get_current;
    
    if ( defined( $season ) ) {
      $event_season = $meeting->event_season;
      $event        = $event_season->event;
    } else {
      # There is no current season, so we can't edit
      $c->response->redirect( $c->uri_for("/events/view_current_season", [$event->url_key],
                                  {mid => $c->set_status_msg( {error => $c->maketext("events.edit.error.no-current-season") } ) }) );
      $c->detach;
      return;
    }
  }
  
  # Grab the foreign keys
  my $type      = $c->model("DB::MeetingType")->find( $c->request->parameters->{type} ) if $c->request->parameters->{type};
  my $venue     = $c->model("DB::Venue")->find( $c->request->parameters->{venue} ) if $c->request->parameters->{venue};
  my $organiser = $c->model("DB::Person")->find( $c->request->parameters->{organiser} ) if $c->request->parameters->{organiser};
  
  # Get the attendees / apologies
  my @attendee_ids  = split( ",", $c->request->parameters->{attendees} );
  my @apologies_ids = split( ",", $c->request->parameters->{apologies} );
  my ( @attendees, @apologies );
  
  push( @attendees, $c->model("DB::Person")->find( $_ ) ) foreach ( @attendee_ids );
  push( @apologies, $c->model("DB::Person")->find( $_ ) ) foreach ( @apologies_ids );
  
  # Call the DB routine to do the error checking and creation
  my $details = $c->model("DB::Meeting")->create_or_edit($action, {
    meeting       => $meeting,
    is_event      => $is_event,
    type          => $type,
    venue         => $venue,
    organiser     => $organiser,
    date          => $c->request->parameters->{date},
    start_hour    => $c->request->parameters->{start_hour},
    start_minute  => $c->request->parameters->{start_minute},
    all_day       => $c->request->parameters->{all_day},
    finish_hour   => $c->request->parameters->{finish_hour},
    finish_minute => $c->request->parameters->{finish_minute},
    attendees     => \@attendees,
    apologies     => \@apologies,
    agenda        => $c->request->parameters->{agenda},
    minutes       => $c->request->parameters->{minutes},
  });
  
  my $redirect_uri;
  if ( scalar( @{ $details->{error} } ) ) {
    my $error = $c->build_message( $details->{error} );
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{form_errored}   = 1;
    $c->flash->{type}           = $c->request->parameters->{type};
    $c->flash->{date}           = $c->request->parameters->{date};
    $c->flash->{start_hour}     = $c->request->parameters->{start_hour};
    $c->flash->{start_minute}   = $c->request->parameters->{start_minute};
    $c->flash->{all_day}        = $c->request->parameters->{all_day};
    $c->flash->{finish_hour}    = $c->request->parameters->{finish_hour};
    $c->flash->{finish_minute}  = $c->request->parameters->{finish_minute};
    $c->flash->{attendees}      = \@attendees;
    $c->flash->{apologies}      = \@apologies;
    $c->flash->{agenda}         = $c->request->parameters->{agenda};
    $c->flash->{minutes}        = $c->request->parameters->{minutes};
    
    if ( $action eq "create" ) {
      # If we're creating, we'll just redirect straight back to the create form
      $redirect_uri = $c->uri_for("/meetings/create",
                            {mid => $c->set_status_msg( {error => $error} ) });
    } else {
      if ( defined( $details->{meeting} ) ) {
        $meeting = $details->{meeting};
        # If we're editing and we found an object to edit, we'll redirect to the edit form for that object
        if ( $is_event ) {
          $redirect_uri = $c->uri_for_action("/events/edit", [$event->url_key],
                                {mid => $c->set_status_msg( {error => $error} ) });
        } else {
          $redirect_uri = $c->uri_for_action("/meetings/edit_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)],
                                {mid => $c->set_status_msg( {error => $error} ) });
        }
        
      } else {
        # If we're editing and we didn't an object to edit, we'll redirect to the list of objects
        if ( $is_event ) {
          $redirect_uri = $c->uri_for("/events",
                                {mid => $c->set_status_msg( {error => $error} ) });
        } else {
          $redirect_uri = $c->uri_for("/meetings",
                                {mid => $c->set_status_msg( {error => $error} ) });
        }
      }
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    my $meeting = $details->{meeting};
    my $action_description;
    
    if ( $action eq "create" ) {
      $action_description = $c->maketext("admin.message.created");
    } else {
      $action_description = $c->maketext("admin.message.edited");
    }
    
    if ( $is_event ) {
      $redirect_uri = $c->uri_for_action("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $event->name, $action_description )} ) });
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["event", $action, {id => $event->id}, $event->name] );
    } else {
      my $encoded_meeting_type  = encode_entities( $meeting->type->name );
      $redirect_uri = $c->uri_for_action("/meetings/view_by_type_and_date", [$meeting->type->url_key, $meeting->date_and_start_time->year, sprintf("%02d", $meeting->date_and_start_time->month), sprintf("%02d", $meeting->date_and_start_time->day)],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", $encoded_meeting_type, $action_description )} ) });
      $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["meeting", $action, {id => $meeting->id}, sprintf( "%s (%s)", $meeting->type->name, $meeting->date_and_start_time->ymd("/") )] );
    }
    
    $c->response->redirect( $redirect_uri );
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
