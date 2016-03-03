use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Table;

ok( request('/table')->is_success, 'Request should succeed' );
done_testing();
