package TopTable::Schema::ResultSet::NewsArticle;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;

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
      -desc => [ qw( pinned date_updated ) ],
    },
    page => $page_number,
    rows => $results_per_page,
  });
}

=head2 unpin_expired_pins

Searches for pinned articles whose expiry date has been reached and sets the pinned flag to 0.

=cut

sub unpin_expired_pins {
  my ( $self ) = @_;
  my $current_time = DateTime->now( time_zone => "UTC" );
  
  # Search for pinned articles (pinned = 1) where the pinned_expires value is in the past (or right now) and set the pinned flag to 0
  return $self->search({
    pinned          => 1,
    pinned_expires  => {"<=" => sprintf( "%s %s", $current_time->ymd, $current_time->hms )},
  })->update({
    pinned  => 0,
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
  
  my $headline          = $parameters->{headline} || undef;
  my $article           = $parameters->{article} || undef;
  my $article_content   = $parameters->{article_content} || undef;
  my $pin_article       = $parameters->{pinned_article} || 0;
  my $pin_expiry_date   = $parameters->{pin_expiry_date}    || undef;
  my $pin_expiry_hour   = $parameters->{pin_expiry_hour}    || undef;
  my $pin_expiry_minute = $parameters->{pin_expiry_minute}  || undef;
  my $user              = $parameters->{user};
  my $ip_address        = $parameters->{ip_address};
  my $log               = $parameters->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $lang              = $parameters->{language} || sub { return wantarray ? @_ : "@_"; }; # Default to a sub that just returns everything, as we don't want errors if we haven't passed in a language sub.
  my $timezone          = $user->timezone if defined( $user ) and defined( $user->timezone );
  $timezone             = "UTC" if !defined( $timezone ) or ( defined( $timezone ) and DateTime::TimeZone->is_valid_name( $timezone ) );
  my $pinned_expires;
  
  # Sanitise the pinned flag
  $pin_article = 1 if $pin_article;
  
  my $return            = {
    fatal             => [],
    error             => [],
    warning           => [],
    sanitised_fields  => {
      headline        => $headline, # Don't need to do anything to sanitise the headline, so just pass it back in
      pinned_article  => $pin_article,
    },
  };
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push( @{ $return->{fatal} }, $lang->("admin.form.invalid-action", $action));
    return $return;
  } elsif ( $action eq "edit" ) {
    if ( defined( $article ) ) {
      # If we're editing, we need to make sure we've got an ID
      if ( ref( $article ) ne "TopTable::Model::DB::NewsArticle" ) {
        # Editing a venue that doesn't exist.
        push( @{ $return->{fatal} }, $lang->("news.form.error.invalid-news-article"));
        return $return;
      }
    } else {
        push( @{ $return->{error} }, $lang->("news.form.error.no-news-article-specified"));
        return $return;
    }
  }
  
  # Error checking
  # Check we have a headline and some article text
  push( @{ $return->{error} }, $lang->("news.form.error.no-headline")) unless defined( $headline );
  
  # Check pinned details
  if ( $pin_article == 1 ) {
    my ($day, $month, $year)  = split("/", $pin_expiry_date) if defined( $pin_expiry_date );
    
    if ( defined( $pin_expiry_date ) ) {
      try {
        $pinned_expires = DateTime->new(
          year        => $year,
          month       => $month,
          day         => $day,
          time_zone   => $timezone,
        );
      } catch {
        push(@{ $return->{error} }, $lang->("news.form.error.pin-expiry-date-invalid"));
        $pin_expiry_date = undef;
      };
      
      # Only check the time if we have a date
      if ( defined( $pinned_expires ) and defined( $pin_expiry_hour ) and defined( $pin_expiry_minute ) ) {
        if ( $pin_expiry_hour and $pin_expiry_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
          push(@{ $return->{error} }, $lang->("news.form.error.pin-expiry-hour-invalid"));
          $pin_expiry_hour = undef;
        }
        
        if ( defined( $pin_expiry_minute ) and $pin_expiry_minute !~ m/^(?:[0-5][0-9])$/ ) {
          push(@{ $return->{error} }, $lang->("news.form.error.pin-expiry-minute-invalid"));
          $pin_expiry_minute = undef;
        }
        
        if ( defined( $pin_expiry_hour ) and defined( $pin_expiry_minute ) ) {
          $pinned_expires->set_hour( $pin_expiry_hour );
          $pinned_expires->set_minute( $pin_expiry_minute );
        }
      }
    }
    
    if ( defined( $pinned_expires ) ) {
      my $now = DateTime->now(time_zone => $timezone);
      push( @{ $return->{error} }, $lang->("news.form.error.pin-expires-in-past") ) if $pinned_expires->ymd("") . $pinned_expires->hms("") < $now->ymd("") . $now->hms("");
    }
  } elsif ( defined( $pinned_expires ) and ( defined( $pin_expiry_hour ) or defined( $pin_expiry_minute ) ) ) {
    # Either hour or minute is specified, but not both, error
    push(@{ $return->{error} }, $lang->("news.form.error.pin-expiry-time-incomplete"));
  } else {
    # Not pinning, ensure expiry date is undef.  Time already will be, since we build that up from the hour and minute as necessary
    $pinned_expires = undef;
  }
  
  # Add hour / minute fields to the sanitised group
  $return->{sanitised_fields}{pin_expiry_date}   = $pinned_expires->dmy("/") if defined( $pinned_expires );
  $return->{sanitised_fields}{pin_expiry_hour}   = $pin_expiry_hour;
  $return->{sanitised_fields}{pin_expiry_minute} = $pin_expiry_minute;
  
  # To check the content we need tor strip out the HTML first, then strip leading and trailing whitespace (trim)
  my $raw_article_content = TopTable->model("FilterHTML")->filter( $article_content );
  $raw_article_content =~ s/^\s+|\s+$//g;
  push( @{ $return->{error} }, $lang->("news.form.error.no-article-content")) unless $raw_article_content;
  
  # Filter the HTML.  Do this before we check if we have any errors so we can feed back into the sanitised fields
  $article_content = TopTable->model("FilterHTML")->filter( $article_content, "textarea" );
  $return->{sanitised_fields}{article} = $article_content;
  
  unless ( scalar @{ $return->{error} } ) {
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
    
    # Store timezone as UTC
    if ( defined( $pinned_expires ) ) {
      $pinned_expires->set_time_zone( "UTC" );
      $pinned_expires = sprintf( "%s %s", $pinned_expires->ymd, $pinned_expires->hms );
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
        pinned                => $pin_article,
        pinned_expires        => $pinned_expires,
      });
    } else {
      # If we're editing, we need to create a new article related to this one
      # Update the URL key in the original article
      $article->update({
        url_key         => $url_key,
        pinned          => $pin_article,
        pinned_expires  => $pinned_expires,
      });
      
      $article->create_related("news_articles", {
        # There is no URL key for an edit; the URL key is gotten from the original article
        url_key               => undef,
        updated_by_user       => $user->id,
        ip_address            => $ip_address,
        headline              => $headline,
        article_content       => $article_content,
        pinned                => $pin_article,
        pinned_expires        => $pinned_expires,
      });
    }
    
    $return->{article} = $article;
  }
  
  return $return;
}

1;