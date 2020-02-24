use utf8;
package TopTable::Schema::Result::TeamMatchGame;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatchGame

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

=head1 TABLE: C<team_match_games>

=cut

__PACKAGE__->table("team_match_games");

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
  is_foreign_key: 1
  is_nullable: 0

=head2 scheduled_game_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 actual_game_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 home_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 away_player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 away_player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 home_doubles_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 away_doubles_pair

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 home_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 home_team_match_score

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 away_team_match_score

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 doubles_game

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 game_in_progress

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 umpire

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 started

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 complete

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 1

=head2 awarded

  data_type: 'tinyint'
  is_nullable: 1

=head2 void

  data_type: 'tinyint'
  is_nullable: 1

=head2 winner

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

We need to distinguish the winner if the game has been awarded to either side.

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
  {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "scheduled_game_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "actual_game_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "home_player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "away_player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "home_doubles_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "away_doubles_pair",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "home_team_legs_won",
  {
    data_type => "tinyint",
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
  "home_team_points_won",
  {
    data_type => "smallint",
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
  "home_team_match_score",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "away_team_match_score",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "doubles_game",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "game_in_progress",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "umpire",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "started",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "complete",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 1,
  },
  "awarded",
  { data_type => "tinyint", is_nullable => 1 },
  "void",
  { data_type => "tinyint", is_nullable => 1 },
  "winner",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=item * L</scheduled_game_number>

=back

=cut

__PACKAGE__->set_primary_key(
  "home_team",
  "away_team",
  "scheduled_date",
  "scheduled_game_number",
);

=head1 RELATIONS

=head2 away_doubles_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->belongs_to(
  "away_doubles_pair",
  "TopTable::Schema::Result::DoublesPair",
  { id => "away_doubles_pair" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 away_player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "away_player",
  "TopTable::Schema::Result::Person",
  { id => "away_player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_doubles_pair

Type: belongs_to

Related object: L<TopTable::Schema::Result::DoublesPair>

=cut

__PACKAGE__->belongs_to(
  "home_doubles_pair",
  "TopTable::Schema::Result::DoublesPair",
  { id => "home_doubles_pair" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 home_player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "home_player",
  "TopTable::Schema::Result::Person",
  { id => "home_player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 individual_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchIndividual>

=cut

__PACKAGE__->belongs_to(
  "individual_match_template",
  "TopTable::Schema::Result::TemplateMatchIndividual",
  { id => "individual_match_template" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 team_match

Type: belongs_to

Related object: L<TopTable::Schema::Result::TeamMatch>

=cut

__PACKAGE__->belongs_to(
  "team_match",
  "TopTable::Schema::Result::TeamMatch",
  {
    away_team      => "away_team",
    home_team      => "home_team",
    scheduled_date => "scheduled_date",
  },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 team_match_legs

Type: has_many

Related object: L<TopTable::Schema::Result::TeamMatchLeg>

=cut

__PACKAGE__->has_many(
  "team_match_legs",
  "TopTable::Schema::Result::TeamMatchLeg",
  {
    "foreign.away_team"             => "self.away_team",
    "foreign.home_team"             => "self.home_team",
    "foreign.scheduled_date"        => "self.scheduled_date",
    "foreign.scheduled_game_number" => "self.scheduled_game_number",
  },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 umpire

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "umpire",
  "TopTable::Schema::Result::Person",
  { id => "umpire" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 winner

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "winner",
  "TopTable::Schema::Result::Team",
  { id => "winner" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-01-08 00:07:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NBWDslp75O1UuFUm5iykHw

use Data::Dumper;

=head2 update_score

Update the scores for this game.

=cut

sub update_score {
  my ( $self, $parameters ) = @_;
  my $log = $parameters->{logger};
  my $return_value = {error => []};
  
  # Convenience: get objects related to the game / match
  my $match             = $self->team_match;
  my $season_home_team  = $match->team_season_home_team_season;
  my $season_away_team  = $match->team_season_away_team_season;
  my $home_team         = $season_home_team->team;
  my $away_team         = $season_away_team->team;
  my $season            = $match->season;
  my $home_player       = ( $self->doubles_game ) ? $self->home_doubles_pair : $self->home_player;
  my $away_player       = ( $self->doubles_game ) ? $self->away_doubles_pair : $self->away_player;
  my $awarded           = $parameters->{awarded}  || 0;
  my $awarded_winner    = $parameters->{winner}   || undef; # Only used if it's been awarded
  my $delete            = $parameters->{delete}   || 0;
  my ( $home_player_missing, $away_player_missing ) = qw( 0 0 );
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{ $return_value->{error} }, {id => "matches.update.error.match-cancelled"});
    return $return_value;
  }
  
  # These are needed further down when updating matches played for the player, so need to be declared here.
  my ( $match_home_player, $match_away_player ) = @_;
  
  # Store the template rules
  my $game_rules = $self->individual_match_template;
  
  if ( $self->doubles_game ) {
    # Doubles game - validate that the doubles pair have been entered
    if ( !defined( $home_player ) or !defined( $away_player ) ) {
      push(@{ $return_value->{error} }, {id => "matches.game.update-score.doubles.error.select-players"});
      return $return_value;
    }
  } else {
    # Singles game - ensure there are players entered
    # Get the team match players object so that we can update all of them with another match played if this is the first game played
    $match_home_player = $match->find_related("team_match_players", {
      player_number => $self->home_player_number,
      location      => "home",
    });
    
    $match_away_player = $match->find_related("team_match_players", {
      player_number => $self->away_player_number,
      location      => "away",
    });
    
    $home_player_missing = $match_home_player->player_missing;
    $away_player_missing = $match_away_player->player_missing;
    
    if ( !defined( $home_player ) or !defined( $away_player ) ) {
      unless ( $home_player_missing or $away_player_missing ) {
        push(@{ $return_value->{error} }, {id => "matches.game.update-score.singles.error.select-players"});
        return $return_value;
      }
    }
  }
  
  # Get the number of legs required to win the game
  my $legs_required_to_win;
  if ( $game_rules->game_type->id eq "best-of" ) {
    $legs_required_to_win = ( $game_rules->legs_per_game / 2 ) + 1; # Best of x legs - halve it and + 1
    $legs_required_to_win = int( $legs_required_to_win ); # Truncate any decimal placeas
  }
  
  # Work out if this match was completed / started already
  my $match_originally_complete = $match->complete;
  my $match_originally_started  = $match->started;
  
  # If it was, work out who won and who lost
  my ( $original_home_team_score, $original_away_team_score );
  if ( $match_originally_complete ) {
    $original_home_team_score = $match->home_team_match_score;
    $original_away_team_score = $match->away_team_match_score;
  }
  
  # Get all the original values for this game
  my $game_originally_started         = $self->started;
  my $game_originally_complete        = $self->complete;
  my $game_originally_awarded         = $self->awarded;
  my $game_original_home_team_score   = $self->home_team_legs_won;
  my $game_original_away_team_score   = $self->away_team_legs_won;
  my $game_original_home_team_points  = $self->home_team_points_won;
  my $game_original_away_team_points  = $self->away_team_points_won;
  my $game_original_winner            = defined( $self->winner ) ? $self->winner->id : undef;
  
  # These values will hold the new cumulative legs / points scores
  my ( $home_team_points, $away_team_points, $winner_legs, $legs_played ) = qw( 0 0 0 0 );
  
  # Now loop through the legs and make sure we have a valid score
  my $game_winner;
  my %game_scores = ();
  my $legs = $self->team_match_legs;
  
  # Default to not void and not awarded
  my ( $home_legs, $away_legs, $void ) = qw( 0 0 0 );
  my $skip_checks   = 0;
  my $game_started  = 0; # Flag for whether the game's started - if not and it's been awarded, we won't update any averages
  my $game_finished = 0; # Flag (when the game's been awarded) to notify us the game's finished even if the score doesn't look complete.
  while ( my $leg = $legs->next ) {
    my $leg_number  = $leg->leg_number;
    my $home_score  = $parameters->{ sprintf( "leg%d-home", $leg->leg_number ) }  || 0;
    my $away_score  = $parameters->{ sprintf( "leg%d-away", $leg->leg_number ) }  || 0;
    my ( $winning_score, $losing_score ) = qw( 0 0 );
    my $winner;
    
    # If we have a true value in either of these, assume the game has started (we'll be error checking later on anyway)
    $game_started = 1 if $home_score or $away_score;
    
    # Work out if the required number of legs have been won / have completed
    if ( $delete ) {
      # Delete the score
      $game_scores{"leg_$leg_number"} = {
        leg_object          => $leg,
        home_score          => 0,
        away_score          => 0,
        started             => 0,
        complete            => 0,
        winner              => undef,
        void                => 0,
        awarded             => 0,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
      };
    } elsif ( !$self->doubles_game and ( $home_player_missing or $away_player_missing ) ) {
      # There's a player missing, so the game has to be awarded (or voided if both are missing)
      if ( $home_player_missing and $away_player_missing ) {
        # Both players missing, game is void
        undef( $winner );
        undef( $game_winner );
        $awarded      = 0;
        $void         = 1;
      } elsif ( $home_player_missing ) {
        # Home player missing, award to away team
        $game_winner  = $away_team->id;
        $winner       = $away_team->id;
        $awarded      = 1;
        $void         = 0;
      } else {
        # Away player missing, award to home team
        $game_winner  = $home_team->id;
        $winner       = $home_team->id;
        $awarded      = 1;
        $void         = 0;
      }
      
      $game_scores{"leg_$leg_number"} = {
        leg_object          => $leg,
        home_score          => 0,
        away_score          => 0,
        started             => 0,
        complete            => 1,
        winner              => $winner,
        awarded             => $awarded,
        void                => $void,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
      };
    } elsif ( $game_finished ) {
      # Finished flag has been set (the game was awarded); disregard the rest of the data passed and set the scores as zero
      $game_scores{"leg_$leg_number"} = {
        leg_object          => $leg,
        home_score          => 0,
        away_score          => 0,
        winner              => undef,
        started             => 0,
        complete            => 0,
        awarded             => 0,
        void                => 0,
        original_home_score => $leg->home_team_points_won,
        original_away_score => $leg->away_team_points_won,
      };
    } else {
      if ( ( defined($legs_required_to_win) && $winner_legs < $legs_required_to_win) || ( !defined($legs_required_to_win) && $legs_played < $game_rules->legs_per_game) ) {
        # There are still legs to play
        # Check the scores are numeric and more than zero
        if ( $home_score !~ m/^\d+$/ or $home_score < 0 or $away_score !~ m/^\d+$/ or $away_score < 0 ) {
          push(@{ $return_value->{error} }, {
            id          => "matches.game.update-score.error.home-not-numeric-or-less-than-zero",
            parameters  => [$leg_number],
          }) if $home_score !~ m/^\d+$/ or $home_score < 0;
          
          push(@{ $return_value->{error} }, {
            id          => "matches.game.update-score.error.away-not-numeric-or-less-than-zero",
            parameters  => [$leg_number],
          }) if $away_score !~ m/^\d+$/ or $away_score < 0;
        } else {
          # Add the to points totals
          $home_team_points += $home_score;
          $away_team_points += $away_score;
          
          # Leg not forefeited 
          # Check the scores are not equal
          if ( $home_score == $away_score and !$awarded ) {
            push(@{ $return_value->{error} }, {
              id          => "matches.game.update-score.error.home-and-away-scores-equal",
              parameters  => [$leg_number],
            });
          } else {
            # Check who's got the higher score
            if ( $home_score > $away_score ) {
              # The current winner is the home team
              $winner         = $home_team->id;
              $winning_score  = $home_score;
              $losing_score   = $away_score;
            } else {
              # The current winner is the away team
              $winner         = $away_team->id;
              $winning_score  = $away_score;
              $losing_score   = $home_score;
            }
            
            my $clear_points = $winning_score - $losing_score;
            
            # Now we have all the information, we can check if the score itself is valid - we either need:
            #   * The winner to have exactly the right number of points for a win and the points difference to be greater than or equal to the minimum points difference required for a win
            #   * The winner to have more than the number of points required for a win and the points difference to be exactly equal to the minimum points difference required for a win  
            if ( ($winning_score == $game_rules->minimum_points_win && $clear_points >= $game_rules->clear_points_win) || ($winning_score > $game_rules->minimum_points_win && $clear_points == $game_rules->clear_points_win) ) {
              # The win is valid
              # Increment the correct player's legs won count and set the $winner_legs, which for convenience holds the winner of the current leg's total legs won count
              if ( $winner eq $home_team->id ) {
                $home_legs++;
                $winner_legs = $home_legs;
              } else {
                $away_legs++;
                $winner_legs = $away_legs;
              }
              
              # See if we've now reached the required number of legs - if so, the winner of this leg is the winner of the game
              if ( defined( $legs_required_to_win ) && $winner_legs == $legs_required_to_win) {
                # If we've reached the end of the game because the winner has won the required number of legs, the winner if the last leg must have won the game
                $game_winner = $winner;
              } elsif ( !defined( $legs_required_to_win ) && $legs_played < $game_rules->legs_per_game ) {
                # If we play a static number of games, we need to work out the winner (if there is one)
                if ( $home_legs > $away_legs ) {
                  $game_winner = $home_team->id;
                } elsif ( $home_legs < $away_legs ) {
                  $game_winner = $away_team->id;
                } else {
                  undef( $game_winner );
                }
              }
              
              # Get the total legs played
              $legs_played = $home_legs + $away_legs;
              
              # Now store all this information into the $game_scores hash
              $game_scores{"leg_$leg_number"} = {
                leg_object          => $leg,
                home_score          => $home_score,
                away_score          => $away_score,
                winner              => $winner,
                started             => 1,
                complete            => 1,
                awarded             => 0,
                void                => 0,
                original_home_score => $leg->home_team_points_won,
                original_away_score => $leg->away_team_points_won,
              };
            } elsif ( $awarded and $awarded_winner eq "home" or $awarded_winner eq "away" ) {
              # The game was awarded - work out who to award it to
              $winner       = ( $awarded_winner eq "home" ) ? $home_team->id : $away_team->id;
              $game_winner  = $winner;
              
              $game_scores{"leg_$leg_number"} = {
                leg_object          => $leg,
                home_score          => $home_score,
                away_score          => $away_score,
                winner              => $winner,
                started             => $game_started,
                complete            => 1,
                awarded             => 1,
                void                => 0,
                original_home_score => $leg->home_team_points_won,
                original_away_score => $leg->away_team_points_won,
              };
              
              # Set the finished flag
              $game_finished = 1;
            } else {
              # The win is not valid
              push(@{ $return_value->{error} }, {
                id          => "matches.game.update-score.error.score-invalid",
                parameters  => [$leg_number, $home_score, $away_score, $game_rules->minimum_points_win, $game_rules->clear_points_win],
              });
            }
          }
        }
      } else {
        # We've already reached the right number of games; disregard the rest of the data passed and set the scores as zero
        $game_scores{"leg_$leg_number"} = {
          leg_object          => $leg,
          home_score          => 0,
          away_score          => 0,
          winner              => undef,
          started             => 0,
          complete            => 0,
          awarded             => 0,
          void                => 0,
          original_home_score => $leg->home_team_points_won,
          original_away_score => $leg->away_team_points_won,
        };
      }
    }
  }
  
  unless ( $delete or $home_player_missing or $away_player_missing or $awarded ) {
    # Make sure we properly finished the game with a winner
    # Error if the required number of games have not been played
    push(@{ $return_value->{error} }, {
      id          => "matches.game.update-score.error.score-incomplete",
      parameters  => [$self->scheduled_game_number],
    }) if ( defined($legs_required_to_win) && $winner_legs < $legs_required_to_win) || ( !defined($legs_required_to_win) && $legs_played < $game_rules->legs_per_game);
  }
  
  # Don't go any further if we've had an error
  return $return_value if scalar( @{ $return_value->{error} } );
  
  ### ERROR CHECKING FINISHED ###
  #### TRANSACTIONS: LOOK AT http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class/ResultSource.pm#schema (schema object has txn_scope_guard)
  # http://search.cpan.org/~ribasushi/DBIx-Class-0.082820/lib/DBIx/Class/Storage/TxnScopeGuard.pm
  # Also see http://search.cpan.org/dist/DBIx-Class/lib/DBIx/Class/Row.pm#result_source to get the result source, if it's a row object
  # Set up the transaction - we'll only write to the database if there are NO errors
  my $transaction = $self->result_source->schema->txn_scope_guard;
  
  # Now we've looped through and checked our legs, we need to update them
  # Update our legs
  foreach my $update_leg ( keys ( %game_scores ) ) {
    $game_scores{$update_leg}{leg_object}->update({
      home_team_points_won  => $game_scores{$update_leg}{home_score},
      away_team_points_won  => $game_scores{$update_leg}{away_score},
      winner                => $game_scores{$update_leg}{winner},
      awarded               => $game_scores{$update_leg}{awarded},
      void                  => $game_scores{$update_leg}{void},
      started               => $game_scores{$update_leg}{started},
      complete              => $game_scores{$update_leg}{complete},
    });
  }
  
  # Update the game
  #my $started = ( $awarded or $delete or $void ) ? 0 : 1;
  my $complete = ( $delete ) ? 0 : 1;
  
  $self->update({
    home_team_legs_won    => $home_legs,
    home_team_points_won  => $home_team_points,
    away_team_legs_won    => $away_legs,
    away_team_points_won  => $away_team_points,
    winner                => $game_winner,
    awarded               => $awarded,
    void                  => $void,
    started               => $game_started,
    complete              => $complete,
  });
  
  # Update the match 
  my $match_scores    = $match->calculate_match_score;
  my $match_started   = $match->check_match_started;
  my $match_complete  = $match->check_match_complete;
  
  # Loop through our returned array (in reverse) to get the final match score; the first game we come across with a match score, we'll break out
  my ( $current_home_match_score, $current_away_match_score, $current_games_drawn );
  
  foreach my $game_index ( reverse 0 .. $#{ $match_scores } ) {
    if ( $match_scores->[$game_index]{home_won} || $match_scores->[$game_index]{away_won} ) {
      $current_home_match_score = $match_scores->[$game_index]{home_won};
      $current_away_match_score = $match_scores->[$game_index]{away_won};
      $current_games_drawn      = $match_scores->[$game_index]{drawn};
      last;
    }
  }
  
  # Deal with the first score in the match being deleted, which means we will have undefined (null) values here,
  # when they should be zero.
  $current_home_match_score = 0 unless defined( $current_home_match_score );
  $current_away_match_score = 0 unless defined( $current_away_match_score );
  $current_games_drawn      = 0 unless defined( $current_games_drawn );
  
  # Work out the number of legs / points in this match now.  To do this, we need to do some maths:
  #   * Take the original value from the $match db object.
  #   * Subtract the original game score / points that we took from the game before we updated it
  #   * Add the new game score / points that we've updated the game with.
  # Remember that:
  #   * In a match, the number of legs is termed as the score in a game.
  #   * In a match / game, the number of points is termed as the score in a leg.
  my $match_home_team_legs_won    = ( $match->home_team_legs_won    - $game_original_home_team_score  ) + $home_legs;
  my $match_away_team_legs_won    = ( $match->away_team_legs_won    - $game_original_away_team_score  ) + $away_legs;
  my $match_home_team_points_won  = ( $match->home_team_points_won  - $game_original_home_team_points ) + $home_team_points;
  my $match_away_team_points_won  = ( $match->away_team_points_won  - $game_original_away_team_points ) + $away_team_points;
  
  # Get the ranking rules
  my $ranking_template = $match->division_season->league_table_ranking_template;
  
  my $assign_points   = $ranking_template->assign_points;
  my $points_per_win  = $ranking_template->points_per_win;
  my $points_per_draw = $ranking_template->points_per_draw;
  my $points_per_loss = $ranking_template->points_per_loss;
  my ( $home_points_adjustment, $away_points_adjustment ) = qw( 0 0 );
  
  # If the match was originally complete or is now complete, we may need to change the number of matches won, lost or drawn for each team
  my $original_winner = "";
  my $new_winner      = "";
  if ( $match_originally_complete ) {
    # If the match was originally complete, we need to check if the winner has changed
    # Get the original winner
    if ( $original_home_team_score > $original_away_team_score ) {
      $original_winner = "home";
    } elsif ( $original_away_team_score > $original_home_team_score ) {
      $original_winner = "away";
    } else {
      # Equal scores: draw
      $original_winner = "draw";
    }
  }
  
  if ( $match_complete ) {
    # To work out who's won, we need to know which value we're checking by the winner type
    if ( $current_home_match_score > $current_away_match_score ) {
      $new_winner = "home";
    } elsif ( $current_away_match_score > $current_home_match_score ) {
      $new_winner = "away";
    } else {
      # Equal scores: draw
      $new_winner = "draw";
    }
  }
  
  # The below variables will contain a mathematical instruction (i.e., +1 or -1) so that we know for each player and team what to do
  my %score_instructions = (
    home => {
      matches_played  => "",
      matches_won     => "",
      matches_drawn   => "",
      matches_lost    => "",
    }, away => {
      matches_played  => "",
      matches_won     => "",
      matches_drawn   => "",
      matches_lost    => "",
    }
  );
  
  if ( $match_originally_started and !$match_started ) {
    # If we're deleting the only score we have in this match, the match will revert to not having been started
    # yet and therefore we'll remove one from matches_played
    $score_instructions{home}{matches_played} = "-1";
    $score_instructions{away}{matches_played} = "-1";
  } elsif ( !$match_originally_started and $match_started ) {
    # If we're adding the first score, we need to add one to matches played
    $score_instructions{home}{matches_played} = "+1";
    $score_instructions{away}{matches_played} = "+1";
  }
  
  if ( ( $original_winner or $new_winner ) and ( $original_winner ne $new_winner ) ) {
    # Either the match was originally complete, or it is now and the winner has changed.
    if ( $original_winner eq "home" ) {
      # Home team won originally
      if ( $new_winner eq "away" ) {
        # Home team originally won, away team has now won
        $score_instructions{home}{matches_won}    = "-1";
        $score_instructions{home}{matches_lost}   = "+1";
        $score_instructions{away}{matches_won}    = "+1";
        $score_instructions{away}{matches_lost}   = "-1";
        
        # If we need to assign points, we add the number of points the home team get for losing, then
        # take off the points they originally had for winning (which should come to a minus figure)
        # and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss - $points_per_win;
          $away_points_adjustment = $points_per_win - $points_per_loss;
        }
      } elsif ( $new_winner eq "draw" ) {
        # Home team originally won, now a draw
        $score_instructions{home}{matches_won}    = "-1";
        $score_instructions{home}{matches_drawn}  = "+1";
        $score_instructions{away}{matches_drawn}  = "+1";
        $score_instructions{away}{matches_lost}   = "-1";
        
        # If we need to assign points, we add the number of points the home and away teams get for drawing,
        # then take off the points the home team originally had for winning and the away team had for losing
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw - $points_per_win;
          $away_points_adjustment = $points_per_draw - $points_per_loss;
        }
      } elsif ( $new_winner eq "" ) {
        # Home team originally won, now not complete
        $score_instructions{home}{matches_won}    = "-1";
        $score_instructions{away}{matches_lost}   = "-1";
        
        # If we need to assign points, we just need to take off the points each team got originally, since the match
        # is now not complete.
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_win;
          $away_points_adjustment -= $points_per_loss;
        }
      }
    } elsif ( $original_winner eq "away" ) {
      # Away team won originally
      if ( $new_winner eq "home" ) {
        # Away team originally won, home team has now won
        $score_instructions{home}{matches_won}    = "+1";
        $score_instructions{home}{matches_lost}   = "-1";
        $score_instructions{away}{matches_won}    = "-1";
        $score_instructions{away}{matches_lost}   = "+1";
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for losing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win - $points_per_loss;
          $away_points_adjustment = $points_per_loss - $points_per_win;
        }
      } elsif ( $new_winner eq "draw" ) {
        # Away team originally won, now a draw
        $score_instructions{home}{matches_drawn}  = "+1";
        $score_instructions{home}{matches_lost}   = "-1";
        $score_instructions{away}{matches_won}    = "-1";
        $score_instructions{away}{matches_drawn}  = "+1";
        
        # If we need to assign points, we add the number of points the home and away teams get for drawing,
        # then take off the points the home team originally had for winning and the away team had for losing
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw - $points_per_loss;
          $away_points_adjustment = $points_per_draw - $points_per_win;
        }
      } elsif ( $new_winner eq "" ) {
        # Away team originally won, now not complete
        $score_instructions{home}{matches_lost}   = "-1";
        $score_instructions{away}{matches_won}    = "-1";
        
        # If we need to assign points, we just need to take off the points each team got originally, since the match
        # is now not complete.
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_loss;
          $away_points_adjustment -= $points_per_win;
        }
      }
    } elsif ( $original_winner eq "draw" ) {
      # Originally a draw
      if ( $new_winner eq "home" ) {
        # Originally a draw, now a home win
        $score_instructions{home}{matches_won}    = "+1";
        $score_instructions{home}{matches_drawn}  = "-1";
        $score_instructions{away}{matches_drawn}  = "-1";
        $score_instructions{away}{matches_lost}   = "+1";
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for drawing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win - $points_per_draw;
          $away_points_adjustment = $points_per_loss - $points_per_draw;
        }
      } elsif ( $new_winner eq "away" ) {
        # Originally a draw, now an away win
        $score_instructions{home}{matches_drawn}  = "-1";
        $score_instructions{home}{matches_lost}   = "+1";
        $score_instructions{away}{matches_won}    = "+1";
        $score_instructions{away}{matches_drawn}  = "-1";
        
        # If we need to assign points, we add the number of points the home team get for winning, then
        # take off the points they originally had for drawing and vice versa for away.
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss - $points_per_draw;
          $away_points_adjustment = $points_per_win - $points_per_draw;
        }
      } elsif ( $new_winner eq "" ) {
        # Originally a draw, now not complete
        $score_instructions{home}{matches_drawn}  = "-1";
        $score_instructions{away}{matches_drawn}  = "-1";
        
        # If we need to assign points, we just take off the number of points each team got for drawing
        if ( $assign_points ) {
          $home_points_adjustment -= $points_per_draw;
          $away_points_adjustment -= $points_per_draw;
        }
      }
    } elsif ( $original_winner eq "" ) {
      # Not originally complete
      if ( $new_winner eq "home" ) {
        # Originally incomplete, now a home win
        $score_instructions{home}{matches_won}    = "+1";
        $score_instructions{away}{matches_lost}   = "+1";
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_win;
          $away_points_adjustment = $points_per_loss;
        }
      } elsif ( $new_winner eq "away" ) {
        # Originally incomplete, now an away win
        $score_instructions{home}{matches_lost}   = "+1";
        $score_instructions{away}{matches_won}    = "+1";
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_loss;
          $away_points_adjustment = $points_per_win;
        }
      } else {
        # Originally incomplete, now a draw
        $score_instructions{home}{matches_drawn}  = "+1";
        $score_instructions{away}{matches_drawn}  = "+1";
        
        if ( $assign_points ) {
          $home_points_adjustment = $points_per_draw;
          $away_points_adjustment = $points_per_draw;
        }
      }
    }
  }
  
  ### UPDATING
  # Update the match fields
  $match->started( $match_started );
  $match->home_team_games_won( $current_home_match_score );
  $match->home_team_games_lost( $current_away_match_score );
  $match->away_team_games_won( $current_away_match_score );
  $match->away_team_games_lost( $current_home_match_score );
  $match->games_drawn( $current_games_drawn );
  $match->home_team_legs_won( $match_home_team_legs_won );
  $match->away_team_legs_won( $match_away_team_legs_won );
  $match->home_team_points_won( $match_home_team_points_won );
  $match->away_team_points_won( $match_away_team_points_won );
  $match->home_team_match_score( $current_home_match_score );
  $match->away_team_match_score( $current_away_match_score );
  $match->complete( $match_complete );
  
  if ( $match_home_team_legs_won + $match_away_team_legs_won ) {
    $match->home_team_average_leg_wins( $match_home_team_legs_won / ( $match_home_team_legs_won + $match_away_team_legs_won ) * 100 );
    $match->away_team_average_leg_wins( $match_away_team_legs_won / ( $match_home_team_legs_won + $match_away_team_legs_won ) * 100 );
  } else {
    $match->home_team_average_leg_wins( 0 );
    $match->away_team_average_leg_wins( 0 );
  }
  
  if ( $match_home_team_points_won + $match_away_team_points_won ) {
    $match->home_team_average_point_wins( $match_home_team_points_won / ( $match_home_team_points_won + $match_away_team_points_won ) * 100 );
    $match->away_team_average_point_wins( $match_away_team_points_won / ( $match_home_team_points_won + $match_away_team_points_won ) * 100 );
  } else {
    $match->home_team_average_point_wins( 0 );
    $match->away_team_average_point_wins( 0 );
  }
  
  # Write the field updates to the match
  $match->update;
  
  ### STATISTICS UPDATE ###
  # Team match statistics were updated during the match update routine, so we just need to do the season statistics
  unless ( defined( $match->tournament_round ) ) {
    # Team season statistics
    $season_home_team->legs_played( $season_home_team->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) + ( $home_legs + $away_legs ) );
    $season_home_team->legs_won( $season_home_team->legs_won - $game_original_home_team_score + $home_legs );
    $season_home_team->legs_lost( $season_home_team->legs_lost - $game_original_away_team_score + $away_legs );
    $season_away_team->legs_played( $season_away_team->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) +  ( $home_legs + $away_legs ) );
    $season_away_team->legs_won( $season_away_team->legs_won - $game_original_away_team_score + $away_legs );
    $season_away_team->legs_lost( $season_away_team->legs_lost - $game_original_home_team_score + $home_legs );
    $season_home_team->points_played( $season_home_team->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ) );
    $season_home_team->points_won( $season_home_team->points_won  - $game_original_home_team_points + $home_team_points );
    $season_home_team->points_lost( $season_home_team->points_lost  - $game_original_away_team_points + $away_team_points );
    $season_away_team->points_played( $season_away_team->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ) );
    $season_away_team->points_won( $season_away_team->points_won  - $game_original_away_team_points + $away_team_points );
    $season_away_team->points_lost( $season_away_team->points_lost  - $game_original_home_team_points + $home_team_points );
    
    # Table points
    if ( $assign_points ) {
      $season_home_team->table_points( $season_home_team->table_points + $home_points_adjustment );
      $season_away_team->table_points( $season_away_team->table_points + $away_points_adjustment );
    }
    
    # We already know what we need to do to each matches won / drawn / lost total, just loop through and do it
    foreach my $stat_team ( keys ( %score_instructions ) ) {
      # Work out which team we're modifying at the moment
      my $mod_team = ( $stat_team eq "home" ) ? $season_home_team : $season_away_team;
      
      foreach my $field ( keys ( %{ $score_instructions{$stat_team} } ) ) {
        if ( $score_instructions{$stat_team}{$field} eq "+1" ) {
          # Add one to the field
          $mod_team->$field( $mod_team->$field + 1 );
        } elsif ( $score_instructions{$stat_team}{$field} eq "-1" ) {
          # Subtract one from the field
          $mod_team->$field( $mod_team->$field - 1 );
        }
      }
    }
    
    # Do the same for games
    # To work out the number of games that this team has won, we need to know whether this game was already completed before this score was submitted
    # (i.e., if we're editing a score that's already been entered).  If so, we will need to know who won originally
    if ( $game_originally_complete ) {
      if ( $delete ) {
        # Remove a game played from each
        $season_home_team->games_played( $season_home_team->games_played - 1 );
        $season_away_team->games_played( $season_away_team->games_played - 1 );
        
        # Remove one from the original winner's total if we're deleting
        if ( defined( $game_original_winner ) and $game_original_winner == $home_team->id ) {
          # Remove a game won from home and a game lost from away
          $season_home_team->games_won( $season_home_team->games_won - 1 );
          $season_away_team->games_lost( $season_away_team->games_lost - 1 );
        } elsif ( defined( $game_original_winner ) and $game_original_winner == $away_team->id ) {
          # Remove a game won from away and a game lost from home
          $season_home_team->games_lost( $season_home_team->games_lost - 1 );
          $season_away_team->games_won( $season_away_team->games_won - 1 );
        } else {
          # Remove a drawn game from both
          $season_home_team->games_drawn( $season_home_team->games_drawn - 1 );
          $season_away_team->games_drawn( $season_away_team->games_drawn - 1 );
        }
      } else {
        if ( $game_original_winner != $game_winner ) {
          # The winner has changed since the last score was entered.
          if ( defined( $game_winner ) and $game_winner == $home_team->id ) {
            # Home player has won
            # Regardless, we need to add one to the home player's games won total / the away player's games lost total
            $season_home_team->games_won( $season_home_team->games_won + 1 );
            $season_away_team->games_lost( $season_away_team->games_lost + 1 );
            
            if ( $game_original_winner == $away_team->id ) {
              # Away player previously won; remove one from the respective won / lost totals
              $season_home_team->games_lost( $season_home_team->games_lost - 1 );
              $season_away_team->games_won( $season_away_team->games_won - 1 );
            } else {
              # The previous score must have been a draw - remove one from both games drawn totals
              $season_home_team->games_drawn( $season_home_team->games_drawn - 1 );
              $season_away_team->games_drawn( $season_away_team->games_drawn - 1 );
            }
          } elsif ( defined( $game_winner ) and $game_winner == $away_team->id ) {
            # Away player has won
            # Regardless, we need to add one to the home player's games won total / the away player's games lost total
            $season_home_team->games_lost( $season_home_team->games_lost + 1 );
            $season_away_team->games_won( $season_away_team->games_won + 1 );
            
            if ( $game_original_winner == $home_team->id ) {
              # Home player previously won; remove one from the respective won / lost totals
              $season_home_team->games_won( $season_home_team->games_won - 1 );
              $season_away_team->games_lost( $season_away_team->games_lost - 1 );
            } else {
              # The previous score must have been a draw - remove one from both games drawn totals
              $season_home_team->games_drawn( $season_home_team->games_drawn - 1 );
              $season_away_team->games_drawn( $season_away_team->games_drawn - 1 );
            }
          } else {
            # This game must have ended in a draw - increase the games drawn totals
            $season_home_team->games_drawn( $season_home_team->games_drawn + 1 );
            $season_away_team->games_drawn( $season_away_team->games_drawn + 1 );
            
            if ( $game_original_winner == $home_team->id ) {
              # Home player won originally; remove one from the respective won / lost totals
              $season_home_team->games_won( $season_home_team->games_won - 1 );
              $season_away_team->games_lost( $season_away_team->games_lost - 1 );
            } else {
              # Away player won originally; remove one from the respective won / lost totals
              $season_home_team->games_lost( $season_home_team->games_lost - 1 );
              $season_away_team->games_won( $season_away_team->games_won - 1 );
            }
          }
        }
      }
    } elsif ( !$delete ) {
      # If the game wasn't complete and we're not trying to delete (which we shouldn't be, as
      # there would be no point trying to delete a score that's not yet been completed), we
      # need to add one to the games played for each player
      $season_home_team->games_played( $season_home_team->games_played + 1 );
      $season_away_team->games_played( $season_away_team->games_played + 1 );
      
      # and work out who's won
      if ( defined( $game_winner ) and $game_winner == $home_team->id ) {
        $season_home_team->games_won( $season_home_team->games_won + 1 );
        $season_away_team->games_lost( $season_away_team->games_lost + 1 );
      } elsif ( defined( $game_winner ) and $game_winner == $away_team->id ) {
        $season_away_team->games_won( $season_away_team->games_won + 1 );
        $season_home_team->games_lost( $season_home_team->games_lost + 1 );
      } else {
        # Draw
        $season_home_team->games_drawn( $season_home_team->games_drawn + 1 );
        $season_away_team->games_drawn( $season_away_team->games_drawn + 1 );
      }
    }
    
    # Work out the averages
    $season_home_team->games_played   ? $season_home_team->average_game_wins( ( $season_home_team->games_won / $season_home_team->games_played ) * 100 )    : $season_home_team->average_game_wins( 0 );
    $season_home_team->legs_played    ? $season_home_team->average_leg_wins( ( $season_home_team->legs_won / $season_home_team->legs_played ) * 100 )       : $season_home_team->average_leg_wins( 0 );
    $season_home_team->points_played  ? $season_home_team->average_point_wins( ( $season_home_team->points_won / $season_home_team->points_played ) * 100 ) : $season_home_team->average_point_wins( 0 );
    $season_away_team->games_played   ? $season_away_team->average_game_wins( ( $season_away_team->games_won / $season_away_team->games_played ) * 100 )    : $season_away_team->average_game_wins( 0 );
    $season_away_team->legs_played    ? $season_away_team->average_leg_wins( ( $season_away_team->legs_won / $season_away_team->legs_played ) * 100 )       : $season_away_team->average_leg_wins( 0 );
    $season_away_team->points_played  ? $season_away_team->average_point_wins( ( $season_away_team->points_won / $season_away_team->points_played ) * 100 ) : $season_away_team->average_point_wins( 0 );
    
    # If it's a doubles game, we work that out too
    if ( $self->doubles_game ) {
      # To work out the number of games that each pair has won, we need to know whether this game was already completed before this score was submitted
      # (i.e., if we're editing a score that's already been entered).  If so, we will need to know who won originally
      if ( $game_originally_complete and $game_originally_started ) {
        # If the game was complete, we need to work out who was the previous winner and if this has changed.  If neither condition below is met, it was
        # a draw, so $original_winner remains undef.
        #print "This game was previously entered and is now being edited.\n";
        my $original_winner;
        if ( $game_original_home_team_score > $game_original_away_team_score ) {
          # Home team originally won
          $original_winner = $home_team->id;
          #print "Home pair originally won.\n";
        } elsif ( $game_original_away_team_score > $game_original_home_team_score ) {
          # Away team originally won
          $original_winner = $away_team->id;
          #print "Away pair originally won.\n";
        }
        
        if ( $delete or ( $awarded and !$game_started ) ) {
          # The score is being deleted OR the game is being awarded, but has not started, so no player stats will be being updated
          # Remove a game played from each
          $season_home_team->doubles_games_played( $season_home_team->doubles_games_played - 1 );
          $season_away_team->doubles_games_played( $season_away_team->doubles_games_played - 1 );
          #print "Either we're deleting a score or we're awarding this game without starting it; take one from games played for everyone.\n";
          
          # Remove one from the original winner's total if we're deleting
          if ( $original_winner == $home_team->id ) {
            # Remove a game won from home and a game lost from away
            $season_home_team->doubles_games_won( $season_home_team->doubles_games_won - 1 );
            $season_away_team->doubles_games_lost( $season_away_team->doubles_games_lost - 1 );
            #print "Remove one from home games won and away games lost, as the home team were originally listed as winners.\n";
          } elsif ( $original_winner == $away_team->id ) {
            # Remove a game won from away and a game lost from home
            $season_home_team->doubles_games_lost( $season_home_team->doubles_games_lost - 1 );
            $season_away_team->doubles_games_won( $season_away_team->doubles_games_won - 1 );
            #print "Remove one from home games lost and away games won, as the away team were originally listed as winners.\n";
          } else {
            # Remove a drawn game from both
            $season_home_team->doubles_games_drawn( $season_home_team->doubles_games_drawn - 1 );
            $season_away_team->doubles_games_drawn( $season_away_team->doubles_games_drawn - 1 );
            #print "Remove one from games drawn, as the game was originally a draw.\n";
          }
        } else {
          # The score is NOT being deleted AND it HAS started (whether being awarded or not), so we increase games won
          #print "This score is not being deleted or awarded, so this is complete score (edited from a previously completed score.\n";
          if ( $original_winner != $game_winner ) {
            #print "The winner has changed.\n";
            # The winner has changed since the last score was entered.
            if ( $game_winner == $home_team->id ) {
              # Home player has won
              # Regardless, we need to add one to the home players' games won total / the away players' games lost total
              $season_home_team->doubles_games_won( $season_home_team->doubles_games_won + 1 );
              $season_away_team->doubles_games_lost( $season_away_team->doubles_games_lost + 1 );
              #print "Home pair has won: add one to their games won and to the away pair's games lost.\n";
              
              if ( $original_winner == $away_team->id ) {
                # Away player previously won; remove one from the respective won / lost totals
                $season_home_team->doubles_games_lost( $season_home_team->doubles_games_lost - 1 );
                $season_away_team->doubles_games_won( $season_away_team->doubles_games_won - 1 );
                #print "Away pair originally won: remove one from their games won and from the home pair's games lost.\n";
              } else {
                # The previous score must have been a draw - remove one from both games drawn totals
                $season_home_team->doubles_games_drawn( $season_home_team->doubles_games_drawn - 1 );
                $season_away_team->doubles_games_drawn( $season_away_team->doubles_games_drawn - 1 );
                #print "1. Originally a draw, remove one from games drawn.\n";
              }
            } elsif ( $game_winner == $away_team->id ) {
              # Away player has won
              # Regardless, we need to add one to the home player's games won total / the away player's games lost total
              $season_home_team->doubles_games_lost( $season_home_team->doubles_games_lost + 1 );
              $season_away_team->doubles_games_won( $season_away_team->doubles_games_won + 1 );
              #print "Away pair has won: add one to their games won and to the home pair's games lost.\n";
              
              if ( $original_winner == $home_team->id ) {
                # Home player previously won; remove one from the respective won / lost totals
                $season_home_team->doubles_games_won( $season_home_team->doubles_games_won - 1 );
                $season_away_team->doubles_games_lost( $season_away_team->doubles_games_lost - 1 );
                #print "Home pair originally won: remove one from their games won and from the away pair's games lost.\n";
              } else {
                # The previous score must have been a draw - remove one from both games drawn totals
                $season_home_team->doubles_games_drawn( $season_home_team->doubles_games_drawn - 1 );
                $season_away_team->doubles_games_drawn( $season_away_team->doubles_games_drawn - 1 );
                #print "2. Originally a draw, remove one from games drawn.\n";
              }
            } else {
              # This game must have ended in a draw - increase the games drawn totals
              $season_home_team->doubles_games_drawn( $season_home_team->doubles_games_drawn + 1 );
              $season_away_team->doubles_games_drawn( $season_away_team->doubles_games_drawn + 1 );
              #print "Draw: add one to games drawn.\n";
              
              if ( $original_winner == $home_team->id ) {
                # Home player won originally; remove one from the respective won / lost totals
                $season_home_team->doubles_games_won( $season_home_team->doubles_games_won - 1 );
                $season_away_team->doubles_games_lost( $season_away_team->doubles_games_lost - 1 );
                #print "D. Home pair originally won: remove one from their games won and from the away pair's games lost.\n";
              } else {
                # Away player won originally; remove one from the respective won / lost totals
                $season_home_team->doubles_games_lost( $season_home_team->doubles_games_lost - 1 );
                $season_away_team->doubles_games_won( $season_away_team->doubles_games_won - 1 );
                #print "D. Away pair originally won: remove one from their games won and from the home pair's games lost.\n";
              }
            }
          }
        }
      } elsif ( !$delete and $game_started ) {
        # If the game wasn't complete, we need to add one to the games played for each player, so long as it's started
        # (it won't have been started if it's been awarded before any points were played)
        $season_home_team->doubles_games_played( $season_home_team->doubles_games_played + 1 );
        $season_away_team->doubles_games_played( $season_away_team->doubles_games_played + 1 );
        #print "This is a new score being entered, add one to games played.\n";
        
        # and work out who's won
        if ( $game_winner == $home_team->id ) {
          $season_home_team->doubles_games_won( $season_home_team->doubles_games_won + 1 );
          $season_away_team->doubles_games_lost( $season_away_team->doubles_games_lost + 1 );
          #print "Home team won, add one to their games won and one to the away team's games lost.\n";
        } elsif ( $game_winner == $away_team->id ) {
          $season_home_team->doubles_games_lost( $season_home_team->doubles_games_lost + 1 );
          $season_away_team->doubles_games_won( $season_away_team->doubles_games_won + 1 );
          #print "Away team won, add one to their games won and one to the home team's games lost.\n";
        } else {
          # Draw
          $season_home_team->doubles_games_drawn( $season_home_team->doubles_games_drawn + 1 );
          $season_away_team->doubles_games_drawn( $season_away_team->doubles_games_drawn + 1 );
          #print "Draw, add one to games drawn.\n";
        }
      }
      
      # Legs and points
      $season_home_team->doubles_legs_played( $season_home_team->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $season_away_team->doubles_legs_played( $season_away_team->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $season_home_team->doubles_legs_won( $season_home_team->doubles_legs_won + ( $home_legs - $game_original_home_team_score ) );
      $season_away_team->doubles_legs_won( $season_away_team->doubles_legs_won + ( $away_legs - $game_original_away_team_score ) );
      $season_home_team->doubles_legs_lost( $season_home_team->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ) );
      $season_away_team->doubles_legs_lost( $season_away_team->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ) );
      $season_home_team->doubles_points_played( $season_home_team->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $season_away_team->doubles_points_played( $season_away_team->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $season_home_team->doubles_points_won( $season_home_team->doubles_points_won + ( $home_team_points - $game_original_home_team_points ) );
      $season_away_team->doubles_points_won( $season_away_team->doubles_points_won + ( $away_team_points - $game_original_away_team_points ) );
      $season_home_team->doubles_points_lost( $season_home_team->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ) );
      $season_away_team->doubles_points_lost( $season_away_team->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ) );
      
      # Work out the averages
      $season_home_team->doubles_games_played  ? $season_home_team->doubles_average_game_wins( ( $season_home_team->doubles_games_won / $season_home_team->doubles_games_played ) * 100 )     : $season_home_team->doubles_average_game_wins( 0 );
      $season_home_team->doubles_legs_played   ? $season_home_team->doubles_average_leg_wins( ( $season_home_team->doubles_legs_won / $season_home_team->doubles_legs_played ) * 100 )        : $season_home_team->doubles_average_leg_wins( 0 );
      $season_home_team->doubles_points_played ? $season_home_team->doubles_average_point_wins( ( $season_home_team->doubles_points_won / $season_home_team->doubles_points_played ) * 100 )  : $season_home_team->doubles_average_point_wins( 0 );
      $season_away_team->doubles_games_played  ? $season_away_team->doubles_average_game_wins( ( $season_away_team->doubles_games_won / $season_away_team->doubles_games_played ) * 100 )     : $season_away_team->doubles_average_game_wins( 0 );
      $season_away_team->doubles_legs_played   ? $season_away_team->doubles_average_leg_wins( ( $season_away_team->doubles_legs_won / $season_away_team->doubles_legs_played ) * 100 )        : $season_away_team->doubles_average_leg_wins( 0 );
      $season_away_team->doubles_points_played ? $season_away_team->doubles_average_point_wins( ( $season_away_team->doubles_points_won / $season_away_team->doubles_points_played ) * 100 )  : $season_away_team->doubles_average_point_wins( 0 );
    }
    
    $season_home_team->update;
    $season_away_team->update;
  }
  
  ## Player
  # Player match statistics (singles games where neither player is missing only)
  if ( !$self->doubles_game and !$home_player_missing and !$away_player_missing ) {
    # First get the match player objects
    my $game_home_player = $match->find_related("team_match_players", {player_number => $self->home_player_number});
    my $game_away_player = $match->find_related("team_match_players", {player_number => $self->away_player_number});
    
    # Calculate the games / points / legs that have been won / lost in this match and during the seasons as a whole for these people
    $game_home_player->legs_played( $game_home_player->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) + ( $home_legs + $away_legs ) );
    $game_away_player->legs_played( $game_away_player->legs_played - ( $game_original_home_team_score + $game_original_away_team_score ) + ( $home_legs + $away_legs ) );
    $game_home_player->legs_won( $game_home_player->legs_won - $game_original_home_team_score + $home_legs );
    $game_away_player->legs_won( $game_away_player->legs_won - $game_original_away_team_score + $away_legs );
    $game_home_player->legs_lost( $game_home_player->legs_lost - $game_original_away_team_score + $away_legs );
    $game_away_player->legs_lost( $game_away_player->legs_lost - $game_original_home_team_score + $home_legs );
    $game_home_player->points_played( $game_home_player->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ) );
    $game_away_player->points_played( $game_away_player->points_played - ( $game_original_home_team_points + $game_original_away_team_points ) + ( $home_team_points + $away_team_points ) );
    $game_home_player->points_won( $game_home_player->points_won - $game_original_home_team_points + $home_team_points );
    $game_away_player->points_won( $game_away_player->points_won - $game_original_away_team_points + $away_team_points );
    $game_home_player->points_lost( $game_home_player->points_lost - $game_original_away_team_points + $away_team_points );
    $game_away_player->points_lost( $game_away_player->points_lost - $game_original_home_team_points + $home_team_points );
    
    # To work out the number of games that this person has won, we need to know whether this game was already completed before this score was submitted
    # (i.e., if we're editing a score that's already been entered).  If so, we will need to know who won originally
    if ( $game_originally_complete and $game_originally_started ) {
      # If the game was complete, we need to work out who was the previous winner and if this has changed.
      my $original_winner;
      if ( $game_original_home_team_score > $game_original_away_team_score ) {
        # Home team originally won
        $original_winner = $home_team->id;
      } else {
        # Away team originally won
        $original_winner = $away_team->id;
      }
      
      if ( $delete or ( $awarded and !$game_started ) ) {
        # The score is being deleted OR the game is being awarded, but has not started, so no player stats will be being updated
        # Remove a game played from each
        $game_home_player->games_played( $game_home_player->games_played - 1 );
        $game_away_player->games_played( $game_away_player->games_played - 1 );
        
        # Remove one from the original winner's total if we're deleting
        if ( $original_winner == $home_team->id ) {
          # Remove a game won from home and a game lost from away
          $game_home_player->games_won( $game_home_player->games_won - 1 );
          $game_away_player->games_lost( $game_away_player->games_lost - 1 );
        } elsif ( $original_winner == $away_team->id ) {
          # Remove a game won from away and a game lost from home
          $game_home_player->games_lost( $game_home_player->games_lost - 1 );
          $game_away_player->games_won( $game_away_player->games_won - 1 );
        } else {
          # Remove a drawn game from both
          $game_home_player->games_drawn( $game_home_player->games_drawn - 1 );
          $game_away_player->games_drawn( $game_away_player->games_drawn - 1 );
        }
      } else {
        # The score is NOT being deleted AND it HAS started (whether being awarded or not), so we increase games won
        if ( $original_winner != $game_winner ) {
          # The winner has changed since the last score was entered.
          if ( $game_winner == $home_team->id ) {
            # Home player has won
            # Regardless, we need to add one to the home player's games won total / the away player's games lost total
            $game_home_player->games_won( $game_home_player->games_won + 1 );
            $game_away_player->games_lost( $game_away_player->games_lost + 1 );
            
            if ( $original_winner == $away_team->id ) {
              # Away player previously won; remove one from the respective won / lost totals
              $game_home_player->games_lost( $game_home_player->games_lost - 1 );
              $game_away_player->games_won( $game_away_player->games_won - 1 );
            } else {
              # The previous score must have been a draw - remove one from both games drawn totals
              $game_home_player->games_drawn( $game_home_player->games_drawn - 1 );
              $game_away_player->games_drawn( $game_away_player->games_drawn - 1 );
            }
          } elsif ( $game_winner == $away_team->id ) {
            # Away player has won
            # Regardless, we need to add one to the home player's games won total / the away player's games lost total
            $game_home_player->games_lost( $game_home_player->games_lost + 1 );
            $game_away_player->games_won( $game_away_player->games_won + 1 );
            
            if ( $original_winner == $home_team->id ) {
              # Home player previously won; remove one from the respective won / lost totals
              $game_home_player->games_won( $game_home_player->games_won -1 );
              $game_away_player->games_lost( $game_away_player->games_lost - 1 );
            } else {
              # The previous score must have been a draw - remove one from both games drawn totals
              $game_home_player->games_drawn( $game_home_player->games_drawn - 1 );
              $game_away_player->games_drawn( $game_away_player->games_drawn - 1 );
            }
          } else {
            # This game must have ended in a draw - increase the games drawn totals
            $game_home_player->games_drawn( $game_home_player->games_drawn + 1 );
            $game_away_player->games_drawn( $game_away_player->games_drawn + 1 );
            
            if ( $original_winner == $home_team->id ) {
              # Home player won originally; remove one from the respective won / lost totals
              $game_home_player->games_won( $game_home_player->games_won - 1 );
              $game_away_player->games_lost( $game_away_player->games_lost - 1 );
            } else {
              # Away player won originally; remove one from the respective won / lost totals
              $game_home_player->games_lost( $game_home_player->games_lost - 1 );
              $game_away_player->games_won( $game_away_player->games_won - 1 );
            }
          }
        }
      }
    } elsif ( !$delete and defined( $home_player ) and defined( $away_player ) and $game_started ) {
      # If the game wasn't complete, we need to add one to the games played for each player, so long as it's started
      # (it won't have been started if it's been awarded before any points were played)
      $game_home_player->games_played( $game_home_player->games_played + 1 );
      $game_away_player->games_played( $game_away_player->games_played + 1 );
      
      # and work out who's won
      if ( defined( $game_winner ) and $game_winner == $home_team->id ) {
        $game_home_player->games_won( $game_home_player->games_won + 1 );
        $game_away_player->games_lost( $game_away_player->games_lost + 1 );
      } elsif ( defined( $game_winner ) and $game_winner == $away_team->id ) {
        $game_home_player->games_lost( $game_home_player->games_lost + 1 );
        $game_away_player->games_won( $game_away_player->games_won + 1 );
      } else {
        # Draw
        $game_home_player->games_drawn( $game_home_player->games_drawn + 1 );
        $game_away_player->games_drawn( $game_away_player->games_drawn + 1 );
      }
    }
    
    $game_home_player->legs_played    ? $game_home_player->average_leg_wins( ( $game_home_player->legs_won / $game_home_player->legs_played ) * 100 )       : $game_home_player->average_leg_wins( 0 );
    $game_home_player->points_played  ? $game_home_player->average_point_wins( ( $game_home_player->points_won / $game_home_player->points_played ) * 100 ) : $game_home_player->average_point_wins( 0 );
    $game_away_player->legs_played    ? $game_away_player->average_leg_wins( ( $game_away_player->legs_won / $game_away_player->legs_played ) * 100 )       : $game_away_player->average_leg_wins( 0 );
    $game_away_player->points_played  ? $game_away_player->average_point_wins( ( $game_away_player->points_won / $game_away_player->points_played ) * 100 ) : $game_away_player->average_point_wins( 0 );
    
    # Update all the fields we've modified
    $game_home_player->update;
    $game_away_player->update;
  }
  
  unless ( defined( $match->tournament_round ) ) {
    # Player season statistics
    if ( $self->doubles_game ) {
      # Doubles game
      # Get the person_season objects we need to update for the individual doubles statistics
      my $home_doubles1 = $home_player->person1->find_related("person_seasons", {season => $season->id, team => $home_team->id});
      my $home_doubles2 = $home_player->person2->find_related("person_seasons", {season => $season->id, team => $home_team->id});
      my $away_doubles1 = $away_player->person1->find_related("person_seasons", {season => $season->id, team => $away_team->id});
      my $away_doubles2 = $away_player->person2->find_related("person_seasons", {season => $season->id, team => $away_team->id});
      #printf "Home doubles pair ID: %d, away doubles pair ID: %d\n", $home_player->id, $away_player->id;
      #printf "H Player 1: %s, H player 2: %s\n", $home_doubles1->display_name, $home_doubles2->display_name;
      #printf "A Player 1: %s, A player 2: %s\n", $away_doubles1->display_name, $away_doubles2->display_name;
      
      # To work out the number of games that each pair has won, we need to know whether this game was already completed before this score was submitted
      # (i.e., if we're editing a score that's already been entered).  If so, we will need to know who won originally
      if ( $game_originally_complete and $game_originally_started ) {
        # If the game was complete, we need to work out who was the previous winner and if this has changed.  If neither condition below is met, it was
        # a draw, so $original_winner remains undef.
        #print "This game was previously entered and is now being edited.\n";
        my $original_winner;
        if ( $game_original_home_team_score > $game_original_away_team_score ) {
          # Home team originally won
          $original_winner = $home_team->id;
          #print "Home pair originally won.\n";
        } elsif ( $game_original_away_team_score > $game_original_home_team_score ) {
          # Away team originally won
          $original_winner = $away_team->id;
          #print "Away pair originally won.\n";
        }
        
        if ( $delete or ( $awarded and !$game_started ) ) {
          # The score is being deleted OR the game is being awarded, but has not started, so no player stats will be being updated
          # Remove a game played from each
          $home_player->games_played( $home_player->games_played - 1 );
          $away_player->games_played( $away_player->games_played - 1 );
          $home_doubles1->doubles_games_played( $home_doubles1->doubles_games_played - 1 );
          $home_doubles2->doubles_games_played( $home_doubles2->doubles_games_played - 1 );
          $away_doubles1->doubles_games_played( $away_doubles1->doubles_games_played - 1 );
          $away_doubles2->doubles_games_played( $away_doubles2->doubles_games_played - 1 );
          #print "Either we're deleting a score or we're awarding this game without starting it; take one from games played for everyone.\n";
          
          # Remove one from the original winner's total if we're deleting
          if ( $original_winner == $home_team->id ) {
            # Remove a game won from home and a game lost from away
            $home_player->games_won( $home_player->games_won - 1 );
            $away_player->games_lost( $away_player->games_lost - 1 );
            $home_doubles1->doubles_games_won( $home_doubles1->doubles_games_won - 1 );
            $home_doubles2->doubles_games_won( $home_doubles2->doubles_games_won - 1 );
            $away_doubles1->doubles_games_lost( $away_doubles1->doubles_games_lost - 1 );
            $away_doubles2->doubles_games_lost( $away_doubles2->doubles_games_lost - 1 );
            #print "Remove one from home games won and away games lost, as the home team were originally listed as winners.\n";
          } elsif ( $original_winner == $away_team->id ) {
            # Remove a game won from away and a game lost from home
            $home_player->games_lost( $home_player->games_lost - 1 );
            $away_player->games_won( $away_player->games_won - 1 );
            $home_doubles1->doubles_games_lost( $home_doubles1->doubles_games_lost - 1 );
            $home_doubles2->doubles_games_lost( $home_doubles2->doubles_games_lost - 1 );
            $away_doubles1->doubles_games_won( $away_doubles1->doubles_games_won - 1 );
            $away_doubles2->doubles_games_won( $away_doubles2->doubles_games_won - 1 );
            #print "Remove one from home games lost and away games won, as the away team were originally listed as winners.\n";
          } else {
            # Remove a drawn game from both
            $home_player->games_drawn( $home_player->games_drawn - 1 );
            $away_player->games_drawn( $away_player->games_drawn - 1 );
            $home_doubles1->doubles_games_drawn( $home_doubles1->doubles_games_drawn - 1 );
            $home_doubles2->doubles_games_drawn( $home_doubles2->doubles_games_drawn - 1 );
            $away_doubles1->doubles_games_drawn( $away_doubles1->doubles_games_drawn - 1 );
            $away_doubles2->doubles_games_drawn( $away_doubles2->doubles_games_drawn - 1 );
            #print "Remove one from games drawn, as the game was originally a draw.\n";
          }
        } else {
          # The score is NOT being deleted AND it HAS started (whether being awarded or not), so we increase games won
          #print "This score is not being deleted or awarded, so this is complete score (edited from a previously completed score.\n";
          if ( $original_winner != $game_winner ) {
            #print "The winner has changed.\n";
            # The winner has changed since the last score was entered.
            if ( $game_winner == $home_team->id ) {
              # Home player has won
              # Regardless, we need to add one to the home players' games won total / the away players' games lost total
              $home_player->games_won( $home_player->games_won + 1 );
              $away_player->games_lost( $away_player->games_lost + 1 );
              $home_doubles1->doubles_games_won( $home_doubles1->doubles_games_won + 1 );
              $home_doubles2->doubles_games_won( $home_doubles2->doubles_games_won + 1 );
              $away_doubles1->doubles_games_lost( $away_doubles1->doubles_games_lost + 1 );
              $away_doubles2->doubles_games_lost( $away_doubles2->doubles_games_lost + 1 );
              #print "Home pair has won: add one to their games won and to the away pair's games lost.\n";
              
              if ( $original_winner == $away_team->id ) {
                # Away player previously won; remove one from the respective won / lost totals
                $home_player->games_lost( $home_player->games_lost - 1 );
                $away_player->games_won( $away_player->games_won - 1 );
                $home_doubles1->doubles_games_lost( $home_doubles1->doubles_games_lost - 1 );
                $home_doubles2->doubles_games_lost( $home_doubles2->doubles_games_lost - 1 );
                $away_doubles1->doubles_games_won( $away_doubles1->doubles_games_won - 1 );
                $away_doubles2->doubles_games_won( $away_doubles2->doubles_games_won - 1 );
                #print "Away pair originally won: remove one from their games won and from the home pair's games lost.\n";
              } else {
                # The previous score must have been a draw - remove one from both games drawn totals
                $home_player->games_drawn( $home_player->games_drawn - 1 );
                $away_player->games_drawn( $away_player->games_drawn - 1 );
                $home_doubles1->doubles_games_drawn( $home_doubles1->doubles_games_drawn - 1 );
                $home_doubles2->doubles_games_drawn( $home_doubles2->doubles_games_drawn - 1 );
                $away_doubles1->doubles_games_drawn( $away_doubles1->doubles_games_drawn - 1 );
                $away_doubles2->doubles_games_drawn( $away_doubles2->doubles_games_drawn - 1 );
                #print "1. Originally a draw, remove one from games drawn.\n";
              }
            } elsif ( $game_winner == $away_team->id ) {
              # Away player has won
              # Regardless, we need to add one to the home player's games won total / the away player's games lost total
              $home_player->games_lost( $home_player->games_lost + 1 );
              $away_player->games_won( $away_player->games_won + 1 );
              $home_doubles1->doubles_games_lost( $home_doubles1->doubles_games_lost + 1 );
              $home_doubles2->doubles_games_lost( $home_doubles2->doubles_games_lost + 1 );
              $away_doubles1->doubles_games_won( $away_doubles1->doubles_games_won + 1 );
              $away_doubles2->doubles_games_won( $away_doubles2->doubles_games_won + 1 );
              #print "Away pair has won: add one to their games won and to the home pair's games lost.\n";
              
              if ( $original_winner == $home_team->id ) {
                # Home player previously won; remove one from the respective won / lost totals
                $home_player->games_won( $home_player->games_won - 1 );
                $away_player->games_lost( $away_player->games_lost - 1 );
                $home_doubles1->doubles_games_won( $home_doubles1->doubles_games_won - 1 );
                $home_doubles2->doubles_games_won( $home_doubles2->doubles_games_won - 1 );
                $away_doubles1->doubles_games_lost( $away_doubles1->doubles_games_lost - 1 );
                $away_doubles2->doubles_games_lost( $away_doubles2->doubles_games_lost - 1 );
                #print "Home pair originally won: remove one from their games won and from the away pair's games lost.\n";
              } else {
                # The previous score must have been a draw - remove one from both games drawn totals
                $home_player->games_drawn( $home_player->games_drawn - 1 );
                $away_player->games_drawn( $away_player->games_drawn - 1 );
                $home_doubles1->doubles_games_drawn( $home_doubles1->doubles_games_drawn - 1 );
                $home_doubles2->doubles_games_drawn( $home_doubles2->doubles_games_drawn - 1 );
                $away_doubles1->doubles_games_drawn( $away_doubles1->doubles_games_drawn - 1 );
                $away_doubles2->doubles_games_drawn( $away_doubles2->doubles_games_drawn - 1 );
                #print "2. Originally a draw, remove one from games drawn.\n";
              }
            } else {
              # This game must have ended in a draw - increase the games drawn totals
              $home_player->games_drawn( $home_player->games_drawn + 1 );
              $away_player->games_drawn( $away_player->games_drawn + 1 );
              $home_doubles1->doubles_games_drawn( $home_doubles1->doubles_games_drawn + 1 );
              $home_doubles2->doubles_games_drawn( $home_doubles2->doubles_games_drawn + 1 );
              $away_doubles1->doubles_games_drawn( $away_doubles1->doubles_games_drawn + 1 );
              $away_doubles2->doubles_games_drawn( $away_doubles2->doubles_games_drawn + 1 );
              #print "Draw: add one to games drawn.\n";
              
              if ( $original_winner == $home_team->id ) {
                # Home player won originally; remove one from the respective won / lost totals
                $home_player->games_won( $home_player->games_won - 1 );
                $away_player->games_lost( $away_player->games_lost - 1 );
                $home_doubles1->doubles_games_won( $home_doubles1->doubles_games_won - 1 );
                $home_doubles2->doubles_games_won( $home_doubles2->doubles_games_won - 1 );
                $away_doubles1->doubles_games_lost( $away_doubles1->doubles_games_lost - 1 );
                $away_doubles2->doubles_games_lost( $away_doubles2->doubles_games_lost - 1 );
                #print "D. Home pair originally won: remove one from their games won and from the away pair's games lost.\n";
              } else {
                # Away player won originally; remove one from the respective won / lost totals
                $home_player->games_lost( $home_player->games_lost - 1 );
                $away_player->games_won( $away_player->games_won - 1 );
                $home_doubles1->doubles_games_lost( $home_doubles1->doubles_games_lost - 1 );
                $home_doubles2->doubles_games_lost( $home_doubles2->doubles_games_lost - 1 );
                $away_doubles1->doubles_games_won( $away_doubles1->doubles_games_won - 1 );
                $away_doubles2->doubles_games_won( $away_doubles2->doubles_games_won - 1 );
                #print "D. Away pair originally won: remove one from their games won and from the home pair's games lost.\n";
              }
            }
          }
        }
      } elsif ( !$delete and $game_started ) {
        # If the game wasn't complete, we need to add one to the games played for each player, so long as it's started
        # (it won't have been started if it's been awarded before any points were played)
        $home_player->games_played( $home_player->games_played + 1 );
        $away_player->games_played( $away_player->games_played + 1 );
        $home_doubles1->doubles_games_played( $home_doubles1->doubles_games_played + 1 );
        $home_doubles2->doubles_games_played( $home_doubles2->doubles_games_played + 1 );
        $away_doubles1->doubles_games_played( $away_doubles1->doubles_games_played + 1 );
        $away_doubles2->doubles_games_played( $away_doubles2->doubles_games_played + 1 );
        #print "This is a new score being entered, add one to games played.\n";
        
        # and work out who's won
        if ( $game_winner == $home_team->id ) {
          $home_player->games_won( $home_player->games_won + 1 );
          $away_player->games_lost( $away_player->games_lost + 1 );
          $home_doubles1->doubles_games_won( $home_doubles1->doubles_games_won + 1 );
          $home_doubles2->doubles_games_won( $home_doubles2->doubles_games_won + 1 );
          $away_doubles1->doubles_games_lost( $away_doubles1->doubles_games_lost + 1 );
          $away_doubles2->doubles_games_lost( $away_doubles2->doubles_games_lost + 1 );
          #print "Home team won, add one to their games won and one to the away team's games lost.\n";
        } elsif ( $game_winner == $away_team->id ) {
          $home_player->games_lost( $home_player->games_lost + 1 );
          $away_player->games_won( $away_player->games_won + 1 );
          $home_doubles1->doubles_games_lost( $home_doubles1->doubles_games_lost + 1 );
          $home_doubles2->doubles_games_lost( $home_doubles2->doubles_games_lost + 1 );
          $away_doubles1->doubles_games_won( $away_doubles1->doubles_games_won + 1 );
          $away_doubles2->doubles_games_won( $away_doubles2->doubles_games_won + 1 );
          #print "Away team won, add one to their games won and one to the home team's games lost.\n";
        } else {
          # Draw
          $home_player->games_drawn( $home_player->games_drawn + 1 );
          $away_player->games_drawn( $away_player->games_drawn + 1 );
          $home_doubles1->doubles_games_drawn( $home_doubles1->doubles_games_drawn + 1 );
          $home_doubles2->doubles_games_drawn( $home_doubles2->doubles_games_drawn + 1 );
          $away_doubles1->doubles_games_drawn( $away_doubles1->doubles_games_drawn + 1 );
          $away_doubles2->doubles_games_drawn( $away_doubles2->doubles_games_drawn + 1 );
          #print "Draw, add one to games drawn.\n";
        }
      }
      
      # Legs and points
      $home_player->legs_played( $home_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $away_player->legs_played( $away_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $home_player->legs_won( $home_player->legs_won + ( $home_legs - $game_original_home_team_score ) );
      $away_player->legs_won( $away_player->legs_won + ( $away_legs - $game_original_away_team_score ) );
      $home_player->legs_lost( $home_player->legs_lost + ( $away_legs - $game_original_away_team_score ) );
      $away_player->legs_lost( $away_player->legs_lost + ( $home_legs - $game_original_home_team_score ) );
      
      $home_player->points_played( $home_player->points_played + ( ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) ) );
      $away_player->points_played( $away_player->points_played + ( ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) ) );
      $home_player->points_won( $home_player->points_won + ( $home_team_points - $game_original_home_team_points ) );
      $away_player->points_won( $away_player->points_won + ( $away_team_points - $game_original_away_team_points ) );
      $home_player->points_lost( $home_player->points_lost + ( $away_team_points - $game_original_away_team_points ) );
      $away_player->points_lost( $away_player->points_lost + ( $home_team_points - $game_original_home_team_points ) );
      
      $home_doubles1->doubles_legs_played( $home_doubles1->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $home_doubles2->doubles_legs_played( $home_doubles2->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $away_doubles1->doubles_legs_played( $away_doubles1->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $away_doubles2->doubles_legs_played( $away_doubles2->doubles_legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
      $home_doubles1->doubles_legs_won( $home_doubles1->doubles_legs_won + ( $home_legs - $game_original_home_team_score ) );
      $home_doubles2->doubles_legs_won( $home_doubles2->doubles_legs_won + ( $home_legs - $game_original_home_team_score ) );
      $away_doubles1->doubles_legs_won( $away_doubles1->doubles_legs_won + ( $away_legs - $game_original_away_team_score ) );
      $away_doubles2->doubles_legs_won( $away_doubles2->doubles_legs_won + ( $away_legs - $game_original_away_team_score ) );
      $home_doubles1->doubles_legs_lost( $home_doubles1->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ) );
      $home_doubles2->doubles_legs_lost( $home_doubles2->doubles_legs_lost + ( $away_legs - $game_original_away_team_score ) );
      $away_doubles1->doubles_legs_lost( $away_doubles1->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ) );
      $away_doubles2->doubles_legs_lost( $away_doubles2->doubles_legs_lost + ( $home_legs - $game_original_home_team_score ) );
      $home_doubles1->doubles_points_played( $home_doubles1->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $home_doubles2->doubles_points_played( $home_doubles2->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $away_doubles1->doubles_points_played( $away_doubles1->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $away_doubles2->doubles_points_played( $away_doubles2->doubles_points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
      $home_doubles1->doubles_points_won( $home_doubles1->doubles_points_won + ( $home_team_points - $game_original_home_team_points ) );
      $home_doubles2->doubles_points_won( $home_doubles2->doubles_points_won + ( $home_team_points - $game_original_home_team_points ) );
      $away_doubles1->doubles_points_won( $away_doubles1->doubles_points_won + ( $away_team_points - $game_original_away_team_points ) );
      $away_doubles2->doubles_points_won( $away_doubles2->doubles_points_won + ( $away_team_points - $game_original_away_team_points ) );
      $home_doubles1->doubles_points_lost( $home_doubles1->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ) );
      $home_doubles2->doubles_points_lost( $home_doubles2->doubles_points_lost + ( $away_team_points - $game_original_away_team_points ) );
      $away_doubles1->doubles_points_lost( $away_doubles1->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ) );
      $away_doubles2->doubles_points_lost( $away_doubles2->doubles_points_lost + ( $home_team_points - $game_original_home_team_points ) );
      
      # Work out the averages
      $home_player->games_played  ? $home_player->average_game_wins( ( $home_player->games_won / $home_player->games_played ) * 100 )     : $home_player->average_game_wins( 0 );
      $home_player->legs_played   ? $home_player->average_leg_wins( ( $home_player->legs_won / $home_player->legs_played ) * 100 )        : $home_player->average_leg_wins( 0 );
      $home_player->points_played ? $home_player->average_point_wins( ( $home_player->points_won / $home_player->points_played ) * 100 )  : $home_player->average_point_wins( 0 );
      $away_player->games_played  ? $away_player->average_game_wins( ( $away_player->games_won / $away_player->games_played ) * 100 )     : $away_player->average_game_wins( 0 );
      $away_player->legs_played   ? $away_player->average_leg_wins( ( $away_player->legs_won / $away_player->legs_played ) * 100 )        : $away_player->average_leg_wins( 0 );
      $away_player->points_played ? $away_player->average_point_wins( ( $away_player->points_won / $away_player->points_played ) * 100 )  : $away_player->average_point_wins( 0 );
      
      $home_doubles1->doubles_games_played  ? $home_doubles1->doubles_average_game_wins( ( $home_doubles1->doubles_games_won / $home_doubles1->doubles_games_played ) * 100 )     : $home_doubles1->doubles_average_game_wins( 0 );
      $home_doubles2->doubles_games_played  ? $home_doubles2->doubles_average_game_wins( ( $home_doubles2->doubles_games_won / $home_doubles2->doubles_games_played ) * 100 )     : $home_doubles2->doubles_average_game_wins( 0 );
      $home_doubles1->doubles_legs_played   ? $home_doubles1->doubles_average_leg_wins( ( $home_doubles1->doubles_legs_won / $home_doubles1->doubles_legs_played ) * 100 )        : $home_doubles1->doubles_average_leg_wins( 0 );
      $home_doubles2->doubles_legs_played   ? $home_doubles2->doubles_average_leg_wins( ( $home_doubles2->doubles_legs_won / $home_doubles2->doubles_legs_played ) * 100 )        : $home_doubles2->doubles_average_leg_wins( 0 );
      $home_doubles1->doubles_points_played ? $home_doubles1->doubles_average_point_wins( ( $home_doubles1->doubles_points_won / $home_doubles1->doubles_points_played ) * 100 )  : $home_doubles1->doubles_average_point_wins( 0 );
      $home_doubles2->doubles_points_played ? $home_doubles2->doubles_average_point_wins( ( $home_doubles2->doubles_points_won / $home_doubles2->doubles_points_played ) * 100 )  : $home_doubles2->doubles_average_point_wins( 0 );
      $away_doubles1->doubles_games_played  ? $away_doubles1->doubles_average_game_wins( ( $away_doubles1->doubles_games_won / $away_doubles1->doubles_games_played ) * 100 )     : $away_doubles1->doubles_average_game_wins( 0 );
      $away_doubles2->doubles_games_played  ? $away_doubles2->doubles_average_game_wins( ( $away_doubles2->doubles_games_won / $away_doubles2->doubles_games_played ) * 100 )     : $away_doubles2->doubles_average_game_wins( 0 );
      $away_doubles1->doubles_legs_played   ? $away_doubles1->doubles_average_leg_wins( ( $away_doubles1->doubles_legs_won / $away_doubles1->doubles_legs_played ) * 100 )        : $away_doubles1->doubles_average_leg_wins( 0 );
      $away_doubles2->doubles_legs_played   ? $away_doubles2->doubles_average_leg_wins( ( $away_doubles2->doubles_legs_won / $away_doubles2->doubles_legs_played ) * 100 )        : $away_doubles2->doubles_average_leg_wins( 0 );
      $away_doubles1->doubles_points_played ? $away_doubles1->doubles_average_point_wins( ( $away_doubles1->doubles_points_won / $away_doubles1->doubles_points_played ) * 100 )  : $away_doubles1->doubles_average_point_wins( 0 );
      $away_doubles2->doubles_points_played ? $away_doubles2->doubles_average_point_wins( ( $away_doubles2->doubles_points_won / $away_doubles2->doubles_points_played ) * 100 )  : $away_doubles2->doubles_average_point_wins( 0 );
      
      $home_player->update;
      $away_player->update;
      $home_doubles1->update;
      $home_doubles2->update;
      $away_doubles1->update;
      $away_doubles2->update;
      
      # If there are player matches played / won / lost to update, do it here for all players in the match
      # We also need to do that for the other players in the match
      my $home_players = $match->search_related("team_match_players", {
        "person_seasons.season" => $season->id,
        "person_seasons.team"   => $home_team->id,
        location => "home",
      }, {
        prefetch => {
          player => "person_seasons"
        }
      });
      
      while ( my $_home_player = $home_players->next ) {
        my $_player = $_home_player->player->person_seasons->first;
        
        foreach my $field ( keys ( %{ $score_instructions{home} } ) ) {
          if ( $score_instructions{home}{$field} eq "+1" ) {
            # Add one to the field
            $_player->$field( $_player->$field + 1 );
          } elsif ( $score_instructions{home}{$field} eq "-1" ) {
            # Subtract one from the field
            $_player->$field( $_player->$field - 1 );
          }
        }
        
        $_player->update;
      }
      
      my $away_players = $match->search_related("team_match_players", {
        "person_seasons.season" => $season->id,
        "person_seasons.team"   => $away_team->id,
        location => "away",
      }, {
        prefetch => {
          player => "person_seasons"
        }
      });
      
      while ( my $_away_player = $away_players->next ) {
        my $_player = $_away_player->player->person_seasons->first;
        
        foreach my $field ( keys ( %{ $score_instructions{home} } ) ) {
          if ( $score_instructions{away}{$field} eq "+1" ) {
            # Add one to the field
            $_player->$field( $_player->$field + 1 );
          } elsif ( $score_instructions{away}{$field} eq "-1" ) {
            # Subtract one from the field
            $_player->$field( $_player->$field - 1 );
          }
        }
        
        $_player->update;
      }
    } else {
      # Singles game
      if ( !$home_player_missing and !$away_player_missing ) {
        # Get the person season objects (assuming they're defined - they may not be if we've set a missing player)
        my $season_home_player = $home_player->find_related("person_seasons", {season => $season->id, team => $home_team->id});
        my $season_away_player = $away_player->find_related("person_seasons", {season => $season->id, team => $away_team->id});
        
        # Create the season object if it doesn't exist (we should never have to do this, as even loan players should
        # be created when added to their match position, before the scores are filled out).
        $season_home_player = $home_player->create_related("person_seasons", {
          season                => $season->id,
          team                  => $home_team->id,
          first_name            => $home_player->first_name,
          surname               => $home_player->surname,
          display_name          => $home_player->display_name,
          team_membership_type  => "loan",
        }) unless defined( $season_home_player );
        
        $season_away_player = $away_player->create_related("person_seasons", {
          season                => $season->id,
          team                  => $away_team->id,
          first_name            => $away_player->first_name,
          surname               => $away_player->surname,
          display_name          => $away_player->display_name,
          team_membership_type  => "loan",
        }) unless defined( $season_away_player );
        
        # We already know what we need to do to each matches won / drawn / lost total, just loop through and do it
        foreach my $stat_team ( keys ( %score_instructions ) ) {
          # Work out which team we're modifying at the moment
          my $mod_team = ( $stat_team eq "home" ) ? $season_home_player : $season_away_player;
          
          foreach my $field ( keys ( %{ $score_instructions{$stat_team} } ) ) {
            if ( $score_instructions{$stat_team}{$field} eq "+1" ) {
              # Add one to the field
              $mod_team->$field( $mod_team->$field + 1 );
            } elsif ( $score_instructions{$stat_team}{$field} eq "-1" ) {
              # Subtract one from the field
              $mod_team->$field( $mod_team->$field - 1 );
            }
          }
        }
        
        # We also need to do that for the other players in the match
        my $home_other_players = $match->search_related("team_match_players", undef, {
          where => {
            player_number => {
              "!=" => $match_home_player->player_number,
            },
            "person_seasons.season" => $season->id,
            "person_seasons.team"   => $home_team->id,
            location => "home",
          },
          prefetch => {
            player => "person_seasons"
          }
        });
        
        while ( my $_home_player = $home_other_players->next ) {
          my $_player = $_home_player->player->person_seasons->first;
          
          foreach my $field ( keys ( %{ $score_instructions{home} } ) ) {
            if ( $score_instructions{home}{$field} eq "+1" ) {
              # Add one to the field
              $_player->$field( $_player->$field + 1 );
            } elsif ( $score_instructions{home}{$field} eq "-1" ) {
              # Subtract one from the field
              $_player->$field( $_player->$field - 1 );
            }
          }
          
          $_player->update;
        }
        
        my $away_other_players = $match->search_related("team_match_players", undef, {
          where => {
            player_number => {
              "!=" => $match_away_player->player_number,
            },
            "person_seasons.season" => $season->id,
            "person_seasons.team"   => $away_team->id,
            location => "away",
          },
          prefetch => {
            player => "person_seasons"
          }
        });
        
        while ( my $_away_player = $away_other_players->next ) {
          my $_player = $_away_player->player->person_seasons->first;
          
          foreach my $field ( keys ( %{ $score_instructions{home} } ) ) {
            if ( $score_instructions{away}{$field} eq "+1" ) {
              # Add one to the field
              $_player->$field( $_player->$field + 1 );
            } elsif ( $score_instructions{away}{$field} eq "-1" ) {
              # Subtract one from the field
              $_player->$field( $_player->$field - 1 );
            }
          }
          
          $_player->update;
        }
        
        # To work out the number of games that each player has won, we need to know whether this game was already completed before this score was submitted
        # (i.e., if we're editing a score that's already been entered).  If so, we will need to know who won originally
        if ( $game_originally_complete and $game_originally_started ) {
          # If the game was complete, we need to work out who was the previous winner and if this has changed.  If neither condition below is met, it was
          # a draw, so $original_winner remains undef.
          my $original_winner;
          if ( $game_original_home_team_score > $game_original_away_team_score ) {
            # Home team originally won
            $original_winner = $home_team->id;
          } elsif ( $game_original_away_team_score > $game_original_home_team_score ) {
            # Away team originally won
            $original_winner = $away_team->id;
          }
          
          if ( $delete ) {
            # Remove one from games played
            $season_home_player->games_played( $season_home_player->games_played - 1 );
            $season_away_player->games_played( $season_away_player->games_played - 1 );
            
            # Remove one from the original winner's total if we're deleting
            if ( $original_winner == $home_team->id ) {
              # Remove a game won from home and a game lost from away
              $season_home_player->games_won( $season_home_player->games_won - 1 );
              $season_away_player->games_lost( $season_away_player->games_lost - 1 );
            } elsif ( $original_winner == $away_team->id ) {
              # Remove a game won from away and a game lost from home
              $season_home_player->games_lost( $season_home_player->games_lost - 1 );
              $season_away_player->games_won( $season_away_player->games_won - 1 );
            } else {
              # Remove a drawn game from both
              $season_home_player->games_drawn( $season_home_player->games_drawn - 1 );
              $season_away_player->games_drawn( $season_away_player->games_drawn - 1 );
            }
          } else {
            if ( $original_winner != $game_winner ) {
              # The winner has changed since the last score was entered.
              if ( $game_winner == $home_team->id ) {
                # Home player has won
                # Regardless, we need to add one to the home player's games won total / the away player's games lost total
                $season_home_player->games_won( $season_home_player->games_won + 1 );
                $season_away_player->games_lost( $season_away_player->games_lost + 1 );
                
                if ( $original_winner == $away_team->id ) {
                  # Away player previously won; remove one from the respective won / lost totals
                  $season_home_player->games_lost( $season_home_player->games_lost - 1 );
                  $season_away_player->games_won( $season_away_player->games_won - 1 );
                } else {
                  # The previous score must have been a draw - remove one from both games drawn totals
                  $season_home_player->games_drawn( $season_home_player->games_drawn - 1 );
                  $season_away_player->games_drawn( $season_away_player->games_drawn - 1 );
                }
              } elsif ( $game_winner == $away_team->id ) {
                # Away player has won
                # Regardless, we need to add one to the home player's games won total / the away player's games lost total
                $season_home_player->games_lost( $season_home_player->games_lost + 1 );
                $season_away_player->games_won( $season_away_player->games_won + 1 );
                
                if ( $original_winner == $home_team->id ) {
                  # Home player previously won; remove one from the respective won / lost totals
                  $season_home_player->games_won( $season_home_player->games_won - 1 );
                  $season_away_player->games_lost( $season_away_player->games_lost - 1 );
                } else {
                  # The previous score must have been a draw - remove one from both games drawn totals
                  $season_home_player->games_drawn( $season_home_player->games_drawn - 1 );
                  $season_away_player->games_drawn( $season_away_player->games_drawn - 1 );
                }
              } else {
                # This game must have ended in a draw - increase the games drawn totals
                $season_home_player->games_drawn( $season_home_player->games_drawn + 1 );
                $season_away_player->games_drawn( $season_away_player->games_drawn + 1 );
                
                if ( $original_winner == $home_team->id ) {
                  # Home player won originally; remove one from the respective won / lost totals
                  $season_home_player->games_won( $season_home_player->games_won - 1 );
                  $season_away_player->games_lost( $season_away_player->games_lost - 1 );
                } else {
                  # Away player won originally; remove one from the respective won / lost totals
                  $season_home_player->games_lost( $season_home_player->games_lost - 1 );
                  $season_away_player->games_won( $season_away_player->games_won - 1 );
                }
              }
            }
          }
        } elsif ( !$delete and $game_started ) {
          # If the game wasn't complete, we need to add one to the games played for each player
          $season_home_player->games_played( $season_home_player->games_played + 1 );
          $season_away_player->games_played( $season_away_player->games_played + 1 );
          
          # and work out who's won
          if ( $game_winner == $home_team->id ) {
            $season_home_player->games_won( $season_home_player->games_won + 1 );
            $season_away_player->games_lost( $season_away_player->games_lost + 1 );
          } elsif ( $game_winner == $away_team->id ) {
            $season_home_player->games_lost( $season_home_player->games_lost + 1 );
            $season_away_player->games_won( $season_away_player->games_won + 1 );
          } else {
            # Draw
            $season_home_player->games_drawn( $season_home_player->games_drawn + 1 );
            $season_away_player->games_drawn( $season_away_player->games_drawn + 1 );
          }
        }
        
        # Player season stats
        $season_home_player->legs_played( $season_home_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
        $season_away_player->legs_played( $season_away_player->legs_played + ( $home_legs + $away_legs ) - ( $game_original_home_team_score + $game_original_away_team_score ) );
        $season_home_player->legs_won( $season_home_player->legs_won + ( $home_legs - $game_original_home_team_score ) );
        $season_away_player->legs_won( $season_away_player->legs_won + ( $away_legs - $game_original_away_team_score ) );
        $season_home_player->legs_lost( $season_home_player->legs_lost + ( $away_legs - $game_original_away_team_score ) );
        $season_away_player->legs_lost( $season_away_player->legs_lost + ( $home_legs - $game_original_home_team_score ) );
        $season_home_player->points_played( $season_home_player->points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
        $season_away_player->points_played( $season_away_player->points_played + ( $home_team_points + $away_team_points ) - ( $game_original_home_team_points  + $game_original_away_team_points ) );
        $season_home_player->points_won( $season_home_player->points_won + ( $home_team_points - $game_original_home_team_points ) );
        $season_away_player->points_won( $season_away_player->points_won + ( $away_team_points - $game_original_away_team_points ) );
        $season_home_player->points_lost( $season_home_player->points_lost + ( $away_team_points - $game_original_away_team_points ) );
        $season_away_player->points_lost( $season_away_player->points_lost + ( $home_team_points - $game_original_home_team_points ) );
        
        # Averages
        $season_home_player->games_played   ? $season_home_player->average_game_wins( ( $season_home_player->games_won / $season_home_player->games_played ) * 100 )      : $season_home_player->average_game_wins( 0 );
        $season_home_player->legs_played    ? $season_home_player->average_leg_wins( ( $season_home_player->legs_won / $season_home_player->legs_played ) * 100 )         : $season_home_player->average_leg_wins( 0 );
        $season_home_player->points_played  ? $season_home_player->average_point_wins( ( $season_home_player->points_won / $season_home_player->points_played  ) * 100 )  : $season_home_player->average_point_wins( 0 );
        $season_away_player->games_played   ? $season_away_player->average_game_wins( ( $season_away_player->games_won / $season_away_player->games_played ) * 100 )      : $season_away_player->average_game_wins( 0 );
        $season_away_player->legs_played    ? $season_away_player->average_leg_wins( ( $season_away_player->legs_won / $season_away_player->legs_played ) * 100 )         : $season_away_player->average_leg_wins( 0 );
        $season_away_player->points_played  ? $season_away_player->average_point_wins( ( $season_away_player->points_won / $season_away_player->points_played ) * 100 )   : $season_away_player->average_point_wins( 0 );
        
        $season_home_player->update;
        $season_away_player->update;
      }
    }
  }
  
  # Finally commit the transaction if there are no errors
  $transaction->commit;
  
  # Return the match object so we can tell whether or not it's complete in the AJAX response
  $return_value->{match} = $match;
  $return_value->{match_originally_complete} = $match_originally_complete;
  return $return_value;
}

=head2 update_umpire

Update the umpire for the game.

=cut

sub update_umpire {
  my ( $self, $parameters ) = @_;
  my $action        = $parameters->{action};
  my $person        = $parameters->{person};
  my $return_value  = {error => []};
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $self->team_match->cancelled ) {
    push(@{ $return_value->{error} }, {id => "matches.update.error.match-cancelled"});
    return $return_value;
  }
  
  if ( $action eq "add" ) {
    if ( defined( $person ) and ref( $person ) eq "TopTable::Model::DB::Person" ) {
      # Person is valid, update
      my $ok = $self->update({umpire => $person->id});
      push(@{ $return_value->{error} }, {id => "matches.umpire.add.database-error"}) unless $ok;
    } else {
      # Invalid person
      push(@{ $return_value->{error} }, {id => "matches.umpire.add.error.person-invalid"});
    }
  } elsif ( $action eq "remove" ) {
    # Remove the umpire
    my $ok = $self->update({umpire => undef});
    push(@{ $return_value->{error} }, {id => "matches.umpire.remove.database-error"}) unless $ok;
  }
  
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # If we've errored, we will provide the original values back so the client-side script can reset the value
    my ( $original_id, $original_name );
    if ( defined( $self->umpire ) ) {
      $original_id    = $self->umpire->id;
      $original_name  = $self->umpire->display_name;
    }
    
    $return_value->{original_umpire} = {
      id    => $original_id,
      name  => $original_name,
    };
  }
  
  return $return_value;
}



=head2 update_doubles_pair

Add or remove a pair of players to a doubles game.

=cut

sub update_doubles_pair {
  my ( $self, $parameters, $c ) = @_;
  my $location      = $parameters->{location} || undef;
  my $players       = $parameters->{players};
  my $match         = $self->team_match;
  my $season        = $match->season;
  my $return_value  = {error =>[]};
  $players          = [ $players ] unless ref( $players ) eq "ARRAY";
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{ $return_value->{error} }, {id => "matches.update.error.match-cancelled"});
    return $return_value;
  }
  
  # Break the two people out of the array to make it easier to access
  my ( $player1, $player2 ) = ( $players->[0], $players->[1] );
  
  if ( $season->complete ) {
    # Error, season is complete
    push(@{ $return_value->{error} }, {id => "matches.update.error.season-complete"});
    return $return_value;
  } else {
    # Check the game we're updating is actually a doubles game
    if ( $self->doubles_game ) {
      # Check we have a location
      if ( defined( $location ) and ( $location eq "home" or $location eq "away" ) ) {
        # Get the team and relevant DB fields for updating
        my $location_team         = ( $location eq "home" ) ? "team_season_home_team_season"  : "team_season_away_team_season";
        my $location_doubles_pair = ( $location eq "home" ) ? "home_doubles_pair"             : "away_doubles_pair";
        my $team_legs_won         = ( $location eq "home" ) ? "home_team_legs_won"            : "away_team_legs_won";
        my $opposition_legs_won   = ( $location eq "home" ) ? "away_team_legs_won"            : "home_team_legs_won";
        my $team_points_won       = ( $location eq "home" ) ? "home_team_points_won"          : "away_team_points_won";
        my $opposition_points_won = ( $location eq "home" ) ? "away_team_points_won"          : "home_team_points_won";
        my $team = $match->$location_team->team;
        my $original_doubles_pair = $self->$location_doubles_pair;
        
        # Check if we are adding or removing - if $player_ids is undefined, we'll remove
        if ( scalar( @{ $players } ) ) {
          # Add - first check the players are valid people
          push(@{ $return_value->{error} }, {id => sprintf("matches.game.update-doubles.error.%s-player1-invalid", $location)}) unless ( defined( $player1 ) and ref( $player1 ) eq "TopTable::Model::DB::Person" );
          push(@{ $return_value->{error} }, {id => sprintf("matches.game.update-doubles.error.%s-player2-invalid", $location), {parameters => ref( $player2 )}}) unless ( defined( $player2 ) and ref( $player2 ) eq "TopTable::Model::DB::Person" );
          
          # If either player is invalid, we return at this point, as they are fatal errors
          return $return_value if scalar( @{ $return_value->{error} } );
          
          # Check we don't have two references to the same person
          push(@{ $return_value->{error} }, {
            id        => "matches.game.update-doubles.error.players-identical",
            location  => [$location],
          }) if $player1->id == $player2->id;
          
          # Return if we have an error here
          return $return_value if scalar( @{ $return_value->{error} } );
          
          # Now check if there's a doubles pairing with the two players
          my $doubles_pair1 = $player1->search_related("doubles_pairs_person1s", {
            season  => $season->id,
            person2 => $player2->id,
            team    => $team->id,
          });
          
          my $doubles_pair2 = $player1->search_related("doubles_pairs_person2s", {
            season  => $season->id,
            person1 => $player2->id,
            team    => $team->id,
          });
          
          my $doubles_pair = $doubles_pair1->union_all( $doubles_pair2 )->first;
          
          # Work out if either player is a loan player
          my $person1_active_season = $player1->find_related("person_seasons", {
            season                => $season->id,
            team                  => $team->id,
            team_membership_type  => "active",
          });
          
          my $person2_active_season = $player2->find_related("person_seasons", {
            season                => $season->id,
            team                  => $team->id,
            team_membership_type  => "active",
          });
          
          my $person1_loan = ( defined( $person1_active_season ) ) ? 0 : 1;
          my $person2_loan = ( defined( $person2_active_season ) ) ? 0 : 1;
          
          # If the doubles pair was returned okay, we don't need to do any more verification, just use the existing one
          unless ( defined( $doubles_pair ) ) {
            # The doubles pair doesn't exist, so we need to verify the people specified are eligible to play in the
            # doubles game; to do this we first need to get a list of eligible players (which will include all players
            # registered for the team plus any players playing as a loan player if appropriate).
            my @player_list = @{ $self->team_match->eligible_players({location => $location}) };
            
            # Check each player against the list of eligible players - start off with both eligible flags set to false
            my $player1_eligible = 0;
            my $player2_eligible = 0;
            foreach my $eligible_player ( @player_list ) {
              # If player 1 is eligible, set the flag to true
              $player1_eligible = 1 if $eligible_player->id == $player1->id;
              
              # If player 1 is eligible, set the flag to true
              $player2_eligible = 1 if $eligible_player->id == $player2->id;
              
              # Don't loop through any more if we've already established both players are eligible
              last if $player1_eligible and $player2_eligible;
            }
          
            # Advise about ineligible players if either are
            push(@{ $return_value->{error} }, {
              id          => "matches.game.update-doubles.error.player-ineligible",
              parameters  => [$player1->display_name, $team->club->short_name, $team->name],
            }) unless $player1_eligible;
            
            push(@{ $return_value->{error} }, {
              id          => "matches.game.update-doubles.error.player-ineligible",
              parameters  => [$player2->display_name, $team->club->short_name, $team->name],
            }) unless $player2_eligible;
            
            return $return_value if scalar( @{ $return_value->{error} } );
            
            # Now do the create
            $doubles_pair = $player1->create_related("doubles_pairs_person1s", {
              person2             => $player2->id,
              season              => $season->id,
              team                => $team->id,
              person1_loan        => $person1_loan,
              person2_loan        => $person2_loan,
            });
            #printf "Creating doubles pair for %s and %s\n", $player1->display_name, $player2->display_name;
          }
          
          # Now regardless we have a doubles pair, whether we created or used the existing one, so finally we can set the doubles team for this game
          $self->$location_doubles_pair( $doubles_pair );
          
          # Update the statistics for the original doubles pair if it's changed and there was an original doubles pair specified
          if ( $self->is_column_changed( $location_doubles_pair ) ) {
            #printf "Doubles pair has changed\n";
            # The doubles pair column has changed, so we need to recalculate some values
            
            if ( defined( $original_doubles_pair ) ) {
              #printf "There was previously another doubles pair\n";
              # Get the original player 1 / player 2 objects to update their individual statistics
              my $original_player1  = $original_doubles_pair->person1->find_related("person_seasons", {season => $season->id, team => $team->id});
              my $original_player2  = $original_doubles_pair->person2->find_related("person_seasons", {season => $season->id, team => $team->id});
              
              # There is an original doubles pair to take some games off
              if ( $self->complete ) {
                $original_doubles_pair->games_played($original_doubles_pair->games_played - 1);
                $original_player1->doubles_games_played( $original_player1->doubles_games_played - 1 );
                $original_player2->doubles_games_played( $original_player2->doubles_games_played - 1 );
              }
              
              # Work out whether we need to take a game won, lost or drawn off
              if ( $self->complete and defined( $self->winner ) and $self->winner->id == $match->$location_team->id ) {
                # Game won
                $original_doubles_pair->games_won( $original_doubles_pair->games_won - 1 );
                $original_player1->doubles_games_won( $original_player1->doubles_games_won - 1 );
                $original_player2->doubles_games_won( $original_player2->doubles_games_won - 1 );
              } elsif ( $self->complete and defined( $self->winner ) and $self->winner->id != $match->$location_team->id ) {
                # Game lost
                $original_doubles_pair->games_lost( $original_doubles_pair->games_lost - 1 );
                $original_player1->doubles_games_lost( $original_player1->doubles_games_lost - 1 );
                $original_player2->doubles_games_lost( $original_player2->doubles_games_lost - 1 );
              } elsif ( $self->complete and !defined( $self->winner ) ) {
                # Game complete but no winner: draw (only relevant for games with a static number of legs)
                $original_doubles_pair->games_drawn( $original_doubles_pair->games_drawn - 1 );
                $original_player1->doubles_games_drawn( $original_player1->doubles_games_drawn - 1 );
                $original_player2->doubles_games_drawn( $original_player2->doubles_games_drawn - 1 );
              }
              
              # Take away the legs that have been played, won and lost in this game from the original pair
              # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
              # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
              $original_doubles_pair->legs_played( $original_doubles_pair->legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ) );
              $original_player1->doubles_legs_played( $original_player1->doubles_legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ) );
              $original_player2->doubles_legs_played( $original_player2->doubles_legs_played - ( $self->$team_legs_won + $self->$opposition_legs_won ) );
              
              $original_doubles_pair->legs_won( $original_doubles_pair->legs_won - $self->$team_legs_won );
              $original_player1->doubles_legs_won( $original_player1->doubles_legs_won - $self->$team_legs_won );
              $original_player2->doubles_legs_won( $original_player2->doubles_legs_won - $self->$team_legs_won );
              
              $original_doubles_pair->legs_lost( $original_doubles_pair->legs_lost - $self->$opposition_legs_won );
              $original_player1->doubles_legs_lost( $original_player1->doubles_legs_lost - $self->$opposition_legs_won );
              $original_player2->doubles_legs_lost( $original_player2->doubles_legs_lost - $self->$opposition_legs_won );
              
              # Take away the points that have been played, won and lost in this game from the original pair
              # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
              # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
              $original_doubles_pair->points_played( $original_doubles_pair->points_played - ( $self->$team_points_won + $self->$opposition_points_won ) );
              $original_player1->doubles_points_played( $original_player1->doubles_points_played - ( $self->$team_points_won + $self->$opposition_points_won ) );
              $original_player2->doubles_points_played( $original_player2->doubles_points_played - ( $self->$team_points_won + $self->$opposition_points_won ) );
              
              $original_doubles_pair->points_won( $original_doubles_pair->points_won - $self->$team_points_won );
              $original_player1->doubles_points_won( $original_player1->doubles_points_won - $self->$team_points_won );
              $original_player2->doubles_points_won( $original_player2->doubles_points_won - $self->$team_points_won );
              
              $original_doubles_pair->points_lost( $original_doubles_pair->points_lost - $self->$opposition_points_won );
              $original_player1->doubles_points_lost( $original_player1->doubles_points_lost - $self->$opposition_points_won );
              $original_player2->doubles_points_lost( $original_player2->doubles_points_lost - $self->$opposition_points_won );
              
              # Work out the averages again
              $original_doubles_pair->games_played      ? $original_doubles_pair->average_game_wins( ( $original_doubles_pair->games_won / $original_doubles_pair->games_played ) * 100 )                 : $original_doubles_pair->average_game_wins( 0 );
              $original_player1->doubles_games_played   ? $original_player1->doubles_average_game_wins( ( $original_player1->doubles_games_won / $original_player1->doubles_games_played ) * 100 )        : $original_player1->doubles_average_game_wins( 0 );
              $original_player2->doubles_games_played   ? $original_player2->doubles_average_game_wins( ( $original_player2->doubles_games_won / $original_player2->doubles_games_played ) * 100 )        : $original_player2->doubles_average_game_wins( 0 );
              
              $original_doubles_pair->legs_played       ? $original_doubles_pair->average_leg_wins( ( $original_doubles_pair->legs_won / $original_doubles_pair->legs_played ) * 100 )                    : $original_doubles_pair->average_leg_wins( 0 );
              $original_player1->doubles_legs_played    ? $original_player1->doubles_average_leg_wins( ( $original_player1->doubles_legs_won / $original_player1->doubles_legs_played ) * 100 )           : $original_player1->doubles_average_leg_wins( 0 );
              $original_player2->doubles_legs_played    ? $original_player2->doubles_average_leg_wins( ( $original_player2->doubles_legs_won / $original_player2->doubles_legs_played ) * 100 )           : $original_player2->doubles_average_leg_wins( 0 );
              
              $original_doubles_pair->points_played     ? $original_doubles_pair->average_point_wins( ( $original_doubles_pair->points_won / $original_doubles_pair->points_played ) * 100 )              : $original_doubles_pair->average_point_wins( 0 );
              $original_player1->doubles_points_played  ? $original_player1->doubles_average_point_wins( ( $original_player1->doubles_points_won / $original_player1->doubles_points_played ) * 100 )     : $original_player1->doubles_average_point_wins( 0 );
              $original_player2->doubles_points_played  ? $original_player2->doubles_average_point_wins( ( $original_player2->doubles_points_won / $original_player2->doubles_points_played ) * 100 )     : $original_player2->doubles_average_point_wins( 0 );
              
              # Do the actual update after everything's been calculated
              $original_doubles_pair->update;
              $original_player1->update;
              $original_player2->update;
            }
            
            my $player1_season = $doubles_pair->person1->find_related("person_seasons", {season => $season->id, team => $team->id});
            my $player2_season = $doubles_pair->person2->find_related("person_seasons", {season => $season->id, team => $team->id});
            
            # Now add those values on to the current doubles pair
            # Add one to the games played
            if ( $self->complete ) {
              $doubles_pair->games_played( $doubles_pair->games_played + 1 );
              $player1_season->doubles_games_played( $player1_season->doubles_games_played + 1 );
              $player2_season->doubles_games_played( $player2_season->doubles_games_played + 1 );
            }
            
            # Work out whether we need to take a game won, lost or drawn off
            if ( $self->complete and defined( $self->winner ) and $self->winner->id == $match->$location_team->id ) {
              # Game won
              $doubles_pair->games_won( $original_doubles_pair->games_won + 1 );
              $player1_season->doubles_games_won( $player1_season->doubles_games_won + 1 );
              $player2_season->doubles_games_won( $player2_season->doubles_games_won + 1 );
              
              # Change the winner
              $self->winner( $match->$location_team->id );
            } elsif ( $self->complete and defined( $self->winner ) and $self->winner->id != $match->$location_team->id ) {
              # Game lost
              $doubles_pair->games_lost( $original_doubles_pair->games_lost + 1 );
              $player1_season->doubles_games_lost( $player1_season->doubles_games_lost + 1 );
              $player2_season->doubles_games_lost( $player2_season->doubles_games_lost + 1 );
            } elsif ( $self->complete and !defined( $self->winner ) ) {
              # Game complete but no winner: draw (only relevant for games with a static number of legs)
              $doubles_pair->games_drawn( $original_doubles_pair->games_drawn + 1 );
              $player1_season->doubles_games_drawn( $player1_season->doubles_games_drawn + 1 );
              $player2_season->doubles_games_drawn( $player2_season->doubles_games_drawn + 1 );
            }
            
            # Take away the legs that have been played, won and lost in this game from the original pair
            # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
            # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
            $doubles_pair->legs_played( $doubles_pair->legs_played + ( $self->$team_legs_won + $self->$opposition_legs_won ) );
            $player1_season->doubles_legs_played( $player1_season->doubles_legs_played + ( $self->$team_legs_won + $self->$opposition_legs_won ) );
            $player2_season->doubles_legs_played( $player2_season->doubles_legs_played + ( $self->$team_legs_won + $self->$opposition_legs_won ) );
              
            $doubles_pair->legs_won( $doubles_pair->legs_won + $self->$team_legs_won );
            $player1_season->doubles_legs_won( $player1_season->doubles_legs_won + $self->$team_legs_won );
            $player2_season->doubles_legs_won( $player2_season->doubles_legs_won + $self->$team_legs_won );
            
            $doubles_pair->legs_lost( $doubles_pair->legs_lost + $self->$opposition_legs_won );
            $player1_season->doubles_legs_lost( $player1_season->doubles_legs_lost + $self->$opposition_legs_won );
            $player2_season->doubles_legs_lost( $player2_season->doubles_legs_lost + $self->$opposition_legs_won );
            
            # Take away the points that have been played, won and lost in this game from the original pair
            # In each game, we don't have a specific legs_played field, so we have to add the legs won for this team to the legs won for the opposition team,
            # then subtract that figure from the original legs_played value in the doubles pair, which will be the combination of all the legs they've played
            $doubles_pair->points_played( $doubles_pair->points_played + ( $self->$team_points_won + $self->$opposition_points_won ) );
            $player1_season->doubles_points_played( $player1_season->doubles_points_played + ( $self->$team_points_won + $self->$opposition_points_won ) );
            $player2_season->doubles_points_played( $player2_season->doubles_points_played + ( $self->$team_points_won + $self->$opposition_points_won ) );
            
            $doubles_pair->points_won( $doubles_pair->points_won + $self->$team_points_won );
            $player1_season->doubles_points_won( $player1_season->doubles_points_won + $self->$team_points_won );
            $player2_season->doubles_points_won( $player2_season->doubles_points_won + $self->$team_points_won );
            
            $doubles_pair->points_lost( $doubles_pair->points_lost + $self->$opposition_points_won );
            $player1_season->doubles_points_lost( $player1_season->doubles_points_lost + $self->$opposition_points_won );
            $player2_season->doubles_points_lost( $player2_season->doubles_points_lost + $self->$opposition_points_won );
            
            # Work out the averages again
            $doubles_pair->games_played             ? $doubles_pair->average_game_wins( ( $doubles_pair->games_won / $doubles_pair->games_played ) * 100 )                                  : $doubles_pair->average_game_wins( 0 );
            $player1_season->doubles_games_played   ? $player1_season->doubles_average_game_wins( ( $player1_season->doubles_games_won / $player1_season->doubles_games_played ) * 100 )    : $player1_season->doubles_average_game_wins( 0 );
            $player2_season->doubles_games_played   ? $player2_season->doubles_average_game_wins( ( $player2_season->doubles_games_won / $player2_season->doubles_games_played ) * 100 )    : $player2_season->doubles_average_game_wins( 0 );
            
            $doubles_pair->legs_played              ? $doubles_pair->average_leg_wins( ( $doubles_pair->legs_won / $doubles_pair->legs_played ) * 100 )                                     : $doubles_pair->average_leg_wins( 0 );
            $player1_season->doubles_legs_played    ? $player1_season->doubles_average_leg_wins( ( $player1_season->doubles_legs_won / $player1_season->doubles_legs_played ) * 100 )       : $player1_season->doubles_average_leg_wins( 0 );
            $player2_season->doubles_legs_played    ? $player2_season->doubles_average_leg_wins( ( $player2_season->doubles_legs_won / $player2_season->doubles_legs_played ) * 100 )       : $player2_season->doubles_average_leg_wins( 0 );
            
            $doubles_pair->points_played            ? $doubles_pair->average_point_wins( ( $doubles_pair->points_won / $doubles_pair->points_played ) * 100 )                               : $doubles_pair->average_point_wins( 0 );
            $player1_season->doubles_points_played  ? $player1_season->doubles_average_point_wins( ( $player1_season->doubles_points_won / $player1_season->doubles_points_played ) * 100 ) : $player1_season->doubles_average_point_wins( 0 );
            $player2_season->doubles_points_played  ? $player2_season->doubles_average_point_wins( ( $player2_season->doubles_points_won / $player2_season->doubles_points_played ) * 100 ) : $player2_season->doubles_average_point_wins( 0 );
            
            # Do the actual update after everything's been calculated
            $doubles_pair->update;
            $player1_season->update;
            $player2_season->update;
          }
          
          # Update our column if needed - we've already 'changed' the value, but not committed it
          $self->update;
          
          # Delete the original doubles pair IF:
          #  * There was a doubles pair set previously AND
          #  * it's different to the submitted doubles pair AND
          #  * there are no games played for the original doubles pair AND
          #  * either player for the original doubles pair are loan players
          $original_doubles_pair->delete if defined( $original_doubles_pair ) and $original_doubles_pair->id != $doubles_pair->id and $original_doubles_pair->games_played == 0 and ( $person1_loan or $person2_loan );
        } else {
          # Remove
          #print "Removing doubles pair.\n";
          if ( defined( $original_doubles_pair ) ) {
            # There is an original doubles pair, we need to delete the score
            $self->update_score({delete => 1});
            #print "Remove original score.\n";
          }
          
          # Delete the original doubles pair IF:
          #  * There was a doubles pair set previously AND
          #  * it's different to the submitted doubles pair AND
          #  * there are no games played for the original doubles pair AND
          #  * either player for the original doubles pair are loan players
          $original_doubles_pair->delete if defined( $original_doubles_pair ) and $original_doubles_pair->games_played == 0 and ( $original_doubles_pair->person1_loan or $original_doubles_pair->person2_loan );
          #print "Deleted doubles pair.\n" if defined( $original_doubles_pair ) and $original_doubles_pair->games_played == 0 and ( $original_doubles_pair->person1_loan or $original_doubles_pair->person2_loan );
        }
      } else {
        # Invalid location
        push(@{ $return_value->{error} }, {id => "matches.game.update-doubles.error.location-invalid"}); 
      }
    } else {
      # Error, game is not a doubles game.
      push(@{ $return_value->{error} }, {
        id          => "matches.game.update-doubles.error.not-doubles-game",
        parameters  => [$self->scheduled_game_number],
      });
    }
  }
  
  return $return_value;
}

