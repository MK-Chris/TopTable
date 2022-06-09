package TopTable::Controller::News;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use Data::Printer;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::News - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.news")});
  
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/news"),
    label => $c->maketext("menu.text.news"),
  });
}

=head2 base_by_url_key

Chain base for getting the news URL key and date parameters and checking them.

=cut

sub base_by_url_key :Chained("/") PathPart("news") CaptureArgs(3) {
  my ( $self, $c, $published_year, $published_month, $id_or_url_key ) = @_;
  
  my $article = $c->model("DB::NewsArticle")->find_id_or_url_key( $id_or_url_key, $published_year, $published_month );
  
  if ( defined($article) ) {
    my $current_details = $article->current_details;
    my $enc_headline = encode_entities($current_details->{headline});
    
    $c->stash({
      article => $article,
      enc_headline => $enc_headline,
      subtitle1 => $enc_headline,
      current_details => $current_details,
    });
    
    # Push the list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/news/view", [$article->published_year, $article->published_month, $article->url_key]),
      label => $enc_headline,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

=head2 base_by_id

Chain base for getting the news ID and checking it.

=cut

sub base_by_id :Chained("/") PathPart("news") CaptureArgs(1) {
  my ( $self, $c, $id ) = @_;
  
  my $article = $c->model("DB::NewsArticle")->find($id);
  
  if ( defined($article) ) {
    my $current_details = $article->current_details;
    my $enc_headline = encode_entities($current_details->{headline});
    
    $c->stash({
      article => $article,
      enc_headline => $enc_headline,
      subtitle1 => $enc_headline,
      current_details => $current_details,
    });
    
    # Push the list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # View page (current season)
      path => $c->uri_for_action("/news/view", [$article->published_year, $article->published_month, $article->url_key]),
      label => $enc_headline,
    });
  } else {
    $c->detach(qw(TopTable::Controller::Root default));
  }
}


=head2 base_list

Chain base for the list of news articles.  Matches /news

=cut

sub base_list :Chained("/") :PathPart("news") :CaptureArgs(0) {
  my ( $self, $c ) = @_;
  my $site_name = $c->stash->{enc_site_name};
  
  # Check that we are authorised to view venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_view", $c->maketext("user.auth.view-news"), 1]);
  
  # Check the authorisation to edit venues we can display the link if necessary
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( news_create news_edit_all news_delete_all ) ], "", 0]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_own", "", 0]) if $c->user_exists and !$c->stash->{authorisation}{news_edit_all}; # Only do this if the user is logged in and we can't edit all articles
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_own", "", 0]) if $c->user_exists and !$c->stash->{authorisation}{news_delete_all}; # Only do this if the user is logged in and we can't delete all articles
  
  # Page description
  $c->stash({
    page_description => $c->maketext("description.news.list", $site_name),
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 list_first_page

List the fixtures grids on the first page.

=cut

sub list_first_page :Chained("base_list") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("retrieve_paged", [1]);
}

=head2 list_specific_page

List the fixtures grids on the specified page.

=cut

sub list_specific_page :Chained("base_list") :PathPart("page") :Args(1) {
  my ( $self, $c, $page_number ) = @_;
  
  # If the page number is less then 1, not defined, false, or not a number, set it to 1
  $page_number = 1 if !defined( $page_number ) or !$page_number or $page_number !~ /^\d+$/ or $page_number < 1;
  
  if ( $page_number == 1 ) {
    $c->stash({canonical_uri => $c->uri_for_action("/news/list_first_page")});
  } else {
    $c->stash({canonical_uri => $c->uri_for_action("/news/list_specific_page", [$page_number])});
  }
  
  $c->detach("retrieve_paged", [$page_number]);
}

=head2 retrieve_paged

Performs the lookups for fixtures grids with the given page number.

=cut

sub retrieve_paged :Private {
  my ( $self, $c, $page_number ) = @_;
  
  my $articles = $c->model("DB::NewsArticle")->page_records({
    page_number => $page_number,
    results_per_page => $c->config->{Pagination}{default_page_size},
  });
  
  my $page_info = $articles->pager;
  my $page_links = $c->forward( "TopTable::Controller::Root", "generate_pagination_links", [{
    page_info => $page_info,
    page1_action => "/news/list_first_page",
    specific_page_action => "/news/list_specific_page",
    current_page => $page_number,
  }] );
  
  # Set up the template to use
  $c->stash({
    template => "html/news/list.ttkt",
    view_online_display => "Viewing news articles",
    view_online_link => 1,
    articles => $articles,
    page_info => $page_info,
    page_links => $page_links,
  });
}

=head2 view_by_id

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_id :Chained("base_by_id") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->detach("view");
}

