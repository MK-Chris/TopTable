use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::League;

ok( request('/league')->is_success, 'Request should succeed' );
done_testing();
