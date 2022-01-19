package TopTable::Controller::Admin::Bans;
use Moose;
use namespace::autoclean;
use HTML::Entities;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Admin::Bans - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

=cut

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to issue bans (there is no check for viewing bans - we can either issue (and therefore view / edit) or not).
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["admin_issue_bans", $c->maketext("user.auth.issue-bans"), 1] );
  
  # The title bar will always have
  $c->stash({subtitle2 => $c->maketext("menu.admin.text.bans")});
  
  push( @{ $c->stash->{breadcrumbs} }, {
    path  => $c->uri_for("/admin/bans"),
    label => $c->maketext("menu.admin.text.bans"),
  });
}

=head2 index

List the ban types.

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->stash({
    template => "html/admin/ban/options.ttkt",
    view_online_display => "Admin",
    view_online_link => 0,
    external_scripts => [
      $c->uri_for("/static/script/standard/option-list.js"),
    ],
  });
}

=head2 base

The start of the bans chain, checks the ban type that's passed in is valid.

=cut

sub base :Chained("/") :PathPart("admin/bans") :CaptureArgs(1) {
  my ( $self, $c, $ban_type_id ) = @_;
  
  my $ban_type = $c->model("DB::LookupBanType")->find( $ban_type_id );
  
  if ( defined( $ban_type ) ) {
    # Club found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    my $ban_type_name =  $c->maketext( sprintf( "ban-type.%s", $ban_type->id ) );
    
    $c->stash({
      ban_type => $ban_type,
      ban_type_name => $ban_type_name,
      subtitle3 => $ban_type_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push( @{ $c->stash->{breadcrumbs} }, {
      # Club view page (current season)
      path  => $c->uri_for_action("/admin/bans/list", [$ban_type->id]),
      label => $ban_type_name,
    });
  } else {
    # 404
    $c->detach( qw/TopTable::Controller::Root default/ );
    return;
  }
}

=head2 list

List the bans under the current ban type.

=cut

sub list :Chained("base") :PathPart("") :Args(0) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  
  # Get from the main Bans resultset regardless - if we pass in a type of 'user', the resultset method will query the correct table
  my $bans = $c->model("DB::Ban")->get_bans({type => $ban_type});
  my ( $ext_scripts, $ext_styles );
  
  if ( $bans->count ) {
    $ext_scripts = [
      $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
      $c->uri_for("/static/script/plugins/datatables/jquery.dataTables.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.fixedHeader.min.js"),
      $c->uri_for("/static/script/plugins/datatables/dataTables.responsive.min.js"),
      $c->uri_for("/static/script/admin/bans/list.js"),
    ];
    
    $ext_styles = [
      $c->uri_for("/static/css/chosen/chosen.min.css"),
      $c->uri_for("/static/css/datatables/jquery.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/fixedHeader.dataTables.min.css"),
      $c->uri_for("/static/css/datatables/responsive.dataTables.min.css"),
    ];
  } else {
    $ext_scripts = [
      $c->uri_for("/static/script/standard/option-list.js"),
    ];
  }
  
  $c->stash({
    template => "html/admin/bans/list.ttkt",
    view_online_display => "Admin",
    view_online_link => 0,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
    bans => $bans,
  });
}

=head2 base_item

Carry the chain on into a specific item (takes a ban ID and verifies, then stashes the ban object).

=cut

sub base_item :Chained("base") :PathPart("") :CaptureArgs( 1 ) {
  my ( $self, $c, $ban_id ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->model("DB::Ban")->get_by_id_and_type({
    type => $ban_type,
    id => $ban_id,
  });
  
  unless ( defined( $ban ) ) {
    # 404
    $c->detach( qw/TopTable::Controller::Root default/ );
    return;
  }
  
  my $encoded_name = $ban_type->id eq "username" ? encode_entities( $ban->banned->username ) : encode_entities( $ban->banned_id );
  
  $c->stash({
    ban => $ban,
    encoded_name => $encoded_name,
  });
}

=head2 view

View the given ban details.

=cut

sub view :Chained("base_item") :PathPart("") :Args( 0 ) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->stash->{ban};
  
  # Set up the title links if we need them
  my @title_links = ();
  
  # Push a delete link if we're authorised to eidt all or to edit our own user and are logged in as the user we're viewing
  push(@title_links, {
    image_uri => $c->uri_for("/static/images/icons/0018-Pencil-icon-32.png"),
    text => $c->maketext("admin.edit"),
    link_uri => $c->uri_for_action("/admin/bans/edit", [$ban_type->id, $ban->id]),
  }, {
    image_uri => $c->uri_for("/static/images/icons/0005-Delete-icon-32.png"),
    text => $c->maketext("admin.delete"),
    link_uri => $c->uri_for_action("/admin/bans/delete", [$ban_type->id, $ban->id]),
  }) unless $c->stash->{delete_screen};
  
  $c->stash({
    template => "html/admin/bans/view.ttkt",
    title_links => \@title_links,
    external_scripts => [
      $c->uri_for("/static/script/standard/vertical-table.js"),
    ],
  });
}

=head2 issue

Display a form to collect information for issuing a ban of the stashed type.  We have slightly different forms for each ban type, so it makes more sense to chain it to the base.

=cut

sub issue :Chained("base") :PathPart("issue") :Args(0) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my ( $scripts, $tokeninput_confs );
  
  # Setup the scripts / styles we need regardless of ban type
  my $ext_scripts = [
    $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
    $c->uri_for("/static/script/standard/prettycheckable.js"),
    $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
    $c->uri_for("/static/script/standard/chosen.js"),
    $c->uri_for("/static/script/standard/datepicker.js"),
    $c->uri_for("/static/script/admin/bans/create-edit.js"),
  ];
  
  my $ext_styles = [
    $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    $c->uri_for("/static/css/chosen/chosen.min.css"),
  ];
  
  if ( $ban_type->id eq "username" ) {
    # Username uses a tokeninput
    # Setup the options that always will be there
    my $tokeninput_opts = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Check if we need to prepopulate
    if ( exists( $c->flash->{show_flashed} ) and $c->flash->{show_flashed} and exists( $c->flash->{banned_user} ) ) {
      my $banned_user = $c->flash->{banned_user};
      $tokeninput_opts->{prePopulate} = [{id => $banned_user->id, name => encode_entities( $banned_user->username ) }];
    }
    
    $scripts = ["tokeninput-standard"];
    $tokeninput_confs = [{
      script => $c->uri_for("/users/search"),
      selector => "banned_id",
      options => encode_json( $tokeninput_opts ),
    }];
    
    # Push the external scripts / styles
    push( @{ $ext_scripts }, $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}) );
    push( @{ $ext_styles }, $c->uri_for("/static/css/tokeninput/token-input-tt.css") );
  }
  
  # Stash our values for TT
  $c->stash({
    template => "html/admin/bans/create-edit.ttkt",
    scripts => $scripts,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
    tokeninput_confs => $tokeninput_confs,
    form_action => $c->uri_for_action("/admin/bans/create", [$ban_type->id]),
    subtitle4 => $c->maketext("admin.create"),
    view_online_display => "Admin",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path => $c->uri_for("/admin/bans/create"),
    label => $c->maketext("admin.create"),
  });
}