=head2 result

Returns a hashref (keys: id = the msgid to use in maketext in the controller; parameters = an arrayref of parameters passed to maketext) denoting who won / lost / drew the game.

=cut

sub result {
  my ( $self ) = @_;
  my $return_value = {};
  my $match = $self->team_match;
  my ( $home_team, $away_team ) = ( $match->team_season_home_team_season, $match->team_season_away_team_season );
  
  # Game is complete, select the correct winner, home and away players and game type based on whether it's singles or doubles
  #my ( $winner, $home_player, $away_player, $game_type, $match_home_player, $match_away_player, $home_player_missing, $away_player_missing );
  my ( $home_player_missing, $away_player_missing );
  my $winner = defined( $self->winner ) ? $self->winner->id : undef;
  my $game_type = $self->doubles_game ? "doubles" : "singles";
  
  # Work out if the home / away player is missing
  if ( $self->doubles_game ) {
    # Players can't be missing in the doubles
    $home_player_missing  = 0;
    $away_player_missing  = 0;
  } else {
    $home_player_missing  = $match->find_related("team_match_players", {player_number => $self->home_player_number})->player_missing;
    $away_player_missing  = $match->find_related("team_match_players", {player_number => $self->away_player_number})->player_missing;
  }
  
  # Check if the game is complete
  if ( $self->complete ) {
    if ( defined( $winner ) and !$self->awarded ) {
      # There is a winner
      # Check if the winner is home or away
      if ( $winner == $home_team->team->id ) {
        # Home winner
        $return_value->{message} = {id => sprintf("matches.game.result.home-%s-win", $game_type)};
      } else {
        # Away winner
        $return_value->{message} = {id => sprintf("matches.game.result.away-%s-win", $game_type)};
      }
    } elsif ( !$self->awarded ) {
      # Either a draw, or we have a player missing
      if ( $home_player_missing or $away_player_missing ) {
        if ( $home_player_missing and $away_player_missing ) {
          # Both players missing
          $return_value->{message} = {id => "matches.game.result.both-players-missing"};
        } elsif ( $home_player_missing ) {
          # Home player missing
          $return_value->{message} = {id => "matches.game.result.home-player-missing"};
        } else {
          # Away player missing
          $return_value->{message} = {id => "matches.game.result.away-player-missing"};
        }
      } else {
        $return_value->{message} = {id => sprintf("matches.game.result.%s-draw", $game_type)};
      }
    } elsif ( $self->awarded ) {
      # Awarded - work out whether the game is started or not.
      my $leg1 = $self->find_related("team_match_legs", {leg_number => 1});
      
      if ( $leg1->started ) {
        if ( $winner == $home_team->id ) {
          # Home won, away player retired
          $return_value->{message} = {id => sprintf("matches.game.result.away-%s-player-retired", $game_type)};
        } else {
          # Away won, home player retired
          $return_value->{message} = {id => sprintf("matches.game.result.home-%s-player-retired", $game_type)};
        }
      } else {
        # If the game wasn't started, someone forefeited before it started
        if ( $home_player_missing and $away_player_missing ) {
          $return_value->{message} = {id => "matches.game.result.both-players-missing"};
        } elsif ( $home_player_missing ) {
          $return_value->{message} = {id => "matches.game.result.home-player-missing"};
        } elsif ( $away_player_missing ) {
          $return_value->{message} = {id => "matches.game.result.away-player-missing"};
        } else {
          if ( $winner == $home_team->id ) {
            # Home won, away player retired
            $return_value->{message} = {id => sprintf("matches.game.result.away-%s-player-forefeited", $game_type)};
          } else {
            # Away won, home player retired
            $return_value->{message} = {id => sprintf("matches.game.result.home-%s-player-forefeited", $game_type)};
          }
        }
      }
    }
  } else {
    # Game not yet played
    $return_value->{message} = {id => "matches.game.score.not-yet-updated"};
  }
  
  $return_value->{winner} = $winner;
  return $return_value;
}

