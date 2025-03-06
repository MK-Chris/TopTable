package TopTable::Controller::Search;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

Main site search - search everything we have a search for (uses a view).

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Check what we're authorised to view (and therefore search for)
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[qw( club_view fixtures_view match_view person_view season_view team_view user_view venue_view template_view )], "", 0]);
  
  # Now set the 'include' array - divisions are automatically in
  my @include_types = ("division");
  push(@include_types, "club") if $c->stash->{authorisation}{club_view};
  push(@include_types, "fixtures-grid") if $c->stash->{authorisation}{fixtures_view};
  push(@include_types, "team-match") if $c->stash->{authorisation}{match_view};
  push(@include_types, "person") if $c->stash->{authorisation}{person_view};
  push(@include_types, "season") if $c->stash->{authorisation}{season_view};
  push(@include_types, "team") if $c->stash->{authorisation}{team_view};
  push(@include_types, "user") if $c->stash->{authorisation}{user_view};
  push(@include_types, "venue") if $c->stash->{authorisation}{venue_view};
  push(@include_types, qw( template-league-table-ranking template-match-individual template-match-team )) if $c->stash->{authorisation}{template_view};
  
  $c->stash({
    db_resultset => "VwSearchAll",
    query_params => {
      q => $c->req->params->{q},
      include_types => \@include_types
    },
    search_action => "/search/index",
    search_all => 1,
    placeholder => $c->maketext("search.form.placeholder", $c->maketext("object.plural.search-all")),
  });
  
  # Do the search
  $c->forward("TopTable::Controller::Search", "do_search");
}

=head2 do_search :Private

Private function for forwarding to from individual search pages to actually do the searches.

=cut

