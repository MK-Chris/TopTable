package TopTable::View::TT::NoWrap;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::TT';
#with qw(CatalystX::I18N::TraitFor::ViewTT);

__PACKAGE__->config(
  TEMPLATE_EXTENSION => '.ttkt',
  render_die => 1,
  
  # Set the location for TT files
  INCLUDE_PATH => [
      TopTable->path_to( "root", "custom-templates" ),
      TopTable->path_to( "root", "templates" ),
  ],
  # Set to 1 for detailed timer stats in your HTML as comments
  TIMER => 0,
);

=head1 NAME

TopTable::View::TT::NoWrap - TT View for TopTable

=head1 DESCRIPTION

TT View for TopTable.

=head1 SEE ALSO

L<TopTable>

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
