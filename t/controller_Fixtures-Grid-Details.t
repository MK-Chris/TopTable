use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Fixtures::Grid::Details;

ok( request('/fixtures/grid/details')->is_success, 'Request should succeed' );
done_testing();
