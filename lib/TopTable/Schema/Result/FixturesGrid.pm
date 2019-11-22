use utf8;
package TopTable::Schema::Result::FixturesGrid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::FixturesGrid

=head1 DESCRIPTION

There is not a lot to put in this table, its just something for other tables (i.e., grid cells) to link back to...

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

=head1 TABLE: C<fixtures_grids>

=cut

__PACKAGE__->table("fixtures_grids");

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
  size: 45

=head2 maximum_teams

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 fixtures_repeated

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 0

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
  { data_type => "varchar", is_nullable => 0, size => 45 },
  "maximum_teams",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
  "fixtures_repeated",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 0 },
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

=head2 division_seasons

Type: has_many

Related object: L<TopTable::Schema::Result::DivisionSeason>

=cut

__PACKAGE__->has_many(
  "division_seasons",
  "TopTable::Schema::Result::DivisionSeason",
  { "foreign.fixtures_grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 fixtures_grid_weeks

Type: has_many

Related object: L<TopTable::Schema::Result::FixturesGridWeek>

=cut

__PACKAGE__->has_many(
  "fixtures_grid_weeks",
  "TopTable::Schema::Result::FixturesGridWeek",
  { "foreign.grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 system_event_log_fixtures_grids

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogFixturesGrid>

=cut

__PACKAGE__->has_many(
  "system_event_log_fixtures_grids",
  "TopTable::Schema::Result::SystemEventLogFixturesGrid",
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
  { "foreign.fixtures_grid" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-10-20 22:46:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IWsmGw4NKh1o+Pw5KJLNmA

=head2 can_delete

Checks to see whether a fixtures grid can be deleted.  A fixtures grid can be deleted if there are no matches and no divisions assigned to it.

=cut

sub can_delete {
  my ( $self ) = @_;
  
  # First check the divisions - this is quicker than matches, as there are lots of matches to check
  my $divisions = $self->search_related("division_seasons")->count;
  return 0 if $divisions;
  
  my $matches = $self->search_related("team_matches")->count;
  return 0 if $matches;
  
  # If we get this far, we can delete
  return 1;
}

=head2 check_and_delete

Process the deletion of the grid; checks that we're able to do this first (via can_delete).

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
    
  # Check we can delete
  #seasons.delete.error.matches-exist
  push(@{ $error }, {
    id          => "fixtures-grids.delete.error.cant-delete",
    parameters  => $self->name,
  }) if !$self->can_delete;
  
  # Delete
  my $ok = $self->delete if !$error;
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) if !$ok;
  
  return $error;
}

=head2 can_create_fixtures

Checks that all the requirements are in place to create the fixtures.  (i.e., the grid matches and team position numbers are filled out and there are no fixtures created for this grid already).

=cut

sub can_create_fixtures {
  my ( $self ) = @_;
  
  # First check the matches have been filled out
  my $incomplete_grid_matches = $self->search_related("fixtures_grid_weeks", [{
    "fixtures_grid_matches.home_team" => undef,
    "fixtures_grid_matches.away_team" => undef,
  }], {
    join => "fixtures_grid_matches",
  })->count;
  
  return 0 if $incomplete_grid_matches;
  
  # Next check the team position numbers have been filled out
  my $incomplete_team_positions = $self->search_related("division_seasons", {
    "team_seasons.grid_position"  => undef,
    "season.complete"             => 0,
  }, {
    join => {
      season => "team_seasons",
    },
  })->count;
  
  return 0 if $incomplete_team_positions;
  
  # If we get this far, we need to check if fixtures have been created
  my $matches = $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
  
  return 0 if $matches;
  
  # If we get this far, we can create
  return 1;
}

=head2 can_delete_fixtures

Checks to see whether the fixtures for the current season that have been created by this grid are able to be deleted.  This is basically if there are no scores filled out for any matches.

=cut

sub can_delete_fixtures {
  my ( $self ) = @_;
  
  my $total_matches = $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
  
  # If there are no matches, we will just return false, as there's nothing to delete
  return 0 if !$total_matches;
  
  my $matches = $self->search_related("team_matches", {
    -and => {
      "season.complete" => 0,
    }, -or => [{
      home_team_games_won => {
        ">" => 0,
      }
    }, {
      home_team_games_lost => {
        ">" => 0,
      }
    }, {
      home_team_legs_won => {
        ">" => 0,
      }
    }, {
      home_team_points_won => {
        ">" => 0,
      }
    }, {
      away_team_games_won => {
        ">" => 0,
      }
    }, {
      away_team_games_lost => {
        ">" => 0,
      }
    }, {
      away_team_legs_won => {
        ">" => 0,
      }
    }, {
      away_team_points_won => {
        ">" => 0,
      }
    }, {
      games_drawn => {
        ">" => 0,
      }
    }]
  }, {
    join => "season",
  })->count;
  
  # Return 1 if the number of matches with any scores in is zero, otherwise zero
  return ( $matches == 0 ) ? 1 : 0;
}

=head2 delete_fixtures

Deletes the fixtures for the grid in the current season (so long as they are able to be deleted - this is checked with can_delete_fixtures).

=cut

sub delete_fixtures {
  my ( $self ) = @_;
  my $return_value = {error => []};
  
  if ( $self->can_delete_fixtures ) {
    my @rows_to_delete = $self->search_related("team_matches", {
      "season.complete" => 0,
    }, {
      join => "season",
    })->all;
    
    # These arrays will be used in event log creation
    my ( @match_names, @match_ids );
    
    if ( scalar( @rows_to_delete ) ) {
      foreach my $match ( @rows_to_delete ) {
        push(@match_ids, {
          home_team       => undef,
          away_team       => undef,
          scheduled_date  => undef,
        });
        
        push( @match_names, sprintf( "%s %s v %s %s (%s)", $match->home_team->club->short_name, $match->home_team->name, $match->away_team->club->short_name, $match->away_team->name, $match->scheduled_date->dmy("/") ) );
      }
      
      my $ok = $self->search_related("team_matches", {
        "season.complete" => 0,
      }, {
        join => "season",
      })->delete;
      
      if ( $ok ) {
        # Deleted ok
        $return_value->{match_names}  = \@match_names;
        $return_value->{match_ids}    = \@match_ids;
        $return_value->{rows}         = $ok;
      } else {
        # Not okay, log an error
        push(@{ $return_value->{error} }, {id => "fixtures-grids.form.delete-fixtures.error.delete-failed"});
      }
    } else {
      $return_value->{rows} = 0;
    }
  } else {
    push(@{ $return_value->{error} }, {
      id          => "fixtures-grids.form.delete-fixtures.error.cant-delete",
      parameters  => [$self->name],
    });
  }
  
  return $return_value;
}

=head2 matches_in_current_season

Returns the number of matches in the current season (defined as the season with a 'complete' value of zero).

=cut

sub matches_in_current_season {
  my ( $self ) = @_;
  
  return $self->search_related("team_matches", {
    "season.complete" => 0,
  }, {
    join => "season",
  })->count;
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
