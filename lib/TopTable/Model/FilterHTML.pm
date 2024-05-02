package TopTable::Model::FilterHTML;

use Moose;
use namespace::clean -except => 'meta';

extends qw( Catalyst::Model );


use HTML::Restrict;


=head1 NAME

TopTable::Model::FilterHTML

=head1 DESCRIPTION

Filters out disallowed HTML tags from what would normally be textarea fields (where a limited subset of HTML is allowed).

=cut


=head1 METHODS

=head2 filter

=cut

sub filter {
	my( $self, $html, $type ) = @_;
	# TODO: Fetch list of allowed tags and attributes from config
  my ( $rules, $uri_schemes );
  
	# Create a HTML::Restrict object
	my $hr = HTML::Restrict->new;
  
  if ( defined($type) and $type eq "textarea" ) {
  	$hr->set_rules({
  		b => [],
  		strong => [],
  		i => [],
  		em => [],
      u => [],
      strike => [],
      s => [],
      sub => [],
      sup => [],
  		small => [],
  		p => [],
  		br => [qw( / )],
  		a => [qw( href title )],
  		img => [qw( src alt title width height style / )],
      ul => [qw( style start )],
      ol => [qw( style start )],
      li => [],
      div => [qw( style )],
      span => [qw( style contenteditable class )],
      table => [qw( width )],
      tbody => [],
      tr => [],
      td => [],
      hr => [qw( / )],
      blockquote => [],
      h1 => [],
      h2 => [],
      h3 => [],
      h4 => [],
      h5 => [],
      h6 => [],
      a => [qw( href target rel )],
      img => [qw( class alt title width height src / )],
      iframe => [qw( width height src )],
  	});
    
    $hr->set_uri_schemes([qw( undef http https  mailto )]);
  }
  
	# Pass the HTML through it
	my $filtered = $hr->process($html) if $html;
  
	# Return the filtered HTML
	return $filtered;
}



=head1 AUTHOR

Chris Welch

=head1 COPYRIGHT

TopTable is copyright (c) 2015 Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

