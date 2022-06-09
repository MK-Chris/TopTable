  package TopTable::Schema::ResultSet::Person;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use Try::Tiny;
use Email::Valid;
use HTML::Entities;
use Text::CSV;
use DateTime::Format::CLDR;

=head2 get_person_and_gender

A find() wrapper that also prefetches the gender.

=cut

sub get_person_and_gender {
  my ( $self, $id ) = @_;
  
  return $self->find({id => $id}, {
    prefetch => [qw( gender user )],
  });
}

=head2 all_people

Return a list of all people sorted by surname then first name.  If a season is specified, only the people playing in that season will be returned.

=cut

sub all_people {
  my ( $self, $season ) = @_;
  my ( $where, $attrib );
  
  if ( $season ) {
    $where = {
      "person_seasons.season" => $season->id,
    };
    
    $attrib = {
      join => "person_seasons",
      order_by => {
        -asc => [qw( surname first_name )],
      },
    };
  } else {
    $where = {};
    $attrib = {
      order_by => {-asc => [qw( surname first_name )]},
    };
  }
  
  return $self->search($where, $attrib);
}

=head2 page_records

Retrieve a paginated list of all people

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
    order_by => {-asc => [qw( surname first_name )]},
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
  my @words = split(/\s+/, $q);
  
  # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
  my $where;
  if ( $split_words ) {
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push(@constructed_like, $constructed_like);
    }
    
    $where = {"me.display_name" => \@constructed_like};
  } else {
    # Don't split words up before performing a like
    $where = {"me.display_name" => {-like => "%$q%"}};
  }
  
  my $attrib = {
    order_by => {-asc => [qw( me.surname me.first_name )]},
    group_by => qw( me.display_name ),
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
    $where->{"person_seasons.season"} = $season->id;
    $attrib->{join} = "person_seasons";
  }
  
  return $self->search($where, $attrib);
}

=head2 find_person_in_season_and_team

=cut

