package TopTable::Schema::ResultSet::TemplateMatchTeamGame;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;

=head2 individual_game_templates

A predefined search to find and return the individual games and their templates for each team match game in a team match.

=cut

sub individual_game_templates {
  my ( $self, $team_match_template ) = @_;
  
  return $self->search({team_match_template => $team_match_template->id}, {
    prefetch => "individual_match_template",
    order_by => {
      -asc => "match_game_number"
    },
  });
}

=head2 division_averages_list

A predefined search to find and return the players within a division in the order in which they should appear in the full league averages.

=cut

sub division_averages_list {
  my ( $self, $season, $division, $minimum_matches_played ) = @_;
  
  $minimum_matches_played = 0 if !$minimum_matches_played;
  
  return $self->search({
    "person_seasons.matches_played" => {">=" => $minimum_matches_played},
    "person_seasons.division" => $division,
    "person_seasons.season" => $season,
  }, {
    join => "person_seasons",
    order_by => {
      -desc => [qw( person_seasons.average_game_wins person_seasons.matches_played person_seasons.games_won person_seasons.games_played person_seasons.average_point_wins person_seasons.points_played person_seasons.points_won )]
    },
  });
}



=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $tt_template = $params->{tt_template} || undef;
  my @games = @{$params->{games}};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  if ( defined($tt_template) ) {
    if ( ref($tt_template) ne "TopTable::Model::DB::TemplateMatchTeam" ) {
      # This may not be an error, we may just need to find from an ID or URL key
      $tt_template = $self->find_id_or_url_key($tt_template);
      
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
  
  # Fatal if we have an error at this point
  return $response if scalar @{$response->{errors}};
  
  # Check we are allowed to edit this template
  unless ( $tt_template->can_edit_or_delete ) {
    push(@{$response->{errors}}, $lang->maketext("templates.edit.error.not-allowed", encode_entities($tt_template->name)));
  }
  
  # Populate will be used to do the creation
  my @populate = ();
  
  # Slightly different, as we pass in objects, rather than just IDs, but same hash structure
  my @fields = ();
  
  # Now loop through our games
  my $game_num = 0;
  foreach my $game ( @games ) {
    $game_num++;
    my $ind_match_tpl = $game->{ind_match_tpl} || undef;
    my $doubles = $game->{doubles} || 0;
    my $home_player = $game->{home_player} || undef;
    my $away_player = $game->{away_player} || undef;
    $doubles = $doubles ? 1 : 0;
    
    # Now we've set our variables up, do some error checking
    if ( defined($ind_match_tpl) ) {
      if ( ref($ind_match_tpl) ne "TopTable::Model::DB::TemplateMatchIndividual" ) {
          # Not passed as an object, try and look it up
          $ind_match_tpl = $schema->resultset("TemplateMatchIndividual")->find_id_or_url_key($ind_match_tpl);
          
          push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.ind-template-invalid", $game_num)) unless defined($ind_match_tpl);
        }
    } else {
      push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.ind-template-blank", $game_num));
    }
    
    if ( $doubles ) {
      # Undef home / away players
      undef($home_player);
      undef($away_player);
    } else {
      # Check for invalid player numbers
      if ( defined($home_player) ) {
        # Selected, make sure it's valid
        push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.home-player-number-invalid", $game_num, $tt_template->singles_players_per_team)) if $home_player !~ m/\d{1,2}/ or $home_player > $tt_template->singles_players_per_team;
      } else {
        # Not selected
        push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.home-player-number-blank", $game_num));
      }
      
      if ( defined($away_player) ) {
        # Selected, make sure it's valid
        push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.away-player-number-invalid", $game_num, ($tt_template->singles_players_per_team + 1), ($tt_template->singles_players_per_team * 2))) if $away_player !~ m/\d{1,2}/ or $away_player < ($tt_template->singles_players_per_team + 1) or $away_player > ($tt_template->singles_players_per_team * 2);
      } else {
        # Not selected
        push(@{$response->{errors}}, $lang->maketext("templates.team-match.games.error.away-player-number-blank", $game_num));
      }
    }
    
    # Finally push on to our populate array
    push(@populate, {
      team_match_template => $tt_template->id,
      individual_match_template => $ind_match_tpl->id,
      match_game_number => $game_num,
      doubles_game => $doubles,
      singles_home_player_number => $home_player,
      singles_away_player_number => $away_player,
    }) unless scalar @{$response->{errors}};
    
    push(@fields, {
      team_match_template => $tt_template,
      individual_match_template => $ind_match_tpl,
      match_game_number => $game_num,
      doubles_game => $doubles,
      singles_home_player_number => $home_player,
      singles_away_player_number => $away_player,
    });
  }
  
  $response->{fields}{games} = \@fields;
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # No errors, so we need to delete any existing games, as these new ones will overwrite.
    my $games_to_delete = $tt_template->search_related("template_match_team_games")->count;
    $tt_template->delete_related("template_match_team_games") if $games_to_delete;
    $response->{deleted_games} = $games_to_delete;
    $self->populate(\@populate);
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("templates.team-match.games.success", $game_num, $tt_template->name));
  }
  
  $response->{tt_template} = $tt_template;
  $response->{games} = $game_num;
  return $response;
}

1;