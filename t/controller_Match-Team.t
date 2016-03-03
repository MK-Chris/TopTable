use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Match::Team;

ok( request('/match/team')->is_success, 'Request should succeed' );
done_testing();
