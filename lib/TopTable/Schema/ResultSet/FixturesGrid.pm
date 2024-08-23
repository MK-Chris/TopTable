package TopTable::Schema::ResultSet::FixturesGrid;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 all_grids

Return all fixtures grids sorted by name.

=cut

sub all_grids {
  my ( $class ) = @_;
  
  return $class->search(undef, {
    order_by => {-asc => qw( name )},
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my $class = shift;
  my ( $params ) = @_;
  my $q = $params->{q};
  my $split_words = $params->{split_words} || 0;
  my $season = $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = $params->{page} || undef;
  my $results_per_page = $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my ( $where );
  if ( $split_words ) {
    my @words = split(/\s+/, $q);
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{name => \@constructed_like}];
  } else {
    # Don't split words up before performing a like
    $where = {
      name => {-like => "%$q%"}
    };
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
  
  if ( defined($season) ) {
    $where->[0]{season} = $season->id;
  }
  
  return $class->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of fixtures grids.

=cut

sub page_records {
  my $class = shift;
  my ( $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search(undef, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( name )},
  });
}

=head2 incomplete_matches

A predefined search to get the matches for a grid in week number, then match number order.

=cut

sub incomplete_matches {
  my $class = shift;
  my ( $grid ) = @_;
  
  return $class->search({
    -or => [{
      "fixtures_grid_matches.home_team" => undef,
      "fixtures_grid_matches.away_team" => undef,
    }],
    -and => {
      id => $grid->id
    },
  }, {
    join => {fixtures_grid_weeks => "fixtures_grid_matches"},
    order_by => {
      -asc => [qw( fixtures_grid_weeks.week fixtures_grid_matches.match_number )]
    },
  });
}

=head2 incomplete_grid_positions

Returns the count of teams that have incomplete grid positions for a given grid in a given season.

=cut

sub incomplete_grid_positions {
  my $class = shift;
  my ( $grid, $season ) = @_;
  
  return $class->search({
    "me.id" => $grid->id,
    "team_seasons.grid_position" => undef,
  }, {
    join => {
      division_seasons => {season => "team_seasons"},
    },
  })->count;
}

=head2 find_with_weeks

Wraps find() with a prefetch on season weeks.

=cut

sub find_with_weeks {
  my $class = shift;
  my ( $grid_id ) = @_;
  
  return $class->find({
    id  => $grid_id,
  }, {
    prefetch => "fixtures_grid_weeks",
  });
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a fixtures grid.

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
  my $grid = $params->{grid};
  my $name = $params->{name};
  my $maximum_teams = $params->{maximum_teams};
  my $fixtures_repeated = $params->{fixtures_repeated};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      maximum_teams => $maximum_teams,
      fixtures_repeated => $fixtures_repeated,
    },
    completed => 0,
  };
  
  if ($action ne "create" and $action ne "edit") {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    return $response;
  } elsif ($action eq "edit") {
    unless ( defined($grid) and ref($grid) eq "TopTable::Model::DB::FixturesGrid" ) {
      # Editing a fixtures grid that doesn't exist.
      push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.error.grid-invalid"));
      return $response;
    }
  }
  
  # See if we're setting up fixtures rounds (we won't if we're editing a restricted grid - i.e., it already has matches attached)
  my $setup_rounds = 1;
  $setup_rounds = 0 if $action eq "edit" and $grid->restricted_edit;
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.error.grid-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $grid}));
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.error.name-blank"));
  }
  
  if ( $setup_rounds ) {
    # Check the maximum teams is a valid numeric value (2-98).
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.error.maximum-teams-invalid")) if !$maximum_teams or $maximum_teams !~ m/^\d{1,2}$/ or $maximum_teams < 2 or $maximum_teams > 98 or $maximum_teams % 2 == 1;
    
    # Check the number of weeks is valid; this needs to be a valid numeric figure and
    # less than 52, as a season will definitely not last a year.
    push(@{$response->{errors}}, $lang->maketext("fixtures-grids.form.error.repeat-fixtures-invalid")) if !$fixtures_repeated or $fixtures_repeated !~ m/^\d$/ or $fixtures_repeated < 1;
  }
  
  if ( scalar( @{$response->{errors}} ) == 0 ) {
    # Generate a URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($name, $grid);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Array used to populate multiple rows of data; each row will be a hashref containing the data we wish to insert.
    # This array will be passed as a reference, but keeping it a normal array right now makes the loop more readable.
    my @week_data = ();
    
    if ( $setup_rounds ) {
      # Now work out the number of fixtures weeks we'll have.  This is the maximum number of teams per division
      # (minus 1) multiplied by the number of times a fixture is repeated; for example if teams play each other
      # team three times and there are a maximum of eight teams per division, number of weeks we will have is:
      # (8 - 1) * 3 = 21.
      my $number_of_weeks = ( $maximum_teams - 1 ) * $fixtures_repeated;
      
      # Number of matches per divsion per week is the maximum teams per division divided by 2.
      my $matches_per_week = $maximum_teams / 2;
      
      # Loop through all of our weeks building a hashref 
      for my $i ( 1 .. $number_of_weeks ) {
        my @matches  = ();
        # Now loop through the week's matches
        for my $x ( 1 .. $matches_per_week ) {
          push(@matches, {match_number => $x});
        }
        
        # The hashref contains the grid ID and week number; the home and
        # away team numbers are populated later.  The grid ID is populated in the create
        push(@week_data, {
          week => $i,
          fixtures_grid_matches => \@matches,
        });
      }
    }
    
    if ( $action eq "create" ) {
      # Create the grid
      $grid = $class->create({
        name => $name,
        url_key => $url_key,
        maximum_teams => $maximum_teams,
        fixtures_repeated => $fixtures_repeated,
        fixtures_grid_weeks => \@week_data,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $grid->name, $lang->maketext("admin.message.created")));
    } else {
      # Set up the update data - name and URL key can always be updated
      my $update = {name => $name, url_key => $url_key};
      
      if ( $setup_rounds ) {
        # Delete the grid weeks and matches if this isn't a restricted edit
        my @weeks = $grid->fixtures_grid_weeks->all;
        my @matches = map $_->fixtures_grid_matches->all, @weeks;
        $_->delete foreach ( @matches );
        $_->delete foreach ( @weeks );
        
        # Add the max teams / fixtures repeated into the update
        $update->{maximum_teams} = $maximum_teams;
        $update->{fixtures_repeated} = $fixtures_repeated;
      }
      
      # Update the existing grid
      $grid->update($update);
      
      if ( $setup_rounds ) {
        foreach my $week ( @week_data ) {
          $grid->create_related("fixtures_grid_weeks", $week);
        }
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", $grid->name, $lang->maketext("admin.message.edited")));
    }
    
    $response->{grid} = $grid;
  }
  
  return $response;
}

1;