=head2 view_by_url_key

View a given team's details for the current season (or last complete season if there is no current season).

=cut

sub view_by_url_key :Chained("base_by_url_key") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  
  # Forward to the real view
  $c->detach("view");
}


=head2 view

View a news article

=cut

sub view :Private {
  my ( $self, $c ) = @_;
  my $article = $c->stash->{article};
  my $current_details = $article->current_details;
  my $enc_headline = $c->stash->{enc_headline};
  
  # Check that we are authorised to view news articles
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_view", $c->maketext("user.auth.view-news"), 1]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", [[ qw( news_create news_edit_all news_edit_own news_delete_all news_delete_own ) ], "", 0]);
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push edit link if we are authorised
  unless ( exists($c->stash->{delete_screen}) ) {
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
      text => $c->maketext("admin.edit-object", $enc_headline),
      link_uri => $c->uri_for_action("/news/edit_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key]),
    }) if $c->stash->{authorisation}{news_edit_all} or ( $c->stash->{authorisation}{news_create} and $c->stash->{authorisation}{news_edit_own} and defined($c->user) and $article->updated_by_user->id == $c->user->id );
    
    # Push a delete link if we're authorised and the club can be deleted
    push(@title_links, {
      image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
      text => $c->maketext("admin.delete-object", $enc_headline),
      link_uri => $c->uri_for_action("/news/delete_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key]),
    }) if $c->stash->{authorisation}{news_delete_all} or ( $c->stash->{authorisation}{news_create} and $c->stash->{authorisation}{news_delete_own} and defined($c->user) and $article->updated_by_user->id == $c->user->id );
  }
  
  # Set up the template to use
  $c->stash({
    template => "html/news/view.ttkt",
    title_links => \@title_links,
    view_online_display => "Viewing " . $current_details->{headline},
    view_online_link => 1,
    canonical_uri => $c->uri_for_action("/news/view_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key]),
    page_description => $article->article_description,
  });
}

=head2 create

Display a form to collect information for creating a news article.

=cut

