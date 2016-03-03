use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::Template::TeamMatch;

ok( request('/template/teammatch')->is_success, 'Request should succeed' );
done_testing();
