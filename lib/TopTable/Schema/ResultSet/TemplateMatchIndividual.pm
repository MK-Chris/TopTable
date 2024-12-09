package TopTable::Schema::ResultSet::TemplateMatchIndividual;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 all_templates

Retrieve all templates in name order

=cut

sub all_templates {
  my $class = shift;
  
  return $class->search({}, {
    order_by => {-asc => "name"},
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
  
  return $class->search($where, $attrib);
}

=head2 page_records

Returns a paginated resultset of clubs.

=cut

sub page_records {
  my $class = shift;
  my ( $params ) = @_;
  my $page_number = $params->{page_number} || 1;
  my $results_per_page = $params->{results_per_page} || 25;
  
  # Set a default for results per page if it's not provided or invalid
  $results_per_page = 25 if !defined($results_per_page) or $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if !defined($page_number) or $page_number !~ m/^\d+$/;
  
  return $class->search({}, {
    page => $page_number,
    rows => $results_per_page,
    order_by => {-asc => qw( name )},
  });
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
  my $tt_template = $params->{tt_template} || undef;
  my $name = $params->{name} || undef;
  my $game_type = $params->{game_type} || undef;
  my $legs_per_game = $params->{legs_per_game} || undef;
  my $minimum_points_win = $params->{minimum_points_win} || undef;
  my $clear_points_win = $params->{clear_points_win} || undef;
  my $serve_type = $params->{serve_type} || undef;
  my $serves = $params->{serves} || undef;
  my $serves_deuce = $params->{serves_deuce} || undef;
  my $handicapped = $params->{handicapped} || 0;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      legs_per_game => $legs_per_game,
      minimum_points_win => $minimum_points_win,
      clear_points_win => $clear_points_win,
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
  } elsif ( $action eq "edit" ) {
    if ( defined($tt_template) ) {
      if ( ref($tt_template) ne "TopTable::Model::DB::TemplateMatchIndividual" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $tt_template = $class->find_id_or_url_key($tt_template);
        
        # Definitely error if we're now undef
        push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.template-invalid")) unless defined($tt_template);
      }
      
      # Template is valid, check we can edit it.
      unless ( $tt_template->can_edit_or_delete ) {
        push(@{$response->{errors}}, $lang->maketext("templates.edit.error.not-allowed", encode_entities($tt_template->name)));
      }
    } else {
      # Editing a template that doesn't exist.
      push(@{$response->{errors}}, $lang-maketext("templates.individual-match.form.error.template-not-specified"));
    }
  }
  
  # Any error at this point is fatal, so we return early
  return $response if scalar(@{$response->{errors}});
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( defined($name) ) {
    push(@{$response->{errors}}, $lang->maketext("templates.form.error.name-exists", encode_entities($name))) if defined($class->search_single_field({field => "name", value => $name, exclusion_obj => $tt_template}));
  } else {
    # Name omitted.
    push(@{$response->{errors}}, $lang->maketext("templates.form.error.name-blank"));
  }
  
  # Check the game type has been selected and is valid
  if ( defined($game_type) ) {
    #$logger->("debug", sprintf("game type: %s, ref: %s", $game_type, ref($game_type)));
    if ( ref($game_type) ne "TopTable::Model::DB::LookupGameType" ) {
      # If we haven't got a valid object, try and look it up assuming an ID
      $game_type = $schema->resultset("LookupGameType")->find($game_type);
      #$logger->("debug", sprintf("game type post-lookup: %s, ref: %s", $game_type, ref($game_type)));
    }
    
    # Definitely an error if we don't have a value now now
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.game-type-invalid")) unless defined($game_type);
  } else {
    # Error, blank game type
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.game-type-blank"));
  }
  
  # Return the object back to the caller
  $response->{fields}{game_type} = $game_type;
  
  # Check the legs per game / minimum points for a win / clear points for a win
  if ( defined($legs_per_game) ) {
    # Value is submitted, ensure it's valid
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.legs-per-game-invalid")) if $legs_per_game !~ m/\d{1,2}/ or $legs_per_game < 1;
  } else {
    # Not submitted
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.legs-per-game-blank"));
  }
  
  if ( defined($minimum_points_win) ) {
    # Value is submitted, ensure it's valid
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.minimum-points-win-invalid")) if $minimum_points_win !~ m/\d{1,2}/ or $minimum_points_win < 1;
  } else {
    # Not submitted
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.minimum-points-win-blank"));
  }
  
  if ( defined($clear_points_win) ) {
    # Value is submitted, ensure it's valid
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.clear-points-win-invalid")) if $clear_points_win !~ m/\d{1,2}/ or $clear_points_win < 1;
  } else {
    # Not submitted
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.clear-points-win-blank"));
  }
  
  # Check the serve type is submitted and valid
  if ( defined($serve_type) ) {
    if ( ref($serve_type) ne "TopTable::Model::DB::LookupServeType" ) {
      # If we haven't got a valid object, try and look it up assuming an ID
      $serve_type = $schema->resultset("LookupServeType")->find($serve_type);
      
      # Definitely an error if we don't have a value now now
      push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serve-type-invalid")) unless defined($game_type);
    }
  } else {
    # Nothing submitted
    push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serve-type-blank"));
  }
  
  # Return the object back to the caller
  $response->{fields}{serve_type} = $serve_type;
  
  # We need to know if the serve type is valid, so that we know if we can make method calls on the object
  my $serve_type_valid = defined($serve_type) ? 1 : 0;
  
  # Only error check the serve numbers is we have a static number of serves
  if ( $serve_type_valid and $serve_type->id == "static" ) {
    # Static number of serves, check that we have a number of serves in normal play / serves in deuce
    if ( defined($serves) ) {
      # We have a number of serves; check it's valid
      push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serves-invalid")) if $serves !~ m/\d{1,2}/ or $serves < 1;
    } else {
      # Nothing submitted
      push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serves-blank"));
    }
    
    if ( defined($serves_deuce) ) {
      # We have a number of serves; check it's valid
      push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serves-deuce-invalid")) if $serves_deuce !~ m/\d{1,2}/ or $serves_deuce < 1;
    } else {
      # Nothing submitted
      push(@{$response->{errors}}, $lang->maketext("templates.individual-match.form.error.serves-deuce-blank"));
    }
  } else {
    # There is not a static number of serves, so blank out those fields.
    undef($serves);
    undef($serves_deuce);
  }
  
  # Return the values back to the caller
  $response->{fields}{serves} = $serves;
  $response->{fields}{serves_deuce} = $serves_deuce;
  
  # Handicapped sanity check - should be 1 or 0, any other true value gets set to 1
  $handicapped = $handicapped ? 1 : 0;
  $response->{fields}{handicapped} = $handicapped;
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # No errors, build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($name, $tt_template);
    } else {
      $url_key = $class->make_url_key($name);
    }
    
    # Success, we need to create / edit the club
    if ( $action eq "create" ) {
      $tt_template = $class->create({
        url_key => $url_key,
        name => $name,
        game_type => $game_type,
        legs_per_game => $legs_per_game,
        minimum_points_win => $minimum_points_win,
        clear_points_win => $clear_points_win,
        serve_type => $serve_type,
        serves => $serves,
        serves_deuce => $serves_deuce,
        handicapped => $handicapped,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.created")));
    } else {
      $tt_template->update({
        url_key => $url_key,
        name => $name,
        game_type => $game_type,
        legs_per_game => $legs_per_game,
        minimum_points_win => $minimum_points_win,
        clear_points_win => $clear_points_win,
        serve_type => $serve_type,
        serves => $serves,
        serves_deuce => $serves_deuce,
        handicapped => $handicapped,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.edited")));
    }
    
    $response->{tt_template} = $tt_template;
  }
  
  return $response;
}

1;
