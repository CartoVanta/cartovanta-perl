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
    'lib/Cartovanta/Unix.pm' => '$(INST_LIBDIR)/Cartovanta/Unix.pm',
  },
);