=head2 summary_score

Returns a hashref with two keys ('home' and 'away'), which will have a value of the home and away team score for the game respectively.  If the match winner type is 'points', this will be the number of points each has won; otherwise it'll be legs.

=cut

sub summary_score {
  my ( $self ) = @_;
  
  if ( $self->team_match->team_match_template->winner_type->id eq "points" ) {
    # Return the number of points each has won
    return {
      home => $self->home_team_points_won,
      away => $self->away_team_points_won,
    };
  } else {
    # Return the number of legs each has won
    return {
      home => $self->home_team_legs_won,
      away => $self->away_team_legs_won,
    };
  }
}

=head2 detailed_scores

Returns an arrayref of leg scores.  Each array element has an hashref with keys 'home' and 'away'.

=cut

sub detailed_scores {
  my ( $self ) = @_;
  
  # Initialise the string we'll return
  my @scores = ();
  
  # Search for the legs
  my $legs = $self->search_related("team_match_legs", undef, {
    where  => [{
      home_team_points_won => {
        ">" => 0,
      }
    }, {
      away_team_points_won => {
        ">" => 0,
      }
    }],
    order_by => {
      -asc => "leg_number",
    },
  });
  
  # Loop through each leg
  if ( $legs->count ) {
    while ( my $leg = $legs->next ) {
      # Push this score on to the array
      #push(@scores, sprintf("%d-%d", $leg->home_team_points_won, $leg->away_team_points_won) );
      push(@scores, {leg_number => $leg->leg_number, home => $leg->home_team_points_won, away => $leg->away_team_points_won});
    }
    
    # Now return the values joined with ", "
    return \@scores;
  } else {
    # No legs with scores in yet
    return undef;
  }
}

=head2 home_player_season

Retrieve the person season object associated with the home player, season and home team that the match is associated with.

=cut

sub home_player_season {
  my ( $self ) = @_;
  my $match = $self->team_match;
  
  # Nothing to return if this is a doubles game
  return undef if $self->doubles_game;
  
  return $self->home_player->find_related("person_seasons", {
    season  => $match->season->id,
    team    => $match->team_season_home_team_season->team->id,
  }) if defined( $self->home_player );
}

=head2 away_player_season

Retrieve the person season object associated with the home player, season and home team that the match is associated with.

=cut

sub away_player_season {
  my ( $self ) = @_;
  my $match = $self->team_match;
  
  # Nothing to return if this is a doubles game
  return undef if $self->doubles_game;
  
  return $self->away_player->find_related("person_seasons", {
    season  => $match->season->id,
    team    => $match->team_season_away_team_season->team->id,
  }) if defined( $self->away_player );
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
