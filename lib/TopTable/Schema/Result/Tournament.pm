use utf8;
package TopTable::Schema::Result::Tournament;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

TopTable::Schema::Result::Tournament

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

=head1 TABLE: C<tournaments>

=cut

__PACKAGE__->table("tournaments");

=head1 ACCESSORS

=head2 event

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 season

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 entry_type

  data_type: 'varchar'
  is_foreign_key: 1
  is_nullable: 0
  size: 20

=head2 allow_online_entries

  data_type: 'tinyint'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 default_team_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 default_individual_match_template

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "event",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "season",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 100 },
  "entry_type",
  { data_type => "varchar", is_foreign_key => 1, is_nullable => 0, size => 20 },
  "allow_online_entries",
  {
    data_type => "tinyint",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "default_team_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "default_individual_match_template",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</event>

=item * L</season>

=back

=cut

__PACKAGE__->set_primary_key("event", "season");

=head1 RELATIONS

=head2 default_individual_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchIndividual>

=cut

__PACKAGE__->belongs_to(
  "default_individual_match_template",
  "TopTable::Schema::Result::TemplateMatchIndividual",
  { id => "default_individual_match_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 default_team_match_template

Type: belongs_to

Related object: L<TopTable::Schema::Result::TemplateMatchTeam>

=cut

__PACKAGE__->belongs_to(
  "default_team_match_template",
  "TopTable::Schema::Result::TemplateMatchTeam",
  { id => "default_team_match_template" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

=head2 entry_type

Type: belongs_to

Related object: L<TopTable::Schema::Result::LookupTournamentType>

=cut

__PACKAGE__->belongs_to(
  "entry_type",
  "TopTable::Schema::Result::LookupTournamentType",
  { id => "entry_type" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 event_season

Type: belongs_to

Related object: L<TopTable::Schema::Result::EventSeason>

=cut

__PACKAGE__->belongs_to(
  "event_season",
  "TopTable::Schema::Result::EventSeason",
  { event => "event", season => "season" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 tournament_people

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentPerson>

=cut

__PACKAGE__->has_many(
  "tournament_people",
  "TopTable::Schema::Result::TournamentPerson",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_rounds

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentRound>

=cut

__PACKAGE__->has_many(
  "tournament_rounds",
  "TopTable::Schema::Result::TournamentRound",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournament_teams

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentTeam>

=cut

__PACKAGE__->has_many(
  "tournament_teams",
  "TopTable::Schema::Result::TournamentTeam",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 tournaments_doubles

Type: has_many

Related object: L<TopTable::Schema::Result::TournamentDoubles>

=cut

__PACKAGE__->has_many(
  "tournaments_doubles",
  "TopTable::Schema::Result::TournamentDoubles",
  { "foreign.event" => "self.event", "foreign.season" => "self.season" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07051 @ 2024-09-29 23:47:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:v+jDIQqYSdXn1OKvjjkz8g
use HTML::Entities;

=head2 create_or_edit_round

Add or edit the given round number.  Should only be called by the application itself when adding - a round is never added manually.

=cut

sub create_or_edit_round {
  my $self = shift;
  my ( $round_number, $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $self->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $name = $params->{name} || undef;
  my $group = $params->{group} || 0;
  my $rank_template = $params->{rank_template} || undef;
  my $match_template = $params->{match_template} || undef;
  my $date = $params->{date};
  my $venue = $params->{venue};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {name => $name},
    completed => 0,
  };
  
  # Check there's the tournament is for the current season
  if ( $self->event_season->season->complete ) {
    push(@{$response->{errors}}, $lang->maketext("tournaments.round.form.error.season-not-current"));
  }
  
  # Check the round number, if given
  my ( $round, $create );
  if ( defined($round_number) ) {
    $create = 0;
    $round = $self->search_related("tournament_rounds", {round_number => $round_number});
    
    if ( !defined($round) ) {
      push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.round-doesnt-exist"));
      return $response; # fatal
    }
  } else {
    # If a round number wasn't passed in, we create a new round, 
    $create = 1;
    $round_number = $self->next_round_number;
  }
  
  # Round name check - can be null, as we can just use the round number instead.  Must be unique to the current tournament
  if ( $create ) {
    push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.round-name-exists", encode_entities($name))) if defined($name) and defined($schema->resultset("TournamentRound")->search_single_field($self, {field => "name", value => $name}));
  } else {
    push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.round-name-exists", encode_entities($name))) if defined($name) and defined($schema->resultset("TournamentRound")->search_single_field($self, {field => "name", value => $name, exclusion_obj => $round}));
  }
  
  
  
  # Sanity check, the group flag must be 1 or 0
  $group = $group ? 1 : 0;
  
  # Can't have a group round past round 1, but this is easy to fix, so raise it as a warning and set the flag to 0
  if ( $group and $round_number > 1 ) {
    push(@{$response->{warnings}}, $lang->maketext("tournaments.form.error.group-round-past-round1-not-allowed"));
    $group = 0;
  }
  
  if ( $group ) {
    # If it's a group round, we need a ranking template
    # Check the template
    if ( defined($rank_template) ) {
      $rank_template = $schema->resultset("TemplateLeagueTableRanking")->find($rank_template) unless $rank_template->isa("TopTable::Schema::Result::TemplateLeagueTableRanking");
      push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.group-round-invalid-rank-template")) unless defined($rank_template);
    } else {
      # No rank template
      push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.group-round-needs-rank-template"));
    }
  }
  
  # Get the class to check the template again based on whether this is a team entry or not
  my ( $tpl_class, $tpl_fld ) = $self->entry_type->id eq "team"
    ? qw( TemplateMatchTeam team_match_template )
    : qw( TemplateMatchIndividual individual_match_template );
  
  # Check the template
  if ( defined($match_template) ) {
    $match_template = $schema->resultset($tpl_class)->find($match_template) unless $match_template->isa("TopTable::Schema::Result::$tpl_class");
    push(@{$response->{errors}}, $lang->maketext("events.form.error.round.match-template-invalid")) unless defined($match_template);
  }
  
  # Check the date if it was sent
  if ( defined($date) ) {
    if ( ref($date) eq "HASH" ) {
      # Hashref, get the year, month, day
      my $year = $date->{year};
      my $month = $date->{month};
      my $day = $date->{day};
      
      # Make sure the date is valid
      try {
        $date = DateTime->new(
          year => $year,
          month => $month,
          day => $day,
        );
      } catch {
        push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.date-invalid"));
      };
    } elsif ( !$date->isa("DateTime") ) {
      # Not a hashref, not a DateTime
      push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.date-invalid"));
    }
  }
  
  # Check the venue if it was sent
  if ( defined($venue) ) {
    # Venue has been passed, make sure it's valid
    if ( !$venue->isa("TopTable::Schema::Result::Venue") ) {
      # Venue hasn't been passed in as an object, try and lookup as an ID / URL key
      $venue = $schema->resultset("Venue")->find_id_or_url_key($venue);
      push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.venue-invalid")) unless defined($venue);
    }
    
    # Now check the venue is active if we have one
    push(@{$response->{errors}}, $lang->maketext("tournaments.form.error.venue-inactive", encode_entities($venue->name))) if defined($venue) and !$venue->active;
  }
  
  
  if ( scalar(@{$response->{errors}}) == 0 ) {
    # Success, we need to create / edit the event
    # Build the key from the name
    my $url_key = $schema->resultset("TournamentRound")->make_url_key($self, $name, $round) if defined($name);
    
    if ( $create ) {
      $self->create_related("tournament_rounds", {
        url_key => $url_key,
        round_number => $round_number,
        name => $name,
        group_round => $group,
        rank_template => $rank_template,
        $tpl_fld => defined($match_template) ? $match_template->id : undef,
        date => defined($date) ? $date->ymd : undef,
        venue => defined($venue) ? $venue->id : undef,
      });
    } else {
      $round->update({
        url_key => $url_key,
        round_number => $round_number,
        name => $name,
        group_round => $group,
        $tpl_fld => defined($match_template) ? $match_template->id : undef,
        date => defined($date) ? $date->ymd : undef,
        venue => defined($venue) ? $venue->id : undef,
      });
    }
    
    $response->{completed} = 1;
  }
  
  return $response;
}

=head2 next_round_number

Return the next round number to be created.

=cut

sub next_round_number {
  my $self = shift;
  
  my $last_round_number = $self->search_related("tournament_rounds", {}, {
    columns => [{
      last_round_number => {max => "round_number"}
    }],
  })->single->get_column("last_round_number");
  
  # Next round number is either the last round number + 1, or round 1
  my $next_round_number = defined($last_round_number) ? $last_round_number + 1 : 1;
  
  # Return the date as a DateTime object if we have a result; if not return undef
  return $next_round_number;
}

=head2 has_group_round

Return 1 if the tournament has a group round, or 0 if not.  Group rounds can only be round 1.

=cut

sub has_group_round {
  my $self = shift;
  return $self->search_related("tournament_rounds", {group_round => 1})->count ? 1 : 0;
}

=head2 rounds

Return the rounds in round number order.

=cut

sub rounds {
  my $self = shift;
  return $self->search_related("tournament_rounds", {}, {
    order_by => {-asc => [qw( round_number )]}
  });
}

=head2 find_round_by_number_or_url_key

Get a specific round number, either by round number or URL key.

=cut

sub find_round_by_number_or_url_key {
  my $self = shift;
  my ( $round_id ) = @_;
  
  if ( $round_id =~ m/^\d+$/ ) {
    # Numeric value, check the ID first, then check the URL key
    my $obj = $self->find_related("tournament_rounds", {round_number => $round_id});
    return $obj if defined($obj);
    $obj = $self->find_related("tournament_rounds", {url_key => $round_id});
    return $obj;
  } else {
    # Not numeric, so it can't be the ID - just check the URL key
    return $self->find_related("tournament_rounds", {url_key => $round_id});
  }
}

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
