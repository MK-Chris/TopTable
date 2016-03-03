use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::FixturesGrid;

ok( request('/fixturesgrid')->is_success, 'Request should succeed' );
done_testing();
