use utf8;
package TopTable::Schema::Result::TeamMatch;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatch

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

=head1 TABLE: C<team_matches>

=cut

__PACKAGE__->table("team_matches");

=head1 ACCESSORS

=head2 home_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 away_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 scheduled_start_time

  data_type: 'time'
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 tournament_group

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

If NULL and tournament_round is not, this is a tournament match but not in a group round.

=head2 tournament_round

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

If NULL, this is a league match.

=head2 division

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

If NULL, this must be part of a tournament

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_week

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 played_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 start_time

  data_type: 'time'
  is_nullable: 1

=head2 team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Denotes that the match has started (remains 1 after the match has started, even if its complete).

=head2 updated_since

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 home_team_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_handicap

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 away_team_games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_handicap

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_match_score

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_match_score_override

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

If populated, this will be the home team score, overridden from the one calculated by the system.

=head2 away_team_match_score

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_match_score_override

  data_type: 'smallint'
  extra: {unsigned => 1}
  is_nullable: 1

If populated, this will be the away team score, overridden from the one calculated by the system.

=head2 player_of_the_match

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 fixtures_grid

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

References the fixtures grid that created this match, so we can determine if the matches for this grid have been created already.

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 league_official_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

References a person on the league committee who has verified the result.

=head2 home_team_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

References a person on the home team who has verified the result.

=head2 away_team_verified

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

References a person on the away team who has verified the result.

=head2 cancelled

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "home_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "away_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "scheduled_start_time",
  { data_type => "time", is_nullable => 0 },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "tournament_group",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "tournament_round",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "division",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_week",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "played_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "start_time",
  { data_type => "time", is_nullable => 1 },
  "team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "updated_since",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "home_team_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_handicap",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "away_team_games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_handicap",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_match_score",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "home_team_match_score_override",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "away_team_match_score",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_match_score_override",
  { data_type => "smallint", extra => { unsigned => 1 }, is_nullable => 1 },
  "player_of_the_match",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "fixtures_grid",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "complete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "league_official_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_team_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_team_verified",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "cancelled",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=back

=cut

__PACKAGE__->set_primary_key("home_team", "away_team", "scheduled_date");

=head1 RELATIONS

