#!/usr/bin/perl

use strict;


my $lexicondata = {
  _decode => 1,
  _style => "gettext",
  en => [
    "Auto",
  ],
  fr => [
    "Slurp",
    "D:\\WAMP\\Apache\\Apache2\\htdocs\\TopTable\\Test\\TopTable\\root\\locale\\fr",
  ],
  en_GB => [
   "Slurp",
   "D:\\WAMP\\Apache\\Apache2\\htdocs\\TopTable\\Test\\TopTable\\root\\locale\\en_GB",
  ],
};

Locale::Maketext::Lexicon->import(\$lexicondata) or die $^E;
