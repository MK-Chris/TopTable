use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Match::Individual;

ok( request('/match/individual')->is_success, 'Request should succeed' );
done_testing();
