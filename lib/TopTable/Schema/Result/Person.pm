use utf8;
package TopTable::Schema::Result::Person;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Person

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

=head1 TABLE: C<people>

=cut

__PACKAGE__->table("people");

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

=head2 first_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 surname

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 display_name

  data_type: 'varchar'
  is_nullable: 0
  size: 301

=head2 date_of_birth

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 gender

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 1
  size: 20

=head2 address1

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 address2

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 address3

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 address4

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 address5

  data_type: 'varchar'
  is_nullable: 1
  size: 150

=head2 postcode

  data_type: 'varchar'
  is_nullable: 1
  size: 8

=head2 home_telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 work_telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 mobile_telephone

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 254

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
  "first_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "surname",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "display_name",
  { data_type => "varchar", is_nullable => 0, size => 301 },
  "date_of_birth",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
  "gender",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 1, size => 20 },
  "address1",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "address2",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "address3",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "address4",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "address5",
  { data_type => "varchar", is_nullable => 1, size => 150 },
  "postcode",
  { data_type => "varchar", is_nullable => 1, size => 8 },
  "home_telephone",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "work_telephone",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "mobile_telephone",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 254 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<url_key>

=over 4

=item * L</url_key>

=back

=cut

__PACKAGE__->add_unique_constraint("url_key", ["url_key"]);

=head1 RELATIONS

=head2 club_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::ClubSeason>

=cut

