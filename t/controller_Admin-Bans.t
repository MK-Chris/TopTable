use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Admin::Bans;

ok( request('/admin/bans')->is_success, 'Request should succeed' );
done_testing();
