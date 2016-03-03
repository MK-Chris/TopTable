use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Info::ContactReasons;

ok( request('/info/contactreasons')->is_success, 'Request should succeed' );
done_testing();
