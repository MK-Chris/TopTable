package TopTable::Model::Cleantalk;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

=head1 NAME

TopTable::Model::Cleantalk - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

=head1 Methods

=cut

__PACKAGE__->config(
  class => "WebService::Antispam",
  args => {
    server_url => "http://moderate.cleantalk.org",
    auth_key => "GetFromCleantalk",
    agent => "TopTable",
  },
);


=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