sub do_search {
  my ( $self, $c ) = @_;
  my $db_resultset = $c->stash->{db_resultset};
  my $query_params = $c->stash->{query_params};
  my $q = $query_params->{q};
  my $view_action = $c->stash->{view_action};
  my $search_action = $c->stash->{search_action};
  my $external_scripts = $c->stash->{external_scripts} || [];
  my $external_styles = $c->stash->{external_styles} || [];
  my $include_types = $c->stash->{include_types};
  
  # Add the logging mechanism into the model for debugging, etc.
  $query_params->{logger} = sub{ my $level = shift; $c->log->$level( @_ ); };
  
  if ( $c->is_ajax ) {
    # AJAX request
    if ( defined($q) and $q ne "" ) {
      # We have a query
      # As it's an AJAX request, don't split words up, as it can mess with the autocomplete / tokeninput highlighting.
      $query_params->{split_words} = 0;
      my $search_results = $c->model("DB::$db_resultset")->search_by_name($query_params);
      
      # Return results in JSON
      my $json_search = [];
      
      # Loop through and push it on to the $json_search arrayref
      while ( my $result = $search_results->next ) {
        # Grab the display parameters
        my %display = %{$result->search_display};
        my $type = $display{type};
        
        my $obj_action;
        if ( defined($view_action) ) {
          $obj_action = $view_action;
        } else {
          # Check type to get view action
          if ( $type eq "person" ) {
            $obj_action = "/people/view_current_season";
          } elsif ( $type eq "team" ) {
            $obj_action = "/teams/view_current_season_by_url_key";
          } elsif ( $type eq "club" ) {
            $obj_action = "/clubs/view_current_season";
          } elsif ( $type eq "team-match" ) {
            $obj_action = "/matches/team/view_by_url_keys";
          } elsif ( $type eq "division" ) {
            $obj_action = "/divisions/view_current_season"
          } elsif ( $type eq "venue" ) {
            $obj_action = "/venues/view";
          } elsif ( $type eq "season" ) {
            $obj_action = "/seasons/view";
          } elsif ( $type eq "fixtures-grid" ) {
            $obj_action = "/fixtures-grids/view_current_season";
          } elsif ( $type eq "template-league-table-ranking" ) {
            $obj_action = "/templates/league-table-ranking/view";
          } elsif ( $type eq "template-match-individual" ) {
            $obj_action = "/templates/match/individual/view";
          } elsif ( $type eq "template-match-team" ) {
            $obj_action = "/templates/match/team/view";
          } elsif ( $type eq "user" ) {
            $obj_action = "/users/view";
          } else {
            # Log an error, invalid type
            $c->log->error("Invalid search type: $type");
            next;
          }
        }
        
        my $json_result = {id => $display{id}, url => $c->uri_for_action($obj_action, $display{url_keys})->as_string};
        $json_result->{name} = ( $result->result_source->schema->source($db_resultset)->has_column("date") and defined($result->date) ) ? sprintf("%s (%s)", $display{name}, $result->date->dmy("/")) : $display{name};
        
        
        if ( $type eq "person" and $db_resultset ne "VwSearchAll" ) {
          # Additional formatting options for people
          $json_result->{initial_and_surname} = $result->initial_and_surname;
          $json_result->{initials} = $result->initials;
          $json_result->{first_name} = $result->first_name;
          $json_result->{surname} = $result->surname;
        }
        
        push(@{$json_search}, $json_result);
      }
      
      # Set up the stash
      $c->stash({
        json_data => {json_search => $json_search},
        skip_view_online => 1,
      });
      
      # Detach to the JSON view
      $c->detach($c->view("JSON"));
      return;
    } else {
      # Error, as we should always have a query via AJAX
      my $error = $c->maketext("search.error.no-query");
      $c->log->error($error);
      $c->res->status(400);
      $c->stash({json_data => {messages => {error => $error}}});
      return;
    }
  } else {
    # HTML request
    # Check external scripts / styles
    if ( scalar @{$external_scripts} ) {
      # We already have scripts stashed for this search page, add to them
      push(@{$external_scripts},
        $c->uri_for("/static/script/plugins/uri/URI.js"),
        $c->uri_for("/static/script/plugins/autocomplete/jquery.easy-autocomplete.js"),
      );
    } else {
      $external_scripts = [
        $c->uri_for("/static/script/plugins/uri/URI.js"),
        $c->uri_for("/static/script/plugins/autocomplete/jquery.easy-autocomplete.js"),
      ];
    }
    
    if ( scalar @{$external_styles} ) {
      # We already have scripts stashed for this search page, add to them
      push(@{$external_styles},
        $c->uri_for("/static/css/autocomplete/easy-autocomplete.min.css"),
        $c->uri_for("/static/css/autocomplete/easy-autocomplete.themes.min.css"),
      );
    } else {
      $external_styles = [
        $c->uri_for("/static/css/autocomplete/easy-autocomplete.min.css"),
        $c->uri_for("/static/css/autocomplete/easy-autocomplete.themes.min.css"),
      ];
    }
    
    # Display the search form / stash the common values (needed whether we have a query submitted or not)
    $c->stash({
      template => "html/search.ttkt",
      form_action => $c->uri_for_action( $search_action ),
      subtitle2 => $c->maketext("search.title"),
      scripts => [
        "search-autocomplete",
      ],
      external_scripts => $external_scripts,
      external_styles => $external_styles,
      autocomplete_list => "json_search",
      view_online_display => sprintf( "Searching" ),
      view_online_link => 1,
      search_scripts_added => 1,
    });
    
    if ( defined($q) and $q ne "" ) {
      # We have a query, display results
      # Add page options as we're not AJAXing
      my $page = $c->req->param( "page" ) || undef;
      $page = 1 if !defined($page) or !$page or $page !~ /^\d+$/ or $page < 1;
      
      my $results_per_page = $c->req->param( "results" );
      $results_per_page = $c->config->{Pagination}{default_page_size} if !defined($results_per_page) or !$results_per_page or $results_per_page !~ /^\d+$/ or $results_per_page < 1;
      $query_params->{page} = $page;
      $query_params->{results} = $results_per_page;
      $query_params->{split_words} = 1;
      my $search_results = $c->model("DB::$db_resultset")->search_by_name($query_params);
      
      # Generate pagination links
      my $page_info = $search_results->pager;
      my $page_links  = $c->forward("TopTable::Controller::Root", "generate_pagination_links_qs",
      [{
        page_info => $page_info,
        action => $search_action,
        page => $page,
        params => {q => $q},
      }]);
      
      # Stash the values we need when we have a query value
      $c->stash({
        search_results => [$search_results->all],
        view_online_link => 1,
        q => $q,
        page_info => $page_info,
        page_links => $page_links,
      });
    }
  }
}


=encoding utf8

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
