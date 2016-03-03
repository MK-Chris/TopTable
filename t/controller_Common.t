use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Common;

ok( request('/common')->is_success, 'Request should succeed' );
done_testing();
