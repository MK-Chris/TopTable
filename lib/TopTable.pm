package TopTable;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::TimeZone;
use Data::Dumper;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
  Compress
  ConfigLoader
  Static::Simple
  StackTrace
  Authentication
  Authorization::Roles
  Session
  Session::Store::DBI
  Session::State::Cookie
  StatusMessage
  DateTime
  +CatalystX::I18N::Role::Base
  +CatalystX::I18N::Role::Maketext
  +CatalystX::I18N::Role::DateTime
  +CatalystX::I18N::Role::NumberFormat
  +CatalystX::I18N::Role::GetLocale
/;
with "CatalystX::DebugFilter";

  #Compress
#    -Debug
#    HashedCookies
  #I18N
  #

use CatalystX::RoleApplicator;
use Digest::MD5;
use Time::HiRes;
use HTML::Entities;
use JavaScript::Value::Escape;

extends 'Catalyst';
__PACKAGE__->apply_request_class_roles(qw/CatalystX::I18N::TraitFor::Request/);
__PACKAGE__->apply_response_class_roles(qw/CatalystX::I18N::TraitFor::Response/);

our $VERSION = "3.00 Beta";

# Configure the application.
#
# Note that settings in toptable.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
  name => "TopTable",
  disable_component_resolution_regex_fallback => 1, # Disable deprecated behavior needed by old applications
  enable_catalyst_header => 1, # Send X-Catalyst header
  "View::JSON" => {
    allow_callback  => 1,    # defaults to 0
    callback_param  => 'cb', # defaults to 'callback'
    expose_stash    => qr/(^json|^link$|^error$)/,
    #expose_stash    => [ "link", "error", qr/^json/ ], # defaults to everything
  },
  "CatalystX::DebugFilter" => {
    # Filter all fields with "password" in their name
    Request => { params => [ qr/password/ ] },
  },
  compression_format => "gzip",
);


=head2 timezone

Get the timezone based on user preferences (or fall back to the default).

=cut

sub timezone :Private {
  my ( $c ) = @_;
  
  # If the user is logged in and there's a valid timezone specified, use that
  return $c->user->timezone if $c->user_exists and defined( $c->user->timezone ) and DateTime::TimeZone->is_valid_name( $c->user->timezone );
  
  # If we can't use the user timezone for whatever reason, use the default if possible
  return $c->config->{DateTime}{default_timezone} if $c->config->{DateTime}{default_timezone} and DateTime::TimeZone->is_valid_name( $c->config->{DateTime}{default_timezone} );
  
  # Finally, fall back to London if all else fails
  return "Europe/London";
}

=head2 datetime_tz

Calls $c->datetime, but first checks that the given timezone is valid (if there is one) and defaults to the one given in $c->config->{DateTime}{default_timezone} if the timezone is either missing or invalid.

=cut

sub datetime_tz {
  my ( $c, $parameters ) = @_;
  
  if ( exists( $parameters->{time_zone} ) and $parameters->{time_zone} ) {
    $parameters->{time_zone} = $c->config->{DateTime}{default_timezone} if !DateTime::TimeZone->is_valid_name( $parameters->{time_zone} );
  } else {
    $parameters->{time_zone} = $c->config->{DateTime}{default_timezone};
  }
  
  return $c->datetime( %{ $parameters } );
}

=head2 build_message

If passed an arrayref, splits it up into an HTML formatted unordered list; if just passed a string, it will just return the string.

=cut

