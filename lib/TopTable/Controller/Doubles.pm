package TopTable::Controller::Doubles;
use Moose;
use namespace::autoclean;
use HTML::Entities;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Doubles - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

Performed by all methods in this controller.  Load the status messages and stash a subtitle

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.doubles")});
   
  # Breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/doubles"),
    label => $c->maketext("menu.text.doubles"),
  });
}

=head2 base

Chain base for getting two people (a person ID or URL key in any order) and finding them.

=cut

sub base :Chained("/") PathPart("doubles") CaptureArgs(2) {
  my ( $self, $c, @ids ) = @_;
  my $pairs = $c->model("DB::DoublesPair")->find_pair({people => \@ids});
  
  if ( $pairs->count ) {
    # Encode our names and stash them
    my $pair = $pairs->first;
    
    my @enc_first_names = (encode_entities($pair->person_season_person1_season_team->first_name), encode_entities($pair->person_season_person2_season_team->first_name));
    my @enc_surnames = (encode_entities($pair->person_season_person1_season_team->surname), encode_entities($pair->person_season_person2_season_team->surname));
    my @enc_display_names = (sprintf("%s %s", $enc_first_names[0], $enc_surnames[0]), sprintf("%s %s", $enc_first_names[1], $enc_surnames[1]));
    
    my %enc_names = (
      first_names => \@enc_first_names,
      surnames => \@enc_first_names,
      display_names => \@enc_display_names,
      pair_display_names => $c->maketext("doubles.pair.display_names", $enc_display_names[0], $enc_display_names[1]),
      pair_sort_names => $c->maketext("doubles.pair.sort_names", $enc_surnames[0], $enc_first_names[0], $enc_surnames[1], $enc_first_names[1]),
    );
    
    $c->stash({
      pairs => $pairs,
      pair => $pair, # First record in the resultset
      people => [$pair->person_season_person1_season_team->person, $pair->person_season_person2_season_team->person],
      enc_names => \%enc_names,
    });
    
    $c->stash->{noindex} = 1 if $pairs->noindex_set;
    
    # Push the people list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/doubles/view_current_season", $pair->url_keys),
      label => $enc_names{pair_display_names},
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 view

View a person's details.

=cut

sub view :Chained("base") :PathPart("") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to view people
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["person_view", $c->maketext("user.auth.view-people"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( person_edit )], "", 0]);
}

=head2

Get and stash the current season (or last complete one if it doesn't exist) for the team view page.

=cut

sub view_current_season :Chained("view") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  my $pairs = $c->stash->{pairs};
  
  # No season ID, try to find the current season
  my $season = $c->model("DB::Season")->get_current;
  $season = $c->model("DB::Season")->last_complete_season if !defined($season); # No current season season, try and find the last season.
  
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    my %enc_names = %{$c->stash->{enc_names}};
    
    $c->stash({
      season => $season,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.doubles.view-current", $enc_names{display_names}[0], $enc_names{display_names}[1], $site_name),
    });
    
    # Forward to the routine that stashes the person's season
    $c->forward("get_season");
  }
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 view_specific_season

View a team with a specific season's details.

=cut

sub view_specific_season :Chained("view") :PathPart("seasons") :Args(1) {
  my ( $self, $c, $season_id_or_url_key ) = @_;
  my $pairs = $c->stash->{pairs};
  my $site_name = $c->stash->{enc_site_name};
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  my %enc_names = %{$c->stash->{enc_names}};
  
  my $season = $c->model("DB::Season")->find_id_or_url_key($season_id_or_url_key);
    
  if ( defined($season) ) {
    my $enc_season_name = encode_entities($season->name);
    
    $c->stash({
      season => $season,
      specific_season => 1,
      subtitle2 => $enc_season_name,
      enc_season_name => $enc_season_name,
      page_description => $c->maketext("description.doubles.view-specific", $enc_names{display_names}[0], $enc_names{display_names}[1], $enc_season_name, $site_name),
    });
  } else {
    # Invalid season
    $c->detach(qw(TopTable::Controller::Root default));
  }
  
  # Forward to the routine that stashes the team's season
  $c->forward("get_season");
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/doubles/view_seasons", [$person1->url_key, $person2->url_key]),
    label => $c->maketext("menu.text.season"),
  }, {
    path => $c->uri_for_action("/people/view_specific_season", [$person1->url_key, $person2->url_key, $season->url_key]),
    label => $season->name,
  });
  
  # Finalise the view routine
  $c->detach("view_finalise");
}

=head2 get_season

Obtain a doubles's pair's details for a given season.

=cut

