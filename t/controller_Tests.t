use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Tests;

ok( request('/tests')->is_success, 'Request should succeed' );
done_testing();
