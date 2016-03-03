package TopTable::Maketext;

use strict;
use warnings;
use parent qw(CatalystX::I18N::Maketext);

# sub load_lexicon {
#     my ( $class, %params ) = @_;
# 
#     my $locales = $params{locales} || [];
#     my $directories = $params{directories};
#     my $gettext_style = defined $params{gettext_style} ? $params{gettext_style} : 1;
#     my $inheritance = $params{inheritance} || {};
#     
#     $directories = [ $directories ]
#         if defined $directories
#         && ref $directories ne 'ARRAY';
#     $directories ||= [];
#     $locales = [ $locales ]
#         unless ref $locales eq 'ARRAY';
#     
#     die "Invalid locales"
#         unless defined $locales
#         && scalar @$locales > 0
#         && ! grep {  $_ !~ $CatalystX::I18N::TypeConstraints::LOCALE_RE } @$locales;
#     
#     {
#         no strict 'refs';
#         my $lexicon_loaded = ${$class.'::LEXICON_LOADED'};
#         if (defined $lexicon_loaded
#             && $lexicon_loaded == 1) {
#             warn "Lexicon has already been loaded for $class";
#             return;
#         }
#     }
#     
#     my $lexicondata = {
#         _decode => 1,
#     };
#     $lexicondata->{_style} = 'gettext'
#         if $gettext_style;
#     
#     my %locale_loaded;
#     
#     # Loop all directories
#     foreach my $directory (@$directories) {
#         next 
#             unless defined $directory;
#         
#         $directory = Path::Class::Dir->new($directory)
#             unless ref $directory eq 'Path::Class::Dir';
#         
#         next
#             unless -d $directory->stringify && -e _ && -r _;
#         
#         my @directory_content =  $directory->children();
#         
#         # Load all avaliable message files
#         foreach my $locale (@$locales) {
#             my $lc_locale = lc($locale);
#             $lc_locale =~ s/-/_/g;
#             my @locale_lexicon;
#             foreach my $content (@directory_content) {
#                 if ($content->is_dir) {
#                     push(@locale_lexicon,'Slurp',$content->stringify)
#                         if $content->basename eq $locale;
#                 } else {
#                     my $filename = $content->basename;
#                     if ($filename =~ m/^$locale\.(mo|po)$/i) {
#                         push(@locale_lexicon,'Gettext',$content->stringify);
#                     } elsif ($filename =~ m/^$locale\.m$/i) {
#                         push(@locale_lexicon,'Msgcat',$content->stringify);
#                     } elsif($filename =~ m/^$locale\.db$/i) {
#                         push(@locale_lexicon,'Tie',[ $class, $content->stringify ]);
#                     } elsif ($filename =~ m/^$lc_locale\.pm$/) {
#                         $locale_loaded{$locale} = 1;
#                         require $content->stringify;
#                         # TODO transform maketext -> gettext syntax if flag is set
#                         # Locale::Maketext::Lexicon::Gettext::_gettext_to_maketext
#                     }
#                 }
#             }
#             $lexicondata->{$locale} = \@locale_lexicon
#                 if scalar @locale_lexicon;
#         }
#     }
#     
#     # Fallback lexicon
#     foreach my $locale (@$locales) {
#         next
#             if exists $inheritance->{$locale};
#         next
#             if exists $locale_loaded{$locale};
#         $lexicondata->{$locale} ||= ['Auto'];
#     }
#     
#     print Data::Dumper::Dumper( $lexicondata );
#     
#     eval qq[
#         package $class;
#         our \$LEXICON_LOADED = 1;
#         Locale::Maketext::Lexicon->import(\$lexicondata)
#     ];
#     
#     while (my ($locale,$inherit) = each %$inheritance) {
#         my $locale_class = lc($locale);
#         my $inherit_class = lc($inherit);
#         $locale_class =~ s/-/_/g;
#         $inherit_class =~ s/-/_/g;
#         $locale_class = $class.'::'.$locale_class;
#         $inherit_class = $class.'::'.$inherit_class;
#         no strict 'refs';
#         push(@{$locale_class.'::ISA'},$inherit_class);
#     }
#     
#     die("Could not load Locale::Maketext::Lexicon: $@") if $@;
#     return;
# }

1;

