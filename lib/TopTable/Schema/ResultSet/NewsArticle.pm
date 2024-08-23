package TopTable::Schema::ResultSet::NewsArticle;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';
use DateTime;
use DateTime::TimeZone;
use Try::Tiny;
use HTML::Entities;

=head2 page_records

A predefined search to find all events, ordered by the datestamp (paged if necessary).

=cut

sub page_records {
  my $class = shift;
  my ( $parameters ) = @_;
  my $page_number = $parameters->{page_number} || 1;
  my $results_per_page = $parameters->{results_per_page} || 25;
  
  # Set a default for results per page if it's invalid
  $results_per_page = 25 if $results_per_page !~ m/^\d+$/;
  
  # Default the page number to 1
  $page_number = 1 if $page_number !~ m/^\d+$/;
  
  
  return $class->search({
    # The original article is undef if this IS the original article
    original_article => undef,
  }, {
    order_by => {
      # ID is in there in case we do any multiple updates together, which may appear in the same second.
      -desc => [qw( pinned date_updated )],
    },
    page => $page_number,
    rows => $results_per_page,
  });
}

=head2 unpin_expired_pins

Searches for pinned articles whose expiry date has been reached and sets the pinned flag to 0.

=cut

sub unpin_expired_pins {
  my $class = shift;
  my $current_time = DateTime->now(time_zone => "UTC");
  
  # Search for pinned articles (pinned = 1) where the pinned_expires value is in the past (or right now) and set the pinned flag to 0
  return $class->search({
    pinned => 1,
    pinned_expires => {"<=" => sprintf("%s %s", $current_time->ymd, $current_time->hms)},
  })->update({pinned => 0});
}

=head2 find_key

Same as find(), but uses the key column instead of the id.  So we can use human-readable URLs.

=cut

sub find_url_key {
  my $class = shift;
  my ( $url_key, $published_year, $published_month ) = @_;
  
  return $class->find({
    url_key => $url_key,
    published_year => $published_year,
    published_month => $published_month,
  });
}

=head2 find_id_or_url_key

Same as find(), but searches for both the id and key columns.  So we can use human-readable URLs.  Overrides the version in TopTable::Schema::ResultSet because URL keys are unique to the published year and month for news articles.

=cut

sub find_id_or_url_key {
  my $class = shift;
  my ( $id_or_url_key, $published_year, $published_month ) = @_;
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
      published_year => $published_year,
      published_month => $published_month,
    };
  }
  
  return $class->find($where);
}

=head2 make_url_key

Generate a unique key from the given season name.

=cut

sub make_url_key {
  my $class = shift;
  my ( $headline, $published_year, $published_month, $exclusion_obj ) = @_;
  my $url_key;
  ( my $original_url_key = substr($headline, 0, 45) ) =~ s/[ \W]/-/g; # Truncate after 45 characters, swap out spaces and non-word characters for dashes
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
          url_key => $url_key,
          published_year => $published_year,
          published_month => $published_month,
          id => {"!=" => $exclusion_obj->id},
        }
      });
    } else {
      # Find anything with this value
      $conflict = $class->find_id_or_url_key($url_key, $published_year, $published_month);
    }
    
    # If not, return it
    return $url_key unless defined($conflict);
    
    # Otherwise, we need to increment the count for the next loop round
    $count++;
  }
}

=head2 create_or_edit