sub create :Local {
  my ( $self, $c ) = @_;
  $c->log->debug( p($c->flash) );
  
  # Check that we are authorised to create venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_create", $c->maketext("user.auth.create-news"), 1]);
  
  # See if we have permissions to pin articles
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_pin", "", 0]);
  
  # Get venues and people to list
  $c->stash({
    template => "html/news/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/standard/ckeditor.js"),
      $c->uri_for("/static/script/news/create-edit.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for("do-create"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Writing a news article",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/news/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit_by_url_key

Chained to the base_by_url_key function, but just forwards to the real routine.

=cut

sub edit_by_url_key :Chained("base_by_url_key") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("edit");
}

=head2 edit_by_id

Chained to the base_by_id function, but just forwards to the real routine.

=cut

sub edit_by_id :Chained("base_by_id") :PathPart("edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("edit");
}

=head2 edit

Display a form to collect information for creating a news article.

=cut

sub edit :Private {
  my ( $self, $c ) = @_;
  my $article = $c->stash->{article};
  my $current_details = $article->current_details;
  
  # Check that we are authorised to edit this article
  my $redirect_on_fail = 1 if !$c->user_exists or ( $c->user_exists and $c->user->id != $article->updated_by_user->id );
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_all", $c->maketext("user.auth.edit-news"), $redirect_on_fail]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_own", $c->maketext("user.auth.edit-news"), 1]) if !$c->stash->{authorisation}{news_edit_all} and $c->user_exists and $c->user->id == $article->updated_by_user->id;
  
  # See if we have permissions to pin articles
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_pin", "", 0]);
  
  # Get venues and people to list
  $c->stash({
    template => "html/news/create-edit.ttkt",
    external_scripts => [
      $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
      $c->uri_for("/static/script/standard/prettycheckable.js"),
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/standard/chosen.js"),
      $c->uri_for("/static/script/standard/datepicker.js"),
      $c->uri_for("/static/script/plugins/ckeditor/ckeditor.js"),
      $c->uri_for("/static/script/plugins/ckeditor/adapters/jquery.js"),
      $c->uri_for("/static/script/standard/ckeditor.js"),
      $c->uri_for("/static/script/news/create-edit.js", {v => 2}),
    ],
    external_styles => [
      $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
      $c->uri_for("/static/css/chosen/chosen.min.css"),
    ],
    form_action => $c->uri_for_action("/news/do_edit_by_url_key", [$article->published_year, $article->published_month, $article->url_key]),
    subtitle2 => "Create",
    view_online_display => sprintf( "Editing news article '%s'", $current_details->{headline} ),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/news/edit_by_url_key", [$article->published_year, $article->published_month, $article->url_key]),
    label => $c->maketext("admin.edit"),
  });
}

=head2 delete_by_url_key

Chained to the base_by_url_key function, but just forwards to the real routine.

=cut

sub delete_by_url_key :Chained("base_by_url_key") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete_by_id

Chained to the base_by_id function, but just forwards to the real routine.

=cut

sub delete_by_id :Chained("base_by_id") :PathPart("delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("delete");
}

=head2 delete

Display the form for deleting the news article.

=cut

sub delete :Private {
  my ( $self, $c ) = @_;
  my $article = $c->stash->{article};
  my $current_details = $article->current_details;
  
  # Check that we are authorised to delete this article
  # The second check (if we get to it) does not redirect, as we don't know the original creator of this article yet (or if the article even exists)
  my $redirect_on_fail = 1 if !$c->user_exists or ( $c->user_exists and $c->user->id != $article->updated_by_user->id );
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_all", $c->maketext("user.auth.delete-news"), $redirect_on_fail]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_own", $c->maketext("user.auth.delete-news"), 1]) if !$c->stash->{authorisation}{news_edit_all} and $c->user_exists;
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    subtitle2 => "Delete",
    subtitle3 => $current_details->{headline},
    template => "html/news/delete.ttkt",
    view_online_display => sprintf( "Deleting %s", $current_details->{headline} ),
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/news/delete_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key]),
    label => $c->maketext("admin.delete"),
  });
}

=head2 do_create

Forwards to the create / edit routine that then passes the data on to the model to error check and process.

=cut

sub do_create :Path("do-create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create venues
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_create", $c->maketext("user.auth.create-news"), 1]);
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["create"]);
}

=head2 do_edit_by_url_key

Chained to the base_by_url_key function, but just forwards to the real routine.

=cut

sub do_edit_by_url_key :Chained("base_by_url_key") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit_by_id

Chained to the base_by_id function, but just forwards to the real routine.

=cut

sub do_edit_by_id :Chained("base_by_id") :PathPart("do-edit") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_edit");
}

=head2 do_edit

Forwards to the create / edit routine that then passes the data on to the model to error check and process.

=cut

sub do_edit :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to edit this article
  # The second check (if we get to it) does not redirect, as we don't know the original creator of this article yet (or if the article even exists)
  my $redirect_on_fail = 1 unless $c->user_exists;
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_all", $c->maketext("user.auth.edit-news"), $redirect_on_fail]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_edit_own", $c->maketext("user.auth.edit-news"), 1]) if !$c->stash->{authorisation}{news_edit_all} and $c->user_exists;
  
  # Forward to the create / edit routine
  $c->detach("process_form", ["edit"]);
}

=head2 do_delete_by_url_key

