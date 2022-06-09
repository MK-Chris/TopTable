package TopTable::Schema::ResultSet::TemplateMatchTeam;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use HTML::Entities;

=head2 all_templates

Retrieve all templates in name order

=cut

sub all_templates {
  my ( $self ) = @_;
  
  return $self->search({}, {
    order_by => {-asc => qw( name )},
  });
}

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
  
  return $self->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of clubs.

=cut

sub page_records {
  my ( $self, $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $self->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( name )},
  });
}

=head2 all_templates_with_games

Retrieve all templates in name order where they have games setup.  This avoids allowing people to select a team match template with no games.

=cut

sub all_templates_with_games {
  my ( $self ) = @_;
  
  return $self->search({
    
  }, {
    order_by => {-asc => qw( name )},
    join => "template_match_team_games",
  });
}

=head2 season_league_match_template

A predefined search to find and return the team match template for league matches within a given season.

=cut

sub season_league_match_template {
  my ( $self, $season ) = @_;
  
  return $self->find({"seasons.id" => $season->id}, {
    join => "seasons",
    prefetch => "template_match_team_games",
  });
}

=head2 division_averages_list

A predefined search to find and return the players within a division in the order in which they should appear in the full league averages.

=cut

sub division_averages_list {
  my ( $self, $season, $division, $minimum_matches_played ) = @_;
  $minimum_matches_played = 0 if !$minimum_matches_played;
  
  return $self->search({
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

=head2 find_url_key

Same as find(), but uses the url_key column instead of the id.  So we can use human-readable URLs.

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

Generate a unique key from the given template name.

=cut

sub generate_url_key {
  my ( $self, $short_name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($short_name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
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
  my $tt_template = $params->{tt_template} || undef;
  my $name = $params->{name} || undef;
  my $singles_players_per_team  = $params->{singles_players_per_team} || undef;
  my $winner_type = $params->{winner_type} || undef;
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
  }
  
  # Any error at this point is fatal, so we return early
  return $response if scalar(@{$response->{errors}});
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    my $template_name_check;
    if ( $action eq "edit" ) {
      $template_name_check = $self->find({}, {
        where => {
          name => $name ,
          id => {"!=" => $tt_template->id}
        }
      });
    } else {
      $template_name_check = $self->find({name => $name});
    }
    
    push(@{$response->{errors}}, $lang->maketext("templates.form.error.name-exists", encode_entities($name))) if defined($template_name_check);
  } else {
    # Full name omitted.
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
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # No errors, build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key($name, $tt_template->id);
    } else {
      $url_key = $self->generate_url_key($name);
    }
    
    # Success, we need to create / edit the club
    if ( $action eq "create" ) {
      $tt_template = $self->create({
        url_key => $url_key,
        name => $name,
        singles_players_per_team => $singles_players_per_team,
        winner_type => $winner_type->id,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.created")));
    } else {
      $tt_template->update({
        url_key => $url_key,
        name => $name,
        singles_players_per_team => $singles_players_per_team,
        winner_type => $winner_type->id,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.edited")));
    }
  }
  
  $response->{tt_template} = $tt_template;
  return $response;
}

1;
