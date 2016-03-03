package TopTable::Schema::ResultSet::NewsArticle;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;

=head2 page_records

A predefined search to find all events, ordered by the datestamp (paged if necessary).

=cut

sub page_records {
  my ( $self, $parameters ) = @_;
  my $page_number       = $parameters->{page_number} || 1;
  my $results_per_page  = $parameters->{results_per_page} || 25;
  my ( $where );
  
  # Set a default for results per page if it's invalid
  $results_per_page = 25 if $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if $page_number !~ m/^\d+$/;
  
  
  return $self->search({
    # The original article is undef if this IS the original article
    original_article  => undef,
  }, {
    order_by  => {
      # ID is in there in case we do any multiple updates together, which may appear in the same second.
      -desc => [ qw(date_updated) ],
    },
    page => $page_number,
    rows => $results_per_page,
  });
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my ( $self, $url_key, $published_year, $published_month ) = @_;
  
  return $self->find({
    url_key         => $url_key,
    published_year  => $published_year,
    published_month => $published_month,
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.

=cut

sub find_id_or_url_key {
  my ( $self, $id_or_url_key, $published_year, $published_month ) = @_;
  my ( $where );
  
  if ( $id_or_url_key =~ m/^\d+$/ ) {
    # Numeric - assume it's the ID
    $where = {
      id => $id_or_url_key,
    };
  } else {
    # Not numeric - must be the URL key
    $where = {
      url_key         => $id_or_url_key,
      published_year  => $published_year,
      published_month => $published_month,
    };
  }
  
  return $self->find( $where );
}

=head2 generate_url_key

Generate a unique key from the given season name.

=cut

sub generate_url_key {
  my ( $self, $headline, $published_year, $published_month, $exclude_id ) = @_;
  my $url_key;
  ( my $original_url_key = substr($headline, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
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
    my $key_check = $self->find_url_key( $url_key, $published_year, $published_month );
    
    # If not, return it
    return $url_key if !defined( $key_check ) or ( defined($exclude_id) and $key_check->id == $exclude_id );
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a venue.

=cut

sub create_or_edit {
  my ( $self, $action, $parameters ) = @_;
  my $return_value = {};
  
  my $article         = $parameters->{article};
  my $headline        = $parameters->{headline};
  my $article_content = $parameters->{article_content};
  my $user            = $parameters->{user};
  my $ip_address      = $parameters->{ip_address};
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    $return_value->{error} .= "An invalid action of '$action' was passed to the create / update routine; the action must be 'create' or 'edit'.\n";
    return $return_value;
  } elsif ( $action eq "edit" ) {
    if ( defined( $article ) ) {
      # If we're editing, we need to make sure we've got an ID
      if ( ref( $article ) ne "TopTable::Model::DB::NewsArticle" ) {
        # Editing a venue that doesn't exist.
        $return_value->{error} .= sprintf( "Invalid news article specified: %s; %s.\n", $article, ref( $article ) );
        return $return_value;
      }
    } else {
        $return_value->{error} .= "No news article was specified to edit\n.";
        return $return_value;
    }
  }
  
  # Error checking
  # Check we have a headline and some article text
  $return_value->{error} .= "The headline has not been filled out.\n" if !$headline;
  
  # To check the content we need tor strip out the HTML first, then strip leading and trailing whitespace (trim)
  my $raw_article_content = TopTable->model("FilterHTML")->filter( $article_content );
  $raw_article_content =~ s/^\s+|\s+$//g;
  $return_value->{error} .= "The article content has not been filled out.\n" if !$raw_article_content;
  
  if ( !$return_value->{error} ) {
    # Get the current year and month
    my $today = DateTime->today( time_zone => "UTC" );
    my ( $published_year, $published_month ) = ( $today->year, $today->month );
    
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $self->generate_url_key( $headline, $published_year, $published_month, $article->id );
    } else {
      $url_key = $self->generate_url_key( $headline, $published_year, $published_month );
    }
    
    # Success, we need to create the venue
    if ( $action eq "create" ) {
       $article = $self->create({
        url_key               => $url_key,
        published_year        => $published_year,
        published_month       => $published_month,
        updated_by_user       => $user->id,
        ip_address            => $ip_address,
        headline              => $headline,
        article_content       => $article_content,
      });
    } else {
      # If we're editing, we need to create a new article related to this one
      # Update the URL key in the original article
      $article->update({
        url_key => $url_key,
      });
      
      $article->create_related("news_articles", {
        # There is no URL key for an edit; the URL key is gotten from the original article
        url_key               => undef,
        updated_by_user       => $user->id,
        ip_address            => $ip_address,
        headline              => $headline,
        article_content       => $article_content,
      });
    }
    
    $return_value->{article} = $article;
  }
  
  return $return_value;
}

1;