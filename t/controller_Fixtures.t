use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Fixtures;

ok( request('/fixtures')->is_success, 'Request should succeed' );
done_testing();
