use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Team;

ok( request('/team')->is_success, 'Request should succeed' );
done_testing();
