use utf8;
package TopTable::Schema::Result::Season;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Season

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

=head1 TABLE: C<seasons>

=cut

__PACKAGE__->table("seasons");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 0
  size: 30

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 default_match_start

  data_type: 'time'
  is_nullable: 0

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 50

=head2 start_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 end_date

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 allow_loan_players_below

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Allow loan players from a lower division than the match being played

=head2 allow_loan_players_above

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Allow loan players from a higher division than the match being played

=head2 allow_loan_players_across

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Allow loan players from the same division as the match being played

=head2 allow_loan_players_multiple_teams_per_division

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Allow loan players to play on loan for more than one team in the same division

=head2 allow_loan_players_same_club_only

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Only allow loan players from the same club as the team they are on loan for

=head2 loan_players_limit_per_player

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Maximum number of times a player may play on loan in total (0 for no limit)

=head2 loan_players_limit_per_player_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Maximum number of times a player may play on loan for the same team (0 for no limit)

=head2 loan_players_limit_per_player_per_opposition

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Maximum number of times a player may play on loan against the same team (0 for no limit)

=head2 loan_players_limit_per_team

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Maximum number of times a team may play loan players (0 for no limit)

=head2 void_unplayed_games_if_both_teams_incomplete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Void games (no team wins) between a present and absent player if both teams have missing players

=head2 forefeit_count_averages_if_game_not_started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

Count a game as won in the player averages even if it was not started (the opposition player pulled out before the game started)

=head2 missing_player_count_win_in_averages

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

If a player is missing, count as a win for the opposition players in the player averages

