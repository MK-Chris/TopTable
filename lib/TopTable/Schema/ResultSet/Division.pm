package TopTable::Schema::ResultSet::Division;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = $params->{q};
  my $split_words = $params->{split_words} || 0;
  my $season = $params->{season} || undef;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my ( $where );
  if ( $split_words ) {
    my @words = split( /\s+/, $q );
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
    order_by => {-asc => [qw( rank )]},
    group_by => [qw( name )],
  };
  
  my $use_paging = defined($page) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page ) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  if ( defined($season) ) {
    $where->[0]{season} = $season->id;
  }
  
  return $self->search($where, $attrib);
}

=head2 divisions_in_season

A predefined search to find and return the divisions within a season.

=cut

sub divisions_in_season {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "division_seasons.season" => $season->id,
  }, {
    prefetch => {division_seasons => "fixtures_grid"},
    order_by => {-asc => "me.rank"}
  });
}

=head2 divisions_and_teams_in_season

A predefined search to find and return the divisions (and the teams in them) within a season.

=cut

sub divisions_and_teams_in_season {
  my ( $self, $season, $grid ) = @_;
  my ( $where );
  
  if ( $grid ) {
    $where = {
      "division_seasons.season" => $season->id,
      "division_seasons.fixtures_grid" => $grid->id,
    };
  } else {
    $where = {"division_seasons.season" => $season->id};
  }
  
  return $self->search( $where, {
    prefetch  => [qw( division_seasons ), {
      "team_seasons" => {
        "team" => [{"club" => "venue"}, qw( home_night )]
      }
    }],
    order_by => {-asc => [qw( rank team_seasons.grid_position club.short_name team.name )]}
  });
}

=head2 divisions_and_teams_in_season_by_grid_position

A predefined search to find and return the divisions (and the teams in them) within a season.

=cut

sub divisions_and_teams_in_season_by_grid_position {
  my ( $self, $season, $grid ) = @_;
  
  return $self->search({
    "division_seasons.season" => $season->id,
    "team_seasons.season" => $season->id,
    "club_season.season" => $season->id,
    "division_seasons.fixtures_grid" => $grid->id,
  }, {
    prefetch => [{
      division_seasons => {
        team_seasons => [qw( team ), {
          club_season => "club",
        }]
      },
    }],
    order_by => {-asc => [qw( me.rank team_seasons.grid_position )]}
  });
}

=head2 all_divisions

A predefined search to find and return all divisions in rank order.

=cut

sub all_divisions {
  my ( $self, $season ) = @_;
  my ( $where, $attrib );
  
  if ( $season ) {
    $where = [{
      "division_seasons.season" => $season->id,
    }, {
      "division_seasons.season" => undef,
    }];
    $attrib = {
      prefetch => {
        division_seasons => {fixtures_grid => "fixtures_grid_weeks"},
      },
      order_by => {-asc => qw( rank )},
    };
  } else {
    $where = {};
    $attrib = {
      prefetch => {
        division_seasons => {fixtures_grid => "fixtures_grid_weeks"},
      },
      order_by => {-asc => qw( rank )}
    };
  }
  
  return $self->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of divisions.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( rank )},
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key ) = @_;
  return $self->find({url_key => $url_key});
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      id => $id_or_url_key
    }, {
      url_key => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {url_key => $id_or_url_key};
  }
  
  return $self->search($where, {rows => 1})->single;
}

=head2 generate_url_key

Generate a unique key from the given division name.

=cut

