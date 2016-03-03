use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Tournaments;

ok( request('/tournaments')->is_success, 'Request should succeed' );
done_testing();
