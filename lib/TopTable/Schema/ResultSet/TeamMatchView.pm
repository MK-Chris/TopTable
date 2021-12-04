package TopTable::Schema::ResultSet::TeamMatchView;

use strict;
use warnings;
use parent 'DBIx::Class::ResultSet';
use Data::Dumper::Concise;


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_name {
  my ( $self, $params ) = @_;
  my $q = delete $params->{q};
  my $split_words = delete $params->{split_words} || 0;
  my $season = delete $params->{season};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = delete $params->{page} || undef;
  my $results_per_page = delete $params->{results} || undef;
  
  # Don't delete these, as the GUI may need them
  my $include_complete = $params->{include_complete} || 0;
  my $include_incomplete = $params->{include_incomplete} || 0;
  my $include_cancelled = $params->{include_cancelled} || 0;
  
  # First construct based on complete / incomplete / cancelled.
  # Note: cancelled matches have the complete flag set to 0, therefore possible combinations:
  #  * complete = 1, incomplete = 1, cancelled = 1 - easiest one to do, don't set criteria and return everything that matches.
  #  * complete = 1, incomplete = 1, cancelled = 0 - return everything EXCEPT cancelled (criteria: cancelled = 0)
  #  * complete = 1, incomplete = 0, cancelled = 0 - ONLY return complete (criteria: complete = 1)
  #  * complete = 1, incomplete = 0, cancelled = 1 - return complete AND cancelled, NOT incomplete (criteria: complete = 1 OR cancelled = 1)
  #  * complete = 0, incomplete = 1, cancelled = 1 - return incomplete AND cancelled (criteria: complete = 0 - this will return cancelled as well, as they don't have the complete flag set)
  #  * complete = 0, incomplete = 1, cancelled = 0 - return incomplete, but NOT cancelled (criteria: complete = 0 AND cancelled = 0)
  #  * complete = 0, incomplete = 0, cancelled = 1 - return cancelled ONLY (criteria: cancelled = 1)
  #  * complete = 0, incomplete = 0, cancelled = 0 - INVALID - will return nothing, so if all are off, turn all on automatically.
  
  # Check if we're including complete / incomplete / cancelled.  If none are passed as true, make sure we include all
  ( $include_complete, $include_incomplete, $include_cancelled ) = ( 1, 1, 1 ) unless $include_complete or $include_incomplete or $include_cancelled;
  
  # Initialise our where clause
  my ( $where );
  
  if ( $include_complete and $include_incomplete and $include_cancelled ) {
    # Search everything, don't include criteria, just setup an empty hashref to add the rest of the where clause
    $where = {};
  } elsif ( $include_complete and $include_incomplete and !$include_cancelled ) {
    # Include complete or incomplete, but not cancelled
    $where = {cancelled => 0};
  } elsif ( $include_complete and !$include_incomplete and !$include_cancelled ) {
    # Include complete only
    $where = {complete => 1};
  } elsif ( $include_complete and !$include_incomplete and $include_cancelled ) {
    # Include complete AND cancelled, but NOT incomplete
    $where = [{
      complete => 1,
    }, {
      cancelled => 1,
    }];
  } elsif ( !$include_complete and $include_incomplete and $include_cancelled ) {
    # Include incomplete and cancelled (so just search where complete = 0)
    $where = {complete => 0};
  } elsif ( !$include_complete and $include_incomplete and !$include_cancelled ) {
    # Include incomplete ONLY (NOT cancelled)
    $where = {complete => 0, cancelled => 0};
  } elsif ( !$include_complete and !$include_incomplete and $include_cancelled ) {
    # Include cancelled ONLY
    $where = {cancelled => 1};
  }
  
  if ( $split_words ) {
    # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
    my @words = split( /\s+/, $q );
    
    # We do words on 'or' here so we can construct a 'club name + team name' in the search
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
    }
    
    if ( ref( $where ) eq "ARRAY" ) {
      # Loop through and add to each element of the array
      for ( my $i = 0; $i < scalar @{ $where }; $i++ ) {
        $where->[$i]{match_name} = \@constructed_like;
      }
    } elsif ( ref( $where ) eq "HASH" ) {
      # Add an element to the hash
      $where->{match_name} = \@constructed_like;
    } else {
      # Shouldn't get here, but sanity check - just assign a new hashref
      $where = {match_name => \@constructed_like};
    }
  } else {
    # Don't split words up before performing a like
    
    if ( ref( $where ) eq "ARRAY" ) {
      # Loop through and add to each element of the array
      for ( my $i = 0; $i < scalar @{ $where }; $i++ ) {
        $where->[$i]{match_name} = {-like => "%$q%"};
      }
    } elsif ( ref( $where ) eq "HASH" ) {
      # Add an element to the hash
      $where->{match_name} = {-like => "%$q%"};
    } else {
      # Shouldn't get here, but sanity check - just assign a new hashref
      $where = {match_name => {-like => "%$q%"}};
    }
  }
  
  # Add the season if we need to
  if ( defined( $season ) ) {
    if ( ref( $where ) eq "ARRAY" ) {
      # Loop through and add to each element of the array
      for ( my $i = 0; $i < scalar @{ $where }; $i++ ) {
        $where->[$i]{season_id} = $season->id;
      }
    } elsif ( ref( $where ) eq "HASH" ) {
      # Add an element to the hash
      $where->{season_id} = $season->id;
    } else {
      # Shouldn't get here, but sanity check - just assign a new hashref
      $where = {season_id => $season->id};
    }
  }
  
  my $attrib = {
    order_by => [{
      -desc => [ qw( complete scheduled_date ) ],
    }, {
      -asc => [ qw( match_name ) ],
    }],
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

1;