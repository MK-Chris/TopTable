package TopTable::Schema::ResultSet::Person;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use Try::Tiny;
use Data::Dumper::Concise;

=head2 get_person_and_gender

A find() wrapper that also prefetches the gender.

=cut

sub get_person_and_gender {
  my ( $self, $id ) = @_;
  
  return $self->find({
    id        => $id,
  }, {
    prefetch  => [ qw( gender user ) ],
  });
}

=head2 all_people

Return a list of all people sorted by surname then first name.  If a season is specified, only the people playing in that season will be returned.

=cut

sub all_people {
  my ( $self, $season ) = @_;
  my ( $where, $attributes );
  
  if ( $season ) {
    $where      = {
      "person_seasons.season" => $season->id,
    };
    
    $attributes = {
      join      => "person_seasons",
      order_by  => {
        -asc => [
          qw( surname first_name )
        ],
      },
    };
  } else {
    $where      = {};
    $attributes = {
      order_by => {
        -asc => [
          qw( surname first_name )
        ],
      },
    };
  }
  
  return $self->search( $where, $attributes );
}

=head2 page_records

Retrieve a paginated list of all people

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
      -asc => [ qw( surname first_name ) ],
    },
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $season = delete $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = delete $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Split into words, so we can match a single word
  my @words = split( /\s+/, $q );
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my ( $where );
  if ( $split_words ) {
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
    }
    
    $where = {"me.display_name" => \@constructed_like};
  } else {
    # Don't split words up before performing a like
    $where = {
      "me.display_name" => {-like => "%$q%"}
    };
  }
  
  my $attrib = {
    order_by => {-asc => [ qw( me.surname me.first_name ) ]},
    group_by => qw( me.display_name ),
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
    $where->{"person_seasons.season"} = $season->id;
    $attrib->{join} = "person_seasons";
  }
  
  return $self->search( $where, $attrib );
}

=head2 find_person_in_season_and_team

=cut

