use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Match::Team::Game;

ok( request('/match/team/game')->is_success, 'Request should succeed' );
done_testing();
