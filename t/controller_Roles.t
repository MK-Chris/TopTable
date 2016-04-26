use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Roles;

ok( request('/roles')->is_success, 'Request should succeed' );
done_testing();
