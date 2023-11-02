package TopTable::Controller::Info::Officials::Positions;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Info::Officials::Positions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
  
}

=head2 base_position

Chain base for getting the committee position ID and checking it.

=cut

sub base_position :Chained("/") :PathPart("info/officials/positions") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  my $position = $c->model("DB::Official")->find_id_or_url_key($id_or_key);
  
  if ( defined($position) ) {
    # Position found, stash it, then stash the name / view URL in the breadcrumbs section of our stash
    my $enc_name = encode_entities($position->position_name);
    $c->stash({
      position => $position,
      enc_name => $enc_name,
      subtitle1 => $enc_name,
    });
    
    # Push the clubs list page on to the breadcrumbs
    push(@{$c->stash->{breadcrumbs}}, {
      # Club view page (current season)
      path => $c->uri_for_action("/officials/view_position", [$position->url_key]),
      label => $enc_name,
    });
  } else {
    # 404
    $c->detach(qw(TopTable::Controller::Root default));
    return;
  }
}

=head2 create

Create an official / committee member position.  The display order can be edited afterwards, but the new position will be placed after all existing ones.  There is also an option to assign at this stage, although this option is also given in the 'assign_position' option.

=cut

sub create :Path("create") {
  my ( $self, $c ) = @_;
  
  # Check that we are authorised to create committee positions
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["committee_create", $c->maketext("user.auth.create-officials"), 1]);
  
  my $current_season = $c->mode("DB::Season")->get_current;
  
  # Check we have a current season
  unless ( defined($current_season) ) {
    # Error, no current season
    $c->response->redirect($c->uri_for("/seasons/create",
                                {mid => $c->set_status_msg({error => $c->maketext("officials.create.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # Get the number of people - if there are none, we can't show the assignment field.
  my $people_count = $c->model("DB::Person")->search->count;
  
  if ( $people_count ) {
    # First setup the function arguments
    my $tokeninput_options = {
      jsonContainer => "json_search",
      tokenLimit => 1,
      hintText => encode_entities($c->maketext("person.tokeninput.type")),
      noResultsText => encode_entities($c->maketext("tokeninput.text.no-results")),
      searchingText => encode_entities($c->maketext("tokeninput.text.searching")),
    };
    
    # Add the pre-population if needed
    $tokeninput_options->{prePopulate} = [{id => $c->flash->{holder}->id, name => $c->flash->{holder}->display_name}] if defined($c->flash->{holder});
    
    my $tokeninput_confs = [{
      script => $c->uri_for("/people/search"),
      options => encode_json($tokeninput_options),
      selector => "holder",
    }];
    
    $c->stash({tokeninput_confs => $tokeninput_confs});
  }
  
  # Get venues and people to list
  $c->stash({
    template => "html/info/officials/create-edit.ttkt",
    scripts => [
      "tokeninput-standard",
    ],
    external_scripts => [
      $c->uri_for("/static/script/plugins/tokeninput/jquery.tokeninput.mod.js", {v => 2}),
      $c->uri_for("/static/script/info/officials/create-edit.js"),
    ],
    external_styles => [
      $c->uri_for("/static/css/tokeninput/token-input-tt.css"),
    ],
    form_action => $c->uri_for("do-create-position"),
    subtitle2 => $c->maketext("admin.create"),
    view_online_display => "Creating league officials",
    view_online_link => 0,
  });
  
  # Push the breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for_action("/info/officials/create_position"),
    label => $c->maketext("admin.create"),
  });
}

=head2 edit_position

Edit an official / committee member position.  This takes effect for the current season (and is used as the basis for the position in future seasons); if there is no current season, an error is thrown.

=cut

sub edit_position :Path("edit-position") {
  my ( $self, $c ) = @_;
  
  
}

=head2 delete_position

Edit an official / committee member position.  This can only be done if the position hasn't been used for any season.

=cut

sub delete_position :Path("delete-position") {
  my ( $self, $c ) = @_;
  
  
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
