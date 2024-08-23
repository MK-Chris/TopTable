package TopTable::Controller::Images;
use Moose;
use namespace::autoclean;
use MIME::Types;
use File::Spec;
use File::Basename;
use HTML::Entities;

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

sub auto :Private {
  my ( $self, $c ) = @_;
  
  # Load the messages
  $c->load_status_msgs;
  
  # The title bar will always have
  $c->stash({subtitle1 => $c->maketext("menu.text.image") });
  
  # Breadcrumbs links
  push(@{$c->stash->{breadcrumbs}}, {
    path => $c->uri_for("/images"),
    label => $c->maketext("menu.text.image"),
  });
}

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # 404 on the index - we need to either stream or upload, perhaps we can have a list of images here at some point
  $c->detach(qw(TopTable::Controller::Root default));
}

=head2 base

Chain base for getting the image ID and checking it.

=cut

sub base :Chained("/") :PathPart("images") :CaptureArgs(1) {
  my ( $self, $c, $id_or_key ) = @_;
  
  if ( my $image = $c->model("DB::UploadedImage")->find_id_or_url_key( $id_or_key ) ) {
    my $file_path = File::Spec->catfile( $c->config->{Paths}{image_streaming}, $image->filename );
    
    if ( -e $file_path and -r $file_path ) {
      # Get MIME type
      my $mime_type = $image->mime_type;
      
      # File exists and can be read
      if ( grep( $_ eq $image->mime_type, @allowed_types ) ) {
        # Correct file type
        
        # Stash it, then stash the name / view URL in the breadcrumbs section of our stash
        my $encoded_image_description = encode_entities( $image->description );
        $c->stash({
          image => $image,
          file_path => $file_path,
          encoded_image_description => $encoded_image_description,
        });
        
        # Push the clubs list page on to the breadcrumbs
        push(@{$c->stash->{breadcrumbs}}, {
          path => $c->uri_for_action("/images/view", [$image->url_key]),
          label => $encoded_image_description,
        });
      } else {
        # Incorrect file type - 404
        $c->detach(qw(TopTable::Controller::Root default));
      }
    } else {
      # File does not exist or cannot be read - 404
      $c->detach(qw(TopTable::Controller::Root default));
    }
  } else {
    # Database record doesn't exist
    $c->detach(qw(TopTable::Controller::Root default));
  }
}

sub upload :Local :Args(0) {
  my ( $self, $c ) = @_;
  
  $c->forward( "TopTable::Controller::Users", "check_authorisation", ["image_upload", $c->maketext("user.auth.upload-images"), 1] );
  
  # Stash the template and information we need
  $c->stash({
    template => "html/images/upload.ttkt",
    subtitle2 => $c->maketext("admin.upload"),
    form_action => $c->uri_for_action("/images/do_upload"),
    view_online_display => "Uploading images",
    view_online_link => 1,
  });
}

sub do_upload :Path("do-upload") :Args(0) {
  my ( $self, $c ) = @_;
  my ( @errors, $response );
  my $description = $c->req->param( "description" );
  
  # The type determines whether we return some JSON or not
  my $return_json = 1 if $c->is_ajax;
  
  if ( my $upload = $c->req->upload("image") ) {
    my $filename = $upload->filename;
    my $target_folder = $c->config->{Paths}{image_streaming};
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
        $target_filename = sprintf( "%s-%03d.%s", $name, $i, $extension );
      }
      
      if ( $upload->copy_to( File::Spec->catfile( $target_folder, $target_filename ) ) ) {
        # File has been copied successfully, insert it into the database
        
        push(@errors, $c->maketext("image.upload.error.description-blank")) unless $description;
        
        unless ( scalar( @errors ) ) {
          my $url_key = $c->model("DB::UploadedImage")->make_url_key($description);
          
          my $image = $c->model("DB::UploadedImage")->create({
            url_key => $url_key,
            description => $description,
            filename => $target_filename,
            mime_type => $mime_type,
          });
          
          $response->{link} = $c->uri_for_action( "/images/stream", [$image->url_key] )->as_string if $return_json;
          
          $c->forward( "TopTable::Controller::SystemEventLog", "add_event", ["image", "upload", {id => $image->id}, $image->filename] );
          
          unless ( $return_json ) {
            $c->response->redirect($c->uri_for_action("/images/view", [$image->url_key],
                        {mid => $c->set_status_msg( {success => $c->maketext("images.upload.success") } )}));
            $c->detach;
            return;
          }
        }
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
      $response->{error} = join("\n", @errors);
    } else {
      $c->flash->{description} = $description;
      
      $c->response->redirect($c->uri_for("/images/upload", {mid => $c->set_status_msg({error => \@errors})}));
      $c->detach;
      return;
    }
  }
  
  if ( $return_json ) {
    $c->stash({json_data => $response});
    $c->detach($c->view("JSON"));
  }
}

=head2 view

View the image within the confines of the image view page.

=cut

sub view :Chained("base") :PathPart("view") :Args(0) {
  my ( $self, $c ) = @_;
  my $image = $c->stash->{image};
  my $encoded_image_description = $c->stash->{encoded_image_description};
  
  $c->stash({
    template => "html/images/view.ttkt",
    view_online_display => sprintf( "Viewing %s", $encoded_image_description ),
    view_online_link => 1,
  });
}

=head2 stream

Stream the image as a static file.

=cut

sub stream :Chained("base") :PathPart("stream") :Args(0) {
  my ( $self, $c ) = @_;
  my $image = $c->stash->{image};
  my $file_path = $c->stash->{file_path};
  
  $c->serve_static_file( $file_path );
  
  # Update the viewed count and detach
  $image->update({viewed_count => $image->viewed_count + 1});
  $c->detach;
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
