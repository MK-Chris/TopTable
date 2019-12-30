use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/lib";
use TopTable;

my $app = TopTable->apply_default_middlewares(TopTable->psgi_app);
$app;

