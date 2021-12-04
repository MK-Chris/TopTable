package TopTable::Schema::ResultSet::TemplateMatchIndividual;

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
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $season = delete $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
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
    order_by => {-asc => [ qw( name ) ]},
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
  
  return $self->search( $where, $attrib );
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
      -asc => "name",
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
  my $return_value = {error => []};
    
  my $tt_template         = $parameters->{tt_template} || undef;
  my $name                = $parameters->{name} || undef;
  my $game_type           = $parameters->{game_type} || undef;
  my $legs_per_game       = $parameters->{legs_per_game} || undef;
  my $minimum_points_win  = $parameters->{minimum_points_win} || undef;
  my $clear_points_win    = $parameters->{clear_points_win} || undef;
  my $serve_type          = $parameters->{serve_type} || undef;
  my $serves              = $parameters->{serves} || undef;
  my $serves_deuce        = $parameters->{serves_deuce} || undef;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{ $return_value->{error} }, {
      id          => "admin.form.invalid-action",
      parameters  => [$action],
    });
    
    # This error is fatal, so we return straight away
    return $return_value;
  } elsif ( $action eq "edit" ) {
    if ( defined( $tt_template ) and ref( $tt_template ) eq "TopTable::Model::DB::TemplateRanking" ) {
      # Template is valid, check we can edit it.
      push(@{ $return_value->{error} }, {
        id          => "templates.edit.error.not-allowed",
        parameters  => [$tt_template->name],
      }) unless $tt_template->can_edit_or_delete;
      
      return $return_value;
    } else {
      # Editing a template that doesn't exist.
      push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.template-invalid"});
      return $return_value;
    }
  }
  
  # Error checking
  # Check the names were entered and don't exist already.
  if ( $name ) {
    # Full name entered, check it.
    my $template_name_check;
    if ( $action eq "edit" ) {
      $template_name_check = $self->find({}, {
        where   => {
          name  => $name ,
          id    => {
            "!=" => $tt_template->id,
          }
        }
      });
    } else {
      $template_name_check = $self->find({name => $name});
    }
    
    push(@{ $return_value->{error} }, {
      id          => "templates.form.error.name-exists",
      parameters  => [$name],
    }) if defined( $template_name_check );
  } else {
    # Full name omitted.
    push(@{ $return_value->{error} }, {id => "templates.form.error.name-blank"});
  }
  
  # Check the game type has been selected and is valid
  push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.game-type-invalid"}) if !defined( $game_type ) or ref( $game_type ) ne "TopTable::Model::DB::LookupGameType";
  
  # Check the legs per game / minimum points for a win / clear points for a win
  push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.legs-per-game-invalid"}) if !defined( $legs_per_game ) or $legs_per_game !~ m/\d{1,2}/ or $legs_per_game < 1;
  push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.minimum-points-win-invalid"}) if !defined( $minimum_points_win ) or $minimum_points_win !~ m/\d{1,2}/ or $minimum_points_win < 1;
  push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.clear-points-win"}) if !defined( $clear_points_win ) or $clear_points_win !~ m/\d{1,2}/ or $clear_points_win < 1;
  
  # Check the serve type is selected and valid
  my $serve_type_valid;
  if ( defined( $serve_type ) and ref( $serve_type ) eq "TopTable::Model::DB::LookupServeType" ) {
    # Valid serve type - set the flag so we can check its valid
    $serve_type_valid = 1;
  } else {
    # Invalid serve type
    push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.serve-type-invalid"});
    $serve_type_valid = 0;
  }
  
  # Only error check the serve numbers is we have a static number of serves
  if ( $serve_type_valid and $serve_type->id == "static" ) {
    # Check the serves / deuce serves
    push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.serves-invalid"}) if !defined( $serves ) or $serves !~ m/\d{1,2}/ or $serves < 1;
    push(@{ $return_value->{error} }, {id => "templates.individual-match.form.error.serves-deuce-invalid"}) if !defined( $serves_deuce ) or $serves_deuce !~ m/\d{1,2}/ or $serves_deuce < 1;
  } else {
    # There is not a static number of serves, so blank out those fields.
    undef( $serves );
    undef( $serves_deuce );
  }
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # No errors, build the key from the name
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $name, $tt_template->id );
    } else {
      $url_key = $self->generate_url_key( $name );
    }
    
    # Success, we need to create / edit the club
    if ( $action eq "create" ) {
      $tt_template = $self->create({
        url_key             => $url_key,
        name                => $name,
        game_type           => $game_type,
        legs_per_game       => $legs_per_game,
        minimum_points_win  => $minimum_points_win,
        clear_points_win    => $clear_points_win,
        serve_type          => $serve_type,
        serves              => $serves,
        serves_deuce        => $serves_deuce,
      });
    } else {
      $tt_template->update({
        url_key             => $url_key,
        name                => $name,
        game_type           => $game_type,
        legs_per_game       => $legs_per_game,
        minimum_points_win  => $minimum_points_win,
        clear_points_win    => $clear_points_win,
        serve_type          => $serve_type,
        serves              => $serves,
        serves_deuce        => $serves_deuce,
      });
    }
    
    $return_value->{tt_template} = $tt_template;
  }
  
  return $return_value;
}

1;