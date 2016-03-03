package TopTable::Controller::Images;
use Moose;
use namespace::autoclean;
use MIME::Types;
use File::Spec;
use File::Basename;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::Image - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

# Set up the allowed file types
my @allowed_types = qw( image/gif image/jpeg image/png  );

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # 404 on the index - we need to either stream or upload
  $c->detach( qw/TopTable::Controller::Root default/ );
}

sub upload :Local :Args(0) {
  my ( $self, $c ) = @_;
  my @errors;
  my $type = $c->request->parameters->{type};
  my ( $return_value, $filename, $new_filename );
  
  # The type determines whether we return some JSON or not
  my $return_json = 1 if $type eq "news";
  if ( my $upload = $c->request->upload("file") ) {
    $filename           = $upload->filename;
    my $target_folder   = $c->config->{Paths}{image_streaming};
    my $target_filename = $filename;
    
    # Get MIME type
    my $mt = MIME::Types->new( only_complete => 1 );
    my $mime_type = $mt->mimeTypeOf($filename)->type;
    if ( grep( $_ eq $mime_type, @allowed_types ) ) {
      # File is valid, try to copy it
      # If this filename already exists, we need to use a different filename
      # We need a counter to add to the filename
      my $i = 0;
      
      # Save the original so that we don't add 001-002 to the filename, we just increment 001 to 002
      my $original_filename = $target_filename;
      while( -e File::Spec->catfile( $target_folder, $target_filename ) ) {
        my ( $name, $path, $extension ) = fileparse( $original_filename, qr/\.[^.]*/ );
        $i++;
        $target_filename = $name . "-" . sprintf( "%03d", $i ) . $extension;
      }
      
      if ( $upload->copy_to( File::Spec->catfile( $target_folder, $target_filename ) ) ) {
        # File has been copied successfully, insert it into the database
        my $image = $c->model("DB::UploadedImage")->create({
          filename  => $target_filename,
          mime_type => $mime_type,
        });
        
        $return_value->{link} = $c->uri_for_action( "/images/stream", [$image->id] )->as_string if $return_json;
        
        $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["image", "upload", {id => $image->id}, $image->filename] );
      } else {
        # Add an error if we can't copy the file
        push(@errors, $c->maketext("image.upload.error.copy-failure", $!));
      }
    } else {
      # File type not allowed
      push(@errors, $c->maketext("image.upload.error.invalid-file-type"));
    }
  } else {
    push(@errors, $c->maketext("file.upload.error.not-uploaded"));
  }
  
  if ( scalar( @errors ) ) {
    if ( $return_json ) {
      $return_value->{error} = join( "\n", @errors );
    } else {
      $c->response->redirect($c->uri_for("/",
                  {mid => $c->set_status_msg( {error => $c->build_message( \@errors ) } )}));
    }
  }
  
  if ( $return_json ) {
    $c->stash($return_value);
    $c->detach( $c->view("JSON") );
  }
}

sub stream :Local :Args(1) {
  my ( $self, $c, $image_id ) = @_;
  
  # Check the file exists and we can read it
  if ( my $image = $c->model("DB::UploadedImage")->find_non_deleted( $image_id ) ) {
    my $file_path = File::Spec->catfile( $c->config->{Paths}{image_streaming}, $image->filename );
    
    if ( -e $file_path and -r $file_path ) {
      # Get MIME type
      my $mime_type = $image->mime_type;
      
      # File exists and can be read
      if ( grep( $_ eq $image->mime_type, @allowed_types ) ) {
        # Correct file type
        $c->serve_static_file( $file_path );
      
        # Update the viewed count
        $image->update({viewed_count => $image->viewed_count + 1});
        $c->detach;
      } else {
        # Incorrect file type - 404
        $c->detach( qw/TopTable::Controller::Root default/ );
      }
    } else {
      # File does not exist or cannot be read - 404
      $c->detach( qw/TopTable::Controller::Root default/ );
    }
  } else {
    # Database record doesn't exist
    $c->detach( qw/TopTable::Controller::Root default/ );
  }
}



=encoding utf8

=head1 AUTHOR

Chris Welch

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
