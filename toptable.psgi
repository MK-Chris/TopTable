use strict;
use warnings;

use TopTable;

my $app = TopTable->apply_default_middlewares(TopTable->psgi_app);
$app;

