package TopTable::Schema::ResultSet::Club;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;
use Regexp::Common qw( URI );

=head2 get_club_and_secretary_and_venue

A find() wrapper that also prefetches the secretary and venue.

=cut

sub get_club_and_secretary_and_venue {
  my $class = shift;
  my ( $club_id ) = @_;
  
  return $class->find({
    id => $club_id,
  }, {
    prefetch => [qw(secretary venue)],
  });
}

=head2 all_clubs_by_name

Retrieve all clubs without any prefetching, ordered by full name.

=cut

sub all_clubs_by_name {
  my $class = shift;
  
  return $class->search(undef, {
    order_by => {-asc => [qw( full_name )]}
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial full / short name.

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
  my ( $where );
  
  if ( $split_words ) {
    # Split individual words and perform a like on each one
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{
      "me.full_name" => \@constructed_like,
    }, {
      "me.short_name" => \@constructed_like,
    }, {
      "me.abbreviated_name" => \@constructed_like,
    }];
  } else {
    # Don't split words up before performing a like
    $where = [{
      "me.full_name" => {-like => "%$q%"},
    }, {
      "me.short_name" => {-like => "%$q%"},
    }, {
      "me.abbreviated_name" => {-like => "%$q%"},
    }];
  }
  
  my $attrib = {
    order_by => {-asc => [qw( me.full_name )]},
    group_by => [ qw( me.full_name ) ],
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
    $where->[0]{"club_seasons.season"} = $season->id;
    $where->[1]{"club_seasons.season"} = $season->id;
    $attrib->{join} = "club_seasons";
  }
  
  return $class->search($where, $attrib);
}

=head2 find_by_short_name

Does a find() based on the club short name.

=cut

sub find_by_short_name {
  my $class = shift;
  my ( $short_name ) = @_;
  return $class->find({short_name  => $short_name});
}

=head2 page_records

Returns a paginated resultset of clubs.

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
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => "full_name"},
  });
}

=head2 clubs_with_teams_in_season

Retrieve all clubs (and prefetch their teams) with teams entering a given season.

=cut

sub clubs_with_teams_in_season {
  my $class = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  my $get_teams = $params->{get_teams};
  my $get_players = $params->{get_players};
  
  my ( $where, $attrib );
  if ( $get_teams and $get_players ) {
    # Prefetch both teams and players
    $where = {
      "team_seasons.season" => $season->id,
      "person_seasons.season" => $season->id,    
    };
    
    $attrib = {
      prefetch => {
        teams => ["team_seasons", {person_seasons => "person"}],
      },
      order_by => {-asc => [qw( me.full_name teams.name person.surname person.first_name )]},
    };
  } elsif ( $get_teams ) {
    # Prefetch players only
    $where = {"team_seasons.season" => $season->id};
    
    $attrib = {
      prefetch => {teams => "team_seasons"},
      order_by => {-asc => [qw( me.full_name teams.name )]},
    };
  } else {
    # Not showing either, so we just join the teams not prefetch.  We need to join,
    # so we can work out which teams have teams in the specified season
    $where = {"team_seasons.season" => $season->id};
    $attrib = {
      join => {teams => "team_seasons"},
      group_by => [qw( me.id )],
      order_by => {-asc => [qw( full_name )]},
    };
  }
  
  return $class->search($where, $attrib);
}

=head2 with_secretary

Returns all clubs with the specified person set as secretary

=cut

