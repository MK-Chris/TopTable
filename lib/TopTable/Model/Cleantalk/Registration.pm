package TopTable::Model::Cleantalk::Registration;
use strict;
use warnings;
use base 'TopTable::Model::Cleantalk';

=head1 NAME

TopTable::Model::Cleantalk - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=cut

=head1 Methods

=cut

__PACKAGE__->config(
  args => {method_name => "check_newuser"},
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
