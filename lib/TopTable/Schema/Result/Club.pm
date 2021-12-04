use utf8;
package TopTable::Schema::Result::Club;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Club

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

=head1 TABLE: C<clubs>

=cut

__PACKAGE__->table("clubs");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 url_key

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 full_name

  data_type: 'varchar'
  is_nullable: 0
  size: 300

=head2 short_name

  data_type: 'varchar'
  is_nullable: 0
  size: 150

=head2 venue

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 secretary

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 email_address

  data_type: 'varchar'
  is_nullable: 1
  size: 200

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 facebook

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 twitter

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 instagram

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 youtube

  data_type: 'varchar'
  is_nullable: 1
  size: 2083

=head2 default_match_start

  data_type: 'time'
  is_nullable: 1

=head2 abbreviated_name

  data_type: 'varchar'
  is_nullable: 0
  size: 20

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
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "full_name",
  { data_type => "varchar", is_nullable => 0, size => 300 },
  "short_name",
  { data_type => "varchar", is_nullable => 0, size => 150 },
  "venue",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "secretary",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "email_address",
  { data_type => "varchar", is_nullable => 1, size => 200 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "facebook",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "twitter",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "instagram",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "youtube",
  { data_type => "varchar", is_nullable => 1, size => 2083 },
  "default_match_start",
  { data_type => "time", is_nullable => 1 },
  "abbreviated_name",
  { data_type => "varchar", is_nullable => 0, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<abbreviated_name>

=over 4

=item * L</abbreviated_name>

=back

=cut

__PACKAGE__->add_unique_constraint("abbreviated_name", ["abbreviated_name"]);

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
  { "foreign.club" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 secretary

Type: belongs_to

Related object: L<TopTable::Schema::Result::Person>

=cut

__PACKAGE__->belongs_to(
  "secretary",
  "TopTable::Schema::Result::Person",
  { id => "secretary" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "SET NULL",
    on_update     => "RESTRICT",
  },
);

=head2 system_event_log_clubs

Type: has_many

Related object: L<TopTable::Schema::Result::SystemEventLogClub>

=cut

__PACKAGE__->has_many(
  "system_event_log_clubs",
  "TopTable::Schema::Result::SystemEventLogClub",
  { "foreign.object_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 teams

Type: has_many

Related object: L<TopTable::Schema::Result::Team>

=cut

__PACKAGE__->has_many(
  "teams",
  "TopTable::Schema::Result::Team",
  { "foreign.club" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07049 @ 2020-02-25 14:03:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+Yc7CDZg1S/4z4MftGCdJw

=head2 url_keys

Return the URL key for this object as an array ref (even if there's only one, an array ref is necessary so we can do the same for other objects with more than one array key field).

=cut

sub url_keys {
  my ( $self ) = @_;
  return [ $self->url_key ];
}


=head2 get_season

Get a club_season object for this club with the specified season.

=cut

sub get_season {
  my ( $self, $season ) = @_;
  
  return undef unless defined ( $season );
  
  return $self->find_related("club_seasons", {
    season => $season->id,
  });
}

=head2 get_seasons

Get club_seasons for this club (all seasons this club has entered).

=cut

sub get_seasons {
  my ( $self, $parameters ) = @_;
  my $page_number       = $parameters->{page_number}      || undef;
  my $results_per_page  = $parameters->{results_per_page} || undef;
  
  my $attributes = {
    prefetch => "season",
    page      => $page_number,
    rows      => $results_per_page,
    order_by => [{
      -asc => [
        qw( season.complete )
      ]}, {
      -desc => [
        qw( season.start_date season.end_date )
      ]}
    ],
  };
  
  if ( defined( $page_number ) or defined( $results_per_page ) ) {
    # If either page number of results per page is defined, set the other to a default (page 1, 25 results).  Also sanitise if they're not numeric
    $page_number      = 1 unless defined( $page_number ) or $page_number !~ /^\d+$/;
    $results_per_page = 25 unless defined( $results_per_page ) or $results_per_page !~ /^\d+$/;
    
    $attributes->{page} = $page_number;
    $attributes->{rows} = $results_per_page;
  }
  
  return $self->search_related("club_seasons", undef, $attributes);
}

=head2 get_team_seasons

Retrieve team_seasons related to this club.

=cut

sub get_team_seasons {
  my ( $self, $parameters ) = @_;
  my $season = $parameters->{season} || undef;
  
  my $query = ( defined( $season ) ) ? {"me.season" => $season->id} : undef;
  
  return $self->search_related("club_seasons", $query, {
    prefetch  => "season",
    group_by  => [qw( season )],
  })->search_related("team_seasons", $query, {
    prefetch  => "season",
    group_by  => [qw( season )],
  });
}


=head2 can_delete

Performs the checks we need to ensure the club is deletable (i.e., has no teams).

=cut

sub can_delete {
  my ( $self ) = @_;
  
  my $teams = $self->search_related("club_seasons")->search_related("team_seasons")->count;
  
  # Return true if the number of teams is zero, otherwise false.
  return ( $teams == 0 ) ? 1 : 0;
}

=head2 check_and_delete

Checks the club can be deleted (via can_delete) and then performs the deletion.

=cut

sub check_and_delete {
  my ( $self ) = @_;
  my $error = [];
  
  # Check we can delete
  push(@{ $error }, {
    id          => "clubs.delete.error.cannot-delete",
    parameters  => [$self->name],
  }) unless $self->can_delete;
  
  # Delete
  my $ok = $self->delete unless scalar( @{ $error } );
  
  # Error if the delete was unsuccessful
  push(@{ $error }, {
    id          => "admin.delete.error.database",
    parameters  => $self->name
  }) unless $ok;
  
  return $error;
}

=head2 last_season_entered

Return the last season this club entered.

=cut

sub last_season_entered {
  my ( $self ) = @_;
  
  my $club_season = $self->search_related("club_seasons", undef, {
    join => "season",
    rows => 1,
    order_by => {
      -desc => [qw( season.start_date season.end_date )]
    },
  })->single;
  
  return defined( $club_season ) ? $club_season->season : undef;
}

=head2 teams_in_club

Return the current list of teams (or, at least, the teams for the last season entered).

=cut

sub teams_in_club {
  my ( $self, $params ) = @_;
  my ( $where, $sort_hash );
  my $season      = $params->{season} || undef;
  my $sort_column = $params->{sort};
  my $order       = $params->{order};
  
  # Sanitist the sort order
  $sort_column  = "name" unless defined( $sort_column ) and ( $sort_column eq "name" or $sort_column eq "captain" or $sort_column eq "division" or $sort_column eq "home-night" );
  $order        = "asc" unless defined( $order ) and ( $order eq "asc" or $order eq "desc" );
  $order        = "-$order"; # The 'order_by' hash key needs to start with a '-'
  
  # If there's no season specified, we won't have a captain, a division or a home night, so we must just be sorting by name
  $sort_column = "name" unless defined( $season );
  
  # Build the hashref that will give us the database columns to sort by
  my %db_columns = (
    name => [ qw( me.name ) ],
    captain => [ qw( captain.surname captain.first_name ) ],
    division => [ qw( division.rank ) ],
    "home-night" => [ qw( home_night.weekday_number ) ],
  );
  
  # Build the sort hash
  my $sort_instruction = {
    $order => $db_columns{$sort_column},
  };
  
  # Add an ascending team name search to the sort hash if the primary sort isn't by name
  if ( $sort_column ne "name" ) {
    if ( $sort_column eq "-asc" ) {
      # We're doing an ascending sort already, so just push "me.name" on to it
      push( @{ $sort_instruction->{$order} }, "me.name" );
    } else {
      # The primary sort is descending, so we need to make the sort hash an array
      $sort_instruction = [ $sort_instruction, {-asc => "me.name"} ];
    }
  }
  
  if ( defined( $season ) ) {
    # We have a season passed in, so we need to go through club_seasons and team_seasons
    my $club_season = $self->search_related("club_seasons", {
      season => $season->id
    }, {
      rows => 1,
    })->single;
    
    return undef unless defined( $club_season );
    
    return $club_season->search_related("team_seasons", undef, {
      prefetch  => ["season", "captain", "home_night", {division_season => "division"}],
      order_by  => $sort_instruction,
    });
    
  } else {
    # No season defined, just search the currently registered teams
    return $self->search_related("teams", undef, {
      prefetch  => {
        "team_seasons" => ["season", "captain", "home_night", {division_season => "division", club_season => "club"}],
      },
      order_by  => [{
        -asc   => ["me.name"]
      }, {
        -desc  => [ qw( season.start_date season.end_date) ]
      }]
    });
  }
}

=head2 players_in_club

Return a list of players who play for this club (in the given season if specified, otherwise just a list of players currently registered).

=cut

sub players_in_club {
  my ( $self, $params ) = @_;
  my $season = $params->{season} || undef;
  my ( $where, $attrib );
  
  # Get a list of teams, then map the IDs into the array
  if ( defined( $season ) ) {
    $where = {"team_seasons.season" => $season->id};
    $attrib = {join => "team_seasons"};
  }
  
  my @teams = $self->search_related("teams", $where, $attrib);
  my @team_ids = map( $_->id , @teams );
  
  if ( defined( $season ) ) {
    $where = {
      "person_seasons.team" => {-in => \@team_ids},
      "person_seasons.season" => $season->id,
    };
    
    $attrib = {
      join => "person_seasons",
    };
  } else {
    $where = {
      team => {-in => \@team_ids},
    };
    
    undef( $attrib );
  }
  
  return $self->result_source->schema->resultset("Person")->search( $where, $attrib );
}

=head2 search_display

Function in all searchable objects to give a common accessor to the text to display. 

=cut

sub search_display {
  my ( $self, $params ) = @_;
  
  return {
    id => $self->id,
    name => $self->full_name,
    url_keys => $self->url_keys,
    type => "club"
  };
}


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
