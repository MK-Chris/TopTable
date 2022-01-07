package TopTable::Schema::ResultSet::Club;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use Data::Dumper::Concise;
use Regexp::Common qw /URI/;

=head2 get_club_and_secretary_and_venue

A find() wrapper that also prefetches the secretary and venue.

=cut

sub get_club_and_secretary_and_venue {
  my ( $self, $club_id ) = @_;
  
  return $self->find({
    id        => $club_id,
  }, {
    prefetch  => [ qw(secretary venue) ],
  });
}

=head2 all_clubs_by_name

Retrieve all clubs without any prefetching, ordered by full name.

=cut

sub all_clubs_by_name {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {
      -asc => [ qw( full_name ) ]
    }
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial full / short name.

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
    # Split individual words and perform a like on each one
    my @words = split( /\s+/, $q );
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
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
    order_by => {-asc => [ qw( me.full_name ) ]},
    group_by => [ qw( me.full_name ) ],
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
    $where->[0]{"club_seasons.season"} = $season->id;
    $where->[1]{"club_seasons.season"} = $season->id;
    $attrib->{join} = "club_seasons";
  }
  
  return $self->search( $where, $attrib );
}

=head2 find_by_short_name

Does a find() based on the club short name.

=cut

sub find_by_short_name {
  my ( $self, $short_name ) = @_;
  
  return $self->find({
    short_name  => $short_name,
  });
}

=head2 page_records

Returns a paginated resultset of clubs.

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
      -asc => "full_name",
    },
  });
}

=head2 clubs_with_teams_in_season

Retrieve all clubs (and prefetch their teams) with teams entering a given season.

=cut

sub clubs_with_teams_in_season {
  my ( $self, $parameters ) = @_;
  my $season      = $parameters->{season};
  my $get_teams   = $parameters->{get_teams};
  my $get_players = $parameters->{get_players};
  
  my ( $where, $attributes );
  if ( $get_teams and $get_players ) {
    # Prefetch both teams and players
    $where = {
      "team_seasons.season"   => $season->id,
      "person_seasons.season" => $season->id,    
    };
    
    $attributes = {
      prefetch => {
        teams => [
          "team_seasons", {
            person_seasons => "person",
          },
        ],
      },
      order_by => {
        -asc => [ qw( me.full_name teams.name person.surname person.first_name ) ],
      },
    };
  } elsif ( $get_teams ) {
    # Prefetch players only
    $where = {
      "team_seasons.season"   => $season->id,    
    };
    
    $attributes = {
      prefetch => {
        teams => "team_seasons",
      },
      order_by => {
        -asc => [ qw( me.full_name teams.name ) ],
      },
    };
  } else {
    # Not showing either, so we just join the teams not prefetch.  We need to join,
    # so we can work out which teams have teams in the specified season
    $where = {
      "team_seasons.season"   => $season->id,    
    };
    
    $attributes = {
      join => {
        teams => "team_seasons",
      },
      group_by => [ qw( me.id ) ],
      order_by => {
        -asc => [ qw( full_name ) ],
      },
    };
  }
  
  return $self->search( $where, $attributes );
}

=head2 get_clubs_with_specified_secretary

Returns all clubs with the specified person set as secretary

=cut

sub get_clubs_with_specified_secretary {
  my ( $self, $person ) = @_;
  return $self->search({secretary => $person->id});
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
  
  return $self->find($where, {
    prefetch  => [ qw( secretary venue ) ],
  });
}

=head2 generate_url_key

