package TopTable::Controller::Reports;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Catalyst Controller for reports.

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
  $c->stash({subtitle1 => $c->maketext("menu.text.report")});
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    # Clubs listing
    path => $c->uri_for("/reports"),
    label => $c->maketext("menu.text.report"),
  });
}


=head2 base

Chain base for getting the report ID and checking it.

=cut

sub base :Chained("/") :PathPart("reports") :CaptureArgs(1) {
  my ( $self, $c, $report_id ) = @_;
  my @reports = qw( loan-players rearranged-matches cancelled-matches missing-players );
  
  if ( grep( $_ eq $report_id, @reports ) ) {
    # Report ID is in the list, stash it and continue
    my $report_name = $c->maketext(sprintf("reports.name.%s", $report_id));
    
    $c->stash({
      report_id => $report_id,
      report_name => $report_name,
    });
    
    # Push the people list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Club view page (current season)
      path => $c->uri_for_action("/reports/view_current_season", [$report_id]),
      label => $report_name,
    });
  } else {
    # 404
    $c->detach(qw( TopTable::Controller::Root default ));
    return;
  }
}

=head2 base_list

Chain base for the list of reports.  Matches /reports

=cut

sub base_list :Chained("/") :PathPart("reports") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check the authorisation required to view the necessary reports.
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( person_view team_view ) ], "", 0]);
  
  # Page description
  $c->stash({
    template => "html/reports/list.ttkt",
    page_description => $c->maketext("description.reports.list"),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 view

Check our permissions for this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $report_name = $c->stash->{report_name};
  
  # Check that we are authorised to view teams
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["team_view", $c->maketext("user.auth.view-teams"), 1]);
  
  $c->stash({subtitle1  => $report_name});
}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the report view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name   = $c->stash->{enc_site_name};
  my $report_name = $c->stash->{encoded_display_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season if !defined($season); # No current season season, try and find the last season.
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      encoded_season_name => $enc_season_name,
      page_description => $c->maketext("description.reports.view-current", $report_name, $site_name),
    });
  }
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 view_specific_season

View a team with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $report_name = $c->stash->{encoded_display_name};
  my $report_id = $c->stash->{report_id};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined( $season ) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.reports.view-specific", $report_name, $enc_season_name, $site_name),
    });
  } else {
    # Invalid season
    $c->detach( /TopTable::Controller::Root default/ );
  }
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/reports/view_seasons_first_page", [$report_id]),
    label => $c->maketext("menu.text.season"),
  }, {
    path => $c->uri_for_action("/reports/view_specific_season", [$report_id, $season->url_key]),
    label => $season->name,
  });
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $report_id = $c->stash->{report_id};
  my $season  = $c->stash->{season};
  my $report_name = $c->stash->{report_name};
  
  # Get the list of seasons they have played in
  my $report_data;
  if ( $report_id eq "loan-players" ) {
    $report_data = $c->model("DB::TeamMatchPlayer")->loan_players({season => $season});
  } elsif ( $report_id eq "rearranged-matches" ) {
    $report_data = $season->league_matches({mode => "rearranged", prefetch => 1});
  } elsif ( $report_id eq "cancelled-matches" ) {
    $report_data = $season->league_matches({mode => "cancelled", prefetch => 1});
  } elsif ( $report_id eq "missing-players" ) {
    $report_data = $season->league_matches({mode => "missing-players", prefetch => 1});
  }
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("/reports/view_specific_season", [$report_id, $season->url_key])
    : $c->uri_for_action("/reports/view_current_season", [$report_id]);
  
  # Set up the template to use
  $c->stash({
    template => sprintf("html/reports/%s.ttkt", $report_id),
    external_scripts => [
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.colReorder.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for(sprintf("/static/script/reports/%s.js", $report_id), {v => 3}),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/colReorder.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    view_online_display => sprintf("Viewing %s", $report_name),
    view_online_link => 1,
    report_data => $report_data,
    canonical_uri => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $report_id = $c->stash->{report_id};
  my $site_name = $c->stash->{enc_site_name};
  my $report_name = $c->stash->{encoded_report_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template => "html/reports/list-seasons.ttkt",
    page_description => $c->maketext("description.reports.list-seasons", $report_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/reports/view_seasons_first_page", [$report_id]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the seasons on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $report_id   = $c->stash->{report_id};
  
  $c->stash({canonical_uri => $c->uri_for_action("/reports/view_seasons_first_page", [$report_id])});
  $c->detach("retrieve_paged_seasons", [1]);
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $report_id = $c->stash->{report_id};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/reports/view_seasons_first_page", [$report_id])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/reports/view_seasons_specific_page", [$report_id, $page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $report_id = $c->stash->{report_id};
  my $report_name = $c->stash->{encoded_report_name};
  
  my $seasons = $c->model("DB::Season")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/reports/view_seasons_first_page",
    page1_action_arguments => [$report_id],
    specific_page_action => "/people/view_seasons_specific_page",
    specific_page_action_arguments => [$report_id],
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/reports/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $report_name ),
    view_online_link => 1,
    seasons => $seasons,
    page_info => $page_info,
    page_links => $page_links,
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
