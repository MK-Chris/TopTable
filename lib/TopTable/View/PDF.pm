package TopTable::View::PDF;

use strict;
use base 'Catalyst::View::PDF::API2';

__PACKAGE__->config(
  TEMPLATE_EXTENSION => '.ttkt',
  render_die => 1,
  
  # Set the location for TT files
  INCLUDE_PATH => [
      TopTable->path_to(qw( root custom-templates pdf )),
      TopTable->path_to(qw( root templates pdf )),
  ],
  # Set to 1 for detailed timer stats in your HTML as comments
  TIMER => 0,
  # Wrapper template
  WRAPPER => "html/wrappers/wraparoundthewrapper.ttkt",
);

=head1 NAME

TopTable::View::PDF - PDF::API2 View for TopTable

=head1 DESCRIPTION

PDF::API2 View for TopTable. 

=head1 AUTHOR

Chris Welch

=head1 SEE ALSO

L<TopTable>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
