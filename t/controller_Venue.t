use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Venue;

ok( request('/venue')->is_success, 'Request should succeed' );
done_testing();
