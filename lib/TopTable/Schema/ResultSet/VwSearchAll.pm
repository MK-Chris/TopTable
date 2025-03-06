package TopTable::Schema::ResultSet::VwSearchAll;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );


=head2 search_by_name

Return search results based on a supplied full or partial club / team name.

=cut

sub search_by_name {
  my $class = shift;
  my ( $params ) = @_;
  my $q = $params->{q};
  my $split_words = $params->{split_words} || 0;
  my $season = $params->{season};
  my $include_types = $params->{include_types};
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $page = $params->{page} || undef;
  my $results_per_page = $params->{results} || undef;
  
  my ( $where );
  if ( $split_words ) {
    # Construct the LIKE '%word1%' AND  LIKE '%word2%' etc.  I couldn't work out how to map this, so a loop it is.
    my @words = split( /\s+/, $q );
    
    # We do words on 'or' here so we can construct a 'club name + team name' in the search
    my @constructed_like = ("-and");
    foreach my $word ( @words ) {
      my $constructed_like = {-like => "%$word%"};
      push (@constructed_like, $constructed_like);
    }
    
    $where = [{
      type => {-in => $include_types},
      name1 => \@constructed_like,
    }, {
      type => {-in => $include_types},
      name2 => \@constructed_like,
    }];
  } else {
    # Don't split words up before performing a like
    $where = [{
      type => {-in => $include_types},
      name1 => {-like => "%$q%"},
    }, {
      type => {-in => $include_types},
      name2 => {-like => "%$q%"},
    }];
  }
  
  my $attrib = {
    order_by => [{
      -asc => [qw( search_priority )],
    }, {
      -desc => [qw( match_complete date )],
    }]
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
  
  return $class->search($where, $attrib);
}

1;