Generate a unique key from the given club short name.

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

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a club.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my ( $club_name_check );
  my $return_value = {error => []};
  
  my $club              = $parameters->{club}             || undef;
  my $full_name         = $parameters->{full_name}        || undef;
  my $short_name        = $parameters->{short_name}       || undef;
  my $abbreviated_name  = $parameters->{abbreviated_name} || undef;
  my $email_address     = $parameters->{email_address}    || undef;
  my $website           = $parameters->{website}          || undef;
  my $start_hour        = $parameters->{start_hour}       || undef;
  my $start_minute      = $parameters->{start_minute}     || undef;
  my $venue             = $parameters->{venue}            || undef;
  my $secretary         = $parameters->{secretary}        || undef;
  
  # Schema for looking up from other tables
  my $schema = $self->result_source->schema;
  
  if ($action ne "create" and $action ne "edit") {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ($action eq "edit") {
    # Check the club passed is valid
    unless ( defined( $club ) and ref( $club ) eq "TopTable::Model::DB::Club" ) {
      push(@{ $return_value->{error} }, {id => "clubs.form.error.club-invalid"});
      
      # Another fatal error
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($full_name) ) {
    # Full name entered, check it.
    if ($action eq "edit") {
      $club_name_check = $self->find({}, {
        where => {
          full_name  => $full_name,
          id        => {
            "!=" => $club->id
          }
        }
      });
    } else {
      $club_name_check = $self->find({full_name => $full_name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "clubs.form.error.full-name-exists",
      parameters  => [$full_name],
    }) if defined( $club_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "clubs.form.error.full-name-blank"});
  }
  
  if ( defined( $short_name ) ) {
    if ($action eq "edit") {
      $club_name_check = $self->find({}, {
        where => {
          short_name  => $short_name,
          id          => {
            "!=" => $club->id
          }
        }
      });
    } else {
      $club_name_check = $self->find({short_name => $short_name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "clubs.form.error.short-name-exists",
      parameters  => [$short_name],
    }) if defined( $club_name_check );
  } else {
    # Short name omitted.
    push(@{ $return_value->{error} }, {id => "clubs.form.error.short-name-blank"});
  }
  
  if ( defined($abbreviated_name) ) {
    # Abbreviated name entered, check it.
    if ($action eq "edit") {
      $club_name_check = $self->find({}, {
        where => {
          abbreviated_name  => $abbreviated_name,
          id        => {
            "!=" => $club->id
          }
        }
      });
    } else {
      $club_name_check = $self->find({abbreviated_name => $abbreviated_name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "clubs.form.error.abbreviated-name-exists",
      parameters  => [$abbreviated_name],
    }) if defined( $club_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "clubs.form.error.abbreviated-name-blank"});
  }
  
  # Email address entered but invalid
  push(@{ $return_value->{error} }, {id => "clubs.form.error.email-invalid"}) if $email_address and $email_address !~ m/^[-!#$%&\'*+\\.\/0-9=?A-Z^_`{|}~]+@([-0-9A-Z]+\.)+([0-9A-Z]){2,4}$/i;
  
  # Website
    # Website entered but invalid
  push(@{ $return_value->{error} }, {id => "clubs.form.error.website-invalid"}) if $website and !$RE{URI}{HTTP}->matches( $website );
  
  # The venue / secretary should be checked to ensure they're a valid venue / person object
  push(@{ $return_value->{error} }, {id => "clubs.form.error.venue-invalid"}) unless defined( $venue ) and ref( $venue ) eq "TopTable::Model::DB::Venue";
  push(@{ $return_value->{error} }, {id => "clubs.form.error.secretary-invalid"}) if defined( $secretary ) and ref( $secretary ) ne "TopTable::Model::DB::Person";
  
  # Check valid start time; if blank, we won't error; they'll just use the season default start time.
  push(@{ $return_value->{error} }, {id => "clubs.form.error.start-hour-invalid"}) if defined( $start_hour ) and $start_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/;
  push(@{ $return_value->{error} }, {id => "clubs.form.error.start-minute-invalid"}) if defined( $start_minute ) and $start_minute !~ m/^(?:[0-5][0-9])$/;
  
  # Check we don't have one and not the other
  push(@{ $return_value->{error} }, {id => "clubs.form.error.start-time-not-complete"}) if ( defined( $start_hour ) and !defined( $start_minute ) ) or ( !defined( $start_hour ) and defined( $start_minute ) );
   
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Grab the submitted values
    # Build the time string
    my $default_match_start = sprintf( "%s:%s", $start_hour, $start_minute ) if $start_hour and $start_minute;
    
    # Build the key from the short name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $short_name, $club->id );
    } else {
      $url_key = $self->generate_url_key( $short_name );
    }
    
    # Success, we need to create / edit the club.  We don't create any club_seasons here, as they may not
    # be entering teams into this season.  This will be done when teams are entered for the club.
    if ( $action eq "create" ) {
      $club = $self->create({
        url_key             => $url_key,
        full_name           => $full_name,
        short_name          => $short_name,
        abbreviated_name    => $abbreviated_name,
        email_address       => $email_address,
        website             => $website,
        default_match_start => $default_match_start,
        venue               => $venue,
        secretary           => $secretary,
      });
    } else {
      $club->update({
        url_key             => $url_key,
        full_name           => $full_name,
        short_name          => $short_name,
        abbreviated_name    => $abbreviated_name,
        email_address       => $email_address,
        website             => $website,
        default_match_start => $default_match_start,
        venue               => $venue,
        secretary           => $secretary,
      });
      
      my $season = $schema->resultset("Season")->get_current;
      my $club_season = $club->get_season( $season ) if defined( $season );
      
      $club_season->update({
        full_name           => $full_name,
        short_name          => $short_name,
        abbreviated_name    => $abbreviated_name,
        venue               => $venue,
        secretary           => $secretary,
      }) if defined $club_season;
    }
    
    $return_value->{club} = $club;
  }
  
  return $return_value;
}

1;
