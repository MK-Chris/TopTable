package TopTable::Schema::ResultSet::Season;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use HTML::Entities;

=head2 get_current

A predefined search to get the current season (complete = 0)

=cut

sub get_current {
  my ( $self ) = @_;
  
  return $self->find({complete => 0}, {
    order_by => {-asc => [qw( division.rank )]},
    prefetch  => {division_seasons  => "division"},
  });
}

=head2 last_complete_season

A predefined search to find the latest season that has been completed; optionally takes a team, in which case returns the latest completed season that the specified team entered.

=cut

sub last_complete_season {
  my ( $self, $team ) = @_;
  
  my $where = {complete => 1};
  my $attrib = {
    order_by => {-desc => [qw( start_date end_date )]},
    rows => 1,
  };
  
  if ( $team ) {
    $where->{"team_seasons.team"} = $team->id;
    $attrib->{prefetch} = {team_seasons => "home_night"};
  }
  
  return $self->search($where, $attrib)->single;
}

=head2 get_current_or_last

A predefined search to get either the current season (complete = 0) or the last complete season.

=cut

sub get_current_or_last {
  my ( $self ) = @_;
  
  # First see if there's an active season
  my $season  = $self->get_current;
  $season = $self->last_complete_season unless defined($season);
  
  return $season;
}

=head2 all_seasons

A predefined search to find all seasons.  A non-complete season will be ordered first, then in descending order of start date, then end date.

=cut

sub all_seasons {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => [{
      -asc => [
        qw( complete )
      ]}, {
      -desc => [
        qw( start_date end_date )
      ]}, {
        -asc => [
          qw( division.rank )
      ]}
    ],
    prefetch => {division_seasons  => "division"},
  });
}

=head2 search_by_name

Search for seasons by name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = $params->{q};
  my $split_words = $params->{split_words} || 0;
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = $params->{page} || undef;
  my $results_per_page = $params->{results} || undef;
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my $where;
  if ( $split_words ) {
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{name => \@constructed_like}];
  } else {
    # Don't split words up before performing a like
    $where = {name => {-like => "%$q%"}};
  }
  
  my $attrib = {
    order_by => {-desc => [qw( start_date end_date )]},
  };
  
  my $use_paging = ( defined($page) ) ? 1 : 0;
  
  if ( $use_paging ) {
    # Set a default for results per page if it's not provided or invalid
    $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
    
    # Default the page number to 1
    $page = 1 if $page !~ m/^\d+$/;
    
    # Set the attribs for paging
    $attrib->{page} = $page;
    $attrib->{rows} = $results_per_page;
  }
  
  return $self->search($where, $attrib);
}

=head2 get_archived

A predefined search to get all archived seasons (complete = 1)

=cut

