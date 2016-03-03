use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::MeetingTypes;

ok( request('/meetingtypes')->is_success, 'Request should succeed' );
done_testing();
