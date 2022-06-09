package TopTable::Model::Email;
use strict;
use warnings;
use base 'Catalyst::Model::Factory';

__PACKAGE__->config(
  class => "Mail::Builder::Simple",
  args => {
    mail_client => {
      mailer => "SMTP",
      mailer_args => {
        host => "mail.host.server.name",
        username => "email-user-name",
        password => "email-password",
      },
    },
    from => [ 'from@domain.com', "From Display Name" ],
    template_args => {
      # Set the location for TT files
      INCLUDE_PATH => [
          TopTable->path_to(qw( root templates emails )),
      ],
    },
  },
);

1;