sub find_person_in_season_and_team {
  my ( $self, $team, $season, $name, $exclude_id ) = @_;
  my $attrib;
  
  if ( $exclude_id ) {
    $attrib = {
      where => {
        "me.display_name" => $name,
        "person_seasons.team" => $team->id,
        "person_seasons.season" => $season->id,
        id => {"!=" => $exclude_id}
      },
      join  => [qw( person_seasons )],
    };
  } else {
    $attrib = {
      where => {
        "me.display_name" => $name,
        "person_seasons.team" => $team->id,
        "person_seasons.season" => $season->id,
      },
      join  => [qw( person_seasons )]
    };
  }
  
  return $self->find({}, $attrib);
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

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_with_user {
  my ( $self, $id_or_url_key ) = @_;
  my $where;
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - look in ID or URL key
    $where = [{
      "me.id" => $id_or_url_key
    }, {
      "me.url_key" => $id_or_url_key
    }];
  } else {
    # Not numeric - must be the URL key
    $where = {"me.url_key" => $id_or_url_key};
  }
  
  return $self->search($where, {
    prefetch => "user",
    rows => 1,
  })->single;
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

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a team.

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
  my $person = $params->{person} || undef;
  my $first_name = $params->{first_name} || undef;
  my $surname = $params->{surname} || undef;
  my $address1 = $params->{address1} || undef;
  my $address2 = $params->{address2} || undef;
  my $address3 = $params->{address3} || undef;
  my $address4 = $params->{address4} || undef;
  my $address5 = $params->{address5} || undef;
  my $postcode = $params->{postcode} || undef;
  my $home_telephone = $params->{home_telephone} || undef;
  my $mobile_telephone = $params->{mobile_telephone} || undef;
  my $work_telephone = $params->{work_telephone} || undef;
  my $email_address = $params->{email_address} || undef;
  my $gender = $params->{gender} || undef;
  my $date_of_birth = $params->{date_of_birth} || undef;
  my $team = $params->{team} || undef;
  my $captain_of = $params->{captain_of} || undef;
  my $secretary_of = $params->{secretary_of} || undef;
  my $registration_date = $params->{registration_date} || undef;
  my $fees_paid = $params->{fees_paid};
  my $user = $params->{user} || undef;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      first_name => $first_name,
      surname => $surname,
      address1 => $address1,
      address2 => $address2,
      address3 => $address3,
      address4 => $address4,
      address5 => $address5,
      postcode => $postcode,
      home_telephone => $home_telephone,
      mobile_telephone => $mobile_telephone,
      work_telephone => $work_telephone,
      email_address => $email_address,
    },
    completed => 0,
    secretaries_removed => [],
    captains_removed => [],
    secretaries_added => [],
    captains_added => [],
  };
  
  # Ensure we have a current season first
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    # Redirect and show the error
    push(@{$response->{errors}}, $lang->maketext("people.create.no-season"));
    return $response;
  }
  
  my ( $person_seasons, $active_person_season );
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( defined($person) ) {
      $person = $self->find_id_or_url_key($person) unless ref($person) eq "TopTable::Model::DB::Person";
      
      if ( defined($person) ) {
        # Search for the person season - membership type 1 just searches for the active one
        $person_seasons = $person->search_related("person_seasons", {
          "me.season" => $season->id,
          "team_season.season" => $season->id,
        }, {prefetch => {team_season => "team"}});
        
        $active_person_season = $person_seasons->find({team_membership_type => "active"}) if $person_seasons->count > 0;
      } else {
        # Not valid.
        push(@{ $response->{errors} }, $lang->maketext("people.form.error.person-not-valid"));
        return $response;
      }
    } else {
      # Not specified.
      push(@{ $response->{errors} }, $lang->maketext("people.form.error.person-not-specified"));
      return $response;
    }
  }
  
  # Error checking
  # Check the first and surnames have been filled out
  if ( $first_name and $surname ) {
    my $person_name_check;
    if ( $action eq "edit" ) {
      $person_name_check = $self->find({}, {
        where => {
          first_name => $first_name,
          surname => $surname,
          id => {"!=" => $person->id}
        }
      });
    } else {
      $person_name_check = $self->find({
        first_name => $first_name,
        surname => $surname,
      });
    }
    
    push(@{$response->{errors}}, $lang->maketext("people.form.error.duplicate-name", $first_name, $surname)) if defined($person_name_check);
  } else {
    push(@{$response->{errors}}, $lang->maketext("people.form.error.first-name-blank")) unless defined($first_name);
    push(@{$response->{errors}}, $lang->maketext("people.form.error.surname-blank")) unless defined($surname);
  }
  
  # Check the email address is valid if we have one.
  if ( defined($email_address) ) {
    # We have an email addreess, check it's vali
    $email_address = Email::Valid->address($email_address);
    push(@{$response->{errors}}, $lang->maketext("people.form.error.email-invalid")) unless defined($email_address);
  }
  
  # Check the specified gender is valid (if there is one)
  if ( defined($gender) ) {
    # Gender is defined, so check it.  Not specifying a gender is fine
    $gender = $schema->resultset("LookupGender")->find($gender) unless ref($gender) eq "TopTable::Model::DB::LookupGender";
    push(@{$response->{errors}}, $lang->maketext("people.form.error.gender-invalid")) unless defined($gender);
  }
  
  $response->{fields}{gender} = $gender;
  
  my $date_error = undef;
  if ( defined($date_of_birth) ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    if ( ref($date_of_birth) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $date_of_birth->{year};
      my $month = $date_of_birth->{month};
      my $day = $date_of_birth->{day};
      
      # Make sure the date is valid
      try {
        $date_of_birth = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        $date_error = $lang->maketext("people.form.error.date-of-birth-invalid");
      };
    } elsif ( ref($date_of_birth) ne "DateTime" ) {
      $date_error = $lang->maketext("people.form.error.date-of-birth-invalid");
    }
  }
  
  $response->{fields}{date_of_birth} = $date_of_birth;
  
  push(@{$response->{errors}}, $date_error) if defined($date_error);
  
  undef($date_error);
  if ( defined($registration_date) ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    if ( ref($registration_date) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $registration_date->{year};
      my $month = $registration_date->{month};
      my $day = $registration_date->{day};
      
      # Make sure the date is valid
      try {
        $registration_date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        $date_error = $lang->maketext("people.form.error.date-of-birth-invalid");
      };
    } elsif ( ref($registration_date) ne "DateTime" ) {
      $date_error = $lang->maketext("people.form.error.registration-date-invalid");
    }
  }
  
  $response->{fields}{registration_date} = $registration_date;
  
  push(@{$response->{errors}}, $date_error) if defined($date_error);
  
  # Check the team entered is correct
  if ( defined($team) ) {
    # Team is specified, check it's valid
    $team = $schema->resultset("Team")->find_with_prefetches($team) unless ref($team) eq "TopTable::Model::DB::Team";
    
    if ( defined($team) ) {
      # If it's valid, now check they've entered
      my $team_season = $team->search_related("team_seasons", {season => $season->id});
      
      # If we don't find a team season, they're not entered yet
      push(@{$response->{errors}}, $lang->maketext("people.form.error.team-not-entered", sprintf("%s %s", encode_entities($team->club->short_name), encode_entities($team->name)), encode_entities($season->name))) unless defined($team_season);
    } else {
      # The team isn't valid
      push(@{$response->{errors}}, $lang->maketext("people.form.error.team-invalid"));
    }
  }
  
  # These will hold the IDs only so that we can produce a not_in query later on to remove captaincies / secretaryships that no longer involve this person
  my ( @team_season_captain_ids, @team_season_captains, @team_captains );
  
  # If we've been given an array ref, just use that; if not, we need to make it an arrayref, so it's easier to loop through
  $captain_of = [$captain_of] unless ref($captain_of) eq "ARRAY";
  
  # Loop through the captain objects (these are actually teams that this person should be captain of)
  foreach my $captain_team ( @{$captain_of} ) {
    if ( defined($captain_team) ) {
      # Look up the team if it wasn't passed in as a DB object
      $captain_team = $schema->resultset("Team")->find_with_prefetches($captain_team) unless ref($captain_team) eq "TopTable::Model::DB::Team";
      
      if ( defined($captain_team) ) {
        # The object is a reference to a team, get the team season object and push it on to the array
        my $team_season = $captain_team->find_related("team_seasons", {season => $season->id});
        
        if ( defined($team_season) ) {
          # Push on to the array of captains to keep (not set to null) if we're editing (if we're creating, there's no way this person can have been captain before)
          push(@team_season_captain_ids, $captain_team->id) if $action eq "edit";
          push(@team_season_captains, $team_season);
          push(@team_captains, $captain_team);
        } else {
          # If we don't find a team season, they're not entered yet
          push(@{$response->{errors}}, "people.form.error.captain-team-not-entered", sprintf("%s %s", encode_entities($captain_team->club->short_name), encode_entities($captain_team->name)), encode_entities($season->name));
        }
      } else {
        # Invalid captain after lookup
        push(@{$response->{warnings}}, $lang->maketext("people.form.warning.captain-team-invalid"));
      }
    }
  }
  
  # If we've been given an array ref, just use that; if not, we need to make it an arrayref, so it's easier to loop through
  $secretary_of = [$secretary_of] unless ref($secretary_of) eq "ARRAY";
  
  # Loop through the secretary objects (these are actually clubs that this person should be secretary of)
  my ( @club_secretary_ids, @club_secretaries, @club_season_secretaries );
  foreach my $club ( @{$secretary_of} ) {
    if ( defined($club) ) {
      $club = $schema->resultset("Club")->find_id_or_url_key($club) unless ref($club) eq "TopTable::Model::DB::Club";
      
      if ( defined($club) ) {
        # The object is a reference to a club, get the team season object and push it on to the array
        my $club_season = $club->find_related("club_seasons", {season => $season->id});
        
        push(@club_season_secretaries, $club_season);
        push(@club_secretaries, $club);
        
        # Push on to the array of clubs to keep (not set to null) if we're editing (if we're creating, there's no way this person can have been secretary before)
        push (@club_secretary_ids, $club->id) if $action eq "edit";
      } else {
        # Invalid club, warn, but don't error
        push(@{$response->{warnings}}, $lang->maketext("people.form.warning.secretary-club-invalid"));
      }
    }
  }
  
  $response->{fields}{team} = $team;
  $response->{fields}{captain_of} = \@team_captains;
  $response->{fields}{secretary_of} = \@club_secretaries;
  
  # Sanity check to ensure we have 1 or 0
  $fees_paid = $fees_paid ? 1 : 0;
  $response->{fields}{fees_paid} = $fees_paid;
  
  # Username check
  if ( defined($user) ) {
    # User passed in, check it's valid
    $user = $schema->resultset("User")->find_id_or_url_key($user) unless ref($user) eq "TopTable::Model::DB::User";
    
    # Check the user is valid
    push(@{$response->{warnings}}, $lang->maketext("people.form.warning.username-invalid", encode_entities($first_name))) unless defined($user);
  }
  
  $response->{fields}{user} = $user;
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # Display name is just first name surname
    my $display_name = "$first_name $surname";
    
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key($display_name, $person->id);
    } else {
      $url_key = $self->generate_url_key($display_name);
    }
    
    # These dates need to be checked first - we format them for SQL if they hold values.
    $registration_date = $registration_date->ymd if defined($registration_date) and ref($registration_date) eq "DateTime";
    $date_of_birth = $date_of_birth->ymd if defined($date_of_birth) and ref($date_of_birth) eq "DateTime";
    
    # Success, we need to create / edit the team
    # First we set up the hashref for new person season data so we only need to do it once (if at all, but here is the easiest place to do it) 
    my $new_person_season_data = {
      season => $season->id,
      team => $team->id,
      first_name => $first_name,
      surname => $surname,
      display_name => $display_name, # Automatically set the display name from first and surnames - the user never interacts with this field.
      registration_date => $registration_date,
      fees_paid => $fees_paid,
    } if defined($team);
    
    
    # Transaction so if we fail, nothing is updated
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    if ( $action eq "create" ) {
      # Setup the person creation data - if they have a team specified, we'll create a person_season connection too
      my $person_create_data = {
        url_key => $url_key,
        first_name => $first_name,
        surname => $surname,
        display_name => $display_name, # Automatically set the display name from first and surnames - the user never interacts with this field.
        address1 => $address1,
        address2 => $address2,
        address3 => $address3,
        address4 => $address4,
        address5 => $address5,
        postcode => $postcode,
        home_telephone => $home_telephone,
        mobile_telephone => $mobile_telephone,
        work_telephone => $work_telephone,
        email_address => $email_address,
        date_of_birth => $date_of_birth,
        gender => defined($gender) ? $gender->id : undef,
      };
      
      $person_create_data->{person_seasons} = [$new_person_season_data] if defined($team);
      $person = $self->create($person_create_data);
    } else {
      # Editing
      # Update the main person object
      $person->update({
        url_key => $url_key,
        first_name => $first_name,
        surname => $surname,
        display_name => $display_name, # Automatically set the display name from first and surnames - the user never interacts with this field.
        address1 => $address1,
        address2 => $address2,
        address3 => $address3,
        address4 => $address4,
        address5 => $address5,
        postcode => $postcode,
        home_telephone => $home_telephone,
        mobile_telephone => $mobile_telephone,
        work_telephone => $work_telephone,
        email_address => $email_address,
        date_of_birth => $date_of_birth,
        gender => defined($gender) ? $gender->id : undef,
      });
      
      # Ensure the name is updated for any person season objects from this season
      $person->search_related("person_seasons", {season => $season->id})->update({
        first_name => $first_name,
        surname => $surname,
        display_name => $display_name, # Automatically set the display name from first and surnames - the user never interacts with this field.
      });
      
      # Because we're updating, there is a complex-ish system of checks for teams that this person is playing for
      if ( defined($team) ) {
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
                team_membership_type => {"!=" => "active"}
              },
            });
            
            # Check if we need to activate an inactive one, or create a new active one
            if ( defined( $association_to_activate ) ) {
              # Activate this association
              $association_to_activate->update({team_membership_type => "active"});
            } else {
              my $new_association = $person->create_related("person_seasons", $new_person_season_data);
            }
            
            # Either way, we need to deactivate the current one (or delete it if there are no matches played on it)
            if ( $active_person_season->matches_played > 0 ) {
              # This person has played matches for this team, so we just deactivate it
              $active_person_season->update({team_membership_type => "inactive"});
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
          
          my $pairings = $pairings1->union($pairings2);
          
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
      my $captains_to_remove = $person->search_related("team_seasons", {
        season => $season->id,
        team => {-not_in => \@team_season_captain_ids},
      });
      
      # Get the team opjects
      my @captains_to_remove = $captains_to_remove->search_related("team");
      $response->{captains_removed} = \@captains_to_remove;
      
      $captains_to_remove->update({captain => undef});
      
      # Update club objects and club season objects
      $person->search_related("club_seasons", {
        club => {-not_in => \@club_secretary_ids},
      })->update({secretary => undef});
      
      # Get a list of clubs to remove
      my $secretaries_to_remove = $person->search_related("clubs", {
        id => {-not_in => \@club_secretary_ids},
      });
      
      # Add to the array to pass back to the calling routine
      my @secretaries_removed = $secretaries_to_remove->all;
      $response->{secretaries_removed} = \@secretaries_removed;
      
      # Now do the removal on the clubs
      $secretaries_to_remove->update({secretary => undef});
    }
    
    # Finally, regardless of creation / editing, we need to add captaincy / secretaryship to any teams / clubs respectively
    foreach my $team_season ( @team_season_captains ) {
      $team_season->captain($person->id);
      
      if ( $team_season->is_column_changed("captain") ) {
        # The column has changed, so this team had a different captain or the captain was null
        $team_season->update;
        push(@{$response->{captains_added}}, $team_season->team);
      }
    }
    
    foreach my $club_season ( @club_season_secretaries ) {
      $club_season->secretary($person->id);
      
      if ( $club_season->is_column_changed("secretary") ) {
        # The column has changed, so this team had a different captain or the captain was null
        $club_season->update;
        
        my $club = $club_season->club;
        $club->update({secretary => $person->id});
        
        push(@{$response->{secretaries_added}}, $club);
      }
    }
    
    # Update the user if required
    $user->update({person => $person->id}) if defined($user);
    
    # Commit the transaction
    $transaction->commit;
    
    # Set to completed with the relevant success message
    $response->{completed} = 1;
    if ( $action eq "create" ) {
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($person->display_name), $lang->maketext("admin.message.created")));
    } else {
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($person->display_name), $lang->maketext("admin.message.edited")));
    }
  }
  
  # Add the person to our return value
  $response->{person} = $person;
  
  # Finally return with everything we need
  return $response;
}

