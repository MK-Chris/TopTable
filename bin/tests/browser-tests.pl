#!/usr/bin/perl

use strict;
use warnings;
use HTTP::BrowserDetect;

my $ua1 = HTTP::BrowserDetect->new( "Mozilla/5.0 (iPhone; CPU iPhone OS 8_3 like Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Version/8.0 Mobile/12F70 Safari/600.1.4 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" );
my $ua2 = HTTP::BrowserDetect->new( "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.96 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)" );

printf "User agent 1 robot: %s\n", $ua1->browser_string;
printf "User agent 2 robot: %s\n", $ua2->browser_string;

