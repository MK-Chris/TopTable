package TopTable::Controller::LeagueAverages;
use Moose;
use namespace::autoclean;
use Data::Dumper::Concise;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

# Sets the actions in this controller to be registered league-averages, so the URLs start /league-averages.
__PACKAGE__->config(namespace => "league-averages");

=head1 NAME

TopTable::Controller::LeagueAverages - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to display league averages for singles, doubles pairs and doubles individuals.  This is just a display mechanism, since the statistics that are displayed here are generated when the matches are updated in the relevant controllers.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Set up average types
  $c->stash({
    subtitle1     => $c->maketext("menu.text.league-averages"),
    average_types => {
      "singles"             => $c->maketext("menu.text.league-averages-singles"),
      "doubles-individuals" => $c->maketext("menu.text.league-averages-doubles-individuals"),
      "doubles-pairs"       => $c->maketext("menu.text.league-averages-doubles-pairs"),
      "doubles-teams"       => $c->maketext("menu.text.league-averages-doubles-teams"),
    },
  });
  
  # Push the clubs list page on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/league-averages"),
    label => $c->maketext("menu.text.league-averages"),
  });
}

=head2 base

Chain base for getting the division ID or URL key and checking it.

=cut

sub base :Chained("/") :PathPart("league-averages") :CaptureArgs(1) {
  my ( $self, $c, $averages_type ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # Check that the type of averages we have is valid
  if ( exists( $c->stash->{average_types}{$averages_type} ) ) {
    $c->stash({averages_type => $averages_type});
    
    # Push the current URI on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      path  => $c->uri_for_action("/league-averages/list_first_page", [$averages_type]),
      label => $c->stash->{average_types}{$averages_type},
    });
  } else {
    # Invalid, 404
    $c->detach(qw/TopTable::Controller::Root default/);
    return;
  }
}

=head2 base_options

Display the options (different types of averages) for viewing.

=cut

sub base_options :Chained("/") :PathPart("league-averages") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  # Stash the details
  $c->stash({
    template            => "html/league-averages/view-options.ttkt",
    view_online_display => "Viewing league averages",
    view_online_link    => 1,
    page_description    => $c->maketext("description.league-averages.options", $site_name),
    external_scripts      => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_divisions

Chain base for the list of divisions.

=cut

sub list_divisions :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{encoded_site_name};
  
  $c->stash({
    page_description  => $c->maketext("description.league-averages.list-divisions", $site_name),
    external_scripts  => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the divisions on the first page.

=cut

sub list_first_page :Chained("list_divisions") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach( "retrieve_paged", [1] );
}

=head2 list_specific_page

List the divisions on the specified page.

=cut

sub list_specific_page :Chained("list_divisions") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/list_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged", [$page_number] );
}

=head2 retrieve_paged

Performs the lookups for divisions with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  my $averages_type = $c->stash->{averages_type};
  
  my $divisions = $c->model("DB::Division")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $divisions->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/league-averages/list_first_page",
    page1_action_arguments          => $averages_type,
    specific_page_action            => "/league-averages/list_specific_page",
    specific_page_action_arguments  => $averages_type,
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-averages/list-divisions.ttkt",
    view_online_display => sprintf( "Viewing League Averages (%s)", $averages_type),
    view_online_link    => 1,
    divisions           => $divisions,
    page_info           => $page_info,
    page_links          => $page_links,
  });
}

=head2 view

Perform the permissions checks for viewing a division and check that the averages type specified is valid.  The actual viewing routines (for viewing the current or a specific season) are chained from this.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(1) {
  my ( $self, $c, $division_id_or_key ) = @_;
  my $averages_type = $c->stash->{averages_type};
  my $division = $c->model("DB::Division")->find_id_or_url_key( $division_id_or_key );
  $c->detach( qw/TopTable::Controller::Root default/ ) unless defined( $division );
  
  my $encoded_division_name = encode_entities( $division->name );
  
  $c->stash({
    division              => $division,
    encoded_division_name => $encoded_division_name,
  });
  
  # Breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/league-averages/view_current_season", [$averages_type, $division->url_key]),
    label => $encoded_division_name,
  });
}

=head2 view_current_season

Chained from the view routine, this will obtain the current (or last complete, if there is no current) season.  This is the end of the chain, but detaches off to the view_finalise routine that retrieves the averges from the database for display.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
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
        division_season     => $division_season,
        page_description    => $c->maketext("description.league-averages.view-current", lc( $c->maketext( sprintf("menu.text.league-averages-%s", $averages_type) ) ), $division_name, $site_name),
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

