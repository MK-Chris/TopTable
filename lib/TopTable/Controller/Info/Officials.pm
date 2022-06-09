package TopTable::Controller::Info::Officials;
use Moose;
use namespace::autoclean;
use HTML::Entities;

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
    path  => $c->uri_for("/info/officials"),
    label => $c->maketext("menu.text.committee"),
  });
}

=head2 base

Start of a chain for viewing the officials for a given season - does nothing else but provide the start of the chain and check authorisation.

=cut

sub base :Chained("/") :PathPart("info/officials") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["committee_view", $c->maketext("user.auth.view-officials"), 1] );
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
  
  if ( defined( $season ) ) {
    $c->stash({
      season            => $season,
      page_description  => $c->maketext("description.officials.view-current", $site_name),
    });
    
    $c->detach( "view_finalise" );
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
  
  my $season = $c->model("DB::Season")->find_id_or_url_key( $season_id_or_url_key );
  
  if ( defined( $season ) ) {
    my $encoded_season_name = encode_entities( $season->name );
    
    $c->stash({
      season              => $season,
      specific_season     => 1,
      encoded_season_name => $encoded_season_name,
      page_description    => $c->maketext("description.officials.view-specific", $site_name, $encoded_season_name),
    });
  
    # Push the season list URI and the current URI on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      path  => $c->uri_for_action("/info/officials/view_seasons_first_page"),
      label => $c->maketext("menu.text.season"),
    }, {
      path  => $c->uri_for_action("/info/officials/view_specific_season", [$season->url_key]),
      label => encode_entities( $season->name ),
    });
    
    $c->detach( "view_finalise" );
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
    template  => "html/info/officials/view.ttkt",
    subtitle1 => $c->maketext("menu.title.officials"),
    subtitle2 => encode_entities( $season->name ),
    officials => [ $c->model("DB::Official")->all_officials_in_season( $season ) ],
  });
}

=head2 view_seasons

View a list of seasons that you can view the officials for.

=cut

sub view_seasons :Chained("base") :PathPart("seasons") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path  => $c->uri_for_action("/info/officials/view_seasons_first_page"),
    label => $c->maketext("menu.text.season"),
  });
}

=head2 view_seasons_first_page

List the clubs on the first page.

=cut

sub view_seasons_first_page :Chained("view_seasons") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({canonical_uri => $c->uri_for_action("/info/officials/view_seasons_first_page")});
  $c->detach( "retrieve_paged_seasons", [1] );
}

=head2 view_seasons_specific_page

List the clubs on the specified page.

=cut

sub view_seasons_specific_page :Chained("view_seasons") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/info/officials/view_seasons_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/info/officials/view_seasons_specific_page", [$page_number])});
  }
  
  $c->detach( "retrieve_paged_seasons", [$page_number] );
}

=head2 retrieve_paged_seasons

Performs the lookups for clubs with the given page number.

=cut

sub retrieve_paged_seasons :Private {
  my ( $self, $c, $page_number ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  my $seasons = $c->model("DB::Season")->page_records({
    page_number       => $page_number,
    results_per_page  => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info   = $seasons->pager;
  my $page_links  = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info                       => $page_info,
    page1_action                    => "/info/officials/view_seasons_first_page",
    specific_page_action            => "/info/officials/view_seasons_specific_page",
    current_page                    => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template            => "html/info/officials/list-seasons.ttkt",
    view_online_display => "Viewing league officials",
    view_online_link    => 1,
    seasons             => $seasons,
    subtitle1           => $c->maketext("menu.title.officials"),
    subtitle2           => $c->maketext("menu.text.season"),
    page_info           => $page_info,
    page_links          => $page_links,
    page_description    => $c->maketext("description.officials.list-seasons", $site_name),
  });
}

=head2 edit

Edit the list of officials for the current season (if there is no current season, an error will be thrown).

=cut

sub edit :Local {
  my ( $self ) = @_;
  
  
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
