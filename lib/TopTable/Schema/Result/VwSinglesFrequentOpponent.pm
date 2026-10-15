package TopTable::Schema::Result::VwSinglesFrequentOpponent;

=head1 NAME

TopTable::Schema::Result::VwSinglesFrequentOpponent - a view to get frequent opponent information for people.

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

=head1 VIEW: C<vw_singles_frequent_opponents>

=cut

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table("vw_singles_frequent_opponents");
__PACKAGE__->result_source_instance->is_virtual(1);
__PACKAGE__->result_source_instance->view_definition(
  "WITH head_to_heads AS (
    SELECT 
        -- Determine Player 1 (Alphabetically first) and pull their data
        CASE WHEN p1.display_name < p2.display_name THEN p1.id ELSE p2.id END AS player1_id,
        CASE WHEN p1.display_name < p2.display_name THEN p1.url_key ELSE p2.url_key END AS player1_url_key,
        CASE WHEN p1.display_name < p2.display_name THEN p1.first_name ELSE p2.first_name END AS player1_first_name,
        CASE WHEN p1.display_name < p2.display_name THEN p1.surname ELSE p2.surname END AS player1_surname,
        CASE WHEN p1.display_name < p2.display_name THEN p1.display_name ELSE p2.display_name END AS player1_display_name,
        
        -- Determine Player 2 (Alphabetically second) and pull their data
        CASE WHEN p1.display_name < p2.display_name THEN p2.id ELSE p1.id END AS player2_id,
        CASE WHEN p1.display_name < p2.display_name THEN p2.url_key ELSE p1.url_key END AS player2_url_key,
        CASE WHEN p1.display_name < p2.display_name THEN p2.first_name ELSE p1.first_name END AS player2_first_name,
        CASE WHEN p1.display_name < p2.display_name THEN p2.surname ELSE p1.surname END AS player2_surname,
        CASE WHEN p1.display_name < p2.display_name THEN p2.display_name ELSE p1.display_name END AS player2_display_name
    FROM team_match_games tmg
    JOIN people p1 ON tmg.home_player = p1.id
    JOIN people p2 ON tmg.away_player = p2.id
)
SELECT 
  player1_id,
  player1_url_key,
  player1_first_name,
  player1_surname,
  player1_display_name,
  player2_id,
  player2_url_key,
  player2_first_name,
  player2_display_name,
  player2_surname,
  COUNT(*) AS total_games
FROM head_to_heads
GROUP BY 
  player1_id, player1_url_key, player1_display_name, player1_first_name, player1_surname,
  player2_id, player2_url_key, player2_display_name, player2_first_name, player2_surname
ORDER BY total_games DESC"
);

__PACKAGE__->add_columns(
  "player1_id" => {
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "player1_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "player1_first_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "player1_surname" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "player1_display_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301,
  },
  "player2_id" => {
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "player2_url_key" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 45,
  },
  "player2_first_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "player2_surname" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 150,
  },
  "player2_display_name" => {
    data_type => "varchar",
    is_nullable => 0,
    size => 301,
  },
  "total_games" => {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
);

__PACKAGE__->set_primary_key("player1_id", "player2_id");


1;