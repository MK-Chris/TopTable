use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Club;

ok( request('/club')->is_success, 'Request should succeed' );
done_testing();
