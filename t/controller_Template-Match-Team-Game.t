use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Template::Match::Team::Game;

ok( request('/template/match/team/game')->is_success, 'Request should succeed' );
done_testing();
