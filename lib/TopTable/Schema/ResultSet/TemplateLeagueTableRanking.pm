package TopTable::Schema::ResultSet::TemplateLeagueTableRanking;

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
    order_by => {
      -asc => "name",
    },
  });
}

=head2 search_by_name

Return search results based on a supplied full or partial name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = $params->{q};
  my $split_words = $params->{split_words} || 0;
  my $season = $params->{season};
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
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
    order_by => {-asc => "name"},
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

Generate a unique key from the given template name.

=cut

sub generate_url_key {
  my ( $self, $name, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($name, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
  $original_url_key =~ s/-+/-/g; # If we find more than one dash in a row, replace it with just one.
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
  my $assign_points = $params->{assign_points} || 0;
  my $points_per_win = $params->{points_per_win};
  my $points_per_draw = $params->{points_per_draw};
  my $points_per_loss = $params->{points_per_loss};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {
      name => $name,
      assign_points => $assign_points,
      points_per_win => $points_per_win,
      points_per_draw => $points_per_draw,
      points_per_loss => $points_per_loss,
    },
    completed => 0,
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
  } elsif ( $action eq "edit" ) {
    if ( defined($tt_template) ) {
      if ( ref($tt_template) ne "TopTable::Model::DB::TemplateRanking" ) {
        # This may not be an error, we may just need to find from an ID or URL key
        $tt_template = $self->find_id_or_url_key($tt_template);
        
        # Definitely error if we're now undef
        push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.template-invalid")) unless defined($tt_template);
      }
      
      # Template is valid, check we can edit it.
      unless ( $tt_template->can_edit_or_delete ) {
        push(@{$response->{errors}}, $lang->maketext("templates.edit.error.not-allowed", $tt_template->name));
      }
    } else {
      # Editing a template that doesn't exist.
      push(@{$response->{errors}}, $lang-maketext("templates.league-table-ranking.form.error.template-not-specified"));
    }
  }
  
  # Any errors at this point are fatal, so we return early
  return $response if scalar @{$response->{errors}};
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Name entered, check it.
    my $template_name_check;
    if ($action eq "edit") {
      $template_name_check = $self->find({}, {
        where => {
          name => $name,
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
  
  # Check the game type has been selected and is valid
  if ( $assign_points ) {
    # Make sure a true value is 1
    $assign_points = 1;
    
    if ( defined($points_per_win) ) {
      # Value is submitted, ensure it's valid
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-win-invalid")) if $points_per_win !~ m/\d{1,2}/ or $points_per_win < 1;
    } else {
      # Not submitted
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-win-blank"));
    }
    
    if ( defined($points_per_draw) ) {
      # Value is submitted, ensure it's valid
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-draw-invalid")) if $points_per_draw !~ m/\d{1,2}/ or $points_per_draw < 1;
    } else {
      # Not submitted
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-draw-blank"));
    }
    
    if ( defined($points_per_loss) ) {
      # Value is submitted, ensure it's valid
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-loss-invalid")) if $points_per_draw !~ m/\d{1,2}/ or $points_per_draw < 1;
    } else {
      # Not submitted
      push(@{$response->{errors}}, $lang->maketext("templates.league-table-ranking.form.error.points-per-loss-blank"));
    }
  } else {
    # Blank out the points per win / draw / loss, as we won't be using them
    $assign_points = 0;
    undef($points_per_win);
    undef($points_per_draw);
    undef($points_per_loss);
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # Build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $tt_template->id);
    } else {
      $url_key = $self->generate_url_key( $name);
    }
    
    # Success, we need to create / edit the club
    if ( $action eq "create" ) {
      $tt_template = $self->create({
        url_key => $url_key,
        name => $name,
        assign_points => $assign_points,
        points_per_win => $points_per_win,
        points_per_draw => $points_per_draw,
        points_per_loss => $points_per_loss,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.created")));
    } else {
      $tt_template->update({
        url_key => $url_key,
        name => $name,
        assign_points => $assign_points,
        points_per_win => $points_per_win,
        points_per_draw => $points_per_draw,
        points_per_loss => $points_per_loss,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($tt_template->name), $lang->maketext("admin.message.edited")));
    }
    
    $response->{tt_template} = $tt_template;
  }
  
  return $response;
}

1;
