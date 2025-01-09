use utf8;
package TopTable::Schema::Result::Team;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Team

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PassphraseColumn>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp", "PassphraseColumn");

=head1 TABLE: C<teams>

=cut

__PACKAGE__->table("teams");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 45

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 club

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 default_match_start

  data_type: 'time'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "url_key",
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "club",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "default_match_start",
  { data_type => "time", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_club>

=over 4

=item * L</name>

=item * L</club>

=back

=cut

__PACKAGE__->add_unique_constraint("name_club", ["name", "club"]);

=head2 C<url_key_club>

=over 4

=item * L</url_key>

=item * L</club>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key_club", ["url_key", "club"]);

=head1 RELATIONS

=head2 club

Type: belongs_to

Related object: L<TopTable::Schema::Result::Club>

=cut

__PACKAGE__->belongs_to(
  "club",
  "TopTable::Schema::Result::Club",
  { id => "club" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 person_tournaments

Type: has_many

Related object: L<TopTable::Schema::Result::PersonTournament>

=cut

__PACKAGE__->has_many(
  "person_tournaments",
  "TopTable::Schema::Result::PersonTournament",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_teams

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTeam>

=cut

__PACKAGE__->has_many(
  "system_event_log_teams",
  "TopTable::Schema::Result::SystemEventLogTeam",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.winner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_legs

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchLeg>

=cut

__PACKAGE__->has_many(
  "team_match_legs",
  "TopTable::Schema::Result::TeamMatchLeg",
  { "foreign.winner" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchPlayer>

=cut

__PACKAGE__->has_many(
  "team_match_players",
  "TopTable::Schema::Result::TeamMatchPlayer",
  { "foreign.loan_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons_intervals

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeasonsInterval>

=cut

__PACKAGE__->has_many(
  "team_seasons_intervals",
  "TopTable::Schema::Result::TeamSeasonsInterval",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:izvVcij50MYlkFylPAoMNA

use HTML::Entities;

=head2 full_name

Return the club (short) name with the team name.

=cut

sub full_name {
  my $self = shift;
  return sprintf("%s %s", $self->club->short_name, $self->name);
}

=head2 abbreviated_name

Return the club (abbreviated) name with the team name.

=cut

sub abbreviated_name {
  my $self = shift;
  return sprintf("%s %s", $self->club->abbreviated_name, $self->name);
}

=head2 object_name

Used for compatibility with person tournament memberships, so we can refer to object_name regardless of whether we're accessing a tournament or direct team object.

=cut

sub object_name {
  my $self = shift;
  return $self->full_name;
}

=head2 get_seasons

Get team_seasons for this team (all seasons this team has entered).

=cut

sub get_seasons {
  my $self = shift;
  my ( $params ) = @_;
  my $page_number = $params->{page_number} || undef;
  my $results_per_page = $params->{results_per_page} || undef;
  
  my $attrib = {
    prefetch => [qw( season home_night ), {
      captain => "person_seasons",
      club_season => "club",
      division_season => "division",
    }],
    order_by => [{
      -asc => [qw( season.complete )],
    }, {
      -desc => [qw( season.start_date season.end_date )],
    }],
  };
  
  if ( defined($results_per_page) ) {
    # If we're passing in a number of results per page and it's numeric, add that in to the query (along with a 
    # page number - which defaults to 1 if it's not passed in, or it's garbage).
    if ( $results_per_page !~ /^\d+$/ ) {
      $page_number = 1 unless defined( $page_number ) and $page_number =~ /^\d+$/;
      $attrib->{page} = $page_number;
      $attrib->{rows} = $results_per_page;
    }
  }
  
  return $self->search_related("team_seasons", undef, $attrib);
}

=head2 get_season

Retrieve details for the specified season for this team.

=cut

sub get_season {
  my $self = shift;
  my ( $season ) = @_;
  
  return $self->search_related("team_seasons", {
    "me.season" => $season->id,
  }, {
    prefetch => [qw( captain home_night ), {
      division_season => "division",
      club_season => "club"
    }],
    rows => 1,
  })->single;
}

=head2 get_players

Retrieve an arrayref of players registered for this team for the given season.

=cut

sub get_players {
  my $self = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  
  return $self->search_related("team_seasons")->search_related("person_seasons", {
    "person_seasons.season" => $season->id,
    "person_seasons.team_membership_type" => "active",
  }, {
    prefetch => "person",
    order_by => {-asc => [qw( person.surname person.first_name )]}
  });
}

=head2 loan_players

Return matches where the team has played a loan player (in a given season if supplied).

=cut

sub loan_players {
  my $self = shift;
  my ( $comp, $params ) = @_;
  my ( $season, $tournament, $is_tourn );
  
  # Work out if we're checking the tournament or the season (league matches check against the season)
  if ( $comp->isa("TopTable::Schema::Result::Tournament") ) {
    $is_tourn = 1;
    $tournament = $comp;
  } else {
    $is_tourn = 0;
    $season = $comp;
  }
  
  my @where = ({
    "me.home_team" => $self->id,
    "me.location" => "home",
    "me.loan_team" => {"<>" => undef},
  }, {
    "me.away_team" => $self->id,
    "me.location" => "away",
    "me.loan_team" => {"<>" => undef},
  });
  
  my %attrib = (
    join => [qw( player ), {
      team_match  => {
        team_season_home_team_season => [qw( team ), {club_season => "club"}],
        team_season_away_team_season => [qw( team ), {club_season => "club"}],
      },
    }],
    order_by => {-asc => [qw( me.scheduled_date me.home_team me.away_team )]},
  );
  
  if ( $is_tourn ) {
    # Tournament match, check against the tournament
    $where[0]{"tournament.id"} = $tournament->id;
    $where[1]{"tournament.id"} = $tournament->id;
    
    # Add to the attributes so we retrieve the tournament too
    # Element 1 is the hash
    $attrib{join}[1]{team_match}{tournament_round} = [qw( tournament )];
  } else {
    # League match, check against the season
    $where[0]{"team_match.season"} = $season->id;
    $where[1]{"team_match.season"} = $season->id;
  }
  
  return $self->result_source->schema->resultset("TeamMatchPlayer")->search(\@where, \%attrib);
}

=head2 get_captain

Retrieve the captain registered for this team for the given season.

=cut

sub get_captain {
  my $self = shift;
  my ( $params ) = @_;
  my $season = $params->{season};
  
  return $self->search_related("team_seasons", {
    season => $season->id,
  }, {
    prefetch => "captain",
    rows => 1, 
  })->single->captain;
}

=head2 last_competed_season

Get the last season that a team competed in.

=cut

sub last_competed_season {
  my $self = shift;
  my ( $parameters ) = @_;
  my $complete_only = delete $parameters->{complete_only} || 0;
  
  my $where = {complete => 1} if $complete_only;
  
  $self->search_related("team_seasons", $where, {
    rows => 1,
    prefetch => [qw( season home_night ), {
      division_season => "division",
    }],
    order_by => {-desc => [qw( start_date end_date )]}
  })->single;
}

=head2 last_season_entered

Return the season this team was last entered in.

=cut

sub last_season_entered {
  my $self = shift;
  
  return $self->result_source->schema->resultset("Season")->search({
    "team_seasons.team" => $self->id,
  }, {
    join => "team_seasons",
    order_by => {-desc => [qw( me.start_date me.end_date )]},
    rows => 1,
  })->single;
}

=head2 can_delete

Performs checks to ensure the team can be deleted.  The team cannot be deleted if it has people attached (in any season) or if it has season associations.  The exception to this is if its only association is the current season where no matches have been created.

=cut

sub can_delete {
  my $self = shift;
  
  my $players = $self->search_related("team_seasons")->search_related("person_seasons")->count;
  
  # If we have players, we can return false straight away - we can't delete if there are players associated in any season.
  return 0 if $players;
  
  # Now get a list of seasons the team has competed in
  my @season_associations = $self->search_related("team_seasons", {}, {
    prefetch => "season",
    order_by => {-desc => [ qw( season.complete season.start_date season.end_date ) ]},
  });
  
  # Get the last season this team competed in
  if ( scalar @season_associations == 0 ) {
    # Team hasn't got any season associations, so it's okay to delete
    return 1;
  } elsif ( scalar @season_associations == 1 and $season_associations[0] ) {
    # If there are seasons, we need to check if we have matches created for that team
    my $last_season = $season_associations[0]->season;
    
    # Avoid a larger query on league matches by returning 0 if the season is already complete
    return 0 if $last_season->complete;
    
    my $matches = $last_season->search_related("team_matches", [{
      home_team => $self->id,
    }, {
      away_team => $self->id,
    }])->count;
    
    if ( $matches > 0 ) {
      # This team has some matches, so we can't delete them
      return 0;
    } else {
      # No matches have been created, so we're okay.
      return 1;
    }
  } else {
    # If there is more than one season, we can't edit, as at least one of these will have matches created.
    return 0;
  }
}

=head2 check_and_delete

Checks we can delete the team (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the name for messaging
  my $name = encode_entities(sprintf("%s %s", $self->club->short_name, $self->name));
  
  # Check we can delete
  unless ( $self->can_delete ) {
    push(@{$response->{error}}, $lang->maketext("clubs.delete.error.cannot-delete", $name));
    return $response;
  }
  
  # Get the club and the current season if there is one.
  my $club = $self->club;
  my $season = $schema->resultset("Season")->get_current;
  
  # Delete
  my $transaction = $schema->txn_scope_guard;
  
  my $ok = $self->delete_related("team_seasons");
  $ok = $self->delete if $ok;
  $club->delete_related("club_seasons", {"me.season" => $season->id}) if $ok and defined($season) and $club->get_team_seasons({season => $season})->count == 0;
  
  # Commit
  $transaction->commit;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $name));
  }
  
  return $response;
}

=head2 adjust_points

Shortcut to adjust the points for a team in the current season; gets the current season and returns with an error if there is no current season, or the team hasn't entered that season.

=cut

sub adjust_points {
  my $self = shift;
  my ( $params ) = @_;
  
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 0, # Default to 0, we'll recreate that key in the overwritten $response from the team season if we get that far.
  };
  
  # Get the current season
  my $season = $schema->resultset("Season")->get_current;
  
  if ( defined($season) ) {
    my $team_season = $self->get_season($season);
    
    if ( defined($team_season) ) {
      $response = $team_season->adjust_points($params);
    } else {
      push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.team-not-entered-season", encode_entities($self->full_name)));
    }
  } else {
    push(@{$response->{error}}, $lang->maketext("tables.adjustments.error.no-current-season"));
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
