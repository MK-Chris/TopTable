package TopTable::Controller::SystemEventLog;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered event-log, so the URLs start /event-log.
__PACKAGE__->config(namespace => "event-viewer");

=head1 NAME

TopTable::Controller::SystemEventLog - Catalyst Controller

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
  $c->stash({subtitle1 => $c->maketext("menu.text.eventlog")});
  
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/event-log"),
    label => $c->maketext("menu.text.eventlog"),
  });
}

=head2 base

Base routine for the event log listing.  Checks the authorisation.

=cut

sub base :Chained("/") :PathPart("event-viewer") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["eventlog_view_all", "view administrative updates", 0]);
  
  # Page description
  $c->stash({page_description => $c->maketext("description.event-log.list", $site_name)});
}

=head2 render_list_page

List the events.

=cut

sub render_list_page :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( user_view_ip )], "", 0]);
  
  # Set up the template to use
  $c->stash({
    template => "html/event-viewer/view-ajax.ttkt",
    scripts => [
      "event-viewer/view"
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/qtip/jquery.qtip.min.js"),
      $c->uri_for("/static/script/standard/qtip.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/plugins/sorting/ip-address.js"),
      $c->uri_for("/static/script/standard/datatable-clear-pipeline.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/qtip/jquery.qtip.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    view_online_display => "Viewing event log",
    view_online_link => 1,
  });
}

=head2 load_events_js

Load the specified page of events.

=cut

sub load_events_js :Path("load.js") :Args(0) {
  my ( $self, $c ) = @_;
  my $start = $c->req->params->{start};
  my $page_length = $c->req->params->{pagelength};
  my $max_results = $c->req->params->{length} || $c->config->{Pagination}{default_page_size}; # Not necessarily the same as page length - we could be caching subsuquent pages
  my $draw = $c->req->params->{draw};
  my $order_col = $c->req->params->{"order[0][column]"} || undef;
  my $order_dir = $c->req->params->{"order[0][dir]"} || undef;
  my $search_val = $c->req->params->{"search[value]"} || undef;
  
  # Sanity checks on parameters
  $draw = 1 unless defined($draw) and $draw =~ /^\d+$/;
  $order_dir = "asc" unless defined($order_dir) and ($order_dir eq "asc" or $order_dir eq "desc");
  
  # Get the name to order by
  $order_col = $c->req->param("columns[$order_col][name]");
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( user_view_ip eventlog_view_all admin_issue_bans ) ], "", 0]);
  
  # Work out if we can view all events or just public ones
  my $public_only = ( $c->stash->{authorisation}{eventlog_view_all} and !exists($c->req->params->{"suppress-private"}) ) ? 0 : 1;
  
  my @events = $c->model("DB::SystemEventLog")->page_records({
    public_only => $public_only,
    page_length => $page_length,
    start => $start + 1, # Start is 0 based from dataTables
    max_results => $max_results,
    order_col => $order_col,
    order_dir => $order_dir,
    search_val => $search_val,
    search_ips => $c->stash->{authorisation}{user_view_ip},
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
  });
  
  # Setup the dataTables columns array
  my @data = ();
  
  foreach my $event ( @events ) {
    # Each of these is a row in the table
    # Add an array to add the row columns to
    my @row = ();
    
    my $user = defined($event->user) ? sprintf('<a href="%s">%s</a>', $c->uri_for_action("/users/view", [$event->user->url_key]), $event->user->display_name) : $c->maketext("system-event-log.guest");
    push(@row, $user) unless $c->stash->{exclude_event_user};
    push(@row, $event->ip_address) if $c->stash->{authorisation}{user_view_ip};
    
    my $updated = $event->log_updated_tz($c->stash->{timezone});
    push(@row, sprintf("%s %s", $updated->dmy("/"), $updated->hms));
    push(@row, ucfirst($c->maketext(sprintf("object.plural.%s", $event->system_event_log_type->plural_objects))));
    
    my $display_desc = $event->display_description(3, 35);
    my $display_obj_text = ""; # Set the object text to blank when we start a new row
    
    # Loop through all our display objects
    my $obj_count = 0;
    foreach my $display_obj ( @{ $display_desc->{for_display} } ) {
      $obj_count++;
      
      # If this is not the first loop through, we'll need to add a comma or "and", depending on some criteria...
      if ( $obj_count > 1 ) {
        if ( $obj_count == scalar @{$display_desc->{for_display}} and scalar @{$display_desc->{for_tooltip}} <= 1 ) {
          # If we're on the last display object and there are no tooltip objects, we need "and"
          $display_obj_text .= sprintf(" %s ", $c->maketext("system-event-log.and"));
        } else {
          # Otherwise, it'll be a comma
          $display_obj_text .= ", ";
        }
      }
      
      if ( $display_obj->{ids}[0] and $event->system_event_log_type->view_action_for_uri ) {
        $display_obj_text .= '<a href="' . $c->uri_for_action( $event->system_event_log_type->view_action_for_uri, $display_obj->{ids} ) . '">' . $display_obj->{name} . '</a>';
      } else {
        $display_obj_text .= $display_obj->{name};
      }
    }
    
    my $tooltip_link_text = "";
    if ( scalar @{$display_desc->{for_tooltip}} > 1 ) {
      # Keep count of our tooltip objects
      $obj_count = 0;
      
      my $tooltip_obj_text = "";
      my $tooltip_display_text = "";
      
      # Loop through all our tooltip objects
      foreach my $tooltip_obj ( @{ $display_desc->{for_tooltip} } ) {
        # Increment the counter
        $obj_count++;
        
        # If this is not the first iteration, add a <br />
        $tooltip_obj_text .= "<br />" if $obj_count > 1;
        
        # Set this name into the tooltip
        if ( $tooltip_obj->{ids}[0] and $event->system_event_log_type->view_action_for_uri ) {
          $tooltip_obj_text .= "<a class='tip' href='" . $c->uri_for_action($event->system_event_log_type->view_action_for_uri, $tooltip_obj->{ids}) . "'>" . $tooltip_obj->{name} . "</a>";
        } else {
          $tooltip_obj_text .= $tooltip_obj->{name};
        }
      }
      
      # Set our 'others'
      $tooltip_obj_text .= "<br />" . $c->maketext("system-event-log.others", scalar(@{$display_desc->{other}}) ) if scalar @{$display_desc->{other}};
      
      # Set up the text to be displayed and the tooltip in the final display text
      $tooltip_link_text = $c->maketext("system-event-log.other-objects", $tooltip_obj_text, ( scalar @{$display_desc->{for_tooltip}} + scalar @{$display_desc->{other}} ), $c->maketext("object.plural." . $event->system_event_log_type->plural_objects));
    } else {
      # Nothing to show in the tooltip, replace the text with nothing
      $tooltip_link_text = "";
    }
    
    push(@row, ucfirst($c->maketext($event->system_event_log_type->description, $display_obj_text, $tooltip_link_text)));
    
    # Now we have all the columns in our row, push on to the data array
    push(@data, \@row);
  }
  
  my $total_records = $c->model("DB::SystemEventLog")->page_records({public_only => $public_only})->count;
  my $filtered_records = ( defined($search_val) ) ? $c->model("DB::SystemEventLog")->page_records({
    public_only => $public_only,
    search_val => $search_val,
    search_ips => $c->stash->{authorisation}{user_view_ip}
  })->count : $total_records; # If there's a search value, we need a filtered count too; if there's not the filtered count IS the same as the total count
  
  # Set up the stash
  $c->stash({
    json_data => {
      draw => $draw,
      recordsTotal => $total_records,
      recordsFiltered => $filtered_records,
      data => \@data,
    },
    skip_view_online => 1,
  });
  
  # Detach to the JSON view
  $c->detach($c->view("JSON"));
}

=head2 add_event

Private sub to add events to the event log.

=cut

sub add_event :Private {
  my ( $self, $c ) = @_;
  my ( $object_type, $event_type, $object_ids, $object_name ) = @{$c->req->args};
  
  my $current_datetime = $c->datetime_tz({time_zone => "UTC"});
  
  # Set the event log
  my $details = $c->model("DB::SystemEventLog")->set_event_log({
    object_type => $object_type,
    event_type => $event_type,
    object_ids => $object_ids,
    object_name => $object_name,
    user => $c->user,
    ip_address => $c->req->address,
    current_time => $current_datetime,
    logger => sub{ my $level = shift; $c->log->$level( @_ ) },
  });
  
  return $details;
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