Provides the wrapper (including error checking) for adding / editing a venue.

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
  my $headline = $params->{headline};
  my $article = $params->{article};
  my $article_content = $params->{article_content};
  my $pin_article = $params->{pin_article} || 0;
  my $pin_expiry_date = $params->{pin_expiry_date} || undef;
  my $pin_expiry_hour = $params->{pin_expiry_hour} || undef;
  my $pin_expiry_minute = $params->{pin_expiry_minute} || undef;
  my $user = $params->{user};
  my $ip_address = $params->{ip_address};
  my $timezone = $user->timezone if defined( $user ) and defined( $user->timezone );
  $timezone = "UTC" if !defined($timezone) or ( defined($timezone) and !DateTime::TimeZone->is_valid_name($timezone) );
  my $pinned_expires;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {headline => $headline},
    completed => 0,
  };
  
  # Sanitise the pinned flag
  $pin_article = $pin_article ? 1 : 0;
  $response->{fields}{pin_article} = $pin_article;
  
  if ( $action ne "create" and $action ne "edit" ) {
    # Invalid action passed
    push(@{$response->{errors}}, $lang->maketext("admin.form.invalid-action", $action));
    return $response;
  } elsif ( $action eq "edit" ) {
    if ( defined($article) ) {
      # If we're editing, we need to make sure we've got an ID
      if ( ref($article) ne "TopTable::Model::DB::NewsArticle" ) {
        # Check if it's a valid ID
        $article = $class->find($article);
        push( @{$response->{errors}}, $lang->maketext("news.form.error.invalid-news-article")) unless defined($article);
        return $response;
      }
    } else {
        push(@{$response->{errors}}, $lang->maketext("news.form.error.no-news-article-specified"));
        return $response;
    }
  }
  
  # Error checking
  # Check we have a headline and some article text
  push(@{$response->{errors}}, $lang->maketext("news.form.error.no-headline")) unless defined($headline) and $headline;
  
  # Check pinned details
  if ( $pin_article ) {
    if ( defined($pin_expiry_date) and $pin_expiry_date ) {
      if ( ref($pin_expiry_date) eq "DateTime" ) {
        # Passed in as a DateTime, just assign to the value we'll use in the DB
        $pinned_expires = $pin_expiry_date;
      } else {
        # Not a DateTime, try and parse the date
        my ( $day, $month, $year );
        
        if ( ref($pin_expiry_date) eq "HASH" ) {
          # Assign to the hash keys
          ( $day, $month, $year ) = ( $pin_expiry_date->{day}, $pin_expiry_date->{month}, $pin_expiry_date->{year} )
        } else {
          # Split and assign
          ( $day, $month, $year ) = split("/", $pin_expiry_date);
        }
        
        # Make sure the date is valid
        try {
          $pinned_expires = DateTime->new(
            year => $year,
            month => $month,
            day => $day,
          );
        } catch {
          push(@{$response->{errors}}, $lang->maketext("news.form.error.pin-expiry-date-invalid"));
        };
      }
      
      # Check if we have a valid pin expiry time
      if ( defined($pin_expiry_hour) and $pin_expiry_hour !~ m/^(?:0[0-9]|1[0-9]|2[0-3])$/ ) {
        push(@{$response->{errors}}, $lang->maketext("news.form.error.pin-expiry-hour-invalid"));
        undef($pin_expiry_hour);
      }
      
      if ( defined($pin_expiry_minute) and $pin_expiry_minute !~ m/^(?:[0-5][0-9])$/ ) {
        push(@{$response->{error}}, $lang->maketext("news.form.error.pin-expiry-minute-invalid"));
        undef($pin_expiry_minute);
      }
      
      if ( defined($pin_expiry_hour) and defined($pin_expiry_minute) ) {
        $pinned_expires->set_hour($pin_expiry_hour);
        $pinned_expires->set_minute($pin_expiry_minute);
      }
    } else {
      # Undef pin expiry options if we're not pinning
      undef($pin_expiry_date);
      undef($pinned_expires);
        
      # Check we don't have a time without a date
      push(@{$response->{errors}}, $lang->maketext("news.form.error.expires-time-passed-without-date")) if defined($pin_expiry_hour) or defined($pin_expiry_minute);
    }
    
    if ( defined($pinned_expires) ) {
      my $now = DateTime->now(time_zone => $timezone);
      push(@{$response->{errors}}, $lang->maketext("news.form.error.pin-expires-in-past")) if $pinned_expires->ymd("") . $pinned_expires->hms("") < $now->ymd("") . $now->hms("");
    }
  } elsif ( defined($pinned_expires) and ( defined($pin_expiry_hour) or defined($pin_expiry_minute) ) ) {
    # Either hour or minute is specified, but not both, error
    push(@{$response->{errors}}, $lang->maketext("news.form.error.pin-expiry-time-incomplete"));
  } else {
    # Not pinning, ensure expiry date is undef.  Time already will be, since we build that up from the hour and minute as necessary
    $pinned_expires = undef;
  }
  
  # Add hour / minute fields to the sanitised group
  $response->{fields}{pin_expiry_date} = $pinned_expires->dmy("/") if defined($pinned_expires);
  $response->{fields}{pin_expiry_hour} = $pin_expiry_hour;
  $response->{fields}{pin_expiry_minute} = $pin_expiry_minute;
  
  # To check the content we need tor strip out the HTML first, then strip leading and trailing whitespace (trim)
  my $raw_article_content = TopTable->model("FilterHTML")->filter($article_content);
  $raw_article_content =~ s/^\s+|\s+$//g if defined($raw_article_content);
  push(@{$response->{errors}}, $lang->maketext("news.form.error.no-article-content")) unless defined($raw_article_content) and $raw_article_content;
  
  # Filter the HTML.  Do this before we check if we have any errors so we can feed back into the sanitised fields
  $article_content = TopTable->model("FilterHTML")->filter($article_content, "textarea");
  $response->{fields}{article_content} = $article_content;
  
  unless ( scalar(@{$response->{errors}}) ) {
    # Get the current year and month
    my $today = DateTime->today(time_zone => "UTC");
    my ($published_year, $published_month) = ($today->year, $today->month);
    
    # Generate a new URL key
    my $url_key;
    if ( $action eq "edit" ) {
      $url_key = $class->make_url_key($headline, $published_year, $published_month, $article->id);
    } else {
      $url_key = $class->make_url_key($headline, $published_year, $published_month);
    }
    
    # Store timezone as UTC
    if ( defined($pinned_expires) ) {
      $pinned_expires->set_time_zone("UTC");
      $pinned_expires = sprintf("%s %s", $pinned_expires->ymd, $pinned_expires->hms);
    }
    
    # Success, we need to create the venue
    if ( $action eq "create" ) {
       $article = $class->create({
        url_key => $url_key,
        published_year => $published_year,
        published_month => $published_month,
        updated_by_user => $user->id,
        ip_address => $ip_address,
        headline => $headline,
        article_content => $article_content,
        pinned => $pin_article,
        pinned_expires => $pinned_expires,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($article->headline), $lang->maketext("admin.message.created")));
    } else {
      # If we're editing, we need to create a new article related to this one
      # Update the URL key in the original article
      $article->update({
        url_key => $url_key,
        pinned => $pin_article,
        pinned_expires => $pinned_expires,
      });
      
      $article->create_related("news_articles", {
        # There is no URL key for an edit; the URL key is gotten from the original article
        url_key => undef,
        updated_by_user => $user->id,
        ip_address => $ip_address,
        headline => $headline,
        article_content => $article_content,
        pinned => $pin_article,
        pinned_expires => $pinned_expires,
      });
      
      $response->{completed} = 1;
      push(@{$response->{success}}, $lang->maketext("admin.forms.success", encode_entities($article->current_details->{headline}), $lang->maketext("admin.message.created")));
    }
    
    $response->{article} = $article;
  }
  
  return $response;
}

1;