=head2 away_team_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "away_team_verified",
  "TopTable::Schema::Result::Person",
  { id => "away_team_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 division_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->belongs_to(
  "division_season",
  "TopTable::Schema::Result::DivisionSeason",
  { division => "division", season => "season" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 fixtures_grid

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesGrid>

=cut

__PACKAGE__->belongs_to(
  "fixtures_grid",
  "TopTable::Schema::Result::FixturesGrid",
  { id => "fixtures_grid" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_team_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "home_team_verified",
  "TopTable::Schema::Result::Person",
  { id => "home_team_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 league_official_verified

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "league_official_verified",
  "TopTable::Schema::Result::Person",
  { id => "league_official_verified" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 player_of_the_match

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "player_of_the_match",
  "TopTable::Schema::Result::Person",
  { id => "player_of_the_match" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 scheduled_week

Type: belongs_to

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->belongs_to(
  "scheduled_week",
  "TopTable::Schema::Result::FixturesWeek",
  { id => "scheduled_week" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 season

Type: belongs_to

Related object: L<TopTable::Schema::Result::Season>

=cut

__PACKAGE__->belongs_to(
  "season",
  "TopTable::Schema::Result::Season",
  { id => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 system_event_log_team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogTeamMatch>

=cut

__PACKAGE__->has_many(
  "system_event_log_team_matches",
  "TopTable::Schema::Result::SystemEventLogTeamMatch",
  {
    "foreign.object_away_team"      => "self.away_team",
    "foreign.object_home_team"      => "self.home_team",
    "foreign.object_scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_games

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchGame>

=cut

__PACKAGE__->has_many(
  "team_match_games",
  "TopTable::Schema::Result::TeamMatchGame",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_players

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchPlayer>

=cut

__PACKAGE__->has_many(
  "team_match_players",
  "TopTable::Schema::Result::TeamMatchPlayer",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_reports

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchReport>

=cut

__PACKAGE__->has_many(
  "team_match_reports",
  "TopTable::Schema::Result::TeamMatchReport",
  {
    "foreign.away_team"      => "self.away_team",
    "foreign.home_team"      => "self.home_team",
    "foreign.scheduled_date" => "self.scheduled_date",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "team_match_template" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_season_away_team_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->belongs_to(
  "team_season_away_team_season",
  "TopTable::Schema::Result::TeamSeason",
  { season => "season", team => "away_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_season_home_team_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->belongs_to(
  "team_season_home_team_season",
  "TopTable::Schema::Result::TeamSeason",
  { season => "season", team => "home_team" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_group

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRoundGroup>

=cut

__PACKAGE__->belongs_to(
  "tournament_group",
  "TopTable::Schema::Result::TournamentRoundGroup",
  { id => "tournament_group" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 tournament_round

Type: belongs_to

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->belongs_to(
  "tournament_round",
  "TopTable::Schema::Result::TournamentRound",
  { id => "tournament_round" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 venue

Type: belongs_to

Related object: L<TopTable::Schema::Result::Venue>

=cut

__PACKAGE__->belongs_to(
  "venue",
  "TopTable::Schema::Result::Venue",
  { id => "venue" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-12-08 23:13:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zWj57DUyQ32OUHOEjaaRBQ

use Try::Tiny;
use DateTime::Duration;
use Set::Object;
use Data::ICal::Entry::Event;
use DateTime;
use DateTime::Format::ICal;
use HTML::Entities;

# Enable automatic date handling
__PACKAGE__->add_columns(
    "updated_since",
    { data_type => "datetime", timezone => "UTC", set_on_create => 0, set_on_update => 1, datetime_undef_if_invalid => 1, is_nullable => 1, },
    "scheduled_date",
    { data_type => "date", timezone => "UTC", set_on_create => 0, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0, },
    "played_date",
    { data_type => "date", timezone => "UTC", set_on_create => 0, set_on_update => 0, datetime_undef_if_invalid => 1, is_nullable => 0, },
);

=head2 url_keys

Returns a hashref with the URL keys in the order we need to use them to generate URLs.

=cut

sub url_keys {
  my $self = shift;
  return [$self->team_season_home_team_season->club_season->club->url_key, $self->team_season_home_team_season->team->url_key, $self->team_season_away_team_season->club_season->club->url_key, $self->team_season_away_team_season->team->url_key, $self->scheduled_date->year, sprintf("%02d", $self->scheduled_date->month), sprintf("%02d", $self->scheduled_date->day)];
}

=head2 name

Match name - param scoreless - returns the teams separated by "v" even if there is a score; if this is not present or passed as false, the return format will be Home Team HScore-AScore Away Team, unless there is no score to show yet.

=cut

sub name {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the scoreless param
  my $scoreless = $params->{scoreless} || 0;
  
  # Shorten the team seasons link
  my $home_season = $self->team_season_home_team_season;
  my $away_season = $self->team_season_away_team_season;
  
  if ( $self->handicapped ) {
    # Start off with both team names
    my $home_team_with_handicap = $home_season->full_name;
    my $away_team_with_handicap = $away_season->full_name;
    
    if ( defined($self->home_team_handicap) or defined($self->away_team_handicap) ) {
      # Handicaps are defined, so are set
      if ( !$self->home_team_handicap and !$self->away_team_handicap ) {
        # Scratch handicap, since they are defined and both 0
        $away_team_with_handicap .= sprintf(" (%s)", $lang->maketext("matches.handicap.scratch-hcp"));
      } else {
        if ( $self->home_team_handicap ) {
          $home_team_with_handicap .= sprintf(" (+%s)", $self->home_team_handicap);
        } else {
          $home_team_with_handicap = $home_season->full_name;
        }
        
        if ( $self->away_team_handicap ) {
          $away_team_with_handicap .= sprintf(" (+%s)", $self->away_team_handicap);
        } else {
          $away_team_with_handicap = $away_season->full_name;
        }
      }
    } else {
      # Handicaps are not defined, so need to be set
      # Add this after the away team
      $away_team_with_handicap .= sprintf(" (%s)", $lang->maketext("matches.handicap.not-yet-set"));
    }
    
    if ( $scoreless or (!$self->home_team_match_score and !$self->away_team_match_score) ) {
      # Scoreless, or there are no scores yet, return Home Team v Away Team; "v" is from the lang files, so needs to be HTML decoded, as it could technically contain HTML and the controller will encode the whole string
      return sprintf("%s %s %s", $home_team_with_handicap, decode_entities($lang->maketext("matches.versus-abbreviation")), $away_team_with_handicap);
    } else {
      # There's a score and we're not asking for scoreless, return with the score
      return sprintf("%s %d-%d %s", $home_team_with_handicap, $self->home_team_match_score, $self->away_team_match_score, $away_team_with_handicap);
    }
  } else {
    if ( $scoreless or (!$self->home_team_match_score and !$self->away_team_match_score) ) {
      # Scoreless, or there are no scores yet, return Home Team v Away Team; "v" is from the lang files, so needs to be HTML decoded, as it could technically contain HTML and the controller will encode the whole string
      return sprintf("%s %s %s", $home_season->full_name, decode_entities($lang->maketext("matches.versus-abbreviation")), $away_season->full_name);
    } else {
      # There's a score and we're not asking for scoreless, return with the score
      return sprintf("%s %d-%d %s", $home_season->full_name, $self->home_team_match_score, $self->away_team_match_score, $away_season->full_name);
    }
  }
}

=head2 competition_name

Return the competition name - this will be "League - [division]" or "[Tournament name] - [round]" (if this is part of a group round, the group name will also be returned)

=cut

sub competition_name {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $comp;
  if ( defined($self->tournament_round) ) {
    # Only encode the tournament name, the round name comes encoded
    $comp = sprintf("%s - %s", encode_entities($self->tournament_round->tournament->event_season->name), $self->tournament_round->name);
    $comp .= sprintf(" (%s)", $self->tournament_group->name) if defined($self->tournament_group);
  } else {
    $comp = sprintf("%s - %s", $lang->maketext("matches.field.competition.value.league"), encode_entities($self->division_season->name));
  }
  
  return $comp;
}

=head2 competition_sort

Return a sortable representation of the competition.  This will be in the format of:

A|B (league = A, tournament = B) - this ensures league is always ahead of tournaments.
League - division rank padded to 3 characters, i.e., 001
Tournament - tournament name, then the round number padded to 3 characters, then optionally the group order number if this is in a group, padded to 3 characters.

Example:
League, Premier Division (or top division):
A001

Tournament "Challenge Cup", round 1, group 10:
BChallenge Cup001010

=cut

sub competition_sort {
  my $self = shift;
  
  my $sort;
  if ( defined($self->tournament_round) ) {
    # Only encode the tournament name, the round name comes encoded
    $sort = sprintf("B%s%03d", encode_entities($self->tournament_round->tournament->event_season->name), $self->tournament_round->round_number);
    $sort .= sprintf("%03d", $self->tournament_group->group_order) if defined($self->tournament_group);
  } else {
    $sort = sprintf("A%03d", encode_entities($self->division_season->division->rank));
  }
  
  return $sort;
}

=head2 handicapped

Return 1 if the match is handicapped, or 0 if not.

=cut

sub handicapped {
  my $self = shift;
  return $self->team_match_template->handicapped;
}

=head2 handicap_format

Tells us if the handicap has been set or needs setting.  Returns undef if this isn't a handicapped match.

=cut

sub handicap_format {
  my $self = shift;
  my ( $location, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Pick up the right field to format
  my $hcp_fld = $location eq "home" ? $self->home_team_handicap : $self->away_team_handicap;
  my $hcp_text;
  if ( $self->handicapped ) {
    if ( $self->handicap_set ) {
      # Handicap is set, if it's greater than 0, add a +
      $hcp_text = $hcp_fld >= 1 ? sprintf("+%d", $hcp_fld) : $hcp_fld;
    } else {
      # Handicap not yet set
      $hcp_text = $lang->maketext("matches.handicap.format.not-set");
    }
  } else {
    # Not a handicapped match
    $hcp_text = "";
  }
  
  return $hcp_text;
}

=head2 relative_handicap

Pass in "home" or "away" as the first argument, the handicap returned is relative to what is passed in (i.e., 'home', the handicap is relative to the home team - if the home team gets the headstart, the handicap will return as a positive; if the away team gets the start, it'll be negative).

=cut

sub relative_handicap {
  my $self = shift;
  my ( $location, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Pick up the right field to format
  my $hcp_text;
  if ( $self->handicapped ) {
    if ( $self->handicap_set ) {
      # Handicap is set
      if ( $location eq "home" ) {
        $hcp_text = $self->home_team_handicap - $self->away_team_handicap;
      } elsif ( $location eq "away" ) {
        $hcp_text = $self->away_team_handicap - $self->home_team_handicap;
      } else {
        return undef;
      }
      
      if ( $hcp_text == 0 ) {
        # Zero - return scratch text
        $hcp_text = $lang->maketext("matches.handicap.scratch");
      } else {
        # Add + if we need to
        $hcp_text = $hcp_text >= 1 ? sprintf("+%d", $hcp_text) : $hcp_text;
      }
    } else {
      # Handicap not yet set
      $hcp_text = $lang->maketext("matches.handicap.format.not-set");
    }
  } else {
    # Not a handicapped match
    $hcp_text = "";
  }
  
  return $hcp_text;
}

=head2 handicap_set

Tells us if the handicap has been set or needs setting.  Returns undef if this isn't a handicapped match.

=cut

sub handicap_set {
  my $self = shift;
  
  if ( $self->handicapped ) {
    if ( defined($self->home_team_handicap) or defined($self->away_team_handicap) ) {
      # Handicaps are defined, so are set
      return 1;
    } else {
      # Handicaps are not defined, so need to be set
      return 0;
    }
  } else {
    # Not handicapped, undef
    return undef;
  }
}

=head2 rules

Return the rules for the match.  Optionally takes a $rule_name argument, which means only that rule is returned, otherwise all are returned as a hash in list context, or hashref in scalar context.

Where these come from depend on the match type (tournament or league); if it's a tournament match and those rules are NULL, we fall back to the season rules.

=cut

sub rules {
  my $self = shift;
  my ( $rule_name ) = @_;
  my $tournament = defined($self->tournament_round) ? $self->tournament_round->tournament : undef;
  my $season = $self->season;
  
  if ( defined($rule_name) ) {
    if ( defined($tournament) ) {
      # Default to tournament rule, if null (not defined) fall back to season
      return $tournament->$rule_name // $season->$rule_name;
    } else {
      # League match, return from the season rules
      return $self->season->$rule_name;
    }
  } else {
    # Return all the rules
    my %rules = defined($tournament)
      ? # Tournament rules, but fall back to season rules if undef
        (
          allow_loan_players_below => $tournament->allow_loan_players_below // $season->allow_loan_players_below,
          allow_loan_players_above => $tournament->allow_loan_players_above // $season->allow_loan_players_above,
          allow_loan_players_across => $tournament->allow_loan_players_across // $season->allow_loan_players_across,
          allow_loan_players_multiple_teams => $tournament->allow_loan_players_multiple_teams // $season->allow_loan_players_multiple_teams_per_division,
          allow_loan_players_same_club_only => $tournament->allow_loan_players_same_club_only // $season->allow_loan_players_same_club_only,
          loan_players_limit_per_player => $tournament->loan_players_limit_per_player // $season->loan_players_limit_per_player,
          loan_players_limit_per_player_per_team => $tournament->loan_players_limit_per_player_per_team // $season->loan_players_limit_per_player_per_team,
          loan_players_limit_per_player_per_opposition => $tournament->loan_players_limit_per_player_per_opposition // $season->loan_players_limit_per_player_per_opposition,
          loan_players_limit_per_team => $tournament->loan_players_limit_per_team // $season->loan_players_limit_per_team,
          void_unplayed_games_if_both_teams_incomplete => $tournament->void_unplayed_games_if_both_teams_incomplete // $season->void_unplayed_games_if_both_teams_incomplete,
          forefeit_count_averages_if_game_not_started => $tournament->forefeit_count_averages_if_game_not_started // $season->forefeit_count_averages_if_game_not_started,
          missing_player_count_win_in_averages => $tournament->missing_player_count_win_in_averages // $season->missing_player_count_win_in_averages,
        )
      : # Season rules (league match)
        (
          allow_loan_players_below => $season->allow_loan_players_below,
          allow_loan_players_above => $season->allow_loan_players_above,
          allow_loan_players_across => $season->allow_loan_players_across,
          allow_loan_players_multiple_teams_per_division => $season->allow_loan_players_multiple_teams_per_division,
          allow_loan_players_same_club_only => $season->allow_loan_players_same_club_only,
          loan_players_limit_per_player => $season->loan_players_limit_per_player,
          loan_players_limit_per_player_per_team => $season->loan_players_limit_per_player_per_team,
          loan_players_limit_per_player_per_opposition => $season->loan_players_limit_per_player_per_opposition,
          loan_players_limit_per_team => $season->loan_players_limit_per_team,
          void_unplayed_games_if_both_teams_incomplete => $season->void_unplayed_games_if_both_teams_incomplete,
          forefeit_count_averages_if_game_not_started => $season->forefeit_count_averages_if_game_not_started,
          missing_player_count_win_in_averages => $season->missing_player_count_win_in_averages,
        );
    
    return wantarray ? %rules : \%rules;
  }
}

=head2 scheduled_start_hour

Return the start hour, split out from the scheduled start time.

=cut

sub scheduled_start_hour {
  my $self = shift;
  
  my @time_bits = split(":", $self->scheduled_start_time);
  return $time_bits[0];
}

=head2 scheduled_start_minute

Return the start hour, split out from the scheduled start time.

=cut

sub scheduled_start_minute {
  my $self = shift;
  
  my @time_bits = split(":", $self->scheduled_start_time);
  return $time_bits[1];
}

=head2 actual_start_hour

Return the start hour, split out from the scheduled start time.

=cut

sub actual_start_hour {
  my $self = shift;
  
  my @time_bits = split(":", $self->actual_start_time);
  return $time_bits[0];
}

=head2 actual_start_minute

Return the start hour, split out from the scheduled start time.

=cut

sub actual_start_minute {
  my $self = shift;
  
  my @time_bits = split(":", $self->actual_start_time);
  return $time_bits[1];
}

=head2 actual_start_time

Return the match start time.  Uses start_time by default, or scheduled_start_time if that's null.

=cut

sub actual_start_time {
  my $self = shift;
  return defined($self->start_time) ? substr($self->start_time, 0, 5) : substr($self->scheduled_start_time, 0, 5);
}

=head2 actual_date

Row-level helper method to get the match played date if there is one, or the scheduled date if not.

=cut

sub actual_date {
  my $self = shift;
  
  if ( defined($self->played_date) ) {
    return $self->played_date;
  } else {
    return $self->scheduled_date;
  }
}

=head2 rescheduled

Returns a simple true or false value based on whether played_date is defined (and if so whether or not it matches scheduled_date).

=cut

sub rescheduled {
  my $self = shift;
  
  # Return 1 if played date is different from the scheduled date.
  if ( $self->played_date->ymd ne $self->scheduled_date->ymd or defined($self->start_time) ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 players_absent

Returns the number of players missing from the match.

=cut

sub players_absent {
  my $self = shift;
  return $self->search_related("team_match_players", {player_missing => 1})->count;
}

=head2 home_players_absent

Returns the number of home players missing from the match.

=cut

sub home_players_absent {
  my $self = shift;
  return $self->search_related("team_match_players", {player_missing => 1, location => "home"})->count;
}

=head2 away_players_absent

Returns the number of home players missing from the match.

=cut

sub away_players_absent {
  my $self = shift;
  return $self->search_related("team_match_players", {player_missing => 1, location => "away"})->count;
}

=head2 games_reordered

Checks whether any 'actual_game_number' fields in games for this match differ from the 'scheduled_game_number' - if so, returns 1, else 0.

=cut

sub games_reordered {
  my $self = shift;
  
  my $reordered_games = $self->search_related("team_match_games", undef, {
    where => {actual_game_number => \'!= scheduled_game_number'},
  })->count;
  
  return $reordered_games ? 1 : 0;
}

=head2 score

Return the score of this match in the format $home_score-$away_score, or the lang code for "not yet played" if the match isn't played yet.

=cut

sub score {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  return $self->started ? sprintf("%d-%d", $self->home_team_match_score, $self->away_team_match_score) : $lang->maketext("matches.versus.not-yet-played");
}

=head2 get_team_seasons

Retrieve the team season objects for the home and away teams in the season that the match took place.  This returns a hashref with 'home' and 'away' keys.

=cut

sub get_team_seasons {
  my $self = shift;
  my $season = $self->season;
  my $team_seasons = {
    home => $self->team_season_home_team_season,
    away => $self->team_season_away_team_season,
  };
  
  return $team_seasons;
}

=head2 update_played_date

Validate and update the played date.

=cut

sub update_played_date {
  my $self = shift;
  my ( $played_date, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  #$logger->("debug", sprintf("date passed: %s, ref: %s", $played_date, ref($played_date)));
  if ( defined($played_date) ) {
    # Do the date checking; eval it to trap DateTime errors and pass them into $error
    if ( ref($played_date) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $played_date->{year};
      my $month = $played_date->{month};
      my $day = $played_date->{day};
      
      # Make sure the date is valid
      try {
        $played_date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        push(@{$response->{errors}}, $lang->maketext("matches.update-match-date.error.date-invalid"));
      };
    } elsif ( ref($played_date) ne "DateTime" ) {
      push(@{$response->{errors}}, $lang->maketext("matches.update-match-date.error.date-invalid"));
    }
  } else {
    push(@{$response->{errors}}, $lang->maketext("matches.update-match-date.error.date-invalid"));
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    #$logger->("debug", sprintf("update played date to %s", $played_date));
    my $ok = $self->update({played_date => $played_date->ymd});
    #$logger->("debug", sprintf("played date is now %s", $self->played_date->ymd));
    
    if ( $ok ) {
      push(@{$response->{success}}, $lang->maketext("matches.update-match-date.success"));
      $response->{completed} = 1;
    } else {
      push(@{$response->{errors}}, $lang->maketext("matches.update-match-date.error.database-update-failed"));
    }
  }
  
  return $response;
}

=head2 played_week

Return the Monday of the played_date week.

=cut

sub played_week {
  my $self = shift;
  my $played_week = $self->played_date->clone;
  $played_week->subtract(days => ($played_week->day_of_week - 1)) unless $played_week->day_of_week == 1;
  
  return $played_week;
}

=head2 update_venue

Validate and update the venue for a match.

=cut

sub update_venue {
  my $self = shift;
  my ( $venue, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  if ( defined($venue) ) {
    # Venue has been submitted, check it's valid
    $venue = $schema->resultset("Venue")->find_id_or_url_key($venue) unless ref($venue) eq "TopTable::Model::DB::Venue";
    
    if ( defined($venue) ) {
      push(@{$response->{errors}}, $lang->maketext("matches.update-venue.error.venue-inactive")) unless $venue->active;
      
      if ( scalar @{$response->{errors}} == 0 ) {
        my $ok = $self->update({venue => $venue->id});
        
        if ( $ok ) {
          push(@{$response->{success}}, $lang->maketext("matches.update-venue.success"));
          $response->{completed} = 1;
        } else {
          push(@{$response->{errors}}, $lang->maketext("matches.update-match-venue.error.database-update-failed"));
        }
      }
    } else {
      # Error, invalid
      push(@{$response->{errors}}, $lang->maketext("matches.update-venue.error.venue-invalid"));
    }
    
  } else {
    # Error, invalid venue
    push(@{$response->{errors}}, $lang->maketext("matches.update-venue.error.venue-blank"));
  }
  
  return $response;
}

=head2 update_handicaps

Validate and update the handicaps for a match.

=cut

sub update_handicaps {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $home_team_handicap = $params->{home_team_handicap} || 0;
  my $away_team_handicap = $params->{away_team_handicap} || 0;
  
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
    fields => {},
  };
  
  # First check if this is a handicapped match
  if ( !$self->handicapped ) {
    push(@{$response->{errors}}, $lang->maketext("matches.handicaps.error.not-a-handicapped-match"));
    return $response;
  }
  
  if ( $self->started ) {
    push(@{$response->{errors}}, $lang->maketext("matches.handicaps.error.match-started"));
    return $response;
  }
  
  # Put in a hash so we can loop through
  my %handicaps = (
    home => $home_team_handicap,
    away => $away_team_handicap,
  );
  
  foreach my $location ( reverse sort keys %handicaps ) {
    if ( $handicaps{$location} ) {
      my $team = $location eq "home" ? $self->team_season_home_team_season->full_name : $self->team_season_away_team_season->full_name;
      push(@{$response->{errors}}, $lang->maketext("matches.handicaps.error.error.handicap-invalid", encode_entities($team))) unless $handicaps{$location} =~ /^-?[1-9]\d{0,2}$/;
    } else {
      # Sanity check - false must be 0
      $handicaps{$location} = 0;
    }
  }
  
  $home_team_handicap = $handicaps{home};
  $away_team_handicap = $handicaps{away};
  $response->{fields}{home_team_handicap} = $home_team_handicap;
  $response->{fields}{away_team_handicap} = $away_team_handicap;
  
  if ( scalar @{$response->{errors}} == 0 ) {
    my $ok = $self->update({home_team_handicap => $home_team_handicap, away_team_handicap => $away_team_handicap});
    
    if ( $ok ) {
      push(@{$response->{success}}, $lang->maketext("matches.handicapes.update.success"));
      $response->{completed} = 1;
    } else {
      push(@{$response->{errors}}, $lang->maketext("matches.handicaps.error.database-update-failed"));
    }
  }
  
  return $response;
}

=head2 update_playing_order

Updates the playing order (i.e., re-orders the the games within a match from the scheduled order).

=cut

sub update_playing_order {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Get the games
  my @games = $self->team_match_games;
  
  # Get the total number of games so we can check we don't go over this number
  my $total_games = scalar @games;
  
  # Store the numbers we've seen
  my %game_numbers;
  
  # Loop through and get the new order for each game.
  foreach my $game ( @games ) {
    # Get the new game number
    my $actual_game_number = $params->{"game-" . $game->scheduled_game_number};
    
    if ( $actual_game_number =~ m/^\d{1,2}$/ and $actual_game_number > $total_games ) {
      # Number invalid
      push(@{$response->{errors}}, $lang->maketext("matches.update-playing-order.error.game-number-invalid", $actual_game_number, $game->scheduled_game_number, $total_games));
    } elsif ( exists($game_numbers{$actual_game_number}) ) {
      # Number already specified
      push(@{$response->{errors}}, $lang->maketext("matches.update-playing-order.error.game-specified-multiple", $actual_game_number, $game->scheduled_game_number, $game_numbers{$actual_game_number}));
    } else {
      $game_numbers{$actual_game_number} = $game->scheduled_game_number;
    }
  }
  
  if ( scalar @{$response->{errors}} == 0 ) {
    # If we get no errors, loop through again and this time update it
    foreach my $game ( @games ) {
      # Get the new game number
      my $actual_game_number = $params->{"game-" . $game->scheduled_game_number};
      
      $game->update({actual_game_number => $actual_game_number});
    }
    
    # Stash the new match scores
    $response->{match_scores} = $self->calculate_match_score;
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("matches.update-playing-order.success"));
  }
  
  return $response;
}

=head2 calculate_match_score

Generate the home and away score of the given match based on the game scores.  Also updates the running game scores if they are incorrect.

=cut

sub calculate_match_score {
  my $self = shift;
  my ( $params ) = @_;
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $match_scores = [];
  
  # The first two $home_score and $away_score will hold the score to be put against each game number, so 0 if it hasn't been played.
  # The internal ones ($_home_score and $_away_score) will be hold the calculated score for each game that's been played and will
  # hold the running score each way through, so if the game hasn't been played this is ignored.
  my ( $home_score, $away_score, $_home_score, $_away_score ) = qw( 0 0 0 0 );
  my ( $home_games_won, $away_games_won, $games_drawn, $_home_games_won, $_away_games_won, $_games_drawn ) = qw( 0 0 0 0 0 0 );
  my $winner_type = $self->team_match_template->winner_type->id;
  
  # Home and away teams to check the winner against in the even of walkovers
  my $home_team = $self->team_season_home_team_season;
  my $away_team = $self->team_season_away_team_season;
  
  # Get the games for the given match
  my @games = $self->search_related("team_match_games", undef, {
    prefetch => qw( individual_match_template ),
    order_by => {-asc => "actual_game_number"}
  });
  
  if ( $self->check_match_started and $self->handicapped ) {
    # If it's handicapped and the match is started, apply the handicaps first
    $_home_score = $self->home_team_handicap;
    $_away_score = $self->away_team_handicap;
  }
  
  # Now loop through the games
  foreach my $game ( @games ) {
    if ( $winner_type eq "games" ) {
      # Match scores are determined by the number of games won
      if ( $game->complete ) {
        # If the game is complete, but wasn't started, it must be a walkover - check the winner field.
        if ( defined($game->winner) ) {
          if ( $game->winner->id == $home_team->team->id ) {
            # Awarded to the home team
            $_home_score++;
            $_home_games_won++;
          } else {
            # Awarded to the away team
            $_away_score++;
            $_away_games_won++;
          }
        } else {
          # Winner not specified, game is void or a draw
          $_games_drawn++ if !$game->void;
        }
      } else {
        # Game not played or in progress, don't increment anything
      }
        
      ( $home_score, $away_score, $home_games_won, $away_games_won, $games_drawn ) = ( $_home_score, $_away_score, $_home_games_won, $_away_games_won, $_games_drawn );
    } elsif ( $winner_type eq "points" ) {
      # Match scores are determined by the number of points won
      if ( $game->started and $game->complete ) {
        # Add the legs won for each team to the total
        $_home_score += $game->home_team_points_won;
        $_away_score += $game->away_team_points_won;
        
        if ( defined($game->winner) ) {
          if ( $game->winner->id == $home_team->id ) {
            # Awarded to the home team - current home points plus the points we need for a win multiplied by the number of legs
            $_home_games_won++;
          } else {
            # Awarded to the away team - current away points plus the points we need for a win multiplied by the number of legs
            $_away_games_won++;
          }
        } else {
          # Must be a draw - it can't be void because it was started
          $_games_drawn++;
        }
        
        ( $home_score, $away_score, $home_games_won, $away_games_won, $games_drawn ) = ( $_home_score, $_away_score, $_home_games_won, $_away_games_won, $_games_drawn );
      } elsif ( $game->complete ) {
        # If the game is complete, but wasn't started, it must be a walkover - check the winner field.
        if ( defined($game->winner) ) {
          # Get the number of points required to win a leg - this will be added to the winner's score for each leg
          my $game_rules = $game->individual_match_template;
          my $minimum_points_win = $game_rules->minimum_points_win;
          my $legs_per_game = $game_rules->legs_per_game;
          
          if ( $game_rules->game_type->id eq "best-of" ) {
            $legs_per_game = ( $game_rules->legs_per_game / 2 ) + 1; # Best of x legs - halve it and + 1
            $legs_per_game = int($legs_per_game); # Truncate any decimal placeas
          }
          
          if ( $game->winner->id == $home_team->id ) {
            # Awarded to the home team - current home points plus the points we need for a win multiplied by the number of legs
            $_home_score += ( $legs_per_game * $minimum_points_win );
            $_home_games_won++;
          } else {
            # Awarded to the away team - current away points plus the points we need for a win multiplied by the number of legs
            $_away_score += ( $legs_per_game * $minimum_points_win );
            $_away_games_won++;
          }
          
          ( $home_score, $away_score, $home_games_won, $away_games_won, $games_drawn ) = ( $_home_score, $_away_score, $_home_games_won, $_away_games_won, $_games_drawn );
        } else {
          # If no winner is defined, the match is void
          ( $home_score, $away_score ) = qw( 0 0 );
        }
      } else {
        # Not played yet
        ( $home_score, $away_score ) = qw( 0 0 );
      }
    }
    
    # Add the score after this match to the array
    push(@{$match_scores}, {
      scheduled_game_number => $game->scheduled_game_number,
      home_score => $home_score,
      away_score => $away_score,
      home_games_won => $home_games_won,
      away_games_won => $away_games_won,
      games_drawn => $games_drawn,
      complete => $game->complete,
      game_in_progress => $game->game_in_progress,
    });
    
    # Check if the database running score is correct; if not, update it
    $game->update({
      home_team_match_score => $home_score,
      away_team_match_score => $away_score,
    });
  }
  
  return $match_scores;
}

=head2 check_match_started

Check whether a match has started by whether at least one game is marked as complete or not - this can be used to determine whether or not to mark the match itself as started.  Returns true if at least one game is complete, or false if no games are.

=cut

sub check_match_started {
  my $self = shift;
  
  # Find games in this match that have been completed
  my $complete_games = $self->search_related("team_match_games", {complete => 1})->count;
  
  if ( $complete_games ) {
    # We have found some completed games, so return true
    return 1;
  } else {
    # No games are complete, so return false
    return 0;
  }
}

=head2 check_match_complete

Check whether a match is complete by whether all of the games are marked complete or not - this can be used to determine whether or not to mark the match itself as complete.  Returns true if all games are complete, or false if one or more game is not.

=cut

sub check_match_complete {
  my $self = shift;
  
  # Loop through the current resultset and push into the array of incomplete games if this one is not complete yet
  my $incomplete_games = $self->search_related("team_match_games", {complete => 0})->count;
  
  if ( $incomplete_games ) {
    # We have found some incomplete games, so return false
    return 0;
  } else {
    # All games are complete, so return true
    return 1;
  }
}

=head2 eligible_players

Return the list of players who are able to play in this match as an array reference; this includes all registered players for either team and any loan players who have been set in a position.

Takes an optional $location parameter, which can specify whether only home or away players are returned.

=cut

sub eligible_players {
  my $self = shift;
  my ( $params ) = @_;
  my $location = $params->{location} || undef;
  undef( $location ) if defined( $location ) and $location ne "home" and $location ne "away";
  my ( @home_players, @away_players );
  my ( $home_team, $away_team ) = ( $self->team_season_home_team_season, $self->team_season_away_team_season );
  
  # Check whether we need to get the home players
  if ( !defined($location) or $location eq "home" ) {
    # Get the registered home players
    @home_players = $self->team_season_home_team_season->search_related("person_seasons", undef, {
      order_by => {-asc => [qw( surname first_name )]}
    })->all;
    
    # Get players set for the match and push them on to the array if they've played up
    my @set_players = $self->search_related("team_match_players", {
      location => "home",
      loan_team => {"!=" => undef},
      "person_seasons.season" => $self->season->id,
    }, {
      prefetch => {player => "person_seasons"},
    });
    
    push(@home_players, $_->player->person_seasons) foreach @set_players;
  }
  
  # Check whether we need to get the home players
  if ( !defined($location) or $location eq "away" ) {
    # Get the registered away players
    @away_players = $self->team_season_away_team_season->search_related("person_seasons", undef, {
      order_by => {-asc => [qw( surname first_name )]}
    })->all;
    
    # Get players set for the match and push them on to the array if they've played up
    my @set_players = $self->search_related("team_match_players", {
      location => "away",
      loan_team => {"!=" => undef},
      "person_seasons.season" => $self->season->id,
    }, {
      prefetch => {player => "person_seasons"},
    });
    
    push(@away_players, $_->player->person_seasons) foreach @set_players;
  }
  
  # Decide what to return
  if ( defined($location) and $location eq "home" ) {
    # Home team only
    return \@home_players;
  } elsif ( defined($location) and $location eq "away" ) {
    # Away team only
    return \@away_players;
  } else {
    # Both teams
    my @return_array = ( @home_players, @away_players );
    return \@return_array;
  }
}

=head2 players

Returns a list of players in the match, along with their 'person' and 'person_seasons' objects.

=cut

sub players {
  my $self = shift;
  my ( $params ) = @_;
  my $location = $params->{location} || "home"; # home or away - default to home
  $location = "home" unless $location eq "home" or $location eq "away"; # Sanity check
  my $where = {"person_seasons.season" => $self->season->id};
  
  # Make sure we bring back the membership of the correct team
  $where->{"person_seasons.team"} = $location eq "home" ? $self->home_team : $self->away_team;
  
  $where->{location} = $location if defined($location);
  
  return $self->search_related("team_match_players", $where, {
    prefetch => {player => "person_seasons"},
  });
}

=head2 noindex_set

Return a list of players who have the 'noindex' flag set on their person record.

=cut

sub noindex_set {
  my ( $self, $on ) = @_;
  
  # Sanity check
  $on = $on ? 1 : 0;
  
  return $self->search_related("team_match_players", {"player.noindex" => $on}, {join => "player"});
}

=head2 update_scorecard

Validates and then updates the details given in the scorecard.

=cut

sub update_scorecard {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
    match_scores => [],
  };
  
  my %game_scores = ();
  
  # Single game if the 'game' and 'leg' parameters are provided
  my $single_game = $params->{game} ? 1 : 0;
  
  # Initial error check that the match is in the current season
  if ( $self->season->complete ) {
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.season-complete"));
    return $response;
  }
  
  
  if ( $self->handicapped and !$self->handicap_set ) {
    push(@{$response->{errors}}, $lang->maketext("matches.update.error.handicap-not-set"));
    return $response;
  }
  
  # Store the season into a more easily accessible variable
  my $season = $self->season;
  
  # The following are needed to get the original scores from this match; if we're editing rather than updating for the first time,
  # we can't just add the scores on to the team / player statistics, as that will add on to the old scores.
  my ( $original_home_team_score, $original_away_team_score, $original_home_team_legs, $original_away_team_legs, $original_home_team_points, $original_away_team_points ) = ( $self->home_team_match_score, $self->away_team_match_score, $self->home_team_legs_won, $self->away_team_legs_won, $self->home_team_points_won, $self->away_team_points_won );
  
  # Check if we're just updating a single leg or a full match
  my $game_response;
  if ( $single_game ) {
    my $game_number = delete $params->{game};
    my $game = $self->team_match_games->find({
      scheduled_game_number => $game_number,
    }, {
      prefetch => [qw( team_match_legs individual_match_template )],
    });
    
    if ( defined($game) ) {
      # Update the game
      $game_response = $game->update_score($params);
      $response->{completed} = $game_response->{completed};
      $response->{match_originally_complete} = $game_response->{match_originally_complete};
      $response->{match_complete} = $game_response->{match_complete};
      $response->{match_scores} = $game_response->{match_scores};
      push(@{$response->{errors}}, @{$game_response->{errors}});
      push(@{$response->{warnings}}, @{$game_response->{warnings}});
      push(@{$response->{info}}, @{$game_response->{info}});
      push(@{$response->{success}}, @{$game_response->{success}});
    } else {
      push(@{$response->{errors}}, $lang->maketext("matches.update-single.error.game-invalid"));
    }
  } else {
    my $games = $self->team_match_games;
    while ( my $game = $games->next ) {
      $game_response = $game->update_score({
        
      });
    }
  }
  
  
  return $response;
}

=head2 cancel

Cancels the match, removing any previous scores and players.

=cut

sub cancel {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 1, # Default to allowed, set to if the season is complete
  };
  
  # Can't cancel a match in a completed season
  if ( $self->season->complete ) {
    push(@{$response->{errors}}, $lang->maketext("matches.cancel.error.season-complete"));
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Grab and error check the points
  my $home_points_awarded = $params->{home_points_awarded} || 0;
  my $away_points_awarded = $params->{away_points_awarded} || 0;
  
  push(@{$response->{errors}}, $lang->maketext("matches.cancel.error.home-points-not-numeric")) if $home_points_awarded !~  /^-?\d+$/;
  push(@{$response->{errors}}, $lang->maketext("matches.cancel.error.away-points-not-numeric")) if $away_points_awarded !~  /^-?\d+$/;
  
  # Return with errors if we have them
  return $response if scalar @{$response->{errors}};
  
  # Transaction so if we fail, nothing is updated
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  # Loop through all the games and delete the scores
  my $games = $self->team_match_games;
  while ( my $game = $games->next ) {
    my $game_result = $game->update_score({delete => 1}) if $game->complete;
  }
  
  # Fields to update the points values for - depends on whether we assign points for win / loss / draw or
  my $league_table_ranking_template = $self->division_season->league_table_ranking_template;
  
  my ( $points_field, $points_against_field );
  if ( $league_table_ranking_template->assign_points ) {
    $points_field = "table_points";
  } else {
    $points_field = "games_won";
    $points_against_field = "games_lost";
  }
  
  # Get and update the team season objects
  my $season = $self->season;
  my ( $home_team, $away_team ) = ( $self->team_season_home_team_season, $self->team_season_away_team_season );
  
  # If the match was previously cancelled and we're just changing the values, we need to alter the awarded points
  if ( $self->cancelled ) {
    # Remove played / won / lost counts (they'll be added to again further down)
    # To be removed in a future update when we don't update matches played / won / lost / drawn for cancellations
    $home_team->matches_played($home_team->matches_played - 1);
    $away_team->matches_played($away_team->matches_played - 1);
    
    if ( $self->home_team_match_score > $self->away_team_match_score ) {
      # Home points awarded are more than away points awarded, so the home team has "won"
      $home_team->matches_won($home_team->matches_won - 1);
      $away_team->matches_lost($away_team->matches_lost - 1);
    } elsif ( $self->home_team_match_score < $self->away_team_match_score ) {
      # Away points awarded are more than home points awarded, so the away team has "won"
      $away_team->matches_won($away_team->matches_won - 1);
      $home_team->matches_lost($home_team->matches_lost  -1);
    } else {
      # Points awarded are equal, so this is a draw
      $away_team->matches_drawn($away_team->matches_drawn - 1);
      $home_team->matches_drawn($home_team->matches_drawn - 1);
    }
    
    # Update the awarded points in the relevant field - also points against if required - the points against should be awarded what the opposite team have been awarded
    # i.e., the away team's points against will be $home_points_awarded
    $home_team->$points_field($home_team->$points_field - $self->home_team_match_score);
    $away_team->$points_field($away_team->$points_field - $self->away_team_match_score);
    
    if ( defined($points_against_field) ) {
      $home_team->$points_against_field($home_team->$points_against_field - $self->away_team_match_score);
      $away_team->$points_against_field($away_team->$points_against_field - $self->home_team_match_score);
    }
  } else {
    # It wasn't previously cancelled, so we need to add one to the matches_cancelled count
    $home_team->matches_cancelled($home_team->matches_cancelled + 1);
    $away_team->matches_cancelled($away_team->matches_cancelled + 1);
  }
    
  # Get a list of the players in this match and remove them; this includes the action of removing the score as well.
  my $players = $self->search_related("team_match_players");
  
  while ( my $player = $players->next ) {
    $player->update_person({action => "remove"});
  }
  
  # Update the match score and cancelled flag
  $self->update({
    home_team_match_score => $home_points_awarded,
    away_team_match_score => $away_points_awarded,
    cancelled => 1,
  });
  
  # Update the awarded points in the relevant field - also points against if required - the points against should be awarded what the opposite team have been awarded
  # i.e., the away team's points against will be $home_points_awarded
  $home_team->$points_field($home_team->$points_field + $home_points_awarded);
  $away_team->$points_field($away_team->$points_field + $away_points_awarded);
  
  if ( defined($points_against_field) ) {
    $home_team->$points_against_field($home_team->$points_against_field + $away_points_awarded);
    $away_team->$points_against_field($away_team->$points_against_field + $home_points_awarded);
  }
  
  # Update the values we know what to update straight off
  # To be removed in a future update when we don't update matches played / won / lost / drawn for cancellations
  $home_team->matches_played($home_team->matches_played + 1);
  $away_team->matches_played($away_team->matches_played + 1);
  
  if ( $home_points_awarded > $away_points_awarded ) {
    # Home points awarded are more than away points awarded, so the home team has "won"
    $home_team->matches_won($home_team->matches_won + 1);
    $away_team->matches_lost($away_team->matches_lost + 1);
  } elsif ( $home_points_awarded < $away_points_awarded ) {
    # Away points awarded are more than home points awarded, so the away team has "won"
    $away_team->matches_won($away_team->matches_won + 1);
    $home_team->matches_lost($home_team->matches_lost + 1);
  } else {
    # Points awarded are equal, so this is a draw
    $away_team->matches_drawn($away_team->matches_drawn + 1);
    $home_team->matches_drawn($home_team->matches_drawn + 1);
  }
  
  # Do the update
  $home_team->update;
  $away_team->update;
  push(@{$response->{success}}, $lang->maketext("matches.cancel.success"));
  $response->{completed} = 1;
  
  # Commit the transaction
  $transaction->commit;
  
  return $response;
}

=head2 uncancel

Undo a match cancellation, remove the points awarded.

=cut

sub uncancel {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
    can_complete => 1, # Default to allowed, set to if the season is complete
  };
  
  # Can't uncancel a match match in a completed season
  if ( $self->season->complete ) {
    push(@{$response->{errors}}, $lang->maketext("matches.uncancel.error.season-complete"));
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Can't uncancel a match that isn't cancelled
  unless ( $self->cancelled ) {
    push(@{$response->{errors}}, $lang->maketext("matches.uncancel.error.not-cancelled"));
    $response->{can_complete} = 0;
    return $response;
  }
  
  # Grab the points that were previously awarded so we can remove them from the home team / away team season totals
  my $home_points_awarded = $self->home_team_match_score;
  my $away_points_awarded = $self->away_team_match_score;
  
  # Transaction so if we fail, nothing is updated
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  # Remove the match score and cancelled flag
  $self->update({
    home_team_match_score => 0,
    away_team_match_score => 0,
    cancelled => 0,
  });
  
  # Get and update the team season objects
  my $season = $self->season;
  my ( $home_team, $away_team ) = ( $self->team_season_home_team_season, $self->team_season_away_team_season );
  
  my $league_table_ranking_template = $self->division_season->league_table_ranking_template;
  
  # Fields to update the points values for - depends on whether we assign points for win / loss / draw or
  my ( $points_field, $points_against_field );
  if ( $league_table_ranking_template->assign_points ) {
    $points_field = "table_points";
  } else {
    $points_field = "games_won";
    $points_against_field = "games_lost";
  }
  
  # Update the awarded points in the relevant field - also points against if required - the points against should be awarded what the opposite team have been awarded
  # i.e., the away team's points against will be $home_points_awarded
  $home_team->$points_field($home_team->$points_field - $home_points_awarded);
  $away_team->$points_field($away_team->$points_field - $away_points_awarded);
  
  if ( defined($points_against_field) ) {
    $home_team->$points_against_field($home_team->$points_against_field - $away_points_awarded);
    $away_team->$points_against_field($away_team->$points_against_field - $home_points_awarded);
  }
  
  # Update the values we know what to update straight off
  $home_team->matches_played($home_team->matches_played - 1);
  $away_team->matches_played($away_team->matches_played - 1);
  $home_team->matches_cancelled($home_team->matches_cancelled - 1);
  $away_team->matches_cancelled($away_team->matches_cancelled - 1);
  
  if ( $home_points_awarded > $away_points_awarded ) {
    # Home points awarded are more than away points awarded, so the home team has "won"
    $home_team->matches_won($home_team->matches_won - 1);
    $away_team->matches_lost($away_team->matches_lost - 1);
  } elsif ( $home_points_awarded < $away_points_awarded ) {
    # Away points awarded are more than home points awarded, so the away team has "won"
    $away_team->matches_won($away_team->matches_won - 1);
    $home_team->matches_lost($home_team->matches_lost - 1);
  } else {
    # Points awarded are equal, so this is a draw
    $away_team->matches_drawn($away_team->matches_drawn - 1);
    $home_team->matches_drawn($home_team->matches_drawn - 1);
  }
  
  # Do the update
  $home_team->update;
  $away_team->update;
  push(@{$response->{success}}, $lang->maketext("matches.uncancel.success"));
  $response->{completed} = 1;
  
  # Commit the transaction
  $transaction->commit;
  
  return $response;
}

=head2 result

Return a hash of details containing various results.  If a location is supplied ("home" or "away"), an extra key "team_result" will contain information regarding whether the team has won, lost, drawn or is winning, losing or drawing.

=cut

sub result {
  my $self = shift;
  my ( $location, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my %return_value = ();
  
  # Check the match status
  if ( $self->started ) {
    # Match has at least been started
    $return_value{score}  = sprintf("%d-%d", $self->home_team_match_score, $self->away_team_match_score);
    
    # Check if we're complete or not
    if ( $self->complete ) {
      # Complete - result is win, loss or draw
      if ( $self->home_team_match_score > $self->away_team_match_score and defined($location) ) {
        # Home win
        if ( $location eq "home" ) {
          # Team specified is home, so this is a win
          $return_value{result} = $lang->maketext("matches.result.win");
        } elsif ( $location eq "away" ) {
          # Team specified is away, so this is a loss
          $return_value{result} = $lang->maketext("matches.result.loss");
        }
      } elsif ( $self->away_team_match_score > $self->home_team_match_score and defined($location) ) {
        # Away win
        if ( $location eq "home" ) {
          # Team specified is home, so this is a loss
          $return_value{result} = $lang->maketext("matches.result.loss");
        } elsif ( $location eq "away" ) {
          # Team specified is away, so this is a win
          $return_value{result} = $lang->maketext("matches.result.win");
        }
      } elsif ( $self->home_team_match_score == $self->away_team_match_score ) {
        # Draw - regardless of which team is specified
        $return_value{result} = $lang->maketext("matches.result.draw");
      }
    } else {
      # Not complete - result is winning, losing or drawing
      # Complete - result is win, loss or draw
      if ( $self->home_team_match_score > $self->away_team_match_score and defined($location) ) {
        # Home winning
        if ( $location eq "home" ) {
          # Team specified is home, so they're winning
          $return_value{result} = $lang->maketext("matches.result.winning");
        } elsif ( $location eq "away" ) {
          # Team specified is away, so they're losing
          $return_value{result} = $lang->maketext("matches.result.losing");
        }
      } elsif ( $self->away_team_match_score > $self->home_team_match_score and defined($location) ) {
        # Away win
        if ( $location eq "home" ) {
          # Team specified is home, so they're losing
          $return_value{result} = $lang->maketext("matches.result.losing");
        } elsif ( $location eq "away" ) {
          # Team specified is away, so they're winning
          $return_value{result} = $lang->maketext("matches.result.winning");
        }
      } elsif ( $self->home_team_match_score == $self->away_team_match_score ) {
        # Draw - regardless of which team is specified
        $return_value{result} = $lang->maketext("matches.result.drawing");
      }
    }
  } elsif ( $self->cancelled ) {
    # Match was cancelled
    $return_value{result} = $lang->maketext("matches.result.cancelled");
    $return_value{score}  = sprintf("%d-%d", $self->home_team_match_score, $self->away_team_match_score);
  } else {
    # Match hasn't been updated yet
    return undef;
  }
  
  return \%return_value;
}

=head2 generate_ical_data

Generate a hashref of data that can be easily manipulated into iCal format.  Takes a get_uri, get_versus_abbreviation parameter as a hostname to generate things this model can't know about.

=cut

sub generate_ical_data {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  my ( $home_team, $away_team ) = ( $self->team_season_home_team_season, $self->team_season_away_team_season );
  
  # Split the start time for setting the hour and minute
  my ( $start_hour, $start_minute ) = split(":", $self->actual_start_time);
  
  # Get the URI
  my $uri = $params->{get_uri}($self->url_keys);
  
  # Get the timezone
  my $zone = $params->{timezone};
  
  my $description;
  
  if ( defined($self->tournament_round) ) {
    $description = sprintf("%s: %s\n%s: %s", $lang->maketext("matches.field.competition"), $self->tournament_round->tournament->event_season->name, $lang->maketext("matches.field.tournament-round"), $self->tournament_round->name);
    $description .= sprintf("\n%s: %s", $lang->maketext("matches.field.tournament-group"), $self->tournament_group->name) if defined($self->tournament_group);
    $description .= sprintf("%s: %s\n%s", $lang->maketext("matches.field.season"), $self->season->name, $uri);
  } else {
    $description = sprintf("%s: %s\n%s: %s\n%s: %s\n%s", $lang->maketext("matches.field.competition"), $lang->maketext("matches.field.competition.value.league"), $lang->maketext("matches.field.division"), $self->division_season->name, $lang->maketext("matches.field.season"), $self->season->name, $uri);
  }
  
  # Current date / time in UTC
  my $now_utc = DateTime->now(time_zone => "UTC");
  
  my ( $home_club_name, $away_club_name );
  
  if ( defined($params->{abbreviated_club_names}) and $params->{abbreviated_club_names} ) {
    $home_club_name = $home_team->club_season->abbreviated_name;
    $away_club_name = $away_team->club_season->abbreviated_name;
  } else {
    $home_club_name = $home_team->club_season->short_name;
    $away_club_name = $away_team->club_season->short_name;
  }
  
  # Add a colon and space to the end of the prefix if the user didn't provide either a colon or hyphen after it (followed by optional space)
  $params->{summary_prefix} .= ": " if exists($params->{summary_prefix}) and defined($params->{summary_prefix}) and $params->{summary_prefix} ne "" and $params->{summary_prefix} !~ m/[-:]\s?$/;
  
  # Set the prefix to a blank space if it doesn't exist or is undef
  $params->{summary_prefix} = "" unless exists($params->{summary_prefix}) and defined($params->{summary_prefix});
  
  my $event = Data::ICal::Entry::Event->new;
  $event->add_properties(
    uid => sprintf("matches.team.%s-%s.%s-%s.%s@%s", $home_team->club_season->club->url_key, $home_team->team->url_key, $away_team->club_season->club->url_key, $away_team->team->url_key, $self->actual_date->ymd("-"), &{$params->{get_host}}),
    summary => sprintf("%s%s %s %s %s %s", $params->{summary_prefix}, $home_club_name, $home_team->name, $lang->maketext("matches.versus-abbreviation"), $away_club_name, $away_team->name),
    status => $self->cancelled ? "CANCELLED" : "CONFIRMED",
    description => $description,
    dtstart => [DateTime::Format::ICal->format_datetime($self->actual_date->set(hour => $start_hour, minute => $start_minute)), {TZID => $zone->timezone}],
    duration => DateTime::Format::ICal->format_duration(DateTime::Duration->new(minutes => &{$params->{get_duration}})),
    location => $self->venue->full_address(", "),
    geo => sprintf("%s;%s", $self->venue->coordinates_latitude, $self->venue->coordinates_longitude),
    url => $uri,
    created => DateTime::Format::ICal->format_datetime($now_utc),
    "last-modified" => DateTime::Format::ICal->format_datetime($now_utc),
    dtstamp => DateTime::Format::ICal->format_datetime($now_utc),
  );
  
  return $event;
}

=head2 get_reports

Retrieve the reports for this match (reports is plural because it also retrieves previous edits of the report).  The live report (most recent edit) will always be the first record (if there are any); subsequent reports if there are any will be edits in descending date published order.

=cut

sub get_reports {
  my $self = shift;
  
  return $self->search_related("team_match_reports", undef, {
    prefetch => "author",
    order_by => {-desc => "published"},
  });
}

=head2 get_original_report

Retrieve the original report for this match (useful for getting the author of the original report).

=cut

sub get_original_report {
  my $self = shift;
  
  return $self->search_related("team_match_reports", undef, {
    prefetch => "author",
    order_by => {-asc => "published"},
    rows => 1,
  })->single;
}

=head2 get_original_report

Retrieve the original report for this match (useful for getting the author of the original report).

=cut

sub get_latest_report {
  my $self = shift;
  
  return $self->search_related("team_match_reports", undef, {
    prefetch => "author",
    order_by => {-desc => "published"},
    rows => 1,
  })->single;
}

=head2 can_report

Test whether a match can be reported on.  If a user parameter is not passed, this just checks whether the match is in the current season and returns true if so and false if not; if a user and the authorisation check from the main app is passed, this will also perform an additional check (if the match is in the current season, otherwise it's pointless) that the user is authorised to submit reports for the team.

=cut

sub can_report {
  my $self = shift;
  my ( $user ) = @_;
  my $season = $self->season;
  
  # Just return false if the season is complete - no one can submit or edit a report in a completed season.
  return 0 if $season->complete or !defined($user) or ref($user) ne "Catalyst::Authentication::Store::DBIx::Class::User";
  
  # Check the user is authorised to do this - first of all we check if there are any reports already
  my $original_report = $self->get_original_report;
  
  # The roles the user has will always be the same regardless of the original; need roles depends on the situation
  my $have_roles = Set::Object->new($user->roles);
  my @need_roles;
  
  if ( defined($original_report) ) {
    # We have an original report, so we need to check if the current user is the original author before we can get the
    # roles that will be allowed to edit.
    
    # Work out which field name we're looking for
    my $auth_column = $original_report->author->id == $user->id ? "matchreport_edit_own" : "matchreport_edit_all";
    
    @need_roles = $self->result_source->schema->resultset("Role")->search({
      $auth_column => 1
    }, {
      order_by => {-asc => [qw( name )]},
    });
  } else {
    # There is no report yet, so we need to check if the user is associated with any clubs or teams before we can get the
    # roles that will be allowed to edit.
    my $home_team = $self->team_season_home_team_season;
    my $away_team = $self->team_season_away_team_season;
    my $home_club = $self->team_season_home_team_season->club_season->club;
    my $away_club = $self->team_season_away_team_season->club_season->club;
    
    my $auth_column = ( $user->plays_for({team => $home_team, season => $season}) or
      $user->captain_for({team => $home_team}) or
      $user->plays_for({team => $away_team, season => $season}) or
      $user->captain_for({team => $away_team, season => $season}) or
      $user->secretary_for({club => $home_club}) or
      $user->secretary_for({club => $away_club})
      ) ? "matchreport_create_associated"
        : "matchreport_create";
    
    @need_roles = $self->result_source->schema->resultset("Role")->search({
      $auth_column => 1
    }, {
      order_by => {-asc => [qw( name )]},
    });
  }
  
  # Extract the name column for each returned value
  @need_roles = map($_->name, @need_roles);
  
  my $need_roles = Set::Object->new(@need_roles);
  if ( $have_roles->intersection($need_roles)->size > 0 ) {
    return 1;
  } else {
    return 0;
  }
}

=head2 add_report

Add a report to the match.

=cut

sub add_report {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  my $report = $params->{report};
  my $user = $params->{user};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  
  my $raw_report = TopTable->model("FilterHTML")->filter($report);
  $raw_report =~ s/^\s+|\s+$//g;
  
  push(@{$response->{errors}}, $lang->maketext("matches.report.error.not-authorised", $user->username)) unless $self->can_report($user);
  push(@{$response->{errors}}, $lang->maketext("matches.report.error.report-blank")) unless $raw_report;
  
  # No errors so far, try and add a report
  unless ( scalar @{$response->{errors}} ) {
    # Determine whether we're creating or editing
    my $original_report = $self->get_original_report;
    
    my ( $action, $action_desc ) = defined($original_report) ? qw( edit edited ) : qw( create created );
    
    $response->{action} = $action;
    my $report = $self->create_related("team_match_reports", {
      author => $user->id,
      report => TopTable->model("FilterHTML")->filter($report, "textarea"),
    });
    
    push(@{$response->{success}}, $lang->maketext("matches.report.success", $lang->maketext("admin.message.$action_desc")));
    $response->{completed} = 1;
  }
  
  return $response;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
