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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2016-01-08 16:54:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:/zZ/bIljpo18UkEaEHqulA

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

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
