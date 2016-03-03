#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw( $Bin );
use lib "$Bin/../../lib";
use Data::Dumper;
use Time::HiRes qw( gettimeofday tv_interval );
use Mail::Builder::Simple;


my $start = [ gettimeofday ];
print "Starting at $start\n";

print "Pre-mail:" . tv_interval( $start ) . "\n";
my $mail = Mail::Builder::Simple->new;
print "Mailer invoked:" . tv_interval( $start ) . "\n";
$mail->send({
  mail_client => {
    mailer => "SMTP",
    mailer_args => {
      #host => "mail.mkttl.co.uk",
      #username => 'admin@mkttl.co.uk',
      #password => "ReubenThomas2209",
      host => "smtp.gmail.com",
      username  => 'chris.welch@document-genetics.co.uk',
      password  => "reubenwelch",
      ssl       => 1,
    },
  },
  from      => [ 'chris.welch@document-genetics.co.uk', "Milton Keynes Table Tennis League" ],
  to        => [ 'welch.chris@gmail.com', "Chris Welch" ],
  subject   => "Test email.",
  plaintext => "Hi Chris\n\nThis is a test email.\n\nRegards\n",
  #htmltext  => ""
  mailer    => "TopTable/Test",
});
print "Mail sent:" . tv_interval( $start ) . "\n";

1;