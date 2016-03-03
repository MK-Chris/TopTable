use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Match::Team::Player;

ok( request('/match/team/player')->is_success, 'Request should succeed' );
done_testing();
