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
  
  # Load the messages
  $c->load_status_msgs;
  
  # Set up average types
  $c->stash({subtitle1 => $c->maketext("menu.text.league-tables")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/league-tables"),
    label => $c->maketext("menu.text.league-tables"),
  });
}

=head2 base

Chain base for getting the division ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("league-tables") :CaptureArgs(1) {
  my ( $self, $c, $id_or_url_key ) = @_;
  
  my $division = $c->model("DB::Division")->find_id_or_url_key( $id_or_url_key );
  
  if ( defined( $division ) ) {
    my $encoded_division_name = encode_entities( $division->name );
    
    $c->stash({
      division => $division,
      encoded_division_name => $encoded_division_name,
    });
    
    # Push the divisions list page and this division on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path => $c->uri_for_action("/league-tables/view_current_season", [$division->url_key]),
      label => $encoded_division_name,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_list

Chain base for the list of divisions.  Matches /league-tables

=cut

sub base_list :Chained("/") :PathPart("league-tables") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  $c->stash({
    page_description => $c->maketext("description.league-tables.list-divisions", $site_name),
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
  
  $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_first_page")});
  $c->detach("retrieve_paged", [1]);
}

=head2 list_specific_page

List the clubs on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined($page_number) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-tables/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for clubs with the given page number.

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
    page1_action => "/league-tables/list_first_page",
    specific_page_action => "/league-tables/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/tables/list.ttkt",
    view_online_display => "Viewing League Tables",
    view_online_link => 1,
    divisions => $divisions,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view

Perform the permissions checks for viewing a division.  The actual viewing routines (for viewing the current or a specific season) are chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {}


=head2 view_current_season

View a division with the current (or last, if there is no current) season's details.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name = $c->stash->{enc_site_name};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current_or_last;
    
  if ( defined($season) ) {
    my $division_season = $division->get_season($season);
    
    if ( defined($division_season) ) {
      my $encoded_season_name = encode_entities($season->name);
      
      $c->stash({
        season => $season,
        division_season => $division_season,
        encoded_season_name => $encoded_season_name,
        page_description => $c->maketext("description.league-tables.view-current", $division_name, $site_name),
      });
    } else {
      # Division is not used for this season
      $c->detach(qw(TopTable::Controller::Root default));
    }
  } else {
    # No seasons to display
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Forward to the routine that stashes the team's season
  $c->detach("view_finalise");
}

=head2 view_specific_season

View a division with a specified season

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $division = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name = $c->stash->{enc_site_name};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined($season) ) {
    my $division_season = $division->get_season($season);
    
    if ( defined($division_season) ) {
      my $encoded_season_name = encode_entities($season->name);
      
      $c->stash({
        season => $season,
        division_season => $division_season,
        encoded_season_name => $encoded_season_name,
        specific_season => 1,
        page_description => $c->maketext("description.league-tables.view-specific", $division_name, $site_name, $encoded_season_name),
      });
      
      # Push the current URI on to the breadcrumbs
      push(@{$c->stash->{breadcrumbs}}, {
        path => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key]),
        label => $c->maketext("menu.text.season"),
      }, {
        path => $c->uri_for_action("/league-tables/view_specific_season", [$division->url_key, $season->url_key]),
        label => $encoded_season_name,
      });
      
      # Forward to the routine that stashes the team's season
      $c->detach("view_finalise");
    } else {
      # Division is not used for this season
      $c->detach(qw(TopTable::Controller::Root default));
    }
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 view_finalise

A private function that retrieves the tables we need for display for the given season and division.

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $season = $c->stash->{season};
  my $division_season = $c->stash->{division_season};
  my $encoded_division_name = $c->stash->{encoded_division_name};
  my $encoded_season_name = $c->stash->{encoded_season_name};
  
  # See if we are authorised to edit / delete so we can display the relevant links
  $c->forward("TopTable::Controller::Users", "check_authorisation", [ [ qw( team_edit team_delete ) ], "", 0]);
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("league-tables/view_specific_season", [$division->url_key, $season->url_key])
    : $c->uri_for_action("league-tables/view_current_season", [$division->url_key]);
  
  # Get the ranking template for the table - we need this before we stash because one of the scripts depends
  # on whether or not we're assigning points (as there's an extra column if we are)
  my $ranking_template = $division_season->league_table_ranking_template;
  my $match_template = $division_season->league_match_template;
  
  # Base JS name - add to it based on whether we have points or not / handicaps or not
  my $table_view_js = "view";
  $table_view_js .= "-points" if $ranking_template->assign_points;
  $table_view_js .= "-hcp" if $match_template->handicapped;
  $table_view_js = $c->uri_for("/static/script/tables/$table_view_js.js", {v => 3});
  
  my @ext_scripts = (
    $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
    $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
    $table_view_js,
  );
  
  my @ext_styles = (
    $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
    $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
  );
  
  my $points_adjustments = $division_season->points_adjustments;
  
  if ( $points_adjustments->count ) {
    push(@ext_scripts,
      $c->uri_for("/static/script/plugins/datatables/dataTables.rowGroup.min.js"),
      $c->uri_for("/static/script/tables/points-adjustments.js")
    );
    
    push(@ext_styles, $c->uri_for("/static/css/datatables/rowGroup.dataTables.min.css"));
  }
  
  # Stash the common details
  $c->stash({
    template => "html/tables/view.ttkt",
    subtitle1 => $c->maketext("stats.table-title.division", $encoded_division_name),
    subtitle2 => $encoded_season_name,
    divisions => [$season->divisions],
    view_online_display => sprintf("Viewing %s table for %s", $division->name, $season->name),
    view_online_link => 1,
    entrants => [$division_season->league_table],
    last_updated => $division_season->table_last_updated,
    table_complete => $division_season->table_complete,
    points_adjustments => $points_adjustments,
    ranking_template => $ranking_template,
    match_template => $match_template,
    canonical_uri => $canonical_uri,
    external_scripts => \@ext_scripts,
    external_styles => \@ext_styles,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this club has entered teams into.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name = $c->stash->{enc_site_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template => "html/clubs/list-seasons.ttkt",
    page_description => $c->maketext("description.league-tables.list-seasons", $division_name, $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key]),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division = $c->stash->{division};
  
  $c->stash({canonical_uri => $c->uri_for_action("/league-tables/view_seasons_first_page", [$division->url_key])});
  $c->detach("retrieve_paged_seasons", [1]);
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
  
  $c->detach("retrieve_paged_seasons", [$page_number]);
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $division = $c->stash->{division};
  
  my $seasons = $c->model("DB::Season")->page_records({
    club => $division,
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $seasons->pager;
  my $page_links = $c->forward("TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/league-tables/view_seasons_first_page",
    page1_action_arguments => [$division->url_key],
    specific_page_action => "/league-tables/view_seasons_specific_page",
    specific_page_action_arguments => [$division->url_key],
    current_page => $page_number,
  }]);
  
  # Set up the template to use
  $c->stash({
    template => "html/tables/list-seasons.ttkt",
    view_online_display => sprintf( "Viewing seasons for ", $division->name ),
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
