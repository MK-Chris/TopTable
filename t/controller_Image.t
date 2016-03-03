use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Image;

ok( request('/image')->is_success, 'Request should succeed' );
done_testing();
