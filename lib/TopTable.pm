package TopTable;
use Moose;
use namespace::autoclean;
use DateTime;
use DateTime::TimeZone;
use Log::Log4perl::Catalyst;
use DDP;

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

use Catalyst qw(
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
);
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
__PACKAGE__->apply_request_class_roles(qw(CatalystX::I18N::TraitFor::Request));
__PACKAGE__->apply_response_class_roles(qw(CatalystX::I18N::TraitFor::Response));
__PACKAGE__->log(Log::Log4perl::Catalyst->new("log.conf")) if -e __PACKAGE__->path_to("log.conf");

our $VERSION = "3.50";

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
    allow_callback => 1,    # defaults to 0
    callback_param => 'cb', # defaults to 'callback'
    expose_stash => "json_data",
    #expose_stash    => qr/(^json|^link$|^error$)/,
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
  return $c->user->timezone if $c->user_exists and defined($c->user->timezone) and DateTime::TimeZone->is_valid_name($c->user->timezone);
  
  # If we can't use the user timezone for whatever reason, use the default if possible
  return $c->config->{DateTime}{default_timezone} if $c->config->{DateTime}{default_timezone} and DateTime::TimeZone->is_valid_name($c->config->{DateTime}{default_timezone});
  
  # Finally, fall back to London if all else fails
  return "Europe/London";
}

=head2 datetime_tz

Calls $c->datetime, but first checks that the given timezone is valid (if there is one) and defaults to the one given in $c->config->{DateTime}{default_timezone} if the timezone is either missing or invalid.

=cut

sub datetime_tz {
  my ( $c, $params ) = @_;
  
  if ( exists($params->{time_zone}) and $params->{time_zone} ) {
    $params->{time_zone} = $c->config->{DateTime}{default_timezone} if !DateTime::TimeZone->is_valid_name($params->{time_zone});
  } else {
    $params->{time_zone} = $c->config->{DateTime}{default_timezone};
  }
  
  return $c->datetime(%{$params});
}

=head2 add_status_messages

Add an array of status messages.

=cut

sub add_status_messages {
  my ( $c, $msgs ) = @_;
  my %msgs = %{$msgs};
  $c->log->debug(np(%msgs));
  
  # Loop through the hash keys - each hash key is a message type - usually error, warning, info, success
  foreach my $type ( keys %msgs ) {
    my $msg = $msgs{$type};
    
    # If there's nothing here, move on to the next type
    next unless defined($msg);
    
    # Make sure it's an array, if not already
    $msg = [$msg] unless ref($msg) eq "ARRAY";
    
    # If there are no elements to this array, move on
    next unless scalar @{$msg};
    
    # Make sure the status_msg exists in the hash
    if ( exists($c->stash->{status_msg}) and ref($c->stash->{status_msg}) eq "HASH" and exists($c->stash->{status_msg}{$type}) ) {
      # Message type exists already, add to it
      # Turn it into an array if it's not already
      $c->stash->{status_msg}{$type} = [$c->stash->{status_msg}{$type}] unless ref($c->stash->{status_msg}{$type}) eq "ARRAY";
      push(@{$c->stash->{status_msg}{$type}}, @{$msg});
    } else {
      if ( ref($c->stash->{status_msg}) eq "HASH" ) {
        # We have status messages, but none of this type.  Set it up as an array so we can add to it in future
        $c->stash->{status_msg}{$type} = $msg;
      } else {
        # We don't have any status messages at all - add it to the stash as a hash (keys are message $type) of arrays.
        $c->stash->{status_msg} = {$type => $msg};
      }
    }
  }
}

=head2 is_ajax

Detect if this request is an AJAX one

=cut

sub is_ajax {
  my ( $c ) = @_;
  return ( defined($c->req->header("X-Requested-With")) and $c->req->header("X-Requested-With") eq "XMLHttpRequest" ) ? 1 : 0;
}

=head2 get_locale_with_uri

Wraps around $c->get_locale (which is provided by CatalystX::I18N::Role::GetLocale) to search the URI first, the various attempts that $c->get_locale uses (session, user, browser, default from config).

This calls check_and_set_locale, which sets a cookie if the user has selected preference cookies, so it should be called after we check the cookie settings.

=cut

sub get_locale_with_uri {
  my ( $c ) = @_;
  
  # Try and get the language first from the URI, which overrides everything
  my $locale = $c->req->params->{locale};
  $locale = $c->check_and_set_locale($locale) if defined($locale);
  return $locale if defined($locale);
  
  # Couldn't get from the query string, check the cookie
  $locale = $c->req->cookie("toptable_locale")->value if defined($c->req->cookie("toptable_locale"));
  $locale = $c->check_and_set_locale($locale) if defined($locale);
  return $locale if defined($locale);
  
  # Otherwise, call get_locale to try and detect via the session
  $locale = $c->get_locale;
  $locale = $c->check_and_set_locale($locale) if defined($locale);
  
  return $locale;
}

=head2 check_and_set_locale

Checks the given value is a valid locale, sets it if so.  Should be called *after* we get the cookie prefs, as this will set a cookie if preferences are selected.

=cut

sub check_and_set_locale {
  my ( $c, $locale ) = @_;
  return unless defined($locale);
  
  # Replace dashes with undescores (validation will fail with dashes)
  $locale =~ s/-/_/;
  
  # Check it's valid
  $locale = $c->check_locale($locale);
  
  # Check it's still defined, as a check will return undef if it's not valid
  return unless defined($locale);
  
  # Set the locale if we can
  $c->locale($locale) if $c->can("locale");
  
  # Set the cookie if we are storing preferences in cookies
  $c->response->cookies->{toptable_locale} = {
    value => $locale,
    expires => "+3M",
    httponly => 1,
  } if exists($c->stash->{cookie_settings}{preferences}) and $c->stash->{cookie_settings}{preferences};
  
  # Return with the language we've set
  return $locale;
}

=head2 warn_on_non_https

Output a warning message if we're not using https.  This should be called when displaying forms with a password field.

=cut

sub warn_on_non_https {
  my ( $c ) = @_;
  
  # If we are set to warn when not secure and we're not secure
  if ( $c->config->{Users}{warn_on_password_entry_non_https} and !$c->req->secure ) {
    # Grab the URI and make a clone of it, then set the scheme to HTTPS so we can display a link.
    my $uri = $c->req->uri->clone;
    $uri->scheme("https");
    $c->add_status_messages({warning => $c->maketext("msg.insecure-password-form", $uri)});
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
