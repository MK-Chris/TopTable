package TopTable::Controller::LeagueTables;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered league-tables, so the URLs start /league-tables.
__PACKAGE__->config(namespace => "league-tables");

=head1 NAME

TopTable::Controller::LeagueTables - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to display league tables.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Set up average types
  $c->stash({subtitle1 => $c->maketext("menu.text.league-tables")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    # Divisions listing
    path  => $c->uri_for("/league-tables"),
    label => $c->maketext("menu.text.league-tables"),
  });
}

=head2 base

Chain base for getting the division ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("league-tables") :CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  my $division = $c->model("DB::Division")->find_id_or_url_key( $id_or_url_key );
  
  if ( defined( $division ) ) {
    my $encoded_division_name = encode_entities( $division->name );
    
    $c->stash({
      division              => $division,
      encoded_division_name => $encoded_division_name,
    });
    
    # Push the divisions list page and this division on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      # Table view page (current season)
      path  => $c->uri_for_action("/league-tables/view_current_season", [$division->url_key]),
      label => $encoded_division_name,
    });
  } else {
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}

=head2 base_list

Chain base for the list of divisions.  Matches /league-tables

=cut

sub base_list :Chained("/") :PathPart("league-tables") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  $c->stash({page_description => $c->maketext("description.league-tables.list-divisions", $site_name)});
  
  # Load the messages
  $c->load_status_msgs;
}

=head2 list_first_page

List the divisions on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->detach( "retrieve_paged", [1] );
  $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_first_page")});
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $divisions = $c->model("DB::Division")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $divisions->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info             => $page_info,
    page1_action          => "/league-tables/list_first_page",
    specific_page_action  => "/league-tables/list_specific_page",
    current_page          => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-tables/list.ttkt",
    view_online_display => "Viewing League Tables",
    view_online_link    => 1,
    divisions           => $divisions,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

Perform the permissions checks for viewing a division.  The actual viewing routines (for viewing the current or a specific season) are chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
}


=head2 view_current_season

View a division with the current (or last, if there is no current) season's details.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name     = $c->stash->{encoded_site_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season unless defined( $season ); # No current season season, try and find the last season.
    
  if ( defined( $season ) ) {
    my $division_season = $division->get_season( $season );
    
    if ( defined( $division_season ) ) {
      my $encoded_season_name = encode_entities( $season->name );
      
      $c->stash({
        season              => $season,
        encoded_season_name => $encoded_season_name,
        page_description    => $c->maketext("description.league-tables.view-current", $division_name, $site_name),
      });
    } else {
      # Division is not used for this season
      $c->detach( qw/TopTable::Controller::Root default/ );
    }
  } else {
    # No seasons to display
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
  
  # Forward to the routine that stashes the team's season
  $c->detach( "view_finalise" );
}

=head2 view_specific_season

View a division with a specified season

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $division = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name     = $c->stash->{encoded_site_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key );
    
  if ( defined( $season ) ) {
    my $division_season = $division->get_season( $season );
    
    if ( defined( $division_season ) ) {
      my $encoded_season_name = encode_entities( $season->name );
      
      $c->stash({
        season              => $season,
        encoded_season_name => $encoded_season_name,
        specific_season     => 1,
        page_description    => $c->maketext("description.league-tables.view-specific", $division_name, $site_name, $encoded_season_name),
      });
      
      # Push the current URI on to the breadcrumbs
      push( @{ $c->stash->{breadcrumbs} }, {
        path  => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key]),
        label => $c->maketext("menu.text.seasons"),
      }, {
        path  => $c->uri_for_action("/league-tables/view_specific_season", [$division->url_key, $season->url_key]),
        label => $encoded_season_name,
      });
      
      # Forward to the routine that stashes the team's season
      $c->detach( "view_finalise" );
    } else {
      # Division is not used for this season
      $c->detach( qw/TopTable::Controller::Root default/ );
    }
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/league-tables/view_current_season", [$division->url_key],
                                {mid => $c->set_status_msg( {error => "The season identifier $season_id_or_url_key is invalid; attempting to find the current season (or if unavailable, the latest season this team played in) instead."} ) }) );
    $c->detach;
    return;
  }
}

=head2 view_finalise

A private function that retrieves the averages we need for display for the given season, division and averages type.

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $division              = $c->stash->{division};
  my $season                = $c->stash->{season};
  my $encoded_division_name = $c->stash->{encoded_division_name};
  my $encoded_season_name   = $c->stash->{encoded_season_name};
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("league-tables/view_specific_season", [$division->url_key, $season->url_key])
    : $c->uri_for_action("league-tables/view_current_season", [$division->url_key]);
  
  # Stash the common details
  $c->stash({
    template            => "html/league-tables/view.ttkt",
    subtitle2           => $encoded_division_name,
    subtitle3           => $encoded_season_name,
    divisions           => [ $season->divisions ],
    view_online_display => sprintf( "Viewing %s league tables for %s", $division->name, $season->name ),
    view_online_link    => 1,
    tables              => [ $c->model("DB::TeamSeason")->get_teams_in_division_in_league_table_order( $season, $division ) ],
    canonical_uri       => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $division      = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name     = $c->stash->{encoded_site_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template          => "html/clubs/list-seasons.ttkt",
    page_description  => $c->maketext("description.league-tables.list-seasons", $division_name, $site_name),
  });
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key]),
    label => $c->maketext("menu.text.seasons"),
  });
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  
  $c->stash({canonical_uri => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key])});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $division = $c->stash->{division};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/view_seasons_specific_page", [$division->url_key])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $division = $c->stash->{division};
  
  my $seasons = $c->model("DB::Season")->page_records({
    club              => $division,
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/league-tables/view_seasons_first_page",
    page1_action_arguments          => [$division->url_key],
    specific_page_action            => "/league-tables/view_seasons_specific_page",
    specific_page_action_arguments  => [$division->url_key],
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-tables/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $division->name ),
    view_online_link    => 1,
    seasons             => $seasons,
    page_info           => $page_info,
    page_links          => $page_links,
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
