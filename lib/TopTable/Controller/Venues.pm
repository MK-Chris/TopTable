package TopTable::Controller::Venues;
use Moose;
use namespace::autoclean;
use JSON;
use GIS::Distance;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Venue - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.venue")});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/venues"),
    label => $c->maketext("menu.text.venue"),
  });
}


=head2 base

Chain base for getting the venue ID and checking it.

=cut

sub base :Chained("/") PathPart("venues") CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  my $venue = $c->model("DB::Venue")->find_id_or_url_key($id_or_url_key);
  
  if ( defined($venue) ) {
    my $enc_name = encode_entities($venue->name);
    
    $c->stash({
      venue => $venue,
      enc_name  => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/venues/view", [$venue->url_key]),
      label => $venue->name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of venues.  Matches /venues

=cut

sub base_list :Chained("/") :PathPart("venues") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_view", $c->maketext("user.auth.view-venues"), 1]);
  
  # Check the authorisation to edit venues we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( venue_edit venue_delete venue_create) ], "", 0]);
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.venues.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the venues on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach("retrieve_paged", [1]);
  $c->stash({canonical_uri => $c->uri_for_action("/venues/list_first_page")});
}

=head2 list_specific_page

List the venues on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/venues/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/venues/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for venues with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $venues = $c->model("DB::Venue")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $venues->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/venues/list_first_page",
    specific_page_action => "/venues/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/venues/list.ttkt",
    view_online_display => "Viewing venues",
    view_online_link => 1,
    venues => $venues,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

=cut

sub view :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $venue = $c->stash->{venue};
  my $venue_name = $c->stash->{enc_name};
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_view", $c->maketext("user.auth.view-venues"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( venue_create venue_edit venue_delete ) ], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  unless ( exists( $c->stash->{delete_screen} ) ) {
    # Push edit / opening hour links if are authorised
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $venue_name),
      link_uri => $c->uri_for_action("/venues/edit", [$venue->url_key]),
    }) if $c->stash->{authorisation}{venue_edit};
    
    # Push a delete link if we're authorised and the venue can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $venue_name),
      link_uri => $c->uri_for_action("/venues/delete", [$venue->url_key]),
    }) if $c->stash->{authorisation}{venue_delete} and $venue->can_delete;
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/venues/view.ttkt",
    title_links => \@title_links,
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/venues/view.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
    ],
    map_id => "map-canvas",
    directions => 1,
    prepare_error_div => 1,
    marker_title => $venue->name,
    subtitle1 => $venue_name,
    view_online_display => sprintf( "Viewing %s", $venue->name ),
    view_online_link => 1,
    map_latitude => $venue->coordinates_latitude,
    map_longitude => $venue->coordinates_longitude,
    page_description => $c->maketext("description.venues.view", $venue_name, $site_name),
    canonical_uri => $c->uri_for_action("/venues/view", [$venue->url_key]),
  });
  
  # Notice if inactive
  $c->add_status_messages({info => $c->maketext("venue.msg.inactive")}) unless $venue->active;
}

=head2 create

Display a form to collect information for creating a venue

=cut

sub create :Local {
  my ($self, $c) = @_;
  
  # Check that we are authorised to create venues
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["venue_create", $c->maketext("user.auth.create-venues"), 1] );
  
  # If we have an address or name, we need to forward to the Geocode searching routine
  if ( $c->flash->{name} or $c->flash->{address1} or $c->flash->{address2} or $c->flash->{address3} or $c->flash->{address4} or $c->flash->{address5} or $c->flash->{postcode} ) {
    my $params = [{
      name => $c->flash->{name},
      address1 => $c->flash->{address1},
      address2 => $c->flash->{address2},
      address3 => $c->flash->{address3},
      address4 => $c->flash->{address4},
      address5 => $c->flash->{address5},
      postode => $c->flash->{postcode},
    }];
    
    $c->forward("search_geolocation", $params);
  }
  
  if ( $c->flash->{geolocation} and $c->flash->{geolocation} =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ ) {
    my @geolocation_bits = split(",", $c->flash->{geolocation});
    $c->stash({
      map_latitude => $geolocation_bits[0],
      map_longitude => $geolocation_bits[1],
    });
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/venues/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for_action("/venues/create_edit_js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    map_id => "map-canvas-form",
    prepare_error_div => 1,
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating venues",
    view_online_link => 0,
  });
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/venues/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit

