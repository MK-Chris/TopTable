use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::FixturesResults;

ok( request('/fixturesresults')->is_success, 'Request should succeed' );
done_testing();
