package TopTable::Controller::Divisions;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Divisions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to display divisions; there is not much to display apart from options (i.e., which statistics you can view), as these are done in the LeagueTables and LeagueAverages controllers.  The creation and editing of these is done with season creation.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Set up average types
  $c->stash({subtitle1 => $c->maketext("menu.text.division")});
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/divisions"),
    label => $c->maketext("menu.text.division"),
  });
}

=head2 base

Chain base for getting the division ID and checking it.

=cut

sub base :Chained("/") PathPart("divisions") CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  my $division = $c->model("DB::Division")->find_id_or_url_key($id_or_url_key);
  
  if ( defined( $division ) ) {
    # Encode the name for future use later in the chain (saves encoding multiple times, which is expensive)
    my $enc_name = encode_entities($division->name);
    
    $c->stash({
      division => $division,
      enc_name => $enc_name,
    });
    
    # Push the list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/divisions/view_current_season", [$division->url_key]),
      label => $enc_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}


=head2 base_list

Chain base for the list of divisions.  Matches /divisions

=cut

sub base_list :Chained("/") PathPart("divisions") CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.divisions.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the divisions on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach("retrieve_paged", [1]);
  $c->stash({canonical_uri => $c->uri_for_action("/divisions/list_first_page")});
}

=head2 list_specific_page

List the divisions on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/divisions/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/divisions/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for divisions with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $divisions = $c->model("DB::Division")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $divisions->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/divisions/list_first_page",
    specific_page_action => "/divisions/list_specific_page",
    current_page => $page_number
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/divisions/list.ttkt",
    view_online_display => "Viewing divisions",
    view_online_link => 1,
    divisions => $divisions,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

View a given division's links (to tables and averages) for the current season (or last complete season if there is no current season).  This does the authentication check, then the real routine (which is different depending on current or specific season) is chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current_or_last;
  
  if ( defined($season) ) {
    $c->stash({
      season => $season,
      page_description => $c->maketext("description.divisions.view-current", $enc_name, $site_name),
      view_online_display => sprintf("Viewing %s", $division->name),
      view_online_link => 1,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect($c->uri_for("/",
                                {mid => $c->set_status_msg({error => $c->maketext("divisions.no-season")})}));
    $c->detach;
    return;
  }
  
  $c->stash({canonical_uri => $c->uri_for_action("/divisions/view_current_season", [$division->url_key])});
  
  # Finalise the view routine
  $c->forward("view_finalise");
}

=head2 view_specific_season

View a division with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $division = $c->stash->{division};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
    
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      encoded_season_name => $enc_season_name,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      view_online_display => sprintf("Viewing %s for %s", $division->name, $season->name),
      view_online_link => 1,
      page_description => $c->maketext("description.divisions.view-specific", $enc_name, $site_name, $enc_season_name),
    });
    
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/divisions/view_seasons_first_page", [$division->url_key]),
      label => $c->maketext("menu.text.season"),
    }, {
      path => $c->uri_for_action("/divisions/view_specific_season", [$division->url_key, $season->url_key]),
      label => $enc_season_name,
    });
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect($c->uri_for_action("/divisions/view_current_season", [$division->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("seasons.invalid-find-current", $season_id_or_url_key)})}));
    $c->detach;
    return;
  }
  
  # Set the canonical URI for search engines to index
  $c->stash({canonical_uri => $c->uri_for_action("/divisions/view_specific_season", [$division->url_key, $season->url_key])});
  
  # Finalise the view routine
  $c->forward("view_finalise");
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $season = $c->stash->{season};
  my $enc_name = $c->stash->{enc_name};
  my $specific_season = $c->stash->{specific_season} || 0;
  
  # If we're viewing a specific season, that name may be different.
  if ( $specific_season ) {
    my $division_season = $division->get_season($season);
    
    if ( defined($division_season) and $division_season->name ne $division->name ) {
      # The name has changed, so it needs re-encoding and a notice needs printing
      my $old_enc_name = encode_entities($division_season->name);
      
      # If the name has changed, we need to display a notice
      $c->add_status_messages({info => $c->maketext("divisions.name.changed-notice", $old_enc_name, $c->stash->{enc_name})});
      
      # Restash the encoded name
      $c->stash->{enc_name} = $old_enc_name;
    }
  }
  
  # Canonical URI
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/divisions/view_specific_season", [$division->url_key, $season->url_key])
    : $c->uri_for_action("/divisions/view_current_season", [$division->url_key]);
  
  $enc_name = $c->stash->{enc_name};
  
  # Set up the template to use
  $c->stash({
    template => "html/divisions/view.ttkt",
    subtitle1 => $enc_name,
    canonical_uri => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this division has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $site_name = $c->stash->{enc_site_name};
  my $enc_name = $c->stash->{enc_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
      template => "html/divisions/list-seasons.ttkt",
      external_scripts => [
        $c->uri_for("/static/script/standard/option-list.js"),
      ],
    });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/divisions/view_seasons_first_page", [$division->url_key]),
    label => $c->maketext("menu.text.season"),
    page_description  => $c->maketext("description.divisions.list-seasons", $enc_name, $site_name),
  });
}

=head2 view_seasons_first_page

List the divisions on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  
  $c->stash({canonical_uri => $c->uri_for_action("/divisions/view_seasons_first_page", [$division->url_key])});
  $c->detach("retrieve_paged_seasons", [1]);
}

=head2 view_seasons_specific_page

List the divisions on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $division = $c->stash->{division};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/divisions/view_seasons_first_page", [$division->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/divisions/view_seasons_specific_page", [$division->url_key, $page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for divisions with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $division = $c->stash->{division};
  
  my $seasons = $c->model("DB::Season")->page_records({
    division => $division,
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/divisions/view_seasons_first_page",
    specific_page_action => "/divisions/view_seasons_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/divisions/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $division->name ),
    view_online_link => 1,
    seasons => $seasons,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 search

Handle search requests and return the data in JSON for AJAX requests, or paginate and return in an HTML page for normal web requests (or just display a search form if no query provided).

=cut

sub search :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({
    db_resultset => "Division",
    query_params => {q => $c->req->param("q")},
    view_action => "/divisions/view_current_season",
    search_action => "/divisions/search",
    placeholder => $c->maketext( "search.form.placeholder", $c->maketext("object.plural.divisions") ),
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
