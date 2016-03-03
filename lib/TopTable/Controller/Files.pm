package TopTable::Controller::Files;
use Moose;
use namespace::autoclean;
use MIME::Types;
use File::Spec;
use File::Basename;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

TopTable::Controller::File - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

# Set up the allowed file types
my @allowed_types = qw(
  image/gif
  image/jpeg
  image/png
  image/x-bmp
  text/plain
  text/csv
  application/msword
  application/vnd.ms-word.document.macroenabled.12
  application/vnd.openxmlformats-officedocument.wordprocessingml.document
  application/vnd.openxmlformats-officedocument.wordprocessingml.template
  message/rfc822
  text/vcard
  text/html
  text/x-log
  application/x-msaccess
  application/oda
  application/vnd.oasis.opendocument.database
  application/vnd.oasis.opendocument.chart
  application/vnd.oasis.opendocument.formula
  application/vnd.oasis.opendocument.formula-template
  application/vnd.oasis.opendocument.graphics
  application/vnd.oasis.opendocument.image
  application/vnd.oasis.opendocument.text-master
  application/vnd.oasis.opendocument.presentation
  application/vnd.oasis.opendocument.spreadsheet
  application/vnd.oasis.opendocument.text
  application/pdf
  application/vnd.ms-powerpoint
  application/vnd.ms-powerpoint.slideshow.macroenabled.12
  application/vnd.openxmlformats-officedocument.presentationml.slideshow
  application/vnd.ms-powerpoint.presentation.macroenabled.12
  application/vnd.openxmlformats-officedocument.presentationml.presentation
  application/x-mspowerpoint
  application/x-mspublisher
  text/uri-list
  application/x-excel
  application/vnd.ms-excel
  application/vnd.ms-excel.addin.macroenabled.12
  application/vnd.ms-works
  application/vnd.ms-excel.sheet.binary.macroenabled.12
  application/vnd.ms-excel.sheet.macroenabled.12
  application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  application/vnd.ms-excel.template.macroenabled.12
  application/vnd.openxmlformats-officedocument.spreadsheetml.template
  application/xml
);

=head2 index

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # 404 on the index - we need to either upload or download
  $c->detach( qw/TopTable::Controller::Root default/ );
}

sub upload :Local Args(0) {
  my ( $self, $c ) = @_;
  my @errors;
  my $type = $c->request->parameters->{type};
  my ( $return_value, $filename, $new_filename );
  
  # The type determines whether we return some JSON or not
  my $return_json = 1 if $type eq "news";
  if ( my $upload = $c->request->upload("file") ) {
    $filename           = $upload->filename;
    my $target_folder   = $c->config->{Paths}{file_downloads};
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
        # Split the file into name, path, extension
        my ( $name, $path, $extension ) = fileparse( $original_filename, qr/\.[^.]*/ );
        $i++;
        $target_filename = $name . "-" . sprintf( "%03d", $i ) . $extension;
      }
      
      if ( $upload->copy_to( File::Spec->catfile( $target_folder, $target_filename ) ) ) {
        # File has been copied successfully, insert it into the database
        my $file = $c->model("DB::UploadedFile")->create({
          filename  => $target_filename,
          mime_type => $mime_type,
        });
        
        $return_value->{link} = $c->uri_for_action( "/files/download", [$file->id] )->as_string if $return_json;
        $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["file", "upload", {id => $file->id}, $file->filename] );
      } else {
        # Add an error if we can't copy the file
        push(@errors, $c->maketext("file.upload.error.copy-failure", $!));
      }
    } else {
      # File type not allowed
      push(@errors, $c->maketext("file.upload.error.invalid-file-type"));
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

sub download :Local Args(1) {
  my ( $self, $c, $file_id ) = @_;
  
  # Look for the file in the DB
  my $file = $c->model("DB::UploadedFile")->find_non_deleted( $file_id );
  
  if ( defined( $file ) ) {
    # File found in the DB, check that it's still on disk
    # First we need the file download directory
    my $filepath = File::Spec->catfile( $c->config->{Paths}{file_downloads}, $file->filename );
    
    if ( -e $filepath and -r $filepath ) {
      # File exists and can be read, serve it up as a downloaded file
      $c->response->header("Content-Type" => $file->mime_type);
      $c->response->header("Content-Disposition" => 'attachment; filename="' . $file->filename . '"');
      $c->response->header("Content-Description" => $file->description) if $file->description;
      $c->serve_static_file( $filepath );
      
      # Update the downloaded count
      $file->update({downloaded_count => $file->downloaded_count + 1});
      $c->detach;
    } else {
      # Doesn't exist or can't be read
      $c->response->redirect($c->uri_for("/",
                  {mid => $c->set_status_msg( {error =>  $c->maketext("file.download.errror.file-doesnt-exist") } )}));
    }
  } else{
    # File not found
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
