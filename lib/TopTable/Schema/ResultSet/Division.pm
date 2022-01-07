package TopTable::Schema::ResultSet::Division;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper::Concise;

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $season = delete $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = delete $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my ( $where );
  if ( $split_words ) {
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
    }
    
    $where = [{
      name => \@constructed_like,
    }];
  } else {
    # Don't split words up before performing a like
    $where = {
      name => {-like => "%$q%"}
    };
  }
  
  my $attrib = {
    order_by => {-asc => [ qw( rank ) ]},
    group_by => [ qw( name ) ],
  };
  
  my $use_paging = ( defined( $page ) ) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined( $results_per_page ) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  if ( defined( $season ) ) {
    $where->[0]{season} = $season->id;
  }
  
  return $self->search( $where, $attrib );
}

=head2 divisions_in_season

A predefined search to find and return the divisions within a season.

=cut

sub divisions_in_season {
  my ( $self, $season ) = @_;
  
  return $self->search({
    "division_seasons.season" => $season->id,
  }, {
    prefetch  => {
      "division_seasons" => "fixtures_grid"
    },
    order_by  => {
      -asc => "rank"
    }
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
      "division_seasons.season"         => $season->id,
      "division_seasons.fixtures_grid"  => $grid->id,
    };
  } else {
    $where = {
      "division_seasons.season" => $season->id,
    };
  }
  
  return $self->search( $where, {
    prefetch  => [
      "division_seasons", {
        "team_seasons" => {
          "team" => [{
              "club" => "venue"
            },
            "home_night",
          ]
        }
      }
    ],
    order_by  => {
      -asc => [ qw( rank team_seasons.grid_position club.short_name team.name ) ]
    }
  });
}

=head2 divisions_and_teams_in_season_by_grid_position

A predefined search to find and return the divisions (and the teams in them) within a season.

=cut

sub divisions_and_teams_in_season_by_grid_position {
  my ( $self, $season, $grid ) = @_;
  
  return $self->search({
    "division_seasons.season"         => $season->id,
    "team_seasons.season"             => $season->id,
    "club_season.season"              => $season->id,
    "division_seasons.fixtures_grid"  => $grid->id,
  }, {
    prefetch => [{
      division_seasons => {
        team_seasons => ["team", {
          club_season => "club",
        }]
      },
    }],
    order_by  => {
      -asc => [ qw( rank team_seasons.grid_position ) ]
    }
  });
}

=head2 all_divisions

A predefined search to find and return all divisions in display order.

=cut

sub all_divisions {
  my ( $self, $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where      = [{
      "division_seasons.season" => $season->id,
    }, {
      "division_seasons.season" => undef,
    }];
    $attributes = {
      prefetch  => {
        division_seasons => {
          fixtures_grid => "fixtures_grid_weeks"
        },
      },
      order_by  => {
        -asc => "rank"
      },
    };
  } else {
    $where      = {};
    $attributes = {
      prefetch  => {
        division_seasons => {
          fixtures_grid => "fixtures_grid_weeks"
        },
      },
      order_by  => {
        -asc => "rank"
      }
    };
  }
  
  return $self->search($where, $attributes);
}

=head2 page_records

Returns a paginated resultset of divisions.

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number         = $parameters->{page_number} || 1;
  my $results_per_page    = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page      => $page_number,
    rows      => $results_per_page,
    order_by  => {
      -asc => "rank",
    },
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key ) = @_;
  
  return $self->find({
    url_key => $url_key,
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key ) = @_;
  my ( $where );
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - assume it's the ID
    $where = {
      id => $id_or_url_key,
    };
  } else {
    # Not numeric - must be the URL key
    $where = {
      url_key => $id_or_url_key,
    };
  }
  
  return $self->find( $where );
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
    my $key_check = $self->find_url_key( $url_key );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 check_and_create

Takes an arrayref of divisions, loops through and creates the new ones, checks the existing ones are valid.

=cut