__PACKAGE__->has_many(
  "club_seasons",
  "TopTable::Schema::Result::ClubSeason",
  { "foreign.secretary" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 clubs

Type: has_many

Related object: L<TopTable::Schema::Result::Club>

=cut

__PACKAGE__->has_many(
  "clubs",
  "TopTable::Schema::Result::Club",
  { "foreign.secretary" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact_reason_recipients

Type: has_many

Related object: L<TopTable::Schema::Result::ContactReasonRecipient>

=cut

__PACKAGE__->has_many(
  "contact_reason_recipients",
  "TopTable::Schema::Result::ContactReasonRecipient",
  { "foreign.person" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 doubles_pairs_person1s

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs_person1s",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.person1" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 doubles_pairs_person2s

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs_person2s",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.person2" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->has_many(
  "event_seasons",
  "TopTable::Schema::Result::EventSeason",
  { "foreign.organiser" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gender

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupGender>

=cut

__PACKAGE__->belongs_to(
  "gender",
  "TopTable::Schema::Result::LookupGender",
  { id => "gender" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 individual_matches_away_players

Type: has_many

Related object: L<TopTable::Schema::Result::IndividualMatch>

=cut

__PACKAGE__->has_many(
  "individual_matches_away_players",
  "TopTable::Schema::Result::IndividualMatch",
  { "foreign.away_player" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 individual_matches_home_players

Type: has_many

Related object: L<TopTable::Schema::Result::IndividualMatch>

=cut

__PACKAGE__->has_many(
  "individual_matches_home_players",
  "TopTable::Schema::Result::IndividualMatch",
  { "foreign.home_player" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 individual_matches_individual_match_templates

Type: has_many

Related object: L<TopTable::Schema::Result::IndividualMatch>

=cut

__PACKAGE__->has_many(
  "individual_matches_individual_match_templates",
  "TopTable::Schema::Result::IndividualMatch",
  { "foreign.individual_match_template" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 meeting_attendees

Type: has_many

Related object: L<TopTable::Schema::Result::MeetingAttendee>

=cut

__PACKAGE__->has_many(
  "meeting_attendees",
  "TopTable::Schema::Result::MeetingAttendee",
  { "foreign.person" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 meetings

Type: has_many

Related object: L<TopTable::Schema::Result::Meeting>

=cut

__PACKAGE__->has_many(
  "meetings",
  "TopTable::Schema::Result::Meeting",
  { "foreign.organiser" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 officials

Type: has_many

Related object: L<TopTable::Schema::Result::Official>

=cut

__PACKAGE__->has_many(
  "officials",
  "TopTable::Schema::Result::Official",
  { "foreign.position_holder" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->has_many(
  "person_seasons",
  "TopTable::Schema::Result::PersonSeason",
  { "foreign.person" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_tournaments_person1s

Type: has_many

Related object: L<TopTable::Schema::Result::PersonTournament>

=cut

__PACKAGE__->has_many(
  "person_tournaments_person1s",
  "TopTable::Schema::Result::PersonTournament",
  { "foreign.person1" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_tournaments_person2s

Type: has_many

Related object: L<TopTable::Schema::Result::PersonTournament>

=cut

__PACKAGE__->has_many(
  "person_tournaments_person2s",
  "TopTable::Schema::Result::PersonTournament",
  { "foreign.person2" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_people

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogPerson>

=cut

__PACKAGE__->has_many(
  "system_event_log_people",
  "TopTable::Schema::Result::SystemEventLogPerson",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games_away_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games_away_players",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.away_player" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games_home_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games_home_players",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.home_player" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games_umpires

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games_umpires",
  "TopTable::Schema::Result::TeamMatchGame",
  { "foreign.umpire" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_legs_first_servers

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchLeg>

=cut

__PACKAGE__->has_many(
  "team_match_legs_first_servers",
  "TopTable::Schema::Result::TeamMatchLeg",
  { "foreign.first_server" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_legs_next_point_server

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchLeg>

=cut

__PACKAGE__->has_many(
  "team_match_legs_next_point_server",
  "TopTable::Schema::Result::TeamMatchLeg",
  { "foreign.next_point_server" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchPlayer>

=cut

__PACKAGE__->has_many(
  "team_match_players",
  "TopTable::Schema::Result::TeamMatchPlayer",
  { "foreign.player" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_away_teams_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_away_teams_verified",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.away_team_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_home_teams_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_home_teams_verified",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.home_team_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_league_officials_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_league_officials_verified",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.league_official_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches_players_of_the_match

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches_players_of_the_match",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.player_of_the_match" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.captain" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_group_individual_membership_person1s

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroupIndividualMembership>

=cut

__PACKAGE__->has_many(
  "tournament_round_group_individual_membership_person1s",
  "TopTable::Schema::Result::TournamentRoundGroupIndividualMembership",
  { "foreign.person1" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_round_group_individual_membership_person2s

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRoundGroupIndividualMembership>

=cut

__PACKAGE__->has_many(
  "tournament_round_group_individual_membership_person2s",
  "TopTable::Schema::Result::TournamentRoundGroupIndividualMembership",
  { "foreign.person2" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches_away_teams_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches_away_teams_verified",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.away_team_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches_home_teams_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches_home_teams_verified",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.home_team_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_team_matches_league_officials_verified

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeamMatch>

=cut

__PACKAGE__->has_many(
  "tournament_team_matches_league_officials_verified",
  "TopTable::Schema::Result::TournamentTeamMatch",
  { "foreign.league_official_verified" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user

Type: might_have

Related object: L<TopTable::Schema::Result::User>

=cut

__PACKAGE__->might_have(
  "user",
  "TopTable::Schema::Result::User",
  { "foreign.person" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 contact_reasons

Type: many_to_many

Composing rels: L</contact_reason_recipients> -> contact_reason

=cut

__PACKAGE__->many_to_many(
  "contact_reasons",
  "contact_reason_recipients",
  "contact_reason",
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-15 14:32:42
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:B0U4NS1K2kJUQl87efv+LA

#
# Row-level helper methods
#

=head2 full_address

Row-level helper method to get the address with blank lines removed.

=cut

sub full_address {
  my ($self) = @_;
  my @full_address = ();
  
  # Add each address line if it's not blank
  push(@full_address, $self->address1) if defined($self->address1) and $self->address1 ne "";
  push(@full_address, $self->address2) if defined($self->address2) and $self->address2 ne "";
  push(@full_address, $self->address3) if defined($self->address3) and $self->address3 ne "";
  push(@full_address, $self->address4) if defined($self->address4) and $self->address4 ne "";
  push(@full_address, $self->address5) if defined($self->address5) and $self->address5 ne "";
  push(@full_address, $self->postcode) if defined($self->postcode) and $self->postcode ne "";
  
  # Return the string joined with linefeeds. 
  return join("\n", @full_address);
}

=head2 can_delete

Performs the logic to tell us whether or not the person can be deleted; they cannot be deleted if they've played matches in any season.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # Select any seasons in which we've played matches
  my @seasons_started = $self->search_related("person_seasons", {}, {
    where => {
      matches_played => {
        ">" => 0,
      },
    },
  });
  
  # If we've got seasons with stats in, no need to do any more checking, we can't delete
  return 0 if scalar( @seasons_started );
  
  # Doubles pairings - if any of the doubles pairings involving this player have games played,
  # we won't allow delection
  my $pairings1 = $self->search_related("doubles_pairs_person1s", undef, {
    where => {
      games_played => {
        ">" => 0,
      },
    }
  });
  
  my $pairings2 = $self->search_related("doubles_pairs_person2s", undef, {
    where => {
      games_played => {
        ">" => 0,
      },
    }
  });
  
  my $pairings = $pairings1->union( $pairings2 );
  return 0 if $pairings->count > 0;
  
  # If we have no seasons with stats in, we just need to do some additional checking, first
  # for matches the person has umpired.
  my $umpired_matches = $self->search_related("team_match_games_home_players")->count + $self->search_related("team_match_games_away_players")->count;
  return 0 if $umpired_matches;
  
  # Next test for matches the person has verified as an away player
  my $verified_matches = $self->search_related("team_matches_away_teams_verified")->count;
  return 0 if $verified_matches;
  
  # Do the same for as a home player
  $verified_matches = $self->search_related("team_matches_home_teams_verified")->count;
  return 0 if $verified_matches;
  
  # See if they've verified any as a league official
  $verified_matches = $self->search_related("team_matches_league_officials_verified")->count;
  return 0 if $verified_matches;
  
  # Finally check for matches they may have played in (do this last, as it's likely to take the longest and
  # if we fail before here, we'll save time)
  my $matches_played = $self->search_related("team_match_players")->count;
  return 0 if $matches_played;
  
  return 1;
}

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "people.delete.error.not-allowed",
    parameters  => [$self->display_name],
  }) unless $self->can_delete;
  
  # Delete
  my $ok = $self->delete if scalar( @{ $error } ) == 0;
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => [$self->display_name],
  }) unless $ok;
  
  return $error;
}

=head2 games_played_in_season

Return a list of games played by the person in this season.

=cut

sub games_played_in_season {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season};
  
  return $self->result_source->schema->resultset("TeamMatchGame")->search([{
    home_player               => $self->id,
    "team_match.season"       => $season->id,
    "team_seasons.season"     => $season->id,
    "team_seasons_2.season"   => $season->id,
    "person_seasons.season"   => $season->id,
    "person_seasons_2.season" => $season->id,
  }, {
    away_player               => $self->id,
    "team_match.season"       => $season->id,
    "team_seasons.season"     => $season->id,
    "team_seasons_2.season"   => $season->id,
    "person_seasons.season"   => $season->id,
    "person_seasons_2.season" => $season->id,
  }], {
    prefetch  => ["winner", {
      home_player => "person_seasons",
      away_player => "person_seasons",
      team_match  => [{
        home_team => {
          team_seasons => "club"
        },
      }, {
        away_team => {
          team_seasons => "club"
        },
      }],
    }],
    order_by  => {
      -asc    => [ qw( team_match.scheduled_date me.actual_game_number ) ],
    },
  });
}

=head2 plays_for

Returns true if the person plays for the specified team in the specified season.

=cut

sub plays_for {
  my ( $self, $parameters ) = @_;
  my $team    = $parameters->{team};
  my $season  = $parameters->{season};
  
  my @players = $team->get_players({season => $season});
  
  # Start off with a default of false
  my $plays_for = 0;
  
  # Loop through the players trying to find the person ID
  foreach my $player ( @players ) {
    if ( $player->person->id == $self->id ) {
      # IDs match, set plays for to true
      $plays_for = 1;
      
      # Exit the loop
      last;
    }
  }
  
  return $plays_for;
}

=head2 captain_for

Returns true if the person is captain for the specified team in the specified season.

=cut

sub captain_for {
  my ( $self, $parameters ) = @_;
  my $team    = $parameters->{team};
  my $season  = $parameters->{season};
  
  # Get the team's captain
  my $captain = $team->get_captain({season => $season});
  $captain = $captain->id if defined( $captain );
  
  # Return true if the IDs match or false if not
  return ( defined( $captain ) and $captain == $self->id ) ? 1 : 0;
}

=head2 secretary_for

Returns true if the person is secretary for the specified club.

=cut

sub secretary_for {
  my ( $self, $parameters ) = @_;
  my $club = $parameters->{club};
  
  # Get the club's secretary
  my $secretary = $club->secretary->id if defined( $club->secretary );
  
  # Return true if the IDs match or false if not
  return ( defined( $secretary ) and $secretary == $self->id ) ? 1 : 0;
}

=head2 transfer_statistics

Transfer the statistics for the person to the "to_person" in the "season" specified.

Parameters (given in an anonymous hashref in the first argument when calling the sub):

to_person: person object to transfer to.
season: season in which the statistics exist. 

=cut

sub transfer_statistics {
  my ( $self, $parameters ) = @_;
  my %result    = (errors => []);
  my $to_person = $parameters->{to_person};
  my $season    = $parameters->{season};
  
  # Check the person and season are valid.
  push( @{ $result{errors} }, {id => "people.transfer.to-person-invalid"} ) if !defined( $to_person ) or ref( $to_person ) ne "TopTable::Model::DB::Person";
  push( @{ $result{errors} }, {id => "people.transfer.season-invalid"} ) if !defined( $season ) or ref( $season ) ne "TopTable::Model::DB::Season";
  
  if ( scalar( @{ $result{errors} } ) == 0 ) {
    # Search the "to" person to make sure they have no current season statistics.
    my $memberships = $self->result_source->schema->resultset("PersonSeason")->get_person_season_and_teams_and_divisions({
      person                    => $to_person,
      season                    => $season,
      separate_membership_types => 0,
    })->count;
    
    if ( $memberships ) {
      push( @{ $result{errors} }, {id => "people.transfer.has-memberhsips"} );
    } else {
      # No errors, now search for memberships to transfer
      my @memberships = $self->result_source->schema->resultset("PersonSeason")->get_person_season_and_teams_and_divisions({
        person                    => $self,
        season                    => $season,
        separate_membership_types => 0,
      });
      
      # Check if we have any memberships
      if ( scalar( @memberships ) ) {
        # Update each PersonSeason object to the new person
        $_->update({
          person        => $to_person->id,
          display_name  => $to_person->display_name,
          first_name    => $to_person->first_name,
          surname       => $to_person->surname,
        }) foreach ( @memberships );
        
        # Look for doubles pairings to update
        my @doubles_pairs = $self->result_source->schema->resultset("DoublesPair")->pairs_involving_person({
          person  => $self,
          season  => $season,
        });
        
        foreach my $pair ( @doubles_pairs ) {
          if ( $pair->person1->id == $self->id ) {
            # Person 1 matches our "from" person and needs to change
            $pair->update({person1 => $to_person->id});
          } elsif ( $pair->person2->id == $self->id ) {
            # Person 2 matches our "from" person and needs to change
            $pair->update({person2 => $to_person->id});
          }
        }
        
        # Look for team match players to update
        my @player_positions = $self->result_source->schema->resultset("TeamMatchPlayer")->search({
          player => $self->id,
          "team_match.season" => $season->id,
        }, {
          join => "team_match"
        });
        
        $_->update({player => $to_person->id}) foreach ( @player_positions );
        
        # Look for games to update
        my @games = $self->result_source->schema->resultset("TeamMatchGame")->search([{
          doubles_game => 0,
          home_player => $self->id,
          "team_match.season" => $season->id,
        }, {
          doubles_game => 0,
          away_player => $self->id,
          "team_match.season" => $season->id,
        }], {
          join => "team_match",
          prefetch => [ qw( home_player away_player ) ],
        });
        
        foreach my $game ( @games ) {
          if ( $game->home_player->id == $self->id ) {
            # Person 1 matches our "from" person and needs to change
            $game->update({home_player => $to_person->id});
          } elsif ( $game->away_player->id == $self->id ) {
            # Person 2 matches our "from" person and needs to change
            $game->update({away_player => $to_person->id});
          }
          
          # Look for players of the match to update
          my @players_of_match = $self->result_source->schema->resultset("TeamMatch")->search({
            season => $season->id,
            player_of_the_match => $self->id,
          });
          
          $_->update({player_of_the_match => $to_person->id}) foreach ( @players_of_match );
        }
      } else {
        push( @{ $result{errors} }, {id => "people.transfer.nothing-to-transfer"} );
      }
    }
  }
  
  return \%result;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