sub generate_url_key {
  my ( $self, $short_name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($short_name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc( $original_url_key ); # Make lower-case
  
  my $count;
  # Infinite loop; we'll break when we can't find the key
  while ( 1 ) {
    if ( defined($count) ) {
      $count = 2 if $count == 1; # We won't have a 1 - if we reach the point where count is a number, we want to start at 2
      
      # If we have a count, we will add it on to the end of the original key
      $url_key = $original_url_key . "-" . $count;
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $key_check = $self->find_url_key($url_key);
    
    # If not, return it
    return $url_key if !defined($key_check) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 get_next_rank

Get the next highest rank after the current lowest ranked division.

=cut

sub get_next_rank {
  my ( $self ) = @_;
  
  my $lowest_ranked_div = $self->search(undef, {
    order_by => {-desc => qw( rank )},
    rows => 1,
  })->single;
  
  my $lowest_rank = defined($lowest_ranked_div) ? $lowest_ranked_div->rank : 0;
  
  my $next_rank = $lowest_rank + 1;
  return $next_rank;
}

=head2 check_and_create

Takes an arrayref of divisions, loops through and creates the new ones, checks the existing ones are valid.

=cut

sub check_and_create {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $submitted_divisions = $params->{divisions} || [];
  $submitted_divisions = [$submitted_divisions] unless ref($submitted_divisions) eq "ARRAY";
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => [], # Array ref because we could be doing multiple divisions
    completed => 0,
  };
  
  my $season = $schema->resultset("Season")->get_current;
  my $season_weeks;
  
  if ( defined($season) ) {
    # There is a current season, but we have to check we aren't restricted from editing the divisions
    push(@{$response->{errors}}, $lang->maketext("divisions.form.error.matches-created-cant-create-or-edit")) if $season->search_related("team_matches")->count;
    $season_weeks = $season->number_of_weeks;
  } else {
    # No current season
    push(@{$response->{errors}}, $lang->maketext("divisions.form.error.no-current-season"));
    return $response;
  }
  
  # Get the existing divisions - grab the corresponding element when the same numbered element in the submitted divisions row is accessed.
  # This ensures they are used in the correct rank order and we know exactly which rows need to have a new division created.
  my @existing_divisions = $self->all_divisions;
  
  # Loop through the divisions we'll be using - only if we've not restricted editing
  my $rank = 0;
  foreach my $i ( 0 .. $#{$submitted_divisions} ) {
    # Get the respective elements from the arrays - submitted divisions and the list we got from the DB
    my $submitted_division = $submitted_divisions->[$i];
    my $existing_division = $existing_divisions[$i] if defined($existing_divisions[$i]);
    
    $rank++;
    my $name = $submitted_division->{name} || undef;
    my $fixtures_grid = $submitted_division->{fixtures_grid};
    my $league_match_template = $submitted_division->{league_match_template};
    my $league_table_ranking_template = $submitted_division->{league_table_ranking_template};
    my $db_obj = $existing_division; # Store the DB object we'll be editing - no checks needed, this is already undef if there isn't one
    my $fields = {name => $name};
    
    my $division_name_check; # DB object when checking storage for a name that already exists
    my %seen_names = (); # This will hold all the names we've already seen, as we can enter more than one, so duplicates could be entered in the form
    if ( defined($name) ) {
      # Full name entered, check it against the current season - if this is being called as part of the season creation, there will be no errors here,
      # but we can't guarantee that.  No point checking Divisions themselves, as those values can change from season to season.
      if ( defined($db_obj) ) {
        $division_name_check = $self->find({}, {
          where => {
            "division_seasons.name" => $name,
            "division_seasons.season" => $season->id,
            id => {"!=" => $db_obj->id},
          },
          join => "division_seasons",
        });
      } else {
        $division_name_check = $self->find({
          "division_seasons.name" => $name,
          "division_seasons.season" => $season->id,
        }, {
          join => "division_seasons",
        });
      }
      
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.division-exists", $db_obj->{name})) if defined($division_name_check);
      
      # This hash will check against the other submitted names to ensure we don't get duplicates there either.
      if ( exists($seen_names{$name}) ) {
        # Already exists, increment the value
        $seen_names{$name}++;
      } else {
        # Doesn't exist, create it so we can check against it next time
        $seen_names{$name} = 1;
      }
    } else {
      # Full name omitted.
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.name-blank", $rank));
    }
    
    # Check the 'seen_names' hash for values more than one
    foreach my $name ( keys %seen_names ) {
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.duplicate-names", $name, $seen_names{$name})) if $seen_names{$name} > 1;
    }
    
    # Foreign key checks
    # Check the fixtures grid
    if ( defined($fixtures_grid) ) {
      if ( ref($fixtures_grid) ne "TopTable::Model::DB::FixturesGrid" ) {
        # Look it up if we need to
        $fixtures_grid = $schema->resultset("FixturesGrid")->find_id_or_url_key($fixtures_grid);
        
        if ( defined($fixtures_grid) ) {
          # Now check the fixtures grid is eligible to be used this year
          my $grid_weeks = $fixtures_grid->fixtures_grid_weeks->count;
          push(@{$response->{errors}}, $lang->maketext("divisions.form.error.selected-grid-too-many-weeks-for-season", $season_weeks, $rank, $grid_weeks)) if defined($season_weeks) and $grid_weeks > $season_weeks;
        } else {
          # Invalid grid
          push(@{$response->{errors}}, $lang->maketext("divisions.form.error.grid-invalid", $rank));
        }
      }
    } else {
      # Fixtures grid not selected
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.grid-blank", $rank));
    }
    
    # Check the league match template
    if ( defined($league_match_template) ) {
      if ( ref($league_match_template) ne "TopTable::Model::DB::TemplateMatchTeam" ) {
        # Look it up if we need to
        $league_match_template = $schema->resultset("TemplateMatchTeam")->find_id_or_url_key($league_match_template);
        push(@{$response->{errors}}, $lang->maketext("divisions.form.error.league-match-template-invalid", $rank)) unless defined($league_match_template);
      }
    } else {
      # Fixtures grid not selected
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.league-match-template-blank", $rank));
    }
    
    # Check the ranking template
    if ( defined($league_table_ranking_template) ) {
      if ( ref($league_table_ranking_template) ne "TopTable::Model::DB::TemplateLeagueTableRanking" ) {
        # Look it up if we need to
        $league_table_ranking_template = $schema->resultset("TemplateLeagueTableRanking")->find_id_or_url_key($league_table_ranking_template);
        push(@{$response->{errors}}, $lang->maketext("divisions.form.error.league-ranking-template-invalid", $rank)) unless defined($league_table_ranking_template);
      }
    } else {
      # Fixtures grid not selected
      push(@{$response->{errors}}, $lang->maketext("divisions.form.error.league-ranking-template-blank", $rank));
    }
    
    # Push our fields back into the response
    $fields->{fixtures_grid} = $fixtures_grid;
    $fields->{league_match_template} = $league_match_template;
    $fields->{league_table_ranking_template} = $league_table_ranking_template;
    push(@{$response->{fields}}, $fields);
    
    # Put the changes we've made back into the array
    $submitted_division->{fixtures_grid} = $fixtures_grid;
    $submitted_division->{league_match_template} = $league_match_template;
    $submitted_division->{league_table_ranking_template} = $league_table_ranking_template;
    $submitted_division->{db_obj} = $db_obj;
  }
  
  # Now we've looped through and done our error checking, we need to loop through again and do the creation if we didn't get any errors
  if ( scalar @{$response->{errors}} == 0 ) {
    for my $division_data ( @{$submitted_divisions} ) {
      # Store the DB object for easy access
      my $name = $division_data->{name} || undef;
      my $fixtures_grid = $division_data->{fixtures_grid};
      my $league_match_template = $division_data->{league_match_template};
      my $league_table_ranking_template = $division_data->{league_table_ranking_template};
      my $division = $division_data->{db_obj}; # Store the DB object we'll be editing - no checks needed, this is already undef if there isn't one
      
      if ( defined($division) ) {
        # Update our pre-existing divisions
        $division->update({
          name => $name,
          url_key => $self->generate_url_key($name, $division->id),
        });
        
        $division_data->{action} = "edit";
        
        my $this_season = $division->division_seasons->find({season => $season->id});
        
        if ( defined($this_season) ) {
          $this_season->update({
            name => $name,
            fixtures_grid => $fixtures_grid->id,
            league_match_template => $league_match_template->id,
            league_table_ranking_template => $league_table_ranking_template->id,
          });
        } else {
          # Insert a link to the season if it doesn't exist already
          my $division_season = $division->create_related("division_seasons", {
            season => $season->id,
            name => $name,
            fixtures_grid => $fixtures_grid->id,
            league_match_template => $league_match_template->id,
            league_table_ranking_template => $league_table_ranking_template->id,
          });
        }
        
        push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($division->name), $lang->maketext("admin.message.edited")));
      } else {
        # Insert a new division
        $division = $self->create({
          name => $name,
          url_key => $self->generate_url_key($division_data->{name}),
          rank => $self->get_next_rank,
          division_seasons => [{
            season => $season->id,
            name => $name,
            fixtures_grid => $fixtures_grid->id,
            league_match_template => $league_match_template->id,
            league_table_ranking_template => $league_table_ranking_template->id,
          }],
        });
        
        $division_data->{action} = "create";
        $division_data->{db_obj} = $division;
        push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($division->name), $lang->maketext("admin.message.created")));
      }
    }
    
    $response->{completed} = 1;
  }
  
  $response->{divisions} = $submitted_divisions;
  return $response;
}

1;