sub get_archived {
  my ( $self ) = @_;
  
  return $self->search({complete => 1}, {
    order_by => [{
      -desc => [qw( start_date end_date )]
    }, {
      -asc => [
        qw( division.rank )
      ],
    }],
    prefetch => {division_seasons  => "division"},
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

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $params ) = @_;
  my $name = $params->{name};
  my $exclude_id = $params->{id};
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
  $original_url_key =~ s/^-|-$//g; # Replace dashes at the start and end with nothing
  $original_url_key = lc($original_url_key); # Make lower-case
  
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

=head2 divisions_and_teams_in_season

Retrieve the season with the specified ID, prefetched with the teams and divisions.

=cut

sub divisions_and_teams_in_season {
  my ( $self, $season_id ) = @_;
  
  return $self->find({id => $season_id}, {
    prefetch => [{
      division_seasons => "division",
      team_seasons => [{
        team => {club => "venue"},
      }, qw( home_night )],
    }],
  });
}

=head2 last_season_with_team_entries

Return the last season that has any teams registered to it.

=cut

sub last_season_with_team_entries {
  my ( $self ) = @_;
  
  return $self->find({}, {
    join => {team_seasons => "team"},
    having => \["COUNT(team.id) > ?", 0],
    group_by => "me.id",
    rows => 1,
    order_by => [{
      -asc => [qw( complete )]
    }, {
      -desc => [qw( start_date end_date )]
    }],
  });
}

=head2 page_records

Retrieve a paginated list of seasons.  If an object is specified (i.e., club, team, division, person), the list is limited to the seasons that involve the specified object

=cut

sub page_records {
  my ( $self, $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  my $club = $params->{club};
  my $team = $params->{team};
  my $division = $params->{division};
  my $person = $params->{person};
  my $grid = $params->{fixutres_grid};
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  # Attributes has a default set that doesn't change (only the join is added after this).  The criteria is added when we know which object is specified
  my $where;
  my $attrib = {
    page => $page_number,
    rows => $results_per_page,
    order_by => [{
      -asc => [qw( complete )]
    }, {
      -desc => [qw( start_date end_date )]
    }],
    group_by => "me.id",
  };
  
  if ( defined($club) ) {
    $where = {"club.id" => $club->id};
    $attrib->{join} = {team_seasons => "club"};
  } elsif ( defined($team) ) {
    $where = {"team.id" => $team->id};
    $attrib->{join} = {team_seasons => "team"};
  } elsif ( defined($division) ) {
    $where = {"division.id" => $division->id};
    $attrib->{join} = {division_seasons => "division"};
  } elsif ( defined($person) ) {
    $where = {"person.id" => $person->id};
    $attrib->{join} = {person_seasons => "person"};
  } elsif ( defined($grid) ) {
    $where = {"fixtures_grid.id" => $grid->id};
    $attrib->{join} = {
      division_seasons => [qw( division fixtures_grid )]
    };
  }
  
  return $self->search($where, $attrib);
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my ( $self, $action, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $season = $params->{season} || undef;
  my $name = $params->{name} || undef;
  my $start_date = $params->{start_date} || undef;
  my $end_date = $params->{end_date} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $timezone = $params->{timezone} || undef;
  my $allow_loan_players = $params->{allow_loan_players} || 0;
  my $allow_loan_players_above = $params->{allow_loan_players_above} || 0;
  my $allow_loan_players_below = $params->{allow_loan_players_below} || 0;
  my $allow_loan_players_across = $params->{allow_loan_players_across} || 0;
  my $allow_loan_players_same_club_only = $params->{allow_loan_players_same_club_only} || 0;
  my $allow_loan_players_multiple_teams_per_division = $params->{allow_loan_players_multiple_teams_per_division} || 0;
  my $loan_players_limit_per_player = $params->{loan_players_limit_per_player} || 0;
  my $loan_players_limit_per_player_per_team = $params->{loan_players_limit_per_player_per_team} || 0;
  my $loan_players_limit_per_player_per_opposition = $params->{loan_players_limit_per_player_per_opposition} || 0;
  my $loan_players_limit_per_team = $params->{loan_players_limit_per_team} || 0;
  my $void_unplayed_games_if_both_teams_incomplete = $params->{void_unplayed_games_if_both_teams_incomplete} || 0;
  my $forefeit_count_averages_if_game_not_started = $params->{forefeit_count_averages_if_game_not_started} || 0;
  my $missing_player_count_win_in_averages = $params->{missing_player_count_win_in_averages} || 0;
  my $rules = $params->{rules} || undef;
  my $divisions = $params->{divisions} // [];
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      start_hour => $start_hour,
      start_minute => $start_minute,
    },
    completed => 0,
    divisions_completed => 0,
  };
  
  my $restricted_edit = 0;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    return $response;
  } elsif ( $action eq "edit" ) {
    # Check the user passed is valid
    if ( defined($season) ) {
      if ( ref($season) ne "TopTable::Model::DB::Season" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $season = $self->find_id_or_url_key($season);
        
        # Definitely error if we're now undef
        push(@{$response->{errors}}, $lang->maketext("seasons.form.error.season-invalid")) unless defined($season);
        
        # Another fatal error
        return $response;
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.season-not-specified"));
    }
    
    # Find out if we can edit the dates for this season; otherwise we'll ignore the date inputs
    my $league_matches = $season->search_related("team_matches")->count;
    
    # Check if we have any rows, if so disable the dates
    $restricted_edit = 1 if $league_matches;
  }
  
  # Make sure we return the restricted edit value
  $response->{restricted_edit} = $restricted_edit;
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    my $season_name_check;
    # Full name entered, check it.
    if ( $action eq "edit" ) {
      $season_name_check = $self->find({}, {
        where => {
          name => $name,
          id => {"!=" => $season->id},
        }
      });
    } else {
      $season_name_check = $self->find({name => $name});
    }
    
    push(@{$response->{errors}}, $lang->maketext("seasons.form.error.name-exists", $name)) if defined($season_name_check);
  } else {
    # Full name omitted.
    push(@{$response->{errors}}, $lang->maketext("seasons.form.error.name-blank"));
  }
  
  # Check the entered start time values (hour and minute) are valid
  if ( !$restricted_edit ) {
    if ( defined($start_date) ) {
      # Do the date checking; eval it to trap DateTime errors and pass them into $error
      if ( ref($start_date) eq "HASH" ) {
        # Hashref, get the year, month, day
        my $year = $start_date->{year};
        my $month = $start_date->{month};
        my $day = $start_date->{day};
        
        # Make sure the date is valid
        try {
          $start_date = DateTime->new(
            year => $year,
            month => $month,
            day => $day,
          );
        } catch {
          push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-date-invalid"));
        };
      } elsif ( ref($start_date) ne "DateTime" ) {
        push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-date-invalid"));
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-date-invalid"));
    }
    
    $response->{fields}{start_date} = $start_date;
    
    if ( defined($end_date) ) {
      # Do the date checking; eval it to trap DateTime errors and pass them into $error
      if ( ref($end_date) eq "HASH" ) {
        # Hashref, get the year, month, day
        my $year = $start_date->{year};
        my $month = $start_date->{month};
        my $day = $start_date->{day};
        
        # Make sure the date is valid
        try {
          $end_date = DateTime->new(
            year => $year,
            month => $month,
            day => $day,
          );
        } catch {
          push(@{$response->{errors}}, $lang->maketext("seasons.form.error.end-date-invalid"));
        };
      } elsif ( ref($end_date) ne "DateTime" ) {
        push(@{$response->{errors}}, $lang->maketext("seasons.form.error.end-date-invalid"));
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.end-date-invalid"));
    }
    
    $response->{fields}{end_date} = $end_date;
    
    if ( defined($start_hour) ) {
      # Start hour submitted, validate it
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-hour-invalid")) unless $start_hour =~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
    } else {
      # Blank start hour
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-hour-blank"));
    }
    
    if ( defined($start_minute) ) {
      # Start hour submitted, validate it
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-minute-invalid")) unless $start_minute =~ m/^(?:[0-5][0-9])$/;
    } else {
      # Blank start hour
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-minute-blank"));
    }
    
    if ( defined($timezone) ) {
      unless ( DateTime::TimeZone->is_valid_name($timezone) ) {
        push(@{$response->{errors}}, $lang->maketext("seasons.form.error.timezone-invalid"));
        undef($timezone);
      }
    } else {
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.timezone-blank"));
    }
    
    $response->{fields}{timezone} = $timezone;
    
    if ( defined($start_date) and defined($end_date) ) {
      # Check the start date is before the end date
      my $date_compare = DateTime->compare_ignore_floating($start_date, $end_date);
      
      if ( $date_compare == 0 or $date_compare == 1 ) {
        # Start date is equal to or after the end date
        push(@{$response->{errors}}, $lang->maketext("seasons.form.error.start-date-after-end-date"));
      } else {
        # Change our week days to the Monday in the same week, if they're not already
        $start_date = TopTable::Controller::Root::get_day_in_same_week($start_date, 1);
        $end_date = TopTable::Controller::Root::get_day_in_same_week($end_date, 1);
        
        # Now find out the number of weeks we'll be using for this
        # Iterate through dates from the start date to the end date, adding one week each time.
        my $season_weeks = 0;
        for (my $dt = $start_date->clone; $dt <= $end_date; $dt->add(weeks => 1) ) {
          $season_weeks++;
        }
        
        $response->{season_weeks} = $season_weeks;
      }
    }
    
    # Check the loan player options
    
    # Loan player rules
    if ( $allow_loan_players ) {
      # Allow loan players - check rules - the booleans are just sanity checks - set to 1 if the value is true, or 0 if not
      $allow_loan_players = 1; # Sanity - make sure a true value is 1
      $allow_loan_players_above = $allow_loan_players_above ? 1 : 0;
      $allow_loan_players_below = $allow_loan_players_below ? 1 : 0;
      $allow_loan_players_across = $allow_loan_players_across ? 1 : 0;
      $allow_loan_players_same_club_only = $allow_loan_players_same_club_only ? 1 : 0;
      $allow_loan_players_multiple_teams_per_division = $allow_loan_players_multiple_teams_per_division ? 1 : 0;
      
      # Check the limits are numeric and not negative
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.loan-playerss-limit-per-player-invalid")) unless $loan_players_limit_per_player =~ m/^\d{1,2}$/;
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.loan-players-limit-per-player-per-team-invalid")) unless $loan_players_limit_per_player_per_team =~ m/^\d{1,2}$/;
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.loan-players-limit-per-player-per-opposition-invalid")) unless $loan_players_limit_per_player_per_opposition =~ m/^\d{1,2}$/;
      push(@{$response->{errors}}, $lang->maketext("seasons.form.error.loan-players-limit-per-team-invalid")) unless $loan_players_limit_per_team =~ m/^\d{1,2}$/;
    } else {
      # No loan players, zero all other options
      $allow_loan_players_above = 0;
      $allow_loan_players_below = 0;
      $allow_loan_players_across = 0;
      $allow_loan_players_same_club_only = 0;
      $loan_players_limit_per_player = 0;
      $loan_players_limit_per_player_per_team = 0;
      $loan_players_limit_per_team = 0;
    }
    
    # Rules covering unplayed games / missing players
    $void_unplayed_games_if_both_teams_incomplete = $void_unplayed_games_if_both_teams_incomplete ? 1 : 0;
    $forefeit_count_averages_if_game_not_started = $forefeit_count_averages_if_game_not_started ? 1 : 0;
    $missing_player_count_win_in_averages = $missing_player_count_win_in_averages ? 1 : 0;
    
    $response->{fields}{allow_loan_players} = $allow_loan_players;
    $response->{fields}{allow_loan_players_above} = $allow_loan_players_above;
    $response->{fields}{allow_loan_players_below} = $allow_loan_players_below;
    $response->{fields}{allow_loan_players_across} = $allow_loan_players_across;
    $response->{fields}{allow_loan_players_same_club_only} = $allow_loan_players_same_club_only;
    $response->{fields}{allow_loan_players_multiple_teams_per_division} = $allow_loan_players_multiple_teams_per_division;
    $response->{fields}{loan_players_limit_per_player} = $loan_players_limit_per_player;
    $response->{fields}{loan_players_limit_per_player_per_team} = $loan_players_limit_per_player_per_team;
    $response->{fields}{loan_players_limit_per_player_per_opposition} = $loan_players_limit_per_player_per_opposition;
    $response->{fields}{loan_players_limit_per_team} = $loan_players_limit_per_team;
    $response->{fields}{void_unplayed_games_if_both_teams_incomplete} = $void_unplayed_games_if_both_teams_incomplete;
    $response->{fields}{forefeit_count_averages_if_game_not_started} = $forefeit_count_averages_if_game_not_started;
    $response->{fields}{missing_player_count_win_in_averages} = $missing_player_count_win_in_averages;
  }
  
  # Filter the HTML from the rules
  #$rules = TopTable->model("FilterHTML")->filter($rules, "textarea");
  $response->{fields}{rules} = $rules;
  
  if ( scalar @{$response->{errors}} == 0 ) {
    my $url_key;
    if ( $action eq "edit" ) {
      
      $url_key = $self->generate_url_key({name => $name, id => $season->id});
    } else {
      $url_key = $self->generate_url_key({name => $name});
    }
    
    my @fixtures_weeks = ();
    if ( ($action eq "create" or !$restricted_edit) and defined($start_date) and defined($end_date) ) {
      # Create the related weeks array
      # Now we need to create some weeks for that season between the start and end dates
      # Iterate through dates from the start date to the end date, adding one week each time.
      for (my $dt = $start_date->clone; $dt <= $end_date; $dt->add( weeks => 1 ) ) {
        push(@fixtures_weeks, {week_beginning_date => $dt->clone->ymd});
      }
    }
    
    if ( $action eq "create" ) {
      # Success, we need to create the season
      $season = $self->create({
        name=> $name,
        url_key => $url_key,
        start_date => $start_date->ymd,
        end_date => $end_date->ymd,
        default_match_start => sprintf("%s:%s", $start_hour, $start_minute),
        timezone => $timezone,
        allow_loan_players_above => $allow_loan_players_above,
        allow_loan_players_below => $allow_loan_players_below,
        allow_loan_players_across => $allow_loan_players_across,
        allow_loan_players_same_club_only => $allow_loan_players_same_club_only,
        allow_loan_players_multiple_teams_per_division => $allow_loan_players_multiple_teams_per_division,
        loan_players_limit_per_player => $loan_players_limit_per_player,
        loan_players_limit_per_player_per_team => $loan_players_limit_per_player_per_team,
        loan_players_limit_per_player_per_opposition => $loan_players_limit_per_player_per_opposition,
        loan_players_limit_per_team => $loan_players_limit_per_team,
        void_unplayed_games_if_both_teams_incomplete => $void_unplayed_games_if_both_teams_incomplete,
        forefeit_count_averages_if_game_not_started => $forefeit_count_averages_if_game_not_started,
        missing_player_count_win_in_averages => $missing_player_count_win_in_averages,
        fixtures_weeks => \@fixtures_weeks,
        rules => $rules,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($season->name), $lang->maketext("admin.message.created")));
    } else {
      my $update_data;
      if ( $restricted_edit ) {
        # In restricted edit mode, we can only update certain fields
        $update_data = {
          name => $name,
          url_key => $url_key,
          default_match_start => sprintf("%02d:%02d", $start_hour, $start_minute),
          rules => $rules,
        };
      } else {
        $update_data = {
          name => $name,
          url_key => $url_key,
          start_date => $start_date->ymd,
          end_date => $end_date->ymd,
          default_match_start => sprintf("%02d:%02d", $start_hour, $start_minute),
          allow_loan_players_above => $allow_loan_players_above,
          allow_loan_players_below => $allow_loan_players_below,
          allow_loan_players_across => $allow_loan_players_across,
          allow_loan_players_same_club_only => $allow_loan_players_same_club_only,
          allow_loan_players_multiple_teams_per_division => $allow_loan_players_multiple_teams_per_division,
          loan_players_limit_per_player => $loan_players_limit_per_player,
          loan_players_limit_per_player_per_team => $loan_players_limit_per_player_per_team,
          loan_players_limit_per_player_per_opposition => $loan_players_limit_per_player_per_opposition,
          loan_players_limit_per_team => $loan_players_limit_per_team,
          void_unplayed_games_if_both_teams_incomplete => $void_unplayed_games_if_both_teams_incomplete,
          forefeit_count_averages_if_game_not_started => $forefeit_count_averages_if_game_not_started,
          missing_player_count_win_in_averages => $missing_player_count_win_in_averages,
          rules => $rules,
        };
      }
      
      $season->update($update_data);
      
      unless ( $restricted_edit ) {
        # Since we're updating, if we've been able to update the dates, we will need to delete the existing fixtures weeks and recreate them
        $season->delete_related("fixtures_weeks");
        
        # Now we need to recreate them
        $season->create_related("fixtures_weeks", $_) for ( @fixtures_weeks ); 
      }
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($season->name), $lang->maketext("admin.message.edited")));
    }
    
    unless ( $restricted_edit ) {
      # Now send our divisions through to the check / create routine
      my $division_response = $schema->resultset("Division")->check_and_create({
        divisions => $divisions,
        logger => $logger,
      });
      
      # Push any responses we get back to the calling routine
      push(@{$response->{errors}}, @{$division_response->{errors}});
      push(@{$response->{warnings}}, @{$division_response->{warnings}});
      push(@{$response->{info}}, @{$division_response->{info}});
      push(@{$response->{success}}, @{$division_response->{success}});
      $response->{divisions} = $division_response->{divisions};
      $response->{divisions_completed} = $division_response->{completed};
    }
  }
  
  # The season needs to be returned so we have a handle to it in the controller  
  $response->{season} = $season;
  return $response;
}

1;
