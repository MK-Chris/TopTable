use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Admin::Ban;

ok( request('/admin/ban')->is_success, 'Request should succeed' );
done_testing();
