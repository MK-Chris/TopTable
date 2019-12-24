#!/usr/local/bin/perl
 
use strict;
use warnings;
 
use feature ":5.10";

use aliased 'DBIx::Class::DeploymentHandler' => 'DH';
use FindBin;
use lib "$FindBin::Bin/../lib";
use TopTable::Schema;
use Config::ZOMG;
use Data::Dumper::Concise;
 
my $config = Config::ZOMG->new( name => 'TopTable' );
my $config_hash  = $config->load;
my $connect_info = $config_hash->{"Model::DB"}{"connect_info"};
my $schema       = TopTable::Schema->connect($connect_info);
 
my $dh = DH->new({
  schema           => $schema,
  script_directory => "$FindBin::Bin/../dbicdh",
  databases        => 'MySQL',
});

$dh->prepare_install;

#my @monikers = sort $schema->sources;
#print join("\n", @monikers);
#my $source = $schema->source("User");
#my $table_name = $source->name;

#printf "%s\n%s\n", $source, $table_name;

#foreach my $col ($source->columns) {
#  my %colinfo = (
#    name => $col,
#    size => 0,
#    is_auto_increment => 0,
#    is_foreign_key => 0,
#    is_nullable => 0,
#    %{$source->column_info($col)}
#  );
#  
#  if ($colinfo{is_nullable}) {
#    $colinfo{default} = '' unless exists $colinfo{default};
#  }
#    
#  my $table = SQL::Translator::Schema::Table->new(
#   name => $table_name,
#   type => 'TABLE',
#  );
#    
#  my $f = $table->add_field(%colinfo) || $schema->throw_exception ($table->error);
#  
#  print Dumper( $source->column_info($col) ) . "\n";
#}

1;