use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::UsersOnline;

ok( request('/usersonline')->is_success, 'Request should succeed' );
done_testing();
