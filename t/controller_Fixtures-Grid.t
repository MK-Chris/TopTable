use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Fixtures::Grid;

ok( request('/fixtures/grid')->is_success, 'Request should succeed' );
done_testing();
