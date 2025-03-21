package TopTable::Schema::ResultSet::VwClubTeam;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

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
  
  my ( $where );
  if ( $split_words ) {
    # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
    my @words = split( /\s+/, $q );
    
    # We do words on 'or' here so we can construct a 'club name + team name' in the search
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = { -like => "%$word%" };
      push ( @constructed_like, $constructed_like );
    }
    
    $where = [{
      team_with_club => \@constructed_like,
    }, {
      abbreviated_team_with_club => \@constructed_like,
    }];
  } else {
    # Don't split words up before performing a like
    $where = [{
      team_with_club => {-like => "%$q%"},
    }, {
      abbreviated_team_with_club => {-like => "%$q%"},
    }];
  }
  
  my $attrib = {
    order_by => {-asc => [ qw( team_with_club abbreviated_team_with_club ) ]},
    group_by => [ qw( team_with_club abbreviated_team_with_club ) ],
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
    $where->[0]{season_id} = $season->id;
    $where->[1]{season_id} = $season->id;
  }
  
  return $class->search( $where, $attrib );
}

1;