sub with_secretary {
  my $class = shift;
  my ( $person ) = @_;
  return $class->search({secretary => $person->id});
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
  my $club = $params->{club} || undef;
  my $full_name = $params->{full_name} || undef;
  my $short_name = $params->{short_name} || undef;
  my $abbreviated_name = $params->{abbreviated_name} || undef;
  my $email_address = $params->{email_address} || undef;
  my $website = $params->{website} || undef;
  my $start_hour = $params->{start_hour} || undef;
  my $start_minute = $params->{start_minute} || undef;
  my $venue = $params->{venue} || undef;
  my $secretary = $params->{secretary} || undef;
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    fields => {
      full_name => $full_name,
      short_name => $short_name,
      abbreviated_name => $abbreviated_name,
      email_address => $email_address,
      website => $website,
      start_hour => $start_hour,
      start_minute => $start_minute,
    },
    completed => 0,
  };
  
  if ($action ne "create" and $action ne "edit") {
    # Invalid action passed
    push(@{$response->{error}}, $lang->maketext("admin.form.invalid-action", $action));
    
    # This error is fatal, so we return straight away
    return $response;
  } elsif ($action eq "edit") {
    # Check the club passed is valid
    if ( defined($club) ) {
      if ( ref($club) ne "TopTable::Model::DB::Club" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $club = $class->find_id_or_url_key($club);
        
        # Definitely error if we're now undef
        push(@{$response->{error}}, $lang->maketext("clubs.form.error.club-invalid")) unless defined($club);
        
        # Another fatal error
        return $response;
      }
    } else {
      push(@{$response->{error}}, $lang->maketext("clubs.form.error.club-not-specified"));
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($full_name) ) {
    # Full name entered, check it.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.full-name-exists", encode_entities($full_name))) if defined($class->search_single_field({field => "full_name", value => $full_name, exclusion_obj => $club}));
  } else {
    # Full name omitted.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.full-name-blank"));
  }
  
  if ( defined($short_name) ) {
    # Full name entered, check it.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.short-name-exists", encode_entities($short_name))) if defined($class->search_single_field({field => "short_name", value => $short_name, exclusion_obj => $club}));
  } else {
    # Full name omitted.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.short-name-blank"));
  }
  
  if ( defined($abbreviated_name) ) {
    # Full name entered, check it.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.abbreviated-name-exists", encode_entities($abbreviated_name))) if defined($class->search_single_field({field => "abbreviated_name", value => $abbreviated_name, exclusion_obj => $club}));
  } else {
    # Full name omitted.
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.abbreviated-name-blank"));
  }
  
  # Email address entered but invalid
  push(@{$response->{error}}, $lang->maketext("clubs.form.error.email-invalid")) if $email_address and $email_address !~ m/^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i;
  
  # Website
  push(@{$response->{error}}, $lang->maketext("clubs.form.error.website-invalid")) if $website and !$RE{URI}{HTTP}->matches($website);
  
  # The venue / secretary should be checked to ensure they're a valid venue / person object or a valid ID / URL key for a venue or person
  if ( defined($venue) ) {
    if ( ref($venue) ne "TopTable::Model::DB::Venue" ) {
      # This may not be an error, we may just need to find from an ID or URL key
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue);
      
      # Definitely error if we're now undef
      if  ( defined($venue) ) {
        $response->{fields}{venue} = $venue;
      } else {
        push(@{$response->{error}}, $lang->maketext("clubs.form.error.venue-invalid"));
      }
    }
  } else {
    push(@{$response->{error}}, $lang->maketext("clubs.form.error.venue-blank"));
  }
  
  # Check the venue is valid
  push(@{$response->{error}}, $lang->maketext("clubs.form.error.venue-inactive", encode_entities($venue->name))) if defined($venue) and !$venue->active;
  
  if ( defined($secretary) ) {
    if ( ref($secretary) ne "TopTable::Model::DB::Person" ) {
      # This may not be an error, we may just need to find from an ID or URL key
      $secretary = $schema->resultset("Person")->find_id_or_url_key($secretary);
      
      # Definitely error if we're now undef
      if ( defined($secretary) ) {
        $response->{fields}{secretary} = $secretary;
      } else {
        push(@{$response->{error}}, $lang->maketext("clubs.form.error.secretary-invalid"));
      }
    }
  }
  
  # Check valid start time; if blank, we won't error; they'll just use the season default start time.
  push(@{$response->{error}}, $lang->maketext("clubs.form.error.start-hour-invalid")) if defined($start_hour) and $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
  push(@{$response->{error}}, $lang->maketext("clubs.form.error.start-minute-invalid")) if defined($start_minute) and $start_minute !~ m/^(?:[0-5][0-9])$/;
  
  # Check we don't have one and not the other
  push(@{ $response->{error} }, $lang->maketext("clubs.form.error.start-time-not-complete")) if ( defined($start_hour) and !defined($start_minute) ) or ( !defined($start_hour) and defined($start_minute) );
   
  if ( scalar(@{$response->{error}}) == 0 ) {
    # Grab the submitted values
    # Build the time string
    my $default_match_start = sprintf("%s:%s", $start_hour, $start_minute) if $start_hour and $start_minute;
    
    # Success, we need to create / edit the club.  We don't create any club_seasons here, as they may not
    # be entering teams into this season.  This will be done when teams are entered for the club.
    if ( $action eq "create" ) {
      $club = $class->create({
        url_key => $class->make_url_key($short_name),
        full_name => $full_name,
        short_name => $short_name,
        abbreviated_name => $abbreviated_name,
        email_address => $email_address,
        website => $website,
        default_match_start => $default_match_start,
        venue => $venue->id,
        secretary => $secretary,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($club->full_name), $lang->maketext("admin.message.created")));
    } else {
      $club->update({
        url_key => $class->make_url_key($short_name, $club),
        full_name => $full_name,
        short_name => $short_name,
        abbreviated_name => $abbreviated_name,
        email_address => $email_address,
        website => $website,
        default_match_start => $default_match_start,
        venue => $venue->id,
        secretary => $secretary,
      });
      
      my $season = $schema->resultset("Season")->get_current;
      my $club_season = $club->get_season($season) if defined($season);
      
      $club_season->update({
        full_name => $full_name,
        short_name => $short_name,
        abbreviated_name => $abbreviated_name,
        venue => $venue,
        secretary => $secretary,
      }) if defined($club_season);
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($club->full_name), $lang->maketext("admin.message.edited")));
    }
    
    $response->{club} = $club;
  }
  
  return $response;
}

1;
