use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::News;

ok( request('/news')->is_success, 'Request should succeed' );
done_testing();
