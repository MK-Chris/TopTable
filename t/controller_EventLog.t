use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::EventLog;

ok( request('/eventlog')->is_success, 'Request should succeed' );
done_testing();