=head2 rules

  data_type: 'longtext'
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
  { data_type => "varchar", is_nullable => 0, size => 30 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "default_match_start",
  { data_type => "time", is_nullable => 0 },
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 50 },
  "start_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "end_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "complete",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "allow_loan_players_below",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_above",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_across",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_multiple_teams_per_division",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "allow_loan_players_same_club_only",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_player",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_player_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_player_per_opposition",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_players_limit_per_team",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "void_unplayed_games_if_both_teams_incomplete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "forefeit_count_averages_if_game_not_started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "missing_player_count_win_in_averages",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "rules",
  { data_type => "longtext", is_nullable => 1 },
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
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 division_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->has_many(
  "division_seasons",
  "TopTable::Schema::Result::DivisionSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 doubles_pairs

Type: has_many

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->has_many(
  "doubles_pairs",
  "TopTable::Schema::Result::DoublesPair",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 event_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->has_many(
  "event_seasons",
  "TopTable::Schema::Result::EventSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_weeks",
  "TopTable::Schema::Result::FixturesWeek",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 official_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::OfficialSeason>

=cut

__PACKAGE__->has_many(
  "official_seasons",
  "TopTable::Schema::Result::OfficialSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 person_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::PersonSeason>

=cut

__PACKAGE__->has_many(
  "person_seasons",
  "TopTable::Schema::Result::PersonSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogSeason>

=cut

__PACKAGE__->has_many(
  "system_event_log_seasons",
  "TopTable::Schema::Result::SystemEventLogSeason",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_matches

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->has_many(
  "team_matches",
  "TopTable::Schema::Result::TeamMatch",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeason>

=cut

__PACKAGE__->has_many(
  "team_seasons",
  "TopTable::Schema::Result::TeamSeason",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 team_seasons_intervals

Type: has_many

Related object: L<TopTable::Schema::Result::TeamSeasonsInterval>

=cut

__PACKAGE__->has_many(
  "team_seasons_intervals",
  "TopTable::Schema::Result::TeamSeasonsInterval",
  { "foreign.season" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-11-21 12:21:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:UrK2VB2hJKZjQa4uPhwISw

use HTML::Entities;

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my $self = shift;
  return [$self->url_key];
}

=head2 number_of_weeks

Returns the number of weeks in the season.

=cut

sub number_of_weeks {
  my $self = shift;
  
  my $season_weeks;
  for (my $dt = $self->start_date->clone; $dt <= $self->end_date; $dt->add(weeks => 1) ) {
    $season_weeks++;
  }
  
  return $season_weeks;
}

=head2 start_date_long

Return the long start date for the season.

=cut

sub start_date_long {
  my $self = shift;
  return sprintf("%s, %s %s %s", ucfirst($self->start_date->day_name), $self->start_date->day, $self->start_date->month_name, $self->start_date->year);
}

=head2 end_date_long

Return the long end date for the season.

=cut

sub end_date_long {
  my $self = shift;
  return sprintf("%s, %s %s %s", ucfirst($self->end_date->day_name), $self->end_date->day, $self->end_date->month_name, $self->end_date->year);
}

=head2 all_clubs

Return a list of teams who have entered this season.

=cut

sub all_clubs {
  my $self = shift;
  
  return $self->search_related("club_seasons", undef, {
    order_by  => {-asc => [qw( full_name )]},
  });
}

=head2 all_teams

Return a list of teams who have entered this season.

=cut

sub all_teams {
  my $self = shift;
  
  return $self->search_related("team_seasons", undef, {
    join => "club_season",
    order_by => {-asc => [qw( club_season.short_name me.name )]},
  });
}

=head2 all_players

Return a list of players who have entered this season.

=cut

sub all_players {
  my $self = shift;
  return $self->search_related("person_seasons", {team_membership_type => "active"});
}

=head2 league_matches

Return a list of mamtches for a given season.  If the 'mode' is given, only those relevant matches are returned; the modes are:

* cancelled - any cancelled match.
* rearranged - any matches where the played_date is not null and doesn't match the scheduled_date
* incomplete-team - any matches where at least one player is missing
* loan-players - any matches that had at least one loan player

=cut

sub league_matches {
  my $self = shift;
  my ( $params ) = @_;
  my $mode = $params->{mode} || undef;
  
  # A lot of these are only used to get a count, in which case we don't need to do expensive prefetches - so we make it a manual option.
  my $prefetch = $params->{prefetch} || 0;
  my $where = {};
  my $attrib = {};
  
  if ( defined($mode) ) {
    if ( $mode eq "cancelled" ) {
      $where->{cancelled} = 1;
    } elsif ( $mode eq "rearranged" ) {
      my $compare_field = "played_date";
      $where->{scheduled_date} = {"!=" => \$compare_field};
      $where->{cancelled} = 0;
    } elsif ( $mode eq "missing-players" ) {
      $where->{"team_match_players.player_missing"} = 1;
      $attrib->{join} = "team_match_players";
    } elsif ( $mode eq "loan-players" ) {
      $where->{"team_match_players.loan_team"} = {"!=" => undef};
      $attrib->{join} = "team_match_players";
    }
    
    # We only prefetch if there's a mode defined, we don't want to do lots of prefetches for all the matches in a season
    if ( $prefetch ) {
      $attrib->{prefetch} = [qw( venue ), {
        division_season => [qw( division )],
        team_season_home_team_season => [qw( team ), {
          club_season => [qw( club )],
        }],
        team_season_away_team_season => [qw( team ), {
          club_season => [qw( club )],
        }],
      }];
    }
  }
  
  return $self->search_related("team_matches", $where, $attrib);
}

=head2 divisions

Return the divisions that have an association with the season.

=cut

sub divisions {
  my $self = shift;
  
  return $self->search_related("division_seasons", undef, {
    prefetch => "division",
    order_by => {-asc => [qw( division.rank )]}
  });
}

=head2 weeks

Get the fixtures weeks objects related to this season.

=cut

sub weeks {
  my $self = shift;
  
  return $self->search_related("fixtures_weeks", {}, {
    order_by => {-asc => [qw( week_beginning_date )]}
  });
}

=head2 can_complete

Checks whether or not we can complete this season, by checking that the matches are either completed or cancelled.  There may be other additions to this in future.

=cut

sub can_complete {
  my $self = shift;
  
  # First check the season is not already complete - if it is, we can't complete it again.
  return 0 if $self->complete;
  
  # Now check matches - return 0 straight away if there are any matches that are incomplete and not cancelled for this season
  return 0 if $self->result_source->schema->resultset("TeamMatch")->incomplete_and_not_cancelled({season => $self})->count > 0;
  
  # If we get this far, return a true value because we can complete the season
  return 1;
}

=head2 check_and_complete

Update the season to show that it's now complete (if possible).

=cut

sub check_and_complete {
  my $self = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Encode the name for messaging
  my $enc_name = encode_entities($self->name);
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Check we can complete
  if ( $self->complete ) {
    push(@{$response->{error}}, $lang->maketext("seasons.complete.error.season-complete", $enc_name));
    return $response;
  }
  
  if ( $schema->resultset("TeamMatch")->incomplete_and_not_cancelled({season => $self})->count > 0 ) {
    push(@{$response->{error}}, $lang->maketext("seasons.complete.error.matches-incomplete", $enc_name));
    return $response;
  }
  
  # Delete
  my $ok = $self->update({complete => 1}) if scalar @{$response->{error}} == 0;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("seasons.complete.success", $enc_name));
  } else {
    push(@{$response->{error}}, $lang->maketext("seasons.complete.error.database", $enc_name));
  }
  
  return $response;
}

=head2 can_uncomplete

This is here so we can call it from controllers, but there's no routine to uncomplete yet, so at the moment this just returns false.

=cut

sub can_uncomplete {
  my $self = shift;
  return 0;
}

=head2 can_delete

Performs some logic checks to see whether or not a season can be deleted.  A season can be deleted if there are no matches in it.

=cut

sub can_delete {
  my $self = shift;
 
 my $matches = $self->search_related("team_matches")->count;
 return $matches == 0 ? 1 : 0;
}

=head2 check_and_delete

Checks that the season can be deleted (via can_delete) and then does the deletion.

=cut

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

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
  
  # Encode the name for messaging
  my $enc_name = encode_entities($self->name);
  my $response = {
    error => [],
    warning => [],
    info => [],
    success => [],
    completed => 0,
  };
  
  # Check we can delete
  push(@{$response->{error}}, $lang->maketext("seasons.delete.error.matches-exist", $enc_name)) unless $self->can_delete;
  
  # Order of the first three is important; person seasons must come before team seasons, which must come before club seasons
  my @relations = qw( person_seasons team_seasons club_seasons division_seasons doubles_pairs event_seasons fixtures_weeks );
  
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  my $ok;
  foreach my $relation ( @relations ) {
    $ok = $self->delete_related($relation);
    
    # Error if the delete was unsuccessful
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $enc_name, ref($relation))) unless $ok;
  }
  
  # Delete
  $ok = $self->delete;
  
  # Error if the delete was unsuccessful
  if ( $ok ) {
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $enc_name, $lang->maketext("admin.message.deleted")));
  } else {
    push(@{$response->{error}}, $lang->maketext("admin.delete.error.database", $enc_name, ref($self)));
  }
  
  $transaction->commit;
  
  return $response;
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my $self = shift;
  my ( $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->name,
    url_keys => $self->url_keys,
    type => "season"
  };
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
