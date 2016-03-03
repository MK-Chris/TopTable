use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Templates::Match;

ok( request('/templates/match')->is_success, 'Request should succeed' );
done_testing();