sub build_message {
  my ( $c, $messages ) = @_;
  
  # Return the first element if we only have one
  if ( ref( $messages ) ne "ARRAY" or scalar( @{ $messages } ) == 1 ) {
    my $message;
    if ( ref( $messages ) eq "ARRAY" ) {
      $message = $messages->[0];
    } else {
      $message = $messages;
    }
    
    if ( ref( $message ) eq "HASH" ) {
      # Hashref, grab the id and parameters
      my @parameters = @{ $message->{parameters} } if exists $message->{parameters};
      my $text = $c->maketext( $message->{id}, @parameters );
      
      # Escape javascript if necessary
      $text = javascript_value_escape( $text ) if defined( $c->request->headers->header("X-Requested-With") ) and $c->request->headers->header("X-Requested-With") eq "XMLHttpRequest";
      return $text;
    } else {
      # Not a hashref, just return the value
      # Escape javascript if necessary
      $message = javascript_value_escape( $message ) if defined( $c->request->headers->header("X-Requested-With") ) and $c->request->headers->header("X-Requested-With") eq "XMLHttpRequest";
      return $message;
    }
  }
  
  my $return_message = "<ul>";
  foreach my $message ( @{ $messages } ) {
    # Get the parameters if there are any
    
    if ( ref( $message ) eq "HASH" ) {
      # Hashref, grab the id and parameters
      my @parameters = @{ $message->{parameters} } if exists $message->{parameters};
      my $text = $c->maketext( $message->{id}, @parameters );
      
      # Escape javascript if necessary
      $text = javascript_value_escape( $text ) if $c->request->headers->header("X-Requested-With") eq "XMLHttpRequest";
      
      $return_message .= sprintf( "  <li>%s</li>", $text );
    } else {
      # Not a hashref, just do a 'maketext' on the value
      # Escape javascript if necessary
      $message = javascript_value_escape( $message ) if $c->request->headers->header("X-Requested-With") eq "XMLHttpRequest";
      
      $return_message .= sprintf( "  <li>%s</li>", $message );
    }
  }
  
  $return_message .= "</ul>";
  return $return_message;
}

=head2 add_status_message

Adds a status message of type info, success, warning or error to the current page.  Checks and adds to the current message if there is one.

=cut

sub add_status_message {
  my ( $c, $type, $message ) = @_;
  
  if ( exists( $c->stash->{status_msg} ) and exists( $c->stash->{status_msg}{$type} ) ) {
    $c->stash->{status_msg}{$type} .= sprintf( "\n\n%s", $message );
  } else {
    $c->stash->{status_msg}{$type} = $message;
  }
}

=head2 is_ajax

Detect if this request is an AJAX one

=cut

sub is_ajax {
  my ( $c ) = @_;
  return ( defined( $c->request->headers->header("X-Requested-With") ) and $c->request->headers->header("X-Requested-With") eq "XMLHttpRequest" ) ? 1 : 0;
}

=head2 get_locale_with_uri

Wraps around $c->get_locale (which is provided by CatalystX::I18N::Role::GetLocale) to search the URI first, the various attempts that $c->get_locale uses (session, user, browser, default from config). 

=cut

sub get_locale_with_uri {
  my ( $c ) = @_;
  
  # Try and get the language first from the URI, which overrides everything
  my $language = $c->request->parameters->{lang} || undef;
  
  if ( defined( $language ) ) {
    # Replace dashes with undescores (validation will fail with dashes)
    $language =~ s/-/_/;
    
    # Check it's valid
    $language = $c->check_locale( $language );
  }
  
  # This separate if statement is checking the same as the last one because the value may have changed since the call to $c->check_locale
  if ( defined( $language ) ) {
    # Set the locale if we can
    $c->locale( $language ) if $c->can("locale");
    
    # Return with the language we've set
    return $language;
  }
  
  # Otherwise, call get_locale to try and detect via the session
  return $c->get_locale;
}

=head2 warn_on_non_https

Output a warning message if we're not using https.  This should be called when displaying forms with a password field.

=cut

sub warn_on_non_https {
  my ( $c ) = @_;
  
  # If we are set to warn when not secure and we're not secure
  if ( $c->config->{Users}{warn_on_password_entry_non_https} and !$c->request->secure ) {
    # Grab the URI and make a clone of it, then set the scheme to HTTPS so we can display a link.
    my $uri = $c->request->uri->clone;
    $uri->scheme( "https" );
    $c->add_status_message( "warning", $c->maketext("msg.insecure-password-form", $uri) );
  }
}

=head2 toptable_version

Return the current version number

=cut

sub toptable_version {
  my ( $c ) = @_;
  return $VERSION;
}

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

TopTable - Catalyst based application

=head1 SYNOPSIS

    script/toptable_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<TopTable::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
