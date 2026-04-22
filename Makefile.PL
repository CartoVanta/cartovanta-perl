use strict;
use warnings;
use ExtUtils::MakeMaker;

if ( $^O eq 'MSWin32' )
{
  os_unsupported();
}

WriteMakefile(
  NAME         => 'Cartovanta',
  DISTNAME     => 'Cartovanta-Perl',
  VERSION_FROM => 'lib/Cartovanta.pm',
  ABSTRACT     => 'Perl resource-access infrastructure for CartoVanta tools.',
  AUTHOR       => 'Sophia Elizabeth Shapira',
  LICENSE      => 'perl',
  PM           => {
    'lib/Cartovanta.pm'      => '$(INST_LIBDIR)/Cartovanta.pm',
    'lib/Cartovanta/Utl.pm' => '$(INST_LIBDIR)/Cartovanta/Utl.pm',
    'lib/Cartovanta/Os_Spc.pm' => '$(INST_LIBDIR)/Cartovanta/Os_Spc.pm',
    'lib/Cartovanta/Unix.pm' => '$(INST_LIBDIR)/Cartovanta/Unix.pm',
    'lib/Cartovanta/Classy.pm' => '$(INST_LIBDIR)/Cartovanta/Classy.pm',
    'lib/Cartovanta/Shell.pm' => '$(INST_LIBDIR)/Cartovanta/Shell.pm',
    'lib/Cartovanta/Rsrc.pm' => '$(INST_LIBDIR)/Cartovanta/Rsrc.pm',
    'lib/Cartovanta/Rslc.pm' => '$(INST_LIBDIR)/Cartovanta/Rslc.pm',
    'lib/Cartovanta/R_Cvperlc.pm' => '$(INST_LIBDIR)/Cartovanta/R_Cvperlc.pm',
    'lib/Cartovanta/R_Cvperli.pm' => '$(INST_LIBDIR)/Cartovanta/R_Cvperli.pm',
  },
);
