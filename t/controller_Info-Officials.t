use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Info::Officials;

ok( request('/info/officials')->is_success, 'Request should succeed' );
done_testing();
