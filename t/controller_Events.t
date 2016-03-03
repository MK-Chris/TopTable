use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Events;

ok( request('/events')->is_success, 'Request should succeed' );
done_testing();