Chained from the view routine, this will obtain the current (or last complete, if there is no current) season.  This is the end of the chain, but detaches off to the view_finalise routine that retrieves the averges from the database for display.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
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
        division_season     => $division_season,
        page_description    => $c->maketext("description.league-averages.view-specific", lc( $c->maketext( sprintf("menu.text.league-averages-%s", $averages_type) ) ), $division_name, $site_name, $encoded_season_name),
      });
      
      # Push the season list URI and the current URI on to the breadcrumbs
      push( @{ $c->stash->{breadcrumbs} }, {
        path  => $c->uri_for_action("/league-averages/view_seasons_first_page", [$averages_type, $division->url_key]),
        label => $c->maketext("menu.text.seasons"),
      }, {
        path  => $c->uri_for_action("/league-averages/view_specific_season", [$averages_type, $division->url_key, $season->url_key]),
        label => $encoded_season_name,
      });
    } else {
      # Division is not used for this season
      $c->detach( qw/TopTable::Controller::Root default/ );
    }
  } else {
    # Invalid season - the message says we are attempting to find the current season, which
    # is correct, as the redirect is to the same page, but with no season ID specified, which
    # should try and match the current season (or if there is no current season the latest season).
    $c->response->redirect( $c->uri_for_action("/league-averages/averages", [$division->url_key, $averages_type],
                                {mid => $c->set_status_msg({error => $c->maketext("seasons.invalid-find-current", $season_id_or_url_key)} ) }) );
    $c->detach;
    return;
  }
  
  # Forward to the routine that stashes the team's season
  $c->detach( "view_finalise" );
}

=head2 view_finalise