Display a form to with the existing information for editing a venue

=cut

sub edit :Chained('base') :PathPart('edit') :Args(0) {
  my ($self, $c) = @_;
  my $venue = $c->stash->{venue};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to edit venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_edit", $c->maketext("user.auth.edit-venues"), 1]);
  
  # If we have an address or name, we need to forward to the Geocode searching routine
  my $params;
  if ( $c->flash->{name} or $c->flash->{address1} or $c->flash->{address2} or $c->flash->{address3} or $c->flash->{address4} or $c->flash->{address5} or $c->flash->{postcode} ) {
    $params = [{
      name => $c->flash->{name},
      address1 => $c->flash->{address1},
      address2 => $c->flash->{address2},
      address3 => $c->flash->{address3},
      address4 => $c->flash->{address4},
      address5 => $c->flash->{address5},
      postode => $c->flash->{postcode},
    }];
  } else {
    # Nothing flashed, use the DB stored values
    $params = [{
      name => $venue->name,
      address1 => $venue->address1,
      address2 => $venue->address2,
      address3 => $venue->address3,
      address4 => $venue->address4,
      address5 => $venue->address5,
      postode  => $venue->postcode,
    }];
  }
  
  if ( $c->flash->{geolocation} and $c->flash->{geolocation} =~ /^[-+]?([1-8]?\d(\.\d+)?|90(\.0+)?),\s*[-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?)$/ ) {
    # Stash the flashed values if there are any and they're valid
    my @geolocation_bits = split(",", $c->flash->{geolocation});
    $c->stash({
      map_latitude => $geolocation_bits[0],
      map_longitude => $geolocation_bits[1],
    });
  } else {
    # Stash the stored DB values
    $c->stash({
      map_latitude => $venue->coordinates_latitude,
      map_longitude => $venue->coordinates_longitude,
    });
  }
  
  # Get the geolocation options
  $c->forward("search_geolocation", $params);
  
  # Get venues to list
  $c->stash({
    template => "html/venues/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/toastmessage/jquery.toastmessage.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for_action("/venues/create_edit_js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/toastmessage/jquery.toastmessage.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    map_id => "map-canvas-form",
    prepare_error_div => 1,
    form_action => $c->uri_for_action("/venues/do_edit", [$venue->url_key]),
    subtitle1 => $venue->name,
    subtitle2 => $c->maketext("admin.edit"),
    view_online_display => "Editing " . $c->stash->{venue}->name,
    view_online_link => 0,
  });
  
  push(@{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/venues/edit", [$venue->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 create_edit_js

Generate the external javascript file to use when editing or creating a seasons

=cut

sub create_edit_js :Path("create-edit.js") {
  my ( $self, $c ) = @_;
  
  # This will be a javascript file, not a HTML
  $c->res->headers->header("Content-type" => "text/javascript");
  
  # Stash no wrapper and the template
  $c->stash({
    template => "scripts/venues/create-edit.ttjs",
    no_wrapper => 1,
  });
  
  $c->detach($c->view("HTML"));
}

=head2 delete

Display the form to delete a venue.

=cut

sub delete :Chained("base") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $venue = $c->stash->{venue};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_delete", $c->maketext("user.auth.delete-venues"), 1]);
  
  unless ( $venue->can_delete ) {
    $c->response->redirect($c->uri_for_action("/venues/view", [$venue->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("venues.delete.error.cannot-delete", $venue->name)})}));
    $c->detach;
    return;
  }
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2 => $c->maketext("admin.delete"),
    template => "html/venues/delete.ttkt",
    view_online_display => sprintf("Deleting %s", $venue->name),
    view_online_link => 0,
  });
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/venues/edit", [$venue->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Process a submitted form to create a venue.

=cut

=head2 do_create

Process the form for creating a venue. 

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_create", $c->maketext("user.auth.create-venues"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit

Process the form for editing a venue. 

=cut

sub do_edit :Chained("base") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_edit", $c->maketext("user.auth.edit-venues"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete

Process the deletion of a venue.

=cut

