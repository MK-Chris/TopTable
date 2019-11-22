use utf8;
package TopTable::Schema::Result::TeamMatchPlayer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::TeamMatchPlayer

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

=head1 TABLE: C<team_match_players>

=cut

__PACKAGE__->table("team_match_players");

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

=head2 player_number

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

Releates to the internal player number (1-6 if there are three players per team)

=head2 location

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 10

Home or away

=head2 player

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 player_missing

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 loan_team

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

Team ID the player currently has active membership for so we know what was the active membership at the time of the match, even if that changes later on

=head2 games_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 games_drawn

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_played

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_won

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 legs_lost

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_leg_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_played

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_won

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 points_lost

  data_type: 'smallint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 average_point_wins

  data_type: 'float'
  default_value: 0
  extra: {unsigned => 1}
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
  {
    data_type => "date",
    datetime_undef_if_invalid => 1,
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "player_number",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "location",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 10 },
  "player",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "player_missing",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "loan_team",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "games_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "games_drawn",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_played",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_won",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "legs_lost",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_leg_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_played",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_won",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "points_lost",
  {
    data_type => "smallint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "average_point_wins",
  {
    data_type => "float",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</home_team>

=item * L</away_team>

=item * L</scheduled_date>

=item * L</player_number>

=back

=cut

__PACKAGE__->set_primary_key("home_team", "away_team", "scheduled_date", "player_number");

=head1 RELATIONS

=head2 loan_team

Type: belongs_to

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->belongs_to(
  "loan_team",
  "TopTable::Schema::Result::Team",
  { id => "loan_team" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 location

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupLocation>

=cut

__PACKAGE__->belongs_to(
  "location",
  "TopTable::Schema::Result::LookupLocation",
  { id => "location" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 player

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "player",
  "TopTable::Schema::Result::Person",
  { id => "player" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-05 21:08:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O7YJrUD6Xkn7BaqE0NQsyQ

=head2 update_person

Add or remove a person from this playing position.

=cut

sub update_person {
  my ( $self, $parameters ) = @_;
  my $action            = $parameters->{action} || "";
  my $loan_player       = $parameters->{loan_player} || 0;
  my $person            = $parameters->{person};
  my $location          = $self->location->id;
  my $match             = $self->team_match;
  my $return_value      = {error => []};
  my $log               = $parameters->{logger};
  my ( $active_season, $loan_team );
  my $originally_missing  = 0;
  my $game_scores_deleted = 0;
  
  # First check the match wasn't cancelled; if it was, we return straight away
  if ( $match->cancelled ) {
    push(@{ $return_value->{error} }, {id => "matches.update.error.match-cancelled"});
    return $return_value;
  }
  
  # Log the original person in case of errors
  my ( $original_id, $original_name );
  if ( defined( $self->player ) ) {
    $original_id    = $self->player->id;
    $original_name  = $self->player->display_name;
  } elsif ( $self->player_missing ) {
    $originally_missing = 1;
  }
  
  $return_value->{original_player} = {
    id          => $original_id,
    name        => $original_name,
    loan_team   => $self->loan_team,
  };
  
  # Check whether or not we have a person specified
  if ( $action eq "add" and defined( $person ) and ref( $person ) eq "TopTable::Model::DB::Person" ) {
    # If the person is available, get the season and division for this season
    $active_season = $person->find_related("person_seasons", {
      person                => $person->id,
      "me.season"           => $self->team_match->season->id,
      team_membership_type  => "active",
    }, {
      prefetch => {
        team => [
          "club", {
            "team_seasons" => "division"
          }
        ]
      },
      join => "team_membership_type",
      order_by => {
        -desc => "team_membership_type.display_order"
      },
    });
    
    if ( defined( $active_season ) ) {
      # Check it's active to be safe
      if ( $loan_player and ( $active_season->team->id == $self->team_match->home_team->id or $active_season->team->id == $self->team_match->away_team->id ) ) {
        # Can't use this person as a sub in a match involving their active team
        push(@{ $return_value->{error} }, {
          id          => "matches.loan-player.add.error.player-active-for-team",
          parameters  => [$person->display_name, $active_season->team->club->short_name, $active_season->team->name],
        });
      } else {
        # Check that we have not got this person set in a position for this match already
        my $player_already_set = $self->team_match->find_related("team_match_players", {}, {
          where => {
            player_number => {
              "!=" => $self->player_number,
            },
            player => $person->id,
          },
        });
        
        push(@{ $return_value->{error} }, {
          id          => "matches.add-player.error.player-already-set",
          parameters  => [$person->display_name, $player_already_set->player_number],
        }) if defined( $player_already_set );
      }
      
      # Get the loan player's active team if indeed it's a loan player
      $loan_team = $active_season->team if $loan_player;
    } else {
      # No teams for this person this season
      push(@{ $return_value->{error} }, {
        id          => "matches.loan-player.add.error.player-not-active",
        parameters  => [$person->display_name, $self->team_match->season->name],
      });
    }
  } elsif ( $action eq "add" ) {
    # Action is add but person is invalid
    push(@{ $return_value ->{error} }, {id => "matches.add-player.error.person-invalid"});
  } else {
    # Action is not add - make sure we undef the person, just in case it was passed
    undef( $person );
  }
  
  # Check if we got an error
  if ( scalar( @{ $return_value->{error} } ) == 0 ) {
    # Wrap all our database writing into a transaction
    my $transaction = $self->result_source->schema->txn_scope_guard;
    
    # Do the update here - if we get here, there are no errors, as we will have returned from the function after logging the error
    my $player_value = defined( $person ) ? $person->id : undef;
    
    # Since that updated okay, we need to search the games involving this player to see which ones have an opponent player set against them
    my $player_games = $match->search_related("team_match_games", { sprintf("%s_player_number", $location) => $self->player_number });
    
    # Loop through and check we have an opposition player for each game we've returned
    while( my $player_game = $player_games->next ) {
      my ( $opposition_location, $opposition_player );
      
      # Get the opposition player object
      if ( $location eq "home" ) {
        # If it's a home player, we need to check the away player number
        $opposition_player = $self->team_match->find_related("team_match_players", {
          player_number => $player_game->away_player_number,
        }, {
          prefetch => "player",
        });
        
        $opposition_location  = "away";
      } else {
        # Otherwise, we need to check the home player number
        $opposition_player = $self->team_match->find_related("team_match_players", {
          player_number => $player_game->home_player_number,
        }, {
          prefetch => "player",
        });
        
        $opposition_location  = "home";
      }
      
      # If we're removing a player, we need to zero their score for each game, as we can't have
      # scores without players.
      # If we're adding a player where they were previously missing, we also call the delete routine
      # to unvoid / award the game.
      if ( ( !defined( $person ) and !$originally_missing ) or ( defined( $person ) and $originally_missing ) ) {
        my $delete_result = $player_game->update_score({delete => 1});
        
        # Game scores are deleted, so the update_score() routine for each game will udpate the player_season statistics - flag this,
        # so we don't try and do it again.
        $game_scores_deleted = 1;
      }
      
      # Now we ensure the person objects are correct or are cleared - we have to do this after the above delete,
      # as that routine will fail if a player isn't set and in any case, it needs to know which person to subtract
      # the statistics from
      my $ok;
      if ( $action eq "add" and defined( $opposition_player->player ) and defined( $person ) ) {
        # If the opposition player is also set, then set both players to this game
        $ok = $player_game->update({
          sprintf("%s_player", $location)             => $person->id,
          sprintf("%s_player", $opposition_location)  => $opposition_player->player->id,
        });
      } else {
        # If the opposition player is not set, make sure we remove both players from this game if they are set.
        $ok = $player_game->update({
          home_player => undef,
          away_player => undef,
        });
      }
      
      push(@{ $return_value->{error} }, {
        id          => "matches.add-player.error.update-game-failed",
        parameters  => [$player_game->scheduled_game_number],
      }) unless $ok;
    }
    
    # We need to update the season statistics for both
    my ( $new_player_season );
    my $match_team_field = ( $location eq "home" ) ? "home_team" : "away_team";
    if ( defined( $person ) ) {
      # Look for a person_season row for this player, team and season; create one if it's not there.
      $new_player_season = $person->search_related("person_seasons", {
        season  => $match->season->id,
        team    => $match->$match_team_field->id,
      }, {
        rows    => 1,
      })->single;
      
      # Create a new season object for the new person if there isn't one already
      $new_player_season = $person->create_related("person_seasons", {
        season                => $self->team_match->season->id,
        team                  => $self->team_match->$match_team_field->id,
        team_membership_type  => "loan",
        first_name            => $person->first_name,
        surname               => $person->surname,
        display_name          => $person->display_name,
      }) unless defined( $new_player_season );
    }
    
    if ( defined( $self->player ) ) {
      # We have a player already, so we're replacing (or removing)
      if ( $match->started ) {
        # If the match has been started, we need to update the statistics
        my $original_player_season = $self->player->search_related("person_seasons", {
          season  => $match->season->id,
          team    => $match->$match_team_field->id,
        }, {
          rows    => 1,
        })->single;
        
        # Add a match played if the match has started
        $new_player_season->matches_played( $new_player_season->matches_played + 1 ) if defined $new_player_season;
        $original_player_season->matches_played( $original_player_season->matches_played - 1 );
        
        if ( $match->complete and !$game_scores_deleted ) {
          # Matches won / lost / drawn need to be worked out if the match is complete
          if ( $match->home_team_match_score > $match->away_team_match_score ) {
            # Home win
            if ( $location eq "home" ) {
              # Home player, add a match won to new, remove from old
              $original_player_season->matches_won( $original_player_season->matches_won - 1 );
              $new_player_season->matches_won( $new_player_season->matches_won + 1 ) if defined $new_player_season;
            } else {
              # Away player, add a match lost to new, remove from old
              $original_player_season->matches_lost( $original_player_season->matches_lost - 1 );
              $new_player_season->matches_lost( $new_player_season->matches_lost + 1 ) if defined $new_player_season;
            }
          } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
            # Away win
            if ( $location eq "home" ) {
              # Home player, add a match lost to new, remove from old
              $original_player_season->matches_lost( $original_player_season->matches_lost - 1 );
              $new_player_season->matches_lost( $new_player_season->matches_lost + 1 ) if defined $new_player_season;
            } else {
              # Away player, add a match won to new, remove from old
              $original_player_season->matches_won( $original_player_season->matches_won - 1 );
              $new_player_season->matches_won( $new_player_season->matches_won + 1 ) if defined $new_player_season;
            }
          } else {
            # Draw, regardless of home or away, add a match drawn to new, remove from old
            $original_player_season->matches_drawn( $original_player_season->matches_drawn - 1 );
            $new_player_season->matches_drawn( $new_player_season->matches_drawn + 1 ) if defined $new_player_season;
          }
        }
        
        if ( !$game_scores_deleted ) {
          # Transfer the games statistics
          $original_player_season->games_played( $original_player_season->games_played - $self->games_played );
          $new_player_season->games_played( $new_player_season->games_played + $self->games_played ) if defined $new_player_season;
          $original_player_season->games_won( $original_player_season->games_won - $self->games_won );
          $new_player_season->games_won( $new_player_season->games_won + $self->games_won ) if defined $new_player_season;
          $original_player_season->games_lost( $original_player_season->games_lost - $self->games_lost );
          $new_player_season->games_lost( $new_player_season->games_lost + $self->games_lost ) if defined $new_player_season;
          $original_player_season->games_drawn( $original_player_season->games_drawn - $self->games_drawn );
          $new_player_season->games_drawn( $new_player_season->games_drawn + $self->games_drawn ) if defined $new_player_season;
          
          # Transfer the legs statistics
          $original_player_season->legs_played( $original_player_season->legs_played - $self->legs_played );
          $new_player_season->legs_played( $new_player_season->legs_played + $self->legs_played ) if defined $new_player_season;
          $original_player_season->legs_won( $original_player_season->legs_won - $self->legs_won );
          $new_player_season->legs_won( $new_player_season->legs_won + $self->legs_won ) if defined $new_player_season;
          $original_player_season->legs_lost( $original_player_season->legs_lost - $self->legs_lost );
          $new_player_season->legs_lost( $new_player_season->legs_lost + $self->legs_lost ) if defined $new_player_season;
          
          # Transfer the points statistics
          $original_player_season->points_played( $original_player_season->points_played - $self->points_played );
          $new_player_season->points_played( $new_player_season->points_played + $self->points_played ) if defined $new_player_season;
          $original_player_season->points_won( $original_player_season->points_won - $self->points_won );
          $new_player_season->points_won( $new_player_season->points_won + $self->points_won ) if defined $new_player_season;
          $original_player_season->points_lost( $original_player_season->points_lost - $self->points_lost );
          $new_player_season->points_lost( $new_player_season->points_lost + $self->points_lost ) if defined $new_player_season;
          
          # Work out the averages
          $original_player_season->games_played ? $original_player_season->average_game_wins( ( $original_player_season->games_won / $original_player_season->games_played ) * 100 )  : $original_player_season->average_game_wins( 0 );
          defined( $new_player_season ) and $new_player_season->games_played ? $new_player_season->average_game_wins( ( $new_player_season->games_won / $new_player_season->games_played ) * 100 ) : $new_player_season->average_game_wins( 0 );
          
          $original_player_season->legs_played ? $original_player_season->average_leg_wins( ( $original_player_season->legs_won / $original_player_season->legs_played ) * 100 )  : $original_player_season->average_leg_wins( 0 );
          defined( $new_player_season ) and $new_player_season->legs_played ? $new_player_season->average_leg_wins( ( $new_player_season->legs_won / $new_player_season->legs_played ) * 100 ) : $new_player_season->average_leg_wins( 0 );
          
          $original_player_season->points_played ? $original_player_season->average_point_wins( ( $original_player_season->points_won / $original_player_season->points_played ) * 100 )  : $original_player_season->average_point_wins( 0 );
          defined( $new_player_season ) and $new_player_season->points_played ? $new_player_season->average_point_wins( ( $new_player_season->points_won / $new_player_season->points_played ) * 100 ) : $new_player_season->average_point_wins( 0 );
        }
          
        # Now do the updates.  The exception is if the original player was a loan player and this is the only match
        # they were down as playing for the team, their record for this team will be deleted, as it's blank anyway.
        
        # These are updated regardless of whether or not the scores were deleted earlier, as we still may need to add / remove a match played from the players being swapped.
        $new_player_season->update if defined $new_player_season;
        
        if ( $original_player_season->matches_played == 0 and $original_player_season->team_membership_type eq "loan" ) {
          $original_player_season->delete;
        } else {
          $original_player_season->update;
        }
      }
    } elsif ( $match->started ) {
      # We're adding a player where there wasn't previously one (we don't do this for the other way round - removing a player where
      # there was previously one - as that's already handled above by the score deletion).
      
      # Search for the player's season object with this team and create it if it isn't there.
      my $match_team_field = ( $location eq "home" ) ? "home_team" : "away_team";
      
      my $new_player_season = $person->search_related("person_seasons", {
        season  => $match->season->id,
        team    => $match->$match_team_field->id,
      }, {
        rows    => 1,
      })->single;
      
      # Create a new season object for the new person if there isn't one already
      $new_player_season = $person->create_related("person_seasons", {
        season                => $self->team_match->season->id,
        team                  => $self->team_match->$match_team_field->id,
        team_membership_type  => "loan"
      }) unless defined( $new_player_season );
      
      $new_player_season->update({matches_played => $new_player_season->matches_played + 1});
      
      if ( $match->complete ) {
        # Matches won / lost / drawn need to be worked out if the match is complete
        if ( $match->home_team_match_score > $match->away_team_match_score ) {
          # Home win
          if ( $location eq "home" ) {
            # Home player, add a match won to new, remove from old
            $new_player_season->matches_won( $new_player_season->matches_won + 1 ) if defined $new_player_season;
          } else {
            # Away player, add a match lost to new, remove from old
            $new_player_season->matches_lost( $new_player_season->matches_lost + 1 ) if defined $new_player_season;
          }
        } elsif ( $match->home_team_match_score < $match->away_team_match_score ) {
          # Away win
          if ( $location eq "home" ) {
            # Home player, add a match lost to new, remove from old
            $new_player_season->matches_lost( $new_player_season->matches_lost + 1 ) if defined $new_player_season;
          } else {
            # Away player, add a match won to new, remove from old
            $new_player_season->matches_won( $new_player_season->matches_won + 1 ) if defined $new_player_season;
          }
        } else {
          # Draw, regardless of home or away, add a match drawn to new, remove from old
          $new_player_season->matches_drawn( $new_player_season->matches_drawn + 1 ) if defined $new_player_season;
        }
      }
    }
    
    # Finally do the update of the person in the match itself
    my $player_missing;
    if ( $action eq "set-missing" ) {
      undef( $loan_team ); # Can't be a loan player if we're setting a missing player
      $player_missing     = 1;
    } else {
      $player_missing     = 0;
    }
    
    my $ok = $self->update({
      player            => $player_value,
      loan_team         => $loan_team,
      player_missing    => $player_missing,
    });
    
    push(@{ $return_value->{error} }, {id => "matches.add-player.error.update-failed"}) unless $ok;
    
    if ( scalar( @{ $return_value->{error} } ) == 0 ) {
      # Go back to the first game - we are going to update the score for each, but couldn't do it in the first loop because we need to remove the person
      # and set the 'missing' flag first (and we can't move that previous loop down here because that would mean we were potentially doing a score deletion
      # after removing the original player, which wouldn't work, as the routine needs to know which player to take the statistics from).
      
      # Note we don't provide scores, as these games aren't actually played, we merely tell the routine to update and it calculates the match scores knowing that
      # one or other of the players are missing.
      $player_games->reset;
      while( my $player_game = $player_games->next ) {
        # Get the opposition player to find out if they're missing
        my ( $opposition_location, $opposition_player );
        
        # Get the opposition player object
        if ( $location eq "home" ) {
          # If it's a home player, we need to check the away player number
          $opposition_player = $self->team_match->find_related("team_match_players", {
            player_number => $player_game->away_player_number,
          }, {
            prefetch => "player",
          });
          
          $opposition_location  = "away";
        } else {
          # Otherwise, we need to check the home player number
          $opposition_player = $self->team_match->find_related("team_match_players", {
            player_number => $player_game->home_player_number,
          }, {
            prefetch => "player",
          });
          
          $opposition_location  = "home";
        }
        
        # Update the score here if either player is missing
        my $update_result = $player_game->update_score if $action eq "set-missing" or $opposition_player->player_missing;
      }
      
      # Get the games involving this player that also have another player involved
      my $return_player_games = [];
      my @player_games = $player_games->all;
      foreach my $game ( @player_games ) {
        push ( @{ $return_player_games }, $game->scheduled_game_number ) if defined( $game->home_player ) and defined( $game->away_player );
      }
      
      $return_value->{player_games} = $return_player_games;
    }
    
    # Finally commit the transaction if there are no errors
    $transaction->commit;
  }
  
  return $return_value;
}

=head2 loan_team_season

Retrieve the season object for a loan player's team if this player has been loaned.

=cut

sub loan_team_season {
  my ( $self ) = @_;
  
  # Return with undefined if the player isn't a loan player
  return undef unless defined( $self->loan_team );
  
  my $match = $self->team_match;
  
  # Otherwise, retrieve the season 
  return $self->loan_team->find_related("team_seasons", {
    season => $match->season->id,
    "division_seasons.season" => $match->season->id,
  }, {
    prefetch => [
      "club", {
      division => "division_seasons",
    }],
  });
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
