use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile
  (
   NAME          => 'Getopt::Gen',
   VERSION_FROM  => 'Gen.pm', # finds $VERSION
   ABSTRACT_FROM => 'Gen.pm',
   AUTHOR        => 'Bryan Jurish <jurish@ling.uni-potsdam.de>',
   PREREQ_PM     => {
		     # Run-time dependencies
		     Parse::Lex => 2.15,
		     # Parser driver
		     Parse::Yapp::Driver => 1.05,
		     # Text::Template
		     Text::Template => 1.42,
		    },
   EXE_FILES     => ['optgen.perl'],
   PM            => {
		     'Gen.pm' => '$(INST_LIBDIR)/Gen.pm',
		     'Gen/Parser.pm' => '$(INST_LIBDIR)/Gen/Parser.pm',
		     'Gen/cmdline_c.pm' => '$(INST_LIBDIR)/Gen/cmdline_c.pm',
		     'Gen/cmdline_h.pm' => '$(INST_LIBDIR)/Gen/cmdline_h.pm',
		     'Gen/cmdline_pod.pm' => '$(INST_LIBDIR)/Gen/cmdline_pod.pm',
		    },
  );

#---------------------------------------------------------------
# Extensions
#---------------------------------------------------------------

sub MY::postamble {
  (
   # how to format the README file
   "README : README.pod\n"
   ."\t pod2text README.pod > README\n\n"
   # how to generate a yapp parser
   ."Gen/Parser.pm : Gen/Parser.yp\n"
   ."\t yapp -v -m Getopt::Gen::Parser -o \$@ \$<\n\n"
  );
}

sub MY::dist_core {
  package MY;
  my $inherited = shift->SUPER::dist_core(@_);
  $inherited =~
    # ... distribution requires current README file
    s/^dist\s*:/dist\ : README/m;
  $inherited;
}
