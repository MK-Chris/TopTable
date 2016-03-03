use strict;
use warnings;
use Test::More;


use Catalyst::Test 'TopTable';
use TopTable::Controller::MatchTemplate;

ok( request('/matchtemplate')->is_success, 'Request should succeed' );
done_testing();