sub do_delete :Chained("base") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  my $venue = $c->stash->{venue};
  my $enc_name = $c->stash->{enc_name};
  
  # Check that we are authorised to delete venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_delete", $c->maketext("user.auth.delete-venues"), 1]);
  
  # Save away the venue name, as if there are no errors and it can be deleted, we will need to
  # reference the name in the message back to the user.
  my $venue_name = $venue->name;
  my $response = $venue->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for("/venues", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["venue", "delete", {id => undef}, $venue_name]);
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/venues/view", [$venue->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Forwarded to from docreate / doedit - sets up the venue and adds / updates the database with the new details.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $venue = $c->stash->{venue};
  my @field_names = qw( name address1 address2 address 3 address4 address5 postcode telephone email_address geolocation active );
  my @processed_field_names = qw( name address1 address2 address 3 address4 address5 postcode telephone email_address map_latitude map_longitude active );
  
  # Do the geocoding from Google first, if we have a postcode
  my ( $latitude, $longitude ) = split(",", $c->req->params->{geolocation});
  
  # Call the DB routine to do the error checking and creation
  my $response = $c->model("DB::Venue")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    venue => $venue,
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
  });
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{error}};
  my @warnings = @{$response->{warning}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $venue = $response->{venue};
    $redirect_uri = $c->uri_for_action("/venues/view", [$venue->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["venue", $action, {id => $venue->id}, $venue->name]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/venues/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/venues/edit", [$venue->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{show_flashed} = 1;
    $c->flash->{$_} = $response->{fields}{$_} foreach @field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

sub search_geolocation :Path("geolocation") {
  my ( $self, $c, $params ) = @_;
  
  # The below stashed values could either be from the DB or from the flashed values - if we have any, we will add some distance values to our results and denote the closest
  my $map_latitude = $c->stash->{map_latitude};
  my $map_longitude = $c->stash->{map_longitude};
  
  # Not an AJAX request, must be privately forwarded, set $params to $c->req->params
  $params = $c->req->params if $c->is_ajax;
  
  # We will store all of our results in the @results array, as we'll be pushing results on to them with each query.
  # To avoid duplicates, before we push, we'll check against the %seen_coordinates hash (which will have $lat,$lng
  # as a key).
  my ( @results, %seen_coordinates );
  
  # The first thing to search for is a place of interest (venue name and postcode)
  my $place = $params->{name} . " " . $params->{postcode} if $params->{name} and $params->{postcode};
  
  # Build the address search string
  # Start with the name
  my $address = $params->{name} . " " if $params->{name};
  
  for my $i ( 1 .. 5 ) {
    # Then build in all the non-blank address lines
    $address .= $params->{"address" . $i} . " " if $params->{"address" . $i};
  }
  
  # Finally the postcode
  $address .= $params->{postcode} if $params->{postcode};
  
  my $geocode = $c->model("Geocode")->search({location => $params->{name}}) if exists($params->{name}) and $params->{name};
  
  if ( defined($geocode) and $geocode->{status} eq "OK" ) {
    # Since we've only done one query so far, we just push them on without checking that we've seen them yet
    foreach my $result ( @{ $geocode->{results} } ) {
      if ( ref( $result ) eq "HASH" ) {
        # Push the result on to the array
        push(@results, $result);
        
        # Set the 'seen' coordinates to the hash
        $seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}} = 1;
      }
    }
  }
  
  undef($geocode);
  $geocode = $c->model("Geocode")->search({location => $place}) if defined($place);
  
  if ( defined($geocode) and $geocode->{status} eq "OK" ) {
    # Since we've only done one query so far, we just push them on without checking that we've seen them yet
    foreach my $result ( @{$geocode->{results}} ) {
      if ( ref($result) eq "HASH" and !exists($seen_coordinates{ $result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}}) ) {
        # Push the result on to the array
        push(@results, $result);
        
        # Set the 'seen' coordinates to the hash
        $seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}} = 1;
      }
    }
  }
  
  # Now search the full address
  undef($geocode);
  $geocode = $c->model("Geocode")->search({location => $address}) if defined($address);
  
  if ( defined($geocode) and $geocode->{status} eq "OK" ) {
    # Loop through and add any previously unseen results to the array
    foreach my $result ( @{$geocode->{results}} ) {
      if ( ref($result) eq "HASH" and !exists($seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}}) ) {
        # Push the result on to the array
        push(@results, $result);
        
        # Set the 'seen' coordinates to the hash
        $seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}} = 1;
      }
    }
  }
  
  # Now just do the postcode
  undef($geocode);
  $geocode = $c->model("Geocode")->search({location => $params->{postcode}}) if exists($params->{postcode}) and $params->{postcode};
  
  # As a final attempt, just try postcode
  if ( defined($geocode) and $geocode->{status} eq "OK" ) {
    # Loop through and add any previously unseen results to the array
    foreach my $result ( @{$geocode->{results}} ) {
      if ( ref($result) eq "HASH" and !exists($seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}} ) ) {
        # Push the result on to the array
        push(@results, $result);
        
        # Set the 'seen' coordinates to the hash
        $seen_coordinates{$result->{geometry}{location}{lat} . "," . $result->{geometry}{location}{lng}} = 1;
      }
    }
  }
  
  # If we have some map co-ordinates, we'll run a distance check and add that into the results.
  if ( $map_latitude and $map_longitude ) {
    my $gis = GIS::Distance->new;
    my $distance_tolerance_value = $c->config->{Google}{Maps}{distance_tolerance_value};
    my $distance_tolerance_unit = $c->config->{Google}{Maps}{distance_tolerance_unit};
    
    foreach my $result ( @results ) {
      my $distance = $gis->distance($map_latitude, $map_longitude => $result->{geometry}{location}{lat}, $result->{geometry}{location}{lng});
      $result->{distance} = $distance;
      
      # This result is selectable if it's under the tolerance set in config
      $result->{selectable} = 1 if $distance->$distance_tolerance_unit < $distance_tolerance_value;
    }
    
    # Now we've looped through and set the distances, we need to find the closest... unfortunately that means looping
    # through again, but a nifty sort means we only have to examine the first one then break out of the loop
    foreach my $result ( sort {$a->{distance}->millimetres <=> $b->{distance}->millimetres} @results ) {
      # Since we're only looping through the first item, we will just set the 'closest' key and get out
      $result->{closest} = 1;
      last;
    }
  }
  
  if ( $c->is_ajax ) {
    # If it's an AJAX request, return a list so that the web app can display the options for selection
    $c->stash({
      json_data => {
        json_results => \@results,
      },
      skip_view_online => 1,
    });
    
    $c->detach($c->view("JSON"));
  } else {
    # Not an AJAX request, just stash the first result
    $c->stash({geocode_results  => \@results});
  }
}

