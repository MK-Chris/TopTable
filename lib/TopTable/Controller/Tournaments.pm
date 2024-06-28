package TopTable::Controller::Tournaments;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Tournaments - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller to handle tournaments; these methods are all private and forwarded from the Events controller, since to all intents and purposes a tournament is just a type of event.

=head1 METHODS

=cut


=head2 index

# There is no index here - tournaments are always a part of an event, so the listing is dealt with in Events.pm.

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  $c->detach(qw(TopTable::Controller::Root default));
}


=head2 base

Chain base for getting the event identifier and checking it.

Since a tournament is really an event, we'll be forwarding this to the Events base, then traversing.  Only we'll return a 404 if we pass in an event identifier that's not a tournament (i.e., a meeting).

=cut

sub base :Chained("/") :PathPart("events") :CaptureArgs(1) {
  my $self = shift;
  my $c = shift;
  $c->stash({tournament => 1});
  $c->forward("TopTable::Controller::Event", "base", \@_);
}

=head2 add_rounds

Show a form to add rounds to a tournament.  We need only add one round; the others will add automatically, according to who goes through from this round.



=cut

sub add_rounds :Chained("base") :PathPart("add-round") :Args(0) {
  my ( $self, $c ) = @_;
  my $event = $c->stash->{event};
  my $enc_name = $c->stash->{enc_name};
  
  # Don't cache this page.
  $c->response->header("Cache-Control" => "no-cache, no-store, must-revalidate");
  $c->response->header("Pragma" => "no-cache");
  $c->response->header("Expires" => 0);
  
  # Ensure there's a current season - and the tournament has an instance
  # Check that we are authorised to edit clubs
  $c->forward("TopTable::Controller::Users", "check_authorisation", ["event_edit", $c->maketext("user.auth.edit-events"), 1]);  # Try to find the current season (or the last completed season if there is no current season)
  my $current_season = $c->model("DB::Season")->get_current;
    
  if ( defined($current_season) ) {
    # Forward to the routine that stashes the event's season details
    $c->stash({season => $current_season});
    $c->forward("get_event_season");
  } else {
    # There is no current season, so we can't edit
    $c->response->redirect($c->uri_for("/events/view_current_season", [$event->url_key],
                                {mid => $c->set_status_msg({error => $c->maketext("events.edit.error.no-current-season")})}));
    $c->detach;
    return;
  }
  
  # If there are rounds already, we can't create - we can only create the first round (the others are auto-created)
  
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
