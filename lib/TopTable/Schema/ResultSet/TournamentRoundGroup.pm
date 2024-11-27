package TopTable::Schema::ResultSet::TournamentRoundGroup;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );

=head2 search_single_field

Check the rounds in the passed in tournament for the field given in the parameter 'field' for the value given in 'value'.  Optionally takes an 'exclusion_obj', which is excluded from the search (this is useful if we want to check if a supposedly unique value is already entered, but want to exclude the object we're supposed to be editing).

Returns the results of the find (which is obviously undef if nothing comes back).

This overrides the version in TopTable::Schema::ResultSet, because we need to check within the tournament round only, not the whole resultset.

=cut

sub search_single_field {
  my ( $class, $round, $params ) = @_;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $field = $params->{field};
  my $value = $params->{value};
  my $exclusion_obj = $params->{exclusion_obj};
  
  if ( defined($exclusion_obj) ) {
    # Find anything with this value, excluding the exclusion object passed in
    return $class->find({}, {
      where => {
        tournament_round => $round->id,
        $field => $value,
        id => {"!=" => $exclusion_obj->id},
      }
    });
  } else {
    # Find anything with this value
    return $class->find({
        tournament_round => $round->id,
        $field => $value,
    });
  }
}

=head2 make_url_key

Generate a unique key from the given name.  Overwrites the version in TopTable::Schema::ResultSet, because they must only be unique within the tournament round the group is in.

=cut

sub make_url_key {
  my ( $class, $round, $name, $exclusion_obj ) = @_;
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
      $url_key = sprintf("%s-%d", $original_url_key, $count);
    } else {
      $url_key = $original_url_key;
    }
    
    # Check if that key already exists
    my $conflict;
    if ( defined($exclusion_obj) ) {
      # Find anything with this value, excluding the exclusion object passed in
      $conflict = $class->find({}, {
        where => {
          tournament_round => $round->id,
          url_key => $url_key,
          id => {"!=" => $exclusion_obj->id},
        }
      });
    } else {
      # Find anything with this value
      $conflict = $class->find({
        tournament_round => $round->id,
        url_key => $url_key,
      });
    }
    
    # If not, return it
    return $url_key unless defined($conflict);
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 find_with_round_tournament_and_season

Find a round by primary key (ID), but provide some prefetches.

=cut

sub find_with_round_tournament_and_season {
  my $class = shift;
  my ( $id ) = @_;
  
  return $class->find($id, {
    prefetch => {
      tournament_round => {
        tournament => {
          event_season => [qw( event season )],
        },
      },
    },
  });
}

1;