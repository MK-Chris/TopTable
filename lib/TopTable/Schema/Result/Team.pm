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

=head2 doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->has_many(
  "person_seasons",
  "TopTable::Schema::Result::PersonSeason",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 team_matches_away_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_away_teams",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.away_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_home_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_home_teams",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.home_team" => "self.id" },
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

=head2 tournament_round_group_team_memberships

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroupTeamMembership>

=cut

__PACKAGE__->has_many(
  "tournament_round_group_team_memberships",
  "TopTable::Schema::Result::TournamentRoundGroupTeamMembership",
  { "foreign.team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches_away_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches_away_teams",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.away_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches_home_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches_home_teams",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.home_team" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2019-12-26 23:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7xEW8y65UN/twvH1LfyXtw

=head2 get_players

Retrieve an arrayref of players registered for this team for the given season.

=cut

sub get_players {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season};
  
  return $self->search_related("person_seasons", {
    season => $season->id,
  }, {
    prefetch => "person",
    order_by => {
      -asc => [ qw( person.surname person.first_name ) ],
    }
  });
}

=head2 get_captain

Retrieve the captain registered for this team for the given season.

=cut

sub get_captain {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season};
  
  return $self->search_related("team_seasons", {
    season => $season->id,
  }, {
    prefetch => "captain",
    rows => 1, 
  })->single->captain;
}

=head2 get_season

Retrieve details for the specified season for this team.

=cut

sub get_season {
  my ( $self, $season ) = @_;
  
  return $self->search_related("team_seasons", {
    season    => $season->id,
  }, {
    prefetch  => [qw( captain division club )],
    rows      => 1,
  })->single;
}

=head2 seasons

Retrieve all seasons associated with the team.

=cut

sub seasons {
  my ( $self ) = @_;
  
  return $self->search_related("team_seasons", undef, {
    prefetch  => [qw( captain division club )],
  });
}

=head2 can_delete

Performs checks to ensure the team can be deleted.  The team cannot be deleted if it has people attached (in any season) or if it has season associations.  The exception to this is if its only association is the current season where no matches have been created.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  my $players = $self->search_related("person_seasons")->count;
  
  # If we have players, we can return false straight away - we can't delete if there are players associated in any season.
  return 0 if $players;
  
  # Now get a list of seasons the team has competed in
  my @season_associations = $self->search_related("team_seasons", {}, {
    prefetch => "season",
    order_by => {
      -desc => [ qw( season.complete season.start_date season.end_date ) ],
    },
  });
  
  # Get the last season this team competed in
  if ( scalar( @season_associations ) == 0 ) {
    # Team hasn't got any season associations, so it's okay to delete
    return 1;
  } elsif ( scalar( @season_associations ) == 1 and $season_associations[0] ) {
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
  my ( $self ) = @_;
  my $error = [];
  my $club = $self->find_related("club");
  
  # Check we can delete
  push(@{ $error }, {
    id          => "seasons.delete.error.matches-exist",
    parameters  => [$club->short_name, $self->name],
  }) unless $self->can_delete;
  
  # Delete
  my $ok = $self->delete if !$error;
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
