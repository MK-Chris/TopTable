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
my $mysql_version = "";

if ( $schema->storage->sqlt_type eq "MySQL" ) {
  $mysql_version = $schema->storage->dbh_do( sub {
    my ($storage, $dbh, @cols) = @_;
    my $cols = join(q{, }, @cols);
    print "$cols\n";
    my $sth = $dbh->prepare("SELECT VERSION();") or die $dbh->errstr;
    
    # Handwaving $ev_code and $pattern2
    $sth->execute;
    
    return $sth->fetchrow_arrayref();
  })->[0];
  
  # Set a MySQL version if we're on MariaDB
  $mysql_version =~ s/-MariaDB$//;
}
 
my $dh = DH->new({
  schema              => $schema,
  script_directory    => "$FindBin::Bin/../dbicdh",
  databases           => $schema->storage->sqlt_type,
  sql_translator_args => {
    add_drop_table    => 0,
    quote_identifiers => 1,
    producer_args     => {
      mysql_version   => $mysql_version,
    },
  },
});
 
sub install {
  # Set "longtext" ddl / upgrade_sql columns for if we're using a MySQL database
  # If we're not, they'll be converted anyway.
  $dh->version_storage->version_rs->result_source->add_columns(
  ddl => {
    data_type         => "longtext",
    is_nullable       => 1,
  },
  upgrade_sql => {
    data_type         => "longtext",
    is_nullable       => 1,
  });
  
  $dh->prepare_install;
  $dh->install;
}
 
sub upgrade {
  die "Please update the version in Schema.pm"
    if ( $dh->version_storage->version_rs->search({version => $dh->schema_version})->count );
 
  die "We only support positive integers for versions around these parts."
    unless $dh->schema_version =~ /^\d+$/;
 
  $dh->prepare_deploy;
  $dh->prepare_upgrade;
  $dh->upgrade;
}
 
sub current_version {
  say $dh->database_version;
}
 
sub help {
say <<'OUT';
usage:
  install
  upgrade
  current-version
OUT
}
 
help unless $ARGV[0];

if ( defined( $ARGV[0] ) and $ARGV[0] eq 'install' ) {
  install();
} elsif ( defined( $ARGV[0] ) and $ARGV[0] eq 'upgrade' ) {
  upgrade();
} elsif ( defined( $ARGV[0] ) and $ARGV[0] eq 'current-version' ) {
  current_version();
} else {
  help();
}