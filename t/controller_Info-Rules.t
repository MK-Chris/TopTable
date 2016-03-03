use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Info::Rules;

ok( request('/info/rules')->is_success, 'Request should succeed' );
done_testing();
