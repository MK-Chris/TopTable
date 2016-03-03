package TopTable::Model::Email;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config(
  class       => "Mail::Builder::Simple",
  args => {
    mail_client => {
      mailer => "SMTP",
      mailer_args => {
        host => "mail.mkttl.co.uk",
        username => 'admin@mkttl.co.uk',
        password => "ReubenThomas2209",
      },
    },
    from      => [ 'admin@mkttl.co.uk', "Milton Keynes Table Tennis League" ],
    template_args => {
      # Set the location for TT files
      INCLUDE_PATH => [
          TopTable->path_to( "root", "templates", "emails" ),
      ],
    },
  },
);

1;
