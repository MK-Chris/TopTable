package TopTable::Controller::Info::Officials;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use DDP;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Info::Officials - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.title.officials") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    # Clubs listing
    path => $c->uri_for("/info/officials"),
    label => $c->maketext("menu.text.officials"),
  });
}

=head2 base

Start of a chain for viewing the officials for a given season - does nothing else but provide the start of the chain and check authorisation.

=cut

sub base :Chained("/") :PathPart("info/officials") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_view", $c->maketext("user.auth.view-officials"), 1]);
  
  # Check the authorisation to edit clubs we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw(committee_create committee_edit committee_delete person_edit person_delete) ], "", 0]);
}

=head2 view_current_season

View the current season's league officials (or the last completed season if there is no current season).

=cut

sub view_current_season :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Get and stash the current season
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined($season);
  
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw(committee_edit) ], "", 0]);
  
  # Set up the title links if we need them - we only want this when viewing the current season, so check it here
  my @title_links = ();
  
  # Push edit link if we are authorised and the season is not yet complete
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.reorder-officials"),
    link_uri => $c->uri_for("/info/officials/reorder"),
  }) if $c->stash->{authorisation}{committee_edit} and !$season->complete;
  
  if ( defined($season) ) {
    $c->stash({
      season => $season,
      page_description => $c->maketext("description.officials.view-current", $site_name),
      title_links => \@title_links,
      season_type => "current", # Set this even if this is the 'last complete' season, as we still want to show the contact details in that case
    });
    
    $c->detach("view_finalise");
  } else {
    # 404 - no seasons
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 view_specific_season

Load and view the specified season's officials.

=cut

sub view_specific_season :Chained("base") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
  
  if ( defined( $season ) ) {
    my $enc_season_name = encode_entities($season->name);
    
    # Stash whether this is the previous or current season so we can choose the right JS file
    my $season_type = $season->complete ? "previous" : "current";
    
    $c->stash({
      season => $season,
      specific_season => 1,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.officials.view-specific", $site_name, $enc_season_name),
      season_type => $season_type,
    });
  
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/info/officials/view_seasons"),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/info/officials/view_specific_season", [$season->url_key]),
      label => $enc_season_name,
    });
    
    $c->detach("view_finalise");
  } else {
    # 404 - no seasons
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 view_finalise

Finalise the officials view

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $season = $c->stash->{season};
  
  $c->stash({
    template => "html/info/officials/view.ttkt",
    subtitle1 => $c->maketext("menu.text.officials"),
    subtitle2 => encode_entities($season->name),
    officials => scalar $c->model("DB::Official")->all_officials_in_season($season),
    external_scripts => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/info/officials/view.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
    ],
  });
}

=head2 view_seasons

View a list of seasons that you can view the officials for.

=cut

sub view_seasons :Chained("base") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Set up the template to use
  $c->stash({
    template => "html/info/officials/list-seasons.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    view_online_display => "Viewing league officials",
    view_online_link => 1,
    seasons => scalar $c->model("DB::Season")->all_seasons,
    subtitle1 => $c->maketext("menu.title.officials"),
    subtitle2 => $c->maketext("menu.text.season"),
    page_description => $c->maketext("description.officials.list-seasons", $site_name),
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/info/officials/view_seasons"),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 reorder

Edit the display order for the list of committee members for the current season; if there is no current season, an error is thrown.

=cut

sub reorder :Path("reorder") {
  my ( $self, $c ) = @_;
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_edit", $c->maketext("user.auth.edit-officials"), 1]);
  
  # Get the current season, so we know which teams and divisions we have.
  my $current_season = $c->model("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.reorder.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  my $officials = $c->model("DB::Official")->all_officials_in_season($current_season);
  
  if ( $officials->count == 0 ) {
    # No officials yet
    $c->response->redirect($c->uri_for("/info/officials",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.reorder.error.no-officials-in-current-season")})}));
    $c->detach;
    return;
  }
  
  $c->stash({
    template => "html/info/officials/reorder.ttkt",
    subtitle1 => $c->maketext("menu.title.officials"),
    subtitle2 => $c->maketext("admin.reorder"),
    external_scripts => [
      $c->uri_for("/static/script/info/officials/reorder.js"),
    ],
    form_action => $c->uri_for_action("/info/officials/do_reorder"),
    view_online_display => "Reordering league officials",
    view_online_link => 0,
    officials => $officials,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/info/officials/reorder"),
    label => $c->maketext("admin.reorder"),
  });
}

=head2 do_reorder

Process the reorder form to set team orders.

=cut

sub do_reorder  :Path("do-reorder") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_edit", $c->maketext("user.auth.edit-officials"), 1]);
  
  my $response = $c->model("DB::Official")->reorder({official_positions => [split(",", $c->req->params->{official_positions})]});
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  # Now actually do the redirection
  $c->response->redirect($c->uri_for("/info/officials", {mid => $mid}));
  $c->detach;
  return;
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