sub check_and_create {
  my ( $self, $parameters ) = @_;
  my $divisions = $parameters->{divisions} || [];
  my $log       = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $lang      = $parameters->{language} || sub { return wantarray ? @_ : "@_"; }; # Default to a sub that just returns everything, as we don't want errors if we haven't passed in a language sub.
  
  my $return          = {
    error             => [],
    warning           => [],
    sanitised_fields  => [], # Array ref because we could be doing multiple divisions
  };
  
  # Get the schema to do foreign key checks
  my $schema = $self->result_source->schema;
  my $season = $schema->resultset("Season")->get_current;
  
  my $season_weeks  = $season->number_of_weeks;
  
  if ( defined( $season ) ) {
    # There is a current season, but we have to check we aren't restricted from editing the divisions
    # Find out if we can edit the dates for this season; otherwise we'll ignore the date inputs
    push( @{ $return->{error} }, $lang->("divisions.form.error.matches-created-cant-create-or-edit") ) if $season->search_related("team_matches")->count;
  } else {
    # No current season
    push( @{ $return->{error} }, $lang->("divisions.form.error.no-current-season") );
    return $return;
  }
  
  # Loop through the divisions we'll be using - only if we've not restricted editing
  my $rank              = 1;
  my $unused_divisions  = 0;
  my $unused_errored    = 0; # Make sure we don't raise the 'unused' error more than once by setting this flag when we raise it the first time
  foreach my $i ( 0 .. scalar( @{ $divisions } ) - 1 ) {
    my $use_division = $divisions->[$i]{use_division} || 0;
    
    # The field is usually disabled on the form for rank 1, so even though it's ticked, this is not transferred, so we need to ensure it's explicitly set to 1.
    $use_division = 1 if $rank == 1;
    
    if ( $use_division ) {
      # If we have seen 'unused' divisions at this point, we need to error, as we can't not use one division then use some below it
      if ( $unused_divisions and !$unused_errored ) {
        push(@{ $return->{error} }, $lang->("divisions.form.error.checkboxes-wrong"));
        $unused_errored = 1;
      }
      
      if ( $divisions->[$i]{id} ) {
        # Get the division object for the current division if we've got an ID
        $divisions->[$i]{db} = $self->find({
          id                        => $divisions->[$i]{id},
          "division_seasons.season" => $season->id,
        }, {
          prefetch => "division_seasons",
        });
        
        push(@{ $return->{error} }, $lang->("divisions.form.error.id-invalid", $rank)) unless defined( $divisions->[$i]{db} );
      }
      
      my $division_name_check; # DB object when checking storage for a name that already exists
      my %seen_names = (); # This will hold all the names we've already seen, as we can enter more than one, so duplicates could be entered in the form
      if ( $divisions->[$i]{name} ) {
        # Full name entered, check it.
        if ( $divisions->[$i]{id} ) {
          $division_name_check = $self->find({}, {
            where => {
              "division_seasons.name"   => $divisions->[$i]{name},
              "division_seasons.season" => $season->id,
              id => {"!=" => $divisions->[$i]{id}},
            },
            join => "division_seasons",
          });
        } else {
          $division_name_check = $self->find({
            "division_seasons.name"   => $divisions->[$i]{name},
            "division_seasons.season" => $season->id,
          }, {
            join => "division_seasons",
          });
        }
        
        push(@{ $return->{error} }, $lang->("divisions.form.error.division-exists", $divisions->[$i]{name})) if defined($division_name_check);
        
        if ( exists( $seen_names{ $divisions->[$i]{name} } ) ) {
          # Already exists, increment the value
          $seen_names{ $divisions->[$i]{name} }++;
        } else {
          # Doesn't exist, create it so we can check against it next time
          $seen_names{ $divisions->[$i]{name} } = 1;
        }
      } else {
        # Full name omitted.
        push(@{ $return->{error} }, $lang->("divisions.form.error.name-blank", $rank ));
      }
      
      # Check the 'seen_names' hash for values more than one
      foreach my $name ( keys %seen_names ) {
        push(@{ $return->{error} }, $lang->("divisions.form.error.duplicate-names", $name, $seen_names{$name})) if $seen_names{$name} > 1;
      }
      
      # Foreign key checks
      # Check the fixtures grid
      my $fixtures_grid_id = $divisions->[$i]{fixtures_grid} || undef;
      $divisions->[$i]{fixtures_grid} = ( defined( $fixtures_grid_id ) ) ? $schema->resultset("FixturesGrid")->find( $fixtures_grid_id ) : undef;
      
      if ( defined( $divisions->[$i]{fixtures_grid} ) ) {
        my $grid_weeks = $divisions->[$i]{fixtures_grid}->fixtures_grid_weeks->count;
        push(@{ $return->{error} }, $lang->("divisions.form.error.selected-grid-too-many-weeks-for-season", $season_weeks, $rank, $grid_weeks)) if defined( $season_weeks ) and $grid_weeks > $season_weeks;
      } else {
        push(@{ $return->{error} }, $lang->("divisions.form.error.grid-invalid", $rank));
      }
      
      # League match template
      my $league_match_template_id = $divisions->[$i]{league_match_template};
      $divisions->[$i]{league_match_template} = ( defined( $league_match_template_id ) ) ? $schema->resultset("TemplateMatchTeam")->find( $league_match_template_id ) : undef;
      push(@{ $return->{error} }, $lang->("divisions.form.error.league-match-template-invalid", $rank)) unless defined( $divisions->[$i]{league_match_template} );
      
      
      my $league_table_ranking_template_id = $divisions->[$i]{league_table_ranking_template};
      $divisions->[$i]{league_table_ranking_template} = ( defined( $league_table_ranking_template_id ) ) ? $schema->resultset("TemplateLeagueTableRanking")->find( $league_table_ranking_template_id ) : undef;
      push(@{ $return->{error} }, $lang->("divisions.form.error.league-ranking-template-invalid", $rank)) unless defined( $divisions->[$i]{league_table_ranking_template} );
    } else {
      # Not using this division; set the '$unused_divisions' variable
      $unused_divisions = 1;
    }
    
    # Push details on to the sanitised fields
    push( @{ $return->{sanitised_fields} }, {
      name                          => $divisions->[$i]{name},
      fixtures_grid                 => $divisions->[$i]{fixtures_grid},
      league_match_template         => $divisions->[$i]{league_match_template},
      league_table_ranking_template => $divisions->[$i]{league_table_ranking_template},
      use_division                  => $use_division,
    });
    
    $rank++;
  }
  
  # Now we've looped through and done our error checking, we need to loop through again and do the creation if we didn't get any errors
  if ( scalar( @{ $return->{error} } ) == 0 ) {
    my $next_rank = 1;
    
    for my $division_data ( @{ $divisions } ) {
      my $use_division = $division_data->{use_division};
      
      if ( $use_division ) {
        # Store the DB object for easy access
        my $division = $division_data->{db};
        
        if ( defined( $division ) ) {
          # Update our pre-existing divisions
          my $url_key = $self->generate_url_key( $division_data->{name}, $division->id );
          
          $division->update({
            name    => $division_data->{name},
            url_key => $url_key,
          });
          
          $division_data->{action} = "edit";
          
          my $this_season = $division->division_seasons->find({
            season  => $season->id,
          });
          
          if ( defined( $this_season ) ) {
            $this_season->update({
              name                          => $division_data->{name},
              fixtures_grid                 => $division_data->{fixtures_grid}->id,
              league_match_template         => $division_data->{league_match_template}->id,
              league_table_ranking_template => $division_data->{league_table_ranking_template}->id,
            });
          } else {
            # Insert a link to the season if it doesn't exist already
            my $division_season = $division->create_related("division_seasons", {
              season                        => $season->id,
              name                          => $division_data->{name},
              fixtures_grid                 => $division_data->{fixtures_grid}->id,
              league_match_template         => $division_data->{league_match_template}->id,
              league_table_ranking_template => $division_data->{league_table_ranking_template}->id,
            });
          }
        } else {
          # Insert a new division
          my $url_key = $self->generate_url_key( $division_data->{name} );
          
          $division = $self->create({
            name                            => $division_data->{name},
            url_key                         => $url_key,
            rank                            => $next_rank,
            division_seasons                => [{
              season                        => $season->id,
              name                          => $division_data->{name},
              fixtures_grid                 => $division_data->{fixtures_grid}->id,
              league_match_template         => $division_data->{league_match_template}->id,
              league_table_ranking_template => $division_data->{league_table_ranking_template}->id,
            }],
          });
          
          $division_data->{action}  = "create";
          $division_data->{db}      = $division;
        }
        
        # Increment the display order
        $next_rank++;
        
        # Add the division DB object to the hash
        $division_data->{db} = $division;
      }
    }
  }
  
  $return->{divisions} = $divisions;
  return $return;
}

1;