=head2 import

Import people from a CSV file - this function processes the CSV file into an array of people to import, then calls create_or_edit on each element of that array.

=cut

sub import {
  my ( $self, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, "@_"; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $fh = $params->{fh};
  my $date_format = $params->{date_format};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    added => [],
  };
  
  # Setup the date format for parsing dates
  my $cldr = DateTime::Format::CLDR->new(pattern => $date_format) if defined($date_format);
  
  # Ensure we have a current season first
  my $season = $schema->resultset("Season")->get_current;
  
  unless ( defined($season) ) {
    # Redirect and show the error
    push(@{$response->{errors}}, $lang->maketext("people.import.no-season"));
    return $response;
  }
  
  my $csv = Text::CSV->new({binary => 1}) or push(@{$response->{errors}}, $lang->maketext("people.form.import-results.csv-error", encode_entities(Text::CSV->error_diag)));
  return $response if scalar @{$response->{errors}};
  
  # This will hold the data we read in.  It will largely resemble what should go into a ->populate command,
  # but not quite because we need the return values to potentially update clubs and teams with secretaries
  # and captains.
  my @people = ();
  
  # This holds the field position numbers for each field name (zero-based so we can use the array index without minusing the value)
  my @people_field_positions = ();
  
  # Loop through the file lines (one person per line)
  # Keep a line count so we know if we're on the first line (headings)
  my $i = 0;
  while ( my $line = $csv->getline($fh) ) {
    # $line is an array ref of cols
    
    # Next line if this one is blank
    next unless scalar @{$line};
    
    # Increase line number
    $i++;
    
    # Get the array index - line number - 2 (first row is the column headers and arrays are zero-based)
    #my $array_index;
    
    if ( $i > 1 ) {
      # Setup the initial array row
      push(@people, {
        errors => [],
        warnings => [],
        info => [],
        success => [],
        fields => {},
      });
      
      #$array_index = $#people;
    }
    
    # Column count
    my $x = 0;
    
    # Loop through the fields
    foreach my $field ( @{$line} ) {
      if ( $i == 1 ) {
        # First line: column headers; set them up as field names
        # We need to check the column exists or is one of our pre-defined 'other' columns to set the team
        if ( $self->result_source->has_column($field) or $field eq "club" or $field eq "team" ) {
          # Field exists or is a special field to add some related data; save the field position number
          push(@people_field_positions, $field);
        } else {
          # Field not recognised
          push(@{$response->{errors}}, $lang->maketext("people.form.import-results.field-heading-invalid", $field));
        }
      } else {
        # Column data, push the value on to this field's column (or undef if it's blank)
        # First we need this column's name, which we can work out from the array we built
        # up on the first row
        my $field_name = $people_field_positions[$x] || undef;
        
        # If it's a date, try and format it
        if ( $field_name eq "date_of_birth" or $field_name eq "registration_date" ) {
          $field = $cldr->parse_datetime($field);
        }
        
        # Assign the field's value to a hashref with its name as the key
        $people[$#people]{fields}{$field_name} = $field || undef;
      }
      
      # Increment column number so we can store where this field occurs when we come to find the data
      $x++;
    }
  }
  
  # Close the file when we're done with it
  $fh->close;
  
  # These arrays will hold the successful and failed rows for display and the details of IDs and names created
  my ( @successful_rows, @failed_rows, @ids, @names );
  
  # End of loop through data, now loop through and do some sanity checks
  foreach my $person ( @people ) {
    # Save the names of fields that refer to foreign tables for displaying later and validate them
    $person->{fields}{club_name} = delete $person->{fields}{club};
    $person->{fields}{team_name} = $person->{fields}{team};
    $person->{fields}{gender_name} = $person->{fields}{gender};
    
    # Validate the playing team if there is one
    my $club_name = $person->{fields}{club_name};
    my $team_name = $person->{fields}{team_name};
    if ( defined($club_name) and defined($team_name) ) {
      my $team = $schema->resultset("Team")->find_by_names({club_name => $club_name, team_name => $team_name});
      
      if ( defined($team) ) {
        $person->{fields}{team} = $team;
      } else {
        push(@{$person->{fields}{errors}}, $lang->maketext("people.form.error.team-invalid"));
      }
    } elsif ( defined($club_name) ) {
      # Club specified but no team
      push(@{$person->{errors}}, $lang->maketext("people.form.import-results.team-not-specified"));
    } elsif ( defined($team_name) ) {
      # Team specified but no club
      push(@{$person->{errors}}, $lang->maketext("people.form.import-results.club-not-specified"));
    }
    
    # Validate the gender if there is one
    if ( defined($person->{fields}{gender}) ) {
      $person->{fields}{gender} = $schema->resultset("LookupGender")->find($person->{fields}{gender});
      push(@{$person->{errors}}, $lang->maketext("people.form.import-results.gender-invalid")) unless defined($person->{fields}{gender});
    }
    
    # If we had an (some) error(s) on this row, we'll need to splice it out and append it (them) to the main returned error
    if ( scalar @{$person->{errors}} ) {
      # Push our failed row on to the failed rows array
      push(@failed_rows, $person);
    } else {
      # No error, pass on to the creation routine, which does the rest of the checking first
      my $create_result = $self->create_or_edit("create", $person->{fields});
      
      # Check our responses
      my @errors = @{$create_result->{errors}};
      my @warnings = @{$create_result->{warnings}};
      my @info = @{$create_result->{info}};
      my @success = @{$create_result->{success}};
      
      push(@{$person->{errors}}, @errors);
      push(@{$person->{warnings}}, @warnings);
      push(@{$person->{info}}, @info);
      push(@{$person->{success}}, @success);
      
      $person->{person} = $create_result->{person};
      
      # Check for errors
      if ( scalar @{$create_result->{errors}} ) {
        # If there are errors, we need to push this row on to the failed rows array after assigning the error in the array row
        push(@failed_rows, $person);
      } else {
        # Success, push the row on to the successful rows array after adding the new person object on to the hashref
        push(@successful_rows, $person);
        
        # Push the event log details we'll need
        push(@{$response->{added}}, {id => $person->{person}->id, name => $person->{person}->display_name});
        push(@ids, {id => $person->{person}->id});
        push(@names, $person->{person}->display_name);
      }
    }
  }
  
  
  $response->{ids} = \@ids;
  $response->{names} = \@names;
  $response->{successful_rows} = \@successful_rows;
  $response->{failed_rows} = \@failed_rows;
  push(@{$response->{success}}, $lang->maketext("people.form.import-results.successfully-imported", scalar @successful_rows)) if scalar @successful_rows;
  push(@{$response->{errors}}, $lang->maketext("people.form.import-results.import-failures", scalar @failed_rows)) if scalar @failed_rows;
  
  return $response;
}

1;
