use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Info;

ok( request('/info')->is_success, 'Request should succeed' );
done_testing();