Chained to the base_by_url_key function, but just forwards to the real routine.

=cut

sub do_delete_by_url_key :Chained("base_by_url_key") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete_by_id

Chained to the base_by_id function, but just forwards to the real routine.

=cut

sub do_delete_by_id :Chained("base_by_id") :PathPart("do-delete") :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach("do_delete");
}

=head2 do_delete

Processes the delete form to delete a news article.

=cut

sub do_delete :Private {
  my ( $self, $c ) = @_;
  my $article = $c->stash->{article};
  my $current_details = $article->current_details;
  my $headline = $current_details->{headline};
  
  # Check that we are authorised to delete this article
  # The second check (if we get to it) does not redirect, as we don't know the original creator of this article yet (or if the article even exists)
  my $redirect_on_fail = 1 unless $c->user_exists;
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_all", $c->maketext("user.auth.delete-news"), $redirect_on_fail]);
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["news_delete_own", $c->maketext("user.auth.delete-news"), 1]) if !$c->stash->{authorisation}{news_edit_all} and $c->user_exists;
  
  my $response = $article->check_and_delete;
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the list page
    $redirect_uri = $c->uri_for_action("/news/list_first_page", {mid => $mid});
    
    # Completed, so we log an event
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["news", "delete", {id => undef}, $headline] );
  } else {
    # Not complete
    $redirect_uri = $c->uri_for_action("/news/view_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key], {mid => $mid});
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=head2 process_form

Process the create / edit form for the news article.

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $article = $c->stash->{article};
  my @field_names = qw( headline article_content pin_article pin_expiry_hour pin_expiry_minute );
  my @processed_field_names = qw( headline article_content pin_article pin_expiry_date pin_expiry_hour pin_expiry_minute );
  
  # See if we have permissions to pin articles
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["news_pin", "", 0] );
  
  unless ( $c->stash->{authorisation}{news_pin} ) {
    # If we can't pin, delete the fields related to pinning
    delete $c->req->params->{pin_article};
    delete $c->req->params->{pin_expiry_date};
    delete $c->req->params->{pin_expiry_hour};
    delete $c->req->params->{pin_expiry_minute};
  } elsif( $c->req->params->{pin_expiry_date} ) {
    
  }
  
  my $response = $c->model("DB::NewsArticle")->create_or_edit($action, {
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
    user => $c->user,
    ip_address => $c->req->address,
    article => $article,
    pin_expiry_date => $c->i18n_datetime_format_date->parse_datetime($c->req->params->{pin_expiry_date}),
    map {$_ => $c->req->params->{$_}} @field_names, # All the fields from the form - put this last because otherwise the following elements are seen as part of the map
  });
  
  # Set the status messages we need to show on redirect
  my @errors = @{$response->{errors}};
  my @warnings = @{$response->{warnings}};
  my @info = @{$response->{info}};
  my @success = @{$response->{success}};
  my $mid = $c->set_status_msg({error => \@errors, warning => \@warnings, info => \@info, success => \@success});
  my $redirect_uri;
  
  if ( $response->{completed} ) {
    # Was completed, display the view page
    $article = $response->{article};
    $redirect_uri = $c->uri_for_action("/news/view_by_url_key", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key], {mid => $mid});
    
    # Completed, so we log an event
    $c->forward("TopTable::Controller::SystemEventLog", "add_event", ["news", $action, {id => $article->id}, $article->current_details->{headline}]);
  } else {
    # Not complete - check if we need to redirect back to the create or view page
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for("/news/create", {mid => $mid});
    } else {
      $redirect_uri = $c->uri_for_action("/news/edit", [$article->published_year, sprintf("%02d", $article->published_month), $article->url_key], {mid => $mid});
    }
    
    # Flash the entered values we've got so we can set them into the form
    $c->flash->{errored_form} = 1;
    $c->flash->{$_} = $response->{fields}{$_} foreach @processed_field_names;
  }
  
  # Now actually do the redirection
  $c->response->redirect($redirect_uri);
  $c->detach;
  return;
}

=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