sub find_person_in_season_and_team {
  my ( $self, $team, $season, $name, $exclude_id ) = @_;
  my ( $attributes );
  
  if ( $exclude_id ) {
    $attributes = {
      where => {
        "me.display_name"       => $name,
        "person_seasons.team"   => $team->id,
        "person_seasons.season" => $season->id,
        id                      => {
          "!=" => $exclude_id
        }
      },
      join  => [ qw( person_seasons ) ]
    };
  } else {
    $attributes = {
      where => {
        "me.display_name"       => $name,
        "person_seasons.team"   => $team->id,
        "person_seasons.season" => $season->id,
      },
      join  => [ qw( person_seasons ) ]
    };
  }
  
  return $self->find({}, $attributes);
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

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_with_user {
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
  
  return $self->find( $where, {
    prefetch  => "user",
  });
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
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

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a team.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $dob_error, $registration_date_error, @team_season_captains, @club_secretaries );
  my $return_value = {error => []};
  
  my $person            = $parameters->{person};
  my $first_name        = $parameters->{first_name};
  my $surname           = $parameters->{surname};
  my $address1          = $parameters->{address1};
  my $address2          = $parameters->{address2};
  my $address3          = $parameters->{address3};
  my $address4          = $parameters->{address4};
  my $address5          = $parameters->{address5};
  my $postcode          = $parameters->{postcode};
  my $home_telephone    = $parameters->{home_telephone};
  my $mobile_telephone  = $parameters->{mobile_telephone};
  my $work_telephone    = $parameters->{work_telephone};
  my $email_address     = $parameters->{email_address};
  my $gender            = $parameters->{gender};
  my $date_of_birth     = $parameters->{date_of_birth};
  my $team              = $parameters->{team};
  my $captains          = $parameters->{captains};
  my $secretaries       = $parameters->{secretaries};
  my $registration_date = $parameters->{registration_date};
  my $fees_paid         = $parameters->{fees_paid};
  my $user              = $parameters->{user};
  my $season            = $parameters->{season};
  my $log               = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.    
  
  my ($dob_day, $dob_month, $dob_year) = split("/", $date_of_birth) if defined( $date_of_birth );
  my ($registration_day, $registration_month, $registration_year) = split("/", $registration_date) if defined( $registration_date );
  
  # Check the season is valid
  if ( !defined( $season ) or ref( $season ) ne "TopTable::Model::DB::Season" ) {
    push(@{ $return_value->{error} }, {id => "seasons.form.error.season-invalid"});
    return $return_value;
  } else {
    # Check it's current
    if ( $season->complete ) {
      push(@{ $return_value->{error} }, {id => "people.form.error.season-not-current"});
      return $return_value;
    }
  }
  
  my ( $person_seasons, $active_person_season );
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ($action eq "edit") {
    if ( defined( $person ) and ref( $person ) eq "TopTable::Model::DB::Person" ) {
      # Search for the person season - membership type 1 just searches for the active one
      $person_seasons = $person->search_related("person_seasons", {
        "me.season"           => $season->id,
        "team_season.season"  => $season->id,
      }, {
        prefetch => {team_season => "team"},
      });
      
      $active_person_season = $person_seasons->find({
        team_membership_type => "active",
      }) if $person_seasons->count > 0;
    } else {
      # Editing a club that doesn't exist.
      push(@{ $return_value->{error} }, {id => "people.form.error.person-not-valid"});
      return $return_value;
    }
  }
  
  # Error checking
  # Check the first and surnames have been filled out
  if ( $first_name and $surname ) {
    my $person_name_check;
    if ( $action eq "edit" ) {
      $person_name_check = $self->find({}, {
        where => {
          first_name  => $first_name,
          surname     => $surname,
          id          => {
            "!="      => $person->id,
          }
        }
      });
    } else {
      $person_name_check = $self->find({
        first_name  => $first_name,
        surname     => $surname,
      });
    }
    
    push(@{ $return_value->{error} }, {
      id          => "people.form.error.duplicate-name",
      parameters  => [$first_name, $surname],
    }) if defined( $person_name_check );
  } else {
    push(@{ $return_value->{error} }, {id => "people.form.error.first-name-blank"}) if !$first_name;
    push(@{ $return_value->{error} }, {id => "people.form.error.surname-blank"}) if !$surname;
  }
  
  # Check the email address is valid if we have one.
  push(@{ $return_value->{error} }, {id => "people.form.error.email-invalid"}) if $email_address and $email_address !~ m/^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i;
  
  # Check the specified gender is valid (if there is one)
  push(@{ $return_value->{error} }, {id => "people.form.error.gender-invalid"}) if defined( $gender ) and ref( $gender ) ne "TopTable::Model::DB::LookupGender";
  
  if ( $date_of_birth ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    try {
      $date_of_birth = DateTime->new(
        year  => $dob_year,
        month => $dob_month,
        day   => $dob_day,
      );
    } catch {
      push(@{ $return_value->{error} }, {id => "people.form.error.date-of-birth-invalid"});
    };
  } else {
    $date_of_birth = undef;
  }
  
  if ( $registration_date ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    try {
      $registration_date = DateTime->new(
        year  => $registration_year,
        month => $registration_month,
        day   => $registration_day,
      );
    } catch {
      push(@{ $return_value->{error} }, {id => "people.form.error.registration-date-invalid"});
    };
    
  } else {
    $registration_date = undef;
  }
  
  # Check the team entered is correct
  if ( defined( $team ) and ref( $team ) eq "TopTable::Model::DB::Team" ) {
    # Team is specified and valid, check they've entered
    my $team_season = $team->search_related("team_seasons", {season => $season->id});
    
    # If we don't find a team season, they're not entered yet
    push(@{ $return_value->{error} }, {
      id          => "people.form.error.team-not-entered",
      parameters  => [ $team->club->short_name, $team->name, $season->name ],
    }) unless defined( $team_season );
  } elsif ( defined( $team ) ) {
    # Team is specified but invalid
    push(@{ $return_value->{error} }, {id => "people.form.error.team-invalid"});
  }
  
  # These will hold the IDs only so that we can produce a not_in query later on to remove captaincies / secretaryships that no longer involve this person
  my ( @team_season_captain_ids, @club_secretary_ids );
  
  # If we've been given an array ref, just use that; if not, we need to make it an arrayref, so it's easier to loop through
  $captains = [$captains] unless ref( $captains ) eq "ARRAY";
  
  # Loop through the captain objects (these are actually teams that this person should be captain of)
  foreach my $captain_team ( @{$captains} ) {
    if ( defined( $captain_team ) and ref( $captain_team ) eq "TopTable::Model::DB::Team" ) {
      # The object is a reference to a team, get the team season object and push it on to the array
      my $captain_team_season = $captain_team->search_related("team_seasons", {season => $season->id});
      
      if ( defined( $captain_team_season ) ) {
        # Push on to the array of captains to keep (not set to null) if we're editing (if we're creating, there's no way this person can have been captain before)
        push( @team_season_captain_ids, $captain_team->id ) if $action eq "edit";
        push( @team_season_captains, $captain_team_season );
      } else {
        # If we don't find a team season, they're not entered yet
        push(@{ $return_value->{error} }, {
          id          => "people.form.error.captain-team-not-entered",
          parameters  => [ $captain_team->club->short_name, $captain_team->name, $season->name ],
        });
      }
    } else {
      # Invalid object
      push(@{ $return_value->{error} }, {
        id          => "people.form.error.captain-team-invalid",
        parameters  => [$captain_team],
      });
    }
  }
  
  # If we've been given an array ref, just use that; if not, we need to make it an arrayref, so it's easier to loop through
  $secretaries = [$secretaries] unless ref( $secretaries ) eq "ARRAY";
  
  # Loop through the secretary objects (these are actually clubs that this person should be secretary of)
  foreach my $club ( @{$secretaries} ) {
    if ( defined( $club ) and ref( $club ) eq "TopTable::Model::DB::Club" ) {
      # The object is a reference to a team, get the team season object and push it on to the array
      push( @club_secretaries, $club );
      
      # Push on to the array of clubs to keep (not set to null) if we're editing (if we're creating, there's no way this person can have been secretary before)
      push ( @club_secretary_ids, $club->id ) if $action eq "edit";
    } else {
      # Invalid object
      push(@{ $return_value->{error} }, {
        id          => "people.form.error.secretary-club-invalid",
        parameters  => [$club],
      });
    }
  }
  
  # Sanity check to ensure we have 1 or 0
  if ( $fees_paid ) {
    $fees_paid = 1;
  } else {
    $fees_paid = 0;
  }
  
  # Username check
  push(@{ $return_value->{error} }, {id => "people.form.error.username-invalid"}) if defined( $user ) and ref( $user ) ne "TopTable::Model::DB::User";
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( sprintf( "%s %s", $first_name, $surname ), $person->id );
    } else {
      $url_key = $self->generate_url_key( sprintf( "%s %s", $first_name, $surname ) );
    }
    
    # These dates need to be checked first - we format them for SQL if they hold values.
    $registration_date  = $registration_date->ymd if defined( $registration_date ) and ref( $registration_date ) eq "DateTime";
    $date_of_birth      = $date_of_birth->ymd if defined( $date_of_birth ) and ref( $date_of_birth ) eq "DateTime";
    
    # Success, we need to create / edit the team
    # First we set up the hashref for new person season data so we only need to do it once (if at all, but here is the easiest place to do it) 
    my $new_person_season_data = {
      season                      => $season->id,
      team                        => $team->id,
      first_name                  => $first_name,
      surname                     => $surname,
      display_name                => sprintf( "%s %s", $first_name, $surname ), # Automatically set the display name from first and surnames - the user never interacts with this field.
      registration_date           => $registration_date,
      fees_paid                   => $fees_paid,
    } if defined( $team );
    
    if ( $action eq "create" ) {
      # Setup the person creation data - if they have a team specified, we'll create a person_season connection too
      my $person_create_data = {
        url_key           => $url_key,
        first_name        => $first_name,
        surname           => $surname,
        display_name      => sprintf( "%s %s", $first_name, $surname ), # Automatically set the display name from first and surnames - the user never interacts with this field.
        address1          => $address1,
        address2          => $address2,
        address3          => $address3,
        address4          => $address4,
        address5          => $address5,
        postcode          => $postcode,
        home_telephone    => $home_telephone,
        mobile_telephone  => $mobile_telephone,
        work_telephone    => $work_telephone,
        email_address     => $email_address,
        date_of_birth     => $date_of_birth,
        gender            => $gender,
      };
      
      $person_create_data->{person_seasons} = [$new_person_season_data] if defined($team);
      
      $person = $self->create( $person_create_data );
    } else {
      # Editing
      $person->update({
        url_key           => $url_key,
        first_name        => $first_name,
        surname           => $surname,
        display_name      => sprintf( "%s %s", $first_name, $surname ), # Automatically set the display name from first and surnames - the user never interacts with this field.
        address1          => $address1,
        address2          => $address2,
        address3          => $address3,
        address4          => $address4,
        address5          => $address5,
        postcode          => $postcode,
        home_telephone    => $home_telephone,
        mobile_telephone  => $mobile_telephone,
        work_telephone    => $work_telephone,
        email_address     => $email_address,
        date_of_birth     => $date_of_birth,
        gender            => $gender,
      });
      
      # Ensure the name is updated for any person season objects from this season
      $person->search_related("person_seasons", {season => $season->id})->update({
        first_name        => $first_name,
        surname           => $surname,
        display_name      => sprintf( "%s %s", $first_name, $surname ), # Automatically set the display name from first and surnames - the user never interacts with this field.
      });
      
      
      # Because we're updating, there is a complex-ish system of checks for teams that this person is playing for
      if ( defined( $team ) ) {
        # We have a team defined - we need to do the following:
        #  * If there's an active team association where the team is the same as the one selected in this edit, we'll do nothing, as the team hasn't changed.
        #  * If there's an active team association where the team is different from the one selected in this edit, we'll make that inactive and either create a new team association (if there isn't an inactive one referencing this team) or make that inactive one active (if there is)
        #  * If there's no active team association, but there's an inactive one with the team selected in this edit, we'll make that active (though technically that shouldn't happen)
        #  * If there's no active team association and no inactive team association with the team selected in this edit, we'll create it.
        if ( defined( $active_person_season ) ) {
          # We have an active association - check if the team has changed in this edit
          if ( $active_person_season->team != $team->id ) {
            # The team has changed; see if there's an inactive association with this team
            my $association_to_activate = $person_seasons->find({}, {
              where => {
                "me.team" => $team->id,
                team_membership_type => {
                  "!=" => "active",
                }
              },
            });
            
            # Check if we need to activate an inactive one, or create a new active one
            if ( defined( $association_to_activate ) ) {
              # Activate this association
              $association_to_activate->update({
                team_membership_type => "active",
              });
            } else {
              my $new_association = $person->create_related("person_seasons", $new_person_season_data);
            }
            
            # Either way, we need to deactivate the current one (or delete it if there are no matches played on it)
            if ( $active_person_season->matches_played > 0 ) {
              # This person has played matches for this team, so we just deactivate it
              $active_person_season->update({
                team_membership_type => "inactive",
              });
            } else {
              # No matches played, delete
              $active_person_season->delete;
            }
          }
        } else {
          # No active season, just create one
          my $new_association = $person->create_related("person_seasons", $new_person_season_data);
        }
      } else {
        # No team defined; if there is an active season association where they haven't played yet, we'll remove it (if they have played, we'll leave it active,
        # as there's no point deactivating it for nothing.)
        if ( defined( $active_person_season ) and $active_person_season->matches_played == 0 ) {
          # Now search for doubles pairs to ensure they haven't played doubles
          my $pairings1 = $active_person_season->search_related("doubles_pairs_person1_season_teams", {
            games_played => {">" => 0},
          });
          
          my $pairings2 = $active_person_season->search_related("doubles_pairs_person2_season_teams", {
            games_played => {">" => 0},
          });
          
          my $pairings = $pairings1->union( $pairings2 );
          
          unless ( $pairings->count ) {
            # We may have a doubles pairing, but they haven't played, so we can delete them
            $active_person_season->delete_related("doubles_pairs_person1_season_teams");
            $active_person_season->delete_related("doubles_pairs_person2_season_teams");
            $active_person_season->delete;
          }
          
        }
      }
      
      # Do the setting to null of secretaries / captains where this person was captain / secretary but is no longer
      # @team_season_captain_ids, @club_secretary_ids
      $person->search_related("team_seasons", {
        season => $season->id,
        team => {
          -not_in => \@team_season_captain_ids,
        },
      })->update({
        captain => undef,
      });
      
      $person->search_related("clubs", {
        id => {
          -not_in => \@club_secretary_ids,
        },
      })->update({
        secretary => undef,
      });
    }
    
    # If we have a team, make sure the possible doubles combinations exist.  To do this, we need to get all the players already playing for the team
    if ( defined( $team ) ) {
      # Get a list of team-mates
      my $teammates = $team->search_related("team_seasons")->search_related("person_seasons", undef, {
        where => {
          "me.season"           => $season->id,
          team_membership_type  => "active",
          person                => {
            "!="                => $person->id,
          },
        },
        prefetch  => "person",
      });
      
      if ( $teammates->count ) {
        # If there are other people in the team, see if we have a doubles-membership with them
        # Loop through all teammates
        while ( my $teammate = $teammates->next ) {
          # Instruction to create the pairing will be 1 if we're creating, or initially 0 if editing (the
          # next if block will then determine whether we set this to 1 or not - if the pairing doesn't exist)
          my $create_pairing = ( $action eq "create" ) ? 1 : 0;
          if ( $action eq "edit" ) {
            # This is only necessary if we're editing; get the doubles pairing involving this teammate
            # and the player we're editing / creating for the team.
            my $pairings1 = $teammate->search_related("doubles_pairs_person1_season_teams", {
              person2 => $person->id,
              season  => $season->id,
              team    => $team->id,
            });
            
            my $pairings2 = $teammate->search_related("doubles_pairs_person2_season_teams", {
              person1 => $person->id,
              season  => $season->id,
              team    => $team->id,
            });
            
            my $pairings = $pairings1->union( $pairings2 );
            
            # Create the pairing unless the count is greater than zero (true value)
            $create_pairing = 1 unless $pairings->count;
          }
          
          # If we need to create the doubles pairing, do it here.  It doesn't matter which person is 1 and which is 2,
          # any searches will need to use an OR query to check both fields - as it happens, using create_related on
          # doubles_pairs_person1_season_teams with the teammate populates person1 with the teammate's ID, so we manually fill
          # person2 with our $person->id
          my $pairing = $teammate->create_related("doubles_pairs_person1_season_teams", {
            person2 => $person->id,
            season  => $season->id,
            team    => $team->id,
          }) if $create_pairing;
        }
      }
    }
    
    # Finally, regardless of creation / editing, we need to add captaincy / secretaryship to any teams / clubs respectively
    $_->update({captain => $person->id}) foreach @team_season_captains; # Update the team season with this person as captain
    $_->update({secretary => $person->id}) foreach @club_secretaries; # Update each club specified with this person as secretary
    
    # Update the user if required
    $user->update({person => $person->id}) if defined( $user );
  }
  
  # Add the person to our return value
  $return_value->{person} = $person;
  
  # Finally return with everything we need
  return $return_value;
}

1;