=head2 opening_hours

Display a form to set the opening hours for a venue.

=cut

sub opening_hours :Chained("base") :PathPart("opening-hours") :Args(0) {
  my ( $self, $c ) = @_;
  my $venue = $c->stash->{venue};
  
  # Check that we are authorised to view venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_edit", $c->maketext("user.auth.edit-venues"), 1]);
  
  my $opening_hours = $venue->get_full_timetable_by_session;
  
  # Add a dummy (blank) row if there aren't any rows on this one
  $opening_hours = [{}] if !defined($opening_hours);
  
  # Set up the template to use
  $c->stash({
    template => "html/venues/opening-hours.ttkt",
    form_action => "set-opening-hours",
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/button-toggle.js", {v => 2}),
    ],
    subtitle2 => $venue->name,
    subtitle3 => $c->maketext("venues.opening-hours"),
    view_online_display => "Setting the opening hours for " . $venue->name,
    view_online_link => 0,
    opening_hours => $opening_hours,
    weekdays => [$c->model("DB::LookupWeekday")->all_days],
  });
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/venues/opening_hours", [$venue->url_key]),
    label => $c->maketext("venues.opening-hours"),
  });
}

=head2 set_opening_hours

Display a form to set the opening hours for a venue.

=cut

sub set_opening_hours :Path("set-opening-hours") {
  my ( $self, $c ) = @_;
  
  
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["venue_view", $c->maketext("user.auth.view-venues"), 1]);
  
  $c->stash({
    db_resultset => "Venue",
    query_params => {q => $c->req->params->{q}},
    view_action => "/venues/view",
    search_action => "/venues/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.venues") ),
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