A private function that retrieves the averages we need for display for the given season, division and averages type.

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my $averages_type         = $c->stash->{averages_type};
  my $division              = $c->stash->{division};
  my $season                = $c->stash->{season};
  my $encoded_division_name = $c->stash->{encoded_division_name};
  my $encoded_season_name   = $c->stash->{encoded_season_name};
  my $config = {
    season    => $season,
    division  => $division,
  };
  
  my ( $defined_filter, $filter_id, $player_types, $custom_filter, $criteria_field, $operator, $criteria_type, $criteria, $filtered );
  unless ( exists( $c->request->parameters->{clear} ) ) {
    if ( exists( $c->request->parameters->{defined_filter} ) ) {
      # Defined filter, validate it and get the values from the database
      
      $defined_filter = 1;
      $filter_id      = $c->request->parameters->{filter_id};
      
      my $filter = $c->model("DB::AverageFilter")->find( $filter_id );
      
      if ( defined( $filter ) ) {
        $config->{player_type} = [];
        push( @{ $config->{player_type} }, "active" )   if $filter->show_active;
        push( @{ $config->{player_type} }, "loan" )     if $filter->show_loan;
        push( @{ $config->{player_type} }, "inactive" ) if $filter->show_inactive;
        $config->{criteria_field} = $filter->criteria_field;
        $config->{criteria_type}  = $filter->criteria_type;
        $config->{operator}       = $filter->operator;
        $config->{criteria}       = $filter->criteria;
        $filtered                 = 1;
      }
    } elsif ( exists( $c->request->parameters->{custom_filter} ) ) {
      # Custom filter, just get the values from the form
      $config->{player_type}    = $c->request->parameters->{player_type};
      $config->{criteria_type}  = $c->request->parameters->{criteria_type};
      $config->{criteria_field} = $c->request->parameters->{criteria_field};
      $config->{operator}       = $c->request->parameters->{operator};
      $config->{criteria}       = $c->request->parameters->{criteria};
      $custom_filter = 1;
      $player_types             = $c->request->parameters->{player_type};
      $criteria_field           = $c->request->parameters->{criteria_field};
      $criteria_type            = $c->request->parameters->{criteria_type};
      $operator                 = $c->request->parameters->{operator};
      $criteria                 = $c->request->parameters->{criteria};
      $filtered                 = 1;
      
      # Arrayref the player type if it isn't already
      $player_types = [ $player_types ] unless ref( $player_types ) eq "ARRAY";
    }
  }
  
  $config->{logger} = sub{ my $level = shift; $c->log->$level( @_ ); };
  
  if ( defined( $averages_type ) and $averages_type eq "singles" ) {
    # Singles averages
    my $singles_averages = $c->model("DB::PersonSeason")->get_people_in_division_in_singles_averages_order( $config );
    $c->stash({
      singles_averages => $singles_averages,
        singles_last_updated => $c->model("DB::PersonSeason")->get_tables_last_updated_timestamp({
        season => $season,
        division => $division,
      }),
    });
    
    # Check if we're authorised to display edit / delete links next to names
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( person_edit person_delete team_edit team_delete ) ], "", 0] );
  } elsif ( defined( $averages_type ) and $averages_type eq "doubles-individuals" ) {
    # Doubles averages (invidual)
    my $doubles_ind_averages = $c->model("DB::PersonSeason")->get_people_in_division_in_doubles_individual_averages_order( $config );
    $c->stash({
      doubles_individual_averages => $doubles_ind_averages,
      doubles_ind_last_updated => $c->model("DB::PersonSeason")->get_tables_last_updated_timestamp({
        season => $season,
        division => $division,
      }),
    });
    
    # Check if we're authorised to display edit / delete links next to names
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( person_edit person_delete team_edit team_delete ) ], "", 0] );
  } elsif ( defined( $averages_type ) and $averages_type eq "doubles-pairs" ) {
    # Doubles averages (pairs)
    my $doubles_pairs_averages = $c->model("DB::DoublesPair")->get_doubles_pairs_in_division_in_averages_order( $config );
    $c->stash({
      doubles_pair_averages => $doubles_pairs_averages,
      doubles_pairs_last_updated => $c->model("DB::DoublesPair")->get_tables_last_updated_timestamp({
        season => $season,
        division => $division,
      }),
    });
    
    # Check if we're authorised to display edit / delete links next to names
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( person_edit person_delete team_edit team_delete ) ], "", 0] );
  } elsif ( defined( $averages_type ) and $averages_type eq "doubles-teams" ) {
    # Team doubles records
    my $doubles_teams_averages = $c->model("DB::TeamSeason")->get_doubles_teams_in_division_in_averages_order( $config );
    $c->stash({
      doubles_team_averages => $doubles_teams_averages,
      doubles_teams_last_updated => $c->model("DB::TeamSeason")->get_tables_last_updated_timestamp({
        season => $season,
        division => $division,
      }),
    });
    
    # Check if we're authorised to display edit / delete links next to names
    $c->forward( "TopTable::Controller::Users", "check_authorisation", [ [ qw( team_edit team_delete ) ], "", 0] );
  }
  
  my $canonical_uri = ( $season->complete )
    ? $c->uri_for_action("/league-averages/view_specific_season", [$averages_type, $division->url_key, $season->url_key])
    : $c->uri_for_action("/league-averages/view_current_season", [$averages_type, $division->url_key]);
  
  # Stash the details
  $c->stash({
    template            => sprintf( "html/league-averages/view_%s.ttkt", $averages_type ),
    subtitle1           => $encoded_division_name,
    subtitle2           => sprintf( "%s - %s", $c->maketext("menu.text.league-averages"), $c->stash->{average_types}{ $averages_type } ),
    subtitle3           => $encoded_season_name,
    external_scripts    => [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/league-averages/filter.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      sprintf( $c->uri_for("/static/script/league-averages/view-%s.js"), $averages_type ),
    ],
    external_styles     => [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ],
    view_online_display => sprintf( "Viewing %s %s for %s", $division->name, $c->stash->{average_types}{ $averages_type }, $season->name ),
    view_online_link    => 1,
    divisions           => [ $season->divisions ],
    criteria_field      => $criteria_field,
    defined_filter      => $c->request->parameters->{defined_filter},
    custom_filter       => $custom_filter,
    player_types        => $player_types,
    operator            => $operator,
    criteria            => $criteria,
    criteria_type       => $criteria_type,
    filter_id           => $filter_id,
    filtered            => $filtered,
    defined_filters     => [ $c->model("DB::AverageFilter")->all_filters({user => $c->user}) ],
    canonical_uri       => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this division has averages to view for.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
  my $division_name = $c->stash->{encoded_division_name};
  my $site_name     = $c->stash->{encoded_site_name};
  
  # Stash the template; the data will be retrieved when we know what page we're on
  $c->stash({
    template          => "html/divisions/averages-list-seasons.ttkt",
    page_description  => $c->maketext("description.league-averages.list-seasons", $division_name, $site_name),
  });
  
  # Push the current URI on to the breadcrumbs
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for_action("/league-averages/view_seasons_first_page", [$division->url_key, $averages_type]),
    label => $c->maketext("menu.text.seasons"),
    external_scripts      => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
  
  $c->stash({canonical_uri => $c->uri_for_action("/league-averages/view_seasons_first_page", [$averages_type, $division->url_key])});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/view_seasons_first_page", [$averages_type, $division->url_key])});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/league-averages/view_seasons_specific_page", [$averages_type, $division->url_key])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $division      = $c->stash->{division};
  my $averages_type = $c->stash->{averages_type};
  
  my $seasons = $c->model("DB::Season")->page_records({
    division          => $division,
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/clubs/view_seasons_first_page",
    page1_action_arguments          => [$averages_type, $division->url_key],
    specific_page_action            => "/clubs/view_seasons_specific_page",
    specific_page_action_arguments  => [$averages_type, $division->url_key],
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/league-averages/list-seasons.ttkt",
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
