use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Info::Officials::Positions;

ok( request('/info/officials/positions')->is_success, 'Request should succeed' );
done_testing();
