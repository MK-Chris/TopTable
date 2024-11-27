package TopTable::Schema::Result::TeamMatchWeeksView;

=head1 NAME

TopTable::Schema::Result::TeamMatchCountsView

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

=head1 VIEW: C<club_teams>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("team_match_weeks");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "SELECT DATE_ADD(played_date, INTERVAL(-WEEKDAY(played_date)) DAY) AS played_week, COUNT(played_date) AS 'number_of_matches', s.id AS season_id, s.url_key AS season_url, s.`name` AS season_name
FROM team_matches m
JOIN seasons s ON m.season = s.id
GROUP BY played_week
ORDER BY played_date"
);

__PACKAGE__->add_columns(
  "played_week" => {
    data_type => "date",
    is_nullable => 0,
    size => 20,
    extra => { unsigned => 1 },
  },
  "number_of_matches" => {
    data_type => "integer",
    is_nullable => 0,
    size => 20,
  },
  "season_id" => {
    data_type => "integer",
    is_nullable => 0,
    size => 20,
  },
  "season_url" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "season_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
);

__PACKAGE__->set_primary_key("played_week");


1;