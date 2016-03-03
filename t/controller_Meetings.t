use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Meetings;

ok( request('/meetings')->is_success, 'Request should succeed' );
done_testing();
