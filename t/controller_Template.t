use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Template;

ok( request('/template')->is_success, 'Request should succeed' );
done_testing();
