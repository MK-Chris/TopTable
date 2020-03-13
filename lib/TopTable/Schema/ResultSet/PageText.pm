package TopTable::Schema::ResultSet::PageText;

use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

=head2 get_text

Gets the page_text for a given page.

=cut

sub get_text {
  my ( $self, $page_key ) = @_;
  
  return $self->find({page_key => $page_key}) || "";
}

=head2 edit

Edit the page text for a given page

=cut

sub edit {
  my ( $self, $parameters ) = @_;
  
  my $page_key      = $parameters->{page_key} || undef;
  my $page_text     = $parameters->{page_text} || undef;
  my $return_value  = {error => []};
  
  if ( defined( $page_key ) ) {
    # Filter the HTML from the page text
    $page_text = TopTable->model("FilterHTML")->filter( $page_text, "textarea" );
    $page_text = "" unless defined( $page_text );
    
    my $page = $self->update_or_create({
      page_key  => $page_key,
      page_text => $page_text,
    });
    
  } else {
    push(@{ $return_value->{error} }, {
      id => "page_text.form.error.page-key-missing",
    });
  }
  
  return $return_value;
}

1;