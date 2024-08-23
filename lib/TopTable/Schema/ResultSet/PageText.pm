package TopTable::Schema::ResultSet::PageText;

use strict;
use warnings;
use base qw( TopTable::Schema::ResultSet );
use HTML::Entities;

=head2 get_text

Gets the page_text for a given page.

=cut

sub get_text {
  my $class = shift;
  my ( $page_key ) = @_;
  
  return $class->find({page_key => $page_key}) || "";
}

=head2 edit

Edit the page text for a given page

=cut

sub edit {
  my $class = shift;
  my ( $params ) = @_;
  # Setup schema / logging
  my $logger = delete $params->{logger} || sub { my $level = shift; printf "LOG - [%s]: %s\n", $level, @_; }; # Default to a sub that prints the log, as we don't want errors if we haven't passed in a logger.
  my $locale = delete $params->{locale} || "en_GB"; # Usually handled by the app, other clients (i.e., for cmdline testing) can pass it in.
  my $schema = $class->result_source->schema;
  $schema->_set_maketext(TopTable::Maketext->get_handle($locale)) unless defined($schema->lang);
  my $lang = $schema->lang;
  
  # Grab the fields
  my $page_key = $params->{page_key};
  my $page_text = $params->{page_text};
  my $response = {
    errors => [],
    warnings => [],
    info => [],
    success => [],
    fields => {},
    completed => 0,
  };
  
  if ( defined($page_key) ) {
    # Filter the HTML from the page text
    #$page_text = TopTable->model("FilterHTML")->filter( $page_text, "textarea" );
    $page_text = "" unless defined($page_text);
    $response->{fields}{page_text} = $page_text;
    
    my $page = $class->update_or_create({
      page_key => $page_key,
      page_text => $page_text,
    });
    
    $response->{completed} = 1;
    push(@{$response->{success}}, $lang->maketext("admin.forms.success", $lang->maketext("menu.text.$page_key"), $lang->maketext("admin.message.edited")));
  } else {
    push(@{$response->{errors}}, $lang->maketext("page_text.form.error.page-key-missing"));
  }
  
  return $response;
}

1;