package TopTable::Schema::ResultSet::TemplateMatchTeam;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 all_templates

Retrieve all templates in name order

=cut

sub all_templates {
  my $class = shift;
  
  return $class->search({}, {
    order_by => {-asc => qw( name )},
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my $class = shift;
  my ( $params ) = @_;
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $season = delete $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = delete $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my $where;
  if ( $split_words ) {
    my @words = split(/\s+/, $q);
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push(@constructed_like, $constructed_like);
    }
    
    $where = [{name => \@constructed_like}];
  } else {
    # Don't split words up before performing a like
    $where = {name => {-like => "%$q%"}};
  }
  
  my $attrib = {
    order_by => {-asc => [qw( name )]},
    group_by => [qw( name )],
  };
  
  my $use_paging = defined($page) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  return $class->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of clubs.

=cut

sub page_records {
  my $class = shift;
  my ( $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( name )},
  });
}

=head2 all_templates_with_games

Retrieve all templates in name order where they have games setup.  This avoids allowing people to select a team match template with no games.

=cut

sub all_templates_with_games {
  my $class = shift;
  
  return $class->search({
    
  }, {
    order_by => {-asc => qw( name )},
    join => "template_match_team_games",
  });
}

=head2 season_league_match_template

A predefined search to find and return the team match template for league matches within a given season.

=cut

sub season_league_match_template {
  my $class = shift;
  my ( $season ) = @_;
  
  return $class->find({"seasons.id" => $season->id}, {
    join => "seasons",
    prefetch => "template_match_team_games",
  });
}

=head2 division_averages_list

A predefined search to find and return the players within a division in the order in which they should appear in the full league averages.

=cut

sub division_averages_list {
  my $class = shift;
  my ( $season, $division, $minimum_matches_played ) = @_;
  $minimum_matches_played = 0 if !$minimum_matches_played;
  
  return $class->search({
    "person_seasons.matches_played" => {">="  => $minimum_matches_played},
    "person_seasons.division" => $division,
    "person_seasons.season" => $season
  }, {
    join => "person_seasons",
    order_by => {
      -desc => [qw( person_seasons.average_game_wins person_seasons.matches_played person_seasons.games_won person_seasons.games_played person_seasons.average_point_wins person_seasons.points_played person_seasons.points_won )]
    }
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my $class = shift;
  my ( $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $tt_template = $params->{tt_template} || undef;
  my $name = $params->{name} || undef;
  my $singles_players_per_team  = $params->{singles_players_per_team} || undef;
  my $winner_type = $params->{winner_type} || undef;
  my $handicapped = $params->{handicapped} || 0;
  my $allow_final_score_override = $params->{allow_final_score_override} || 0;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      legs_pesingles_players_per_teamr_game => $singles_players_per_team,
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
  } elsif ( $action eq "edit" ) {
    if ( defined($tt_template) ) {
      if ( ref($tt_template) ne "TopTable::Model::DB::TemplateMatchTeam" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $tt_template = $class->find_id_or_url_key($tt_template);
        
        # Definitely error if we're now undef
        push(@{$response->{errors}}, $lang->maketext("templates.team-match.form.error.template-invalid")) unless defined($tt_template);
      }
      
      # Template is valid, check we can edit it.
      unless ( $tt_template->can_edit_or_delete ) {
        push(@{$response->{errors}}, $lang->maketext("templates.edit.error.not-allowed", $tt_template->name));
      }
    } else {
      # Editing a template that doesn't exist.
      push(@{$response->{errors}}, $lang-maketext("templates.team-match.form.error.template-not-specified"));
    }
  }
  
  # Any error at this point is fatal, so we return early
  return $response if scalar(@{$response->{errors}});
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    push(@{$response->{errors}}, $lang->maketext("templates.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $tt_template}));
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("templates.form.error.name-blank"));
  }
  
  # Check the number of singles players per team has been entered and is valid
  if ( defined($singles_players_per_team) ) {
    # Submitted, check it's valid
    push(@{$response->{errors}}, $lang->maketext("templates.team-match.form.error.singles-players-per-team-invalid")) if $singles_players_per_team !~ m/\d{1,2}/ or $singles_players_per_team < 1;
  } else {
    # Not submitted
    push(@{$response->{errors}}, $lang->maketext("templates.team-match.form.error.singles-players-per-team-blank"));
  }
  
  # Check the match score type
  if ( defined($winner_type) ) {
    if ( ref($winner_type) ne "TopTable::Model::DB::LookupWinnerType" ) {
      # If we haven't got a valid object, try and look it up assuming an ID
      $winner_type = $schema->resultset("LookupWinnerType")->find($winner_type);
      
      # Definitely an error if we don't have a value now now
      push(@{$response->{errors}}, $lang->maketext("templates.team-match.form.error.winner-type-invalid")) unless defined($winner_type);
    }
  } else {
    # Nothing submitted
    push(@{$response->{errors}}, $lang->maketext("templates.team-match.form.error.winner-type-blank"));
  }
  
  $response->{fields}{winner_type} = $winner_type;
  
  # Handicapped sanity check - should be 1 or 0, any other true value gets set to 1
  $handicapped = $handicapped ? 1 : 0;
  $response->{fields}{handicapped} = $handicapped;
  
  # Allow score override sanity check
  $allow_final_score_override = $allow_final_score_override ? 1 : 0;
  $response->{fields}{allow_final_score_override} = $allow_final_score_override;
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # No errors, build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($name, $tt_template);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Success, we need to create / edit the club
    if ( $action eq "create" ) {
      $tt_template = $class->create({
        url_key => $url_key,
        name => $name,
        singles_players_per_team => $singles_players_per_team,
        winner_type => $winner_type->id,
        handicapped => $handicapped,
        allow_final_score_override => $allow_final_score_override,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.created")));
    } else {
      $tt_template->update({
        url_key => $url_key,
        name => $name,
        singles_players_per_team => $singles_players_per_team,
        winner_type => $winner_type->id,
        handicapped => $handicapped,
        allow_final_score_override => $allow_final_score_override,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.edited")));
    }
  }
  
  $response->{tt_template} = $tt_template;
  return $response;
}

1;