=head2 create

Process the form to create a ban

=cut

sub create :Chained("base") :PathPart("create") :Args(0) {
  my ( $self, $c ) = @_;
  $c->forward( "process_form", ["create"] );
}

=head2 edit

Display a form to collect information for editing an existing ban of the stashed type.  We have slightly different forms for each ban type, so it makes more sense to chain it to the base.

=cut

sub edit :Chained("base_item") :PathPart("edit") :Args( 0 ) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->stash->{ban};
  
  my ( $scripts, $tokeninput_confs );
  
  # Setup the scripts / styles we need regardless of ban type
  my $ext_scripts = [
    $c->uri_for("/static/script/plugins/prettycheckable/prettyCheckable.min.js"),
    $c->uri_for("/static/script/standard/prettycheckable.js"),
    $c->uri_for("/static/script/plugins/chosen/chosen.jquery.min.js"),
    $c->uri_for("/static/script/standard/chosen.js"),
    $c->uri_for("/static/script/standard/datepicker.js"),
    $c->uri_for("/static/script/admin/bans/create-edit.js"),
  ];
  
  my $ext_styles = [
    $c->uri_for("/static/css/prettycheckable/prettyCheckable.css"),
    $c->uri_for("/static/css/chosen/chosen.min.css"),
  ];
  
  if ( $ban_type->id eq "username" ) {
    # Username uses a tokeninput
    # Check if we need to prepopulate
    # Setup the options that always will be there
    my $tokeninput_opts = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => $c->maketext("person.tokeninput.type"),
      noResultsText => encode_entities( $c->maketext("tokeninput.text.no-results") ),
      searchingText => encode_entities( $c->maketext("tokeninput.text.searching") ),
    };
    
    # Check if we need to prepopulate
    if ( exists( $c->flash->{show_flashed} ) and $c->flash->{show_flashed} and exists( $c->flash->{banned_user} ) ) {
      my $banned_user = $c->flash->{banned_user};
      $tokeninput_opts->{prePopulate} = [{id => $banned_user->id, name => encode_entities( $banned_user->username ) }];
    } elsif ( !exists( $c->flash->{show_flashed} ) or !$c->flash->{show_flashed} ) {
      # Prepopulate with the values from the DB
      my $banned_user = $ban->banned;
      $tokeninput_opts->{prePopulate} = [{id => $banned_user->id, name => encode_entities( $banned_user->username ) }];
    }
    
    $scripts = ["tokeninput-standard"];
    $tokeninput_confs = [{
      script => $c->uri_for("/users/search"),
      selector => "banned_id",
      options => encode_json( $tokeninput_opts ),
    }];
    
    # Push the external scripts / styles
    push( @{ $ext_scripts }, $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}) );
    push( @{ $ext_styles }, $c->uri_for("/static/css/tokeninput/token-input-tt.css") );
  }
  
  # Stash our values for TT
  $c->stash({
    template => "html/admin/bans/create-edit.ttkt",
    scripts => $scripts,
    external_scripts => $ext_scripts,
    external_styles => $ext_styles,
    tokeninput_confs => $tokeninput_confs,
    form_action => $c->uri_for_action("/admin/bans/do_edit", [$ban_type->id, $ban->id]),
    subtitle4 => $c->maketext("admin.create"),
    view_online_display => "Admin",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push( @{ $c->stash->{breadcrumbs} }, {
    path => $c->uri_for("/admin/bans/edit", [$ban->id]),
    label => $c->maketext("admin.create"),
  });
}

=head2 do_edit

Display a form to collect information for editing an existing ban of the stashed type.  We have slightly different forms for each ban type, so it makes more sense to chain it to the base.

=cut

sub do_edit :Chained("base_item") :PathPart("do-edit") :Args( 0 ) {
  my ( $self, $c ) = @_;
  $c->forward( "process_form", ["edit"] );
}

=head2 process_form

Process the form to issue a new ban or edit an existing one. 

=cut

sub process_form :Private {
  my ( $self, $c, $action ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->stash->{ban};
  my $banned_id = $c->req->param( "banned_id" );
  my $expires_date = $c->req->param( "expires_date" );
  my $expires_hour = $c->req->param( "expires_hour" );
  my $expires_minute = $c->req->param( "expires_minute" );
  my $ban_access = $c->req->param( "ban_access" );
  my $ban_registration = $c->req->param( "ban_registration" );
  my $ban_login = $c->req->param( "ban_login" );
  my $ban_contact = $c->req->param( "ban_contact" );
  
  my $response = $c->model("DB::Ban")->create_or_edit({
    action => $action,
    ban => $ban,
    ban_type => $ban_type,
    banned_id => $banned_id,
    expires_date => $expires_date,
    expires_hour => $expires_hour,
    expires_minute => $expires_minute,
    expires_timezone => $c->timezone,
    ban_access => $ban_access,
    ban_registration => $ban_registration,
    ban_login => $ban_login,
    ban_contact => $ban_contact,
    banning_user => $c->user,
    logger => sub{ my $level = shift; $c->log->$level( @_ ); },
  });
  
  my $status_msg = {};
  my @errors = @{$response->{error}};
  
  if ( scalar(@errors) ) {
    # Build the error message
    $status_msg->{error} = $c->build_message( \@errors );
    
    # Flash our form values, then redirect back to the form with an error
    $c->flash({
      show_flashed => 1,
      banned_id => $banned_id,
      expires_date => $expires_date,
      expires_hour => $expires_hour,
      expires_minute => $expires_minute,
      ban_access => $ban_access,
      ban_registration => $ban_registration,
      ban_login => $ban_login,
      ban_contact => $ban_contact,
    });
    
    $c->flash->{banned_user} = $response->{banned_user} if exists( $response->{banned_user} );
    
    my $redirect_uri;
    if ( $action eq "create" ) {
      $redirect_uri = $c->uri_for_action("/admin/bans/issue", [$ban_type->id],
                                {mid => $c->set_status_msg( $status_msg ) });
    } else {
      $redirect_uri = $c->uri_for_action("/admin/bans/edit", [$ban_type->id, $ban->id],
                                {mid => $c->set_status_msg( $status_msg ) });
    }
    
    $c->response->redirect( $redirect_uri );
    $c->detach;
    return;
  } else {
    # Success, log the creation and redirect to the view page
    my $action_description;
    if ( $action eq "create" ) {
      $ban = $response->{ban};
      $action_description = $c->maketext("admin.message.created");
    } else {
      $action_description = $c->maketext("admin.message.edited");
    }
    
    my $object_type = $ban_type->id eq "user" ? "banned-user" : "ban";
    
    my $banned_id = $ban_type->id eq "username" ? $ban->banned->username : $ban->banned_id;
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", [$object_type, $action, {type => $ban_type->id, id => $ban->id}, $banned_id] );
    
    $c->response->redirect( $c->uri_for_action("/admin/bans/view", [$ban_type->id, $ban->id],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.bans.form.success", encode_entities( $banned_id ), $action_description )} ) }) );
    $c->detach;
    return;
  }
}

=head2 delete

Show a form (just a button really) for deleting a ban, along with the ban details.

=cut

sub delete :Chained("base_item") :PathPart("delete") :Args( 0 ) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->stash->{ban};
  
  # We need to run the view_current_season routine to stash some display values.
  # Before that, we stash a value to tell that routine that we're actually showing
  # the delete screen, so it doesn't forward to view_finalise, which we don't need
  $c->stash->{delete_screen} = 1;
  $c->forward("view");
  
  $c->stash({
    template => "html/admin/bans/delete.ttkt",
  });
}

=head2 do_delete

Process the deletion of a ban.

=cut

sub do_delete :Chained("base_item") :PathPart("do-delete") :Args( 0 ) {
  my ( $self, $c ) = @_;
  my $ban_type = $c->stash->{ban_type};
  my $ban = $c->stash->{ban};
  my $ban_name = $ban->banned_id;
  
  my $error = $ban->check_and_delete;
  
  if ( scalar( @{ $error } ) ) {
    # Error deleting
    $c->response->redirect( $c->uri_for_action("/admin/bans/view", [ $ban_type->id, $ban->id ],
                                {mid => $c->set_status_msg( {error => $c->build_message($error)} ) }) );
    $c->detach;
    return;
  } else {
    # Success
    my $object_type = $ban_type->id eq "user" ? "banned-user" : "ban";
    $c->forward( "TopTable::Controller::SystemEventLog", "add_event", [$object_type, "delete", {id => undef}, $ban_name] );
    $c->response->redirect( $c->uri_for_action("/admin/bans/list", [$ban_type->id],
                                {mid => $c->set_status_msg( {success => $c->maketext( "admin.forms.success", encode_entities( $ban_name ), $c->maketext("admin.message.deleted") )} ) }) );
    $c->detach;
    return;
  }
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