sub get_season :Private {
  my ( $self, $c ) = @_;
  my ( $pairs, $season, $enc_names ) = ( $c->stash->{pairs}, $c->stash->{season}, $c->stash->{enc_names} );
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  
  my $season_pairs = $pairs->get_season({season => $season});
  my $pair = $season_pairs->first;
  
  # Grab the games
  my $games = $season_pairs->get_games({season => $season});
  
  if ( !exists($c->stash->{noindex}) or !$c->stash->{noindex} ) {
    # If this pair isn't set to 'noindex', check if any of the people they've played in this season are - no point in doing this expensive query if the pair is already
    # set to noindex
    my $noindex = $games->noindex_set(1)->count;
    $c->stash->{noindex} = 1 if $noindex;
  }
  
  my $enc_season_name = encode_entities($season->name);
  
  # Overwrite display names with the current season
  my @enc_first_names = (encode_entities($pair->person_season_person1_season_team->first_name), encode_entities($pair->person_season_person2_season_team->first_name));
  my @enc_surnames = (encode_entities($pair->person_season_person1_season_team->surname), encode_entities($pair->person_season_person2_season_team->surname));
  my @enc_display_names = (sprintf("%s %s", $enc_first_names[0], $enc_surnames[0]), sprintf("%s %s", $enc_first_names[1], $enc_surnames[1]));
  
  my %enc_names = (
    first_names => \@enc_first_names,
    surnames => \@enc_first_names,
    display_names => \@enc_display_names,
    pair_display_names => $c->maketext("doubles.pair.display_names", $enc_display_names[0], $enc_display_names[1]),
    pair_sort_names => $c->maketext("doubles.pair.sort_names", $enc_surnames[0], $enc_first_names[0], $enc_surnames[1], $enc_first_names[1]),
  );
  
  # Add info messages if names have changed
  $c->add_status_messages({info => $c->maketext("people.name.changed-notice", $enc_names{display_names}[0], encode_entities($person1->display_name))}) if $person1->display_name ne $pair->person_season_person1_season_team->display_name;
  $c->add_status_messages({info => $c->maketext("people.name.changed-notice", $enc_names{display_names}[1], encode_entities($person2->display_name))}) if $person2->display_name ne $pair->person_season_person2_season_team->display_name;
  
  $c->stash->{subtitle1} = $enc_names{pair_display_names};
  
  $c->stash({
    season => $season,
    season_pairs => $season_pairs,
    games => $games,
    pair => $pair,
  });
}

=head2 view_finalise

Finalise the view routine, whether we were given a season or not

=cut

sub view_finalise :Private {
  my ( $self, $c ) = @_;
  my ( $pairs, $pair, $season, $enc_names ) = ( $c->stash->{pairs}, $c->stash->{pair}, $c->stash->{season}, $c->stash->{enc_names} );
  my ( $person1, $person2 ) = @{$c->stash->{people}};
  my $enc_display_name = $enc_names->{pair_display_names};
  
  # Get the list of seasons they have played in
  my $pair_seasons = $pairs->get_all_seasons;
  
  my $canonical_uri = $season->complete
    ? $c->uri_for_action("/doubles/view_specific_season", [$person1->url_key, $person2->url_key, $season->url_key])
    : $c->uri_for_action("/doubles/view_current_season", [$person1->url_key, $person2->url_key]);
  
  # Set up the template to use
  $c->stash({
    template => "html/doubles/view.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/responsive-tabs/jquery.responsiveTabs.mod.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedColumns.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.select.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.searchPanes.min.js"),
      $c->uri_for("/static/script/doubles/view.js"),
      $c->uri_for("/static/script/standard/option-list.js"),
      $c->uri_for("/static/script/standard/vertical-table.js"),
    ],
      external_styles => [
      $c->uri_for("/static/css/responsive-tabs/responsive-tabs.css"),
      $c->uri_for("/static/css/responsive-tabs/style-jqueryui.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedColumns.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/select.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/searchPanes.dataTables.min.css"),
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    ],
    view_online_display => sprintf("Viewing %s", $enc_display_name),
    view_online_link => 1,
    pair_seasons => $pair_seasons,
    seasons => $pair_seasons->count,
    canonical_uri => $canonical_uri,
  });
}

=head2 view_seasons

Retrieve and display a list of seasons that this doubles pair has played together in.

=cut

sub view_seasons :Chained("view") :PathPart("seasons") :Args(0) {
  my ( $self, $c ) = @_;
  my ( $pairs, $pair, $season, $enc_names, $site_name ) = ( $c->stash->{pairs}, $c->stash->{pair}, $c->stash->{season}, $c->stash->{enc_names}, $c->stash->{enc_site_name} );
  my $seasons = $pairs->get_all_seasons;
  
  # See if we have a count or not
  my ( $ext_scripts, $ext_styles );
  if ( $seasons->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/doubles/seasons.js"),
    ];
    $ext_styles = [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/dataTables.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ];
  } else {
    $ext_scripts = [$c->uri_for("/static/script/standard/option-list.js")];
    $ext_styles = [];
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/doubles/list-seasons-table.ttkt",
    subtitle2 => $c->maketext("menu.text.season"),
    page_description => $c->maketext("description.doubles.list-seasons", $enc_names->{display_names}[0], $enc_names->{display_names}[1], $site_name),
    view_online_display => sprintf("Viewing seasons for %s", $enc_names->{pair_display_names}),
    view_online_link => 1,
    seasons => $seasons,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
  });
  
  # Push the current URI on to the breadcrumbs
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/doubles/view_seasons", $pair->url_keys),
    label => $c->maketext("menu.text.season"),
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
