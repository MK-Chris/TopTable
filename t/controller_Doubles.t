use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Doubles;

ok( request('/doubles')->is_success, 'Request should succeed' );
done_testing();
