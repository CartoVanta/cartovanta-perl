package Cartovanta::Utl;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
  require_str
);

sub require_str{
  my $lc_pkg;
  
  $lc_pkg = $_[0];
  if ( !($lc_pkg) )
  {
    die("\n" . '`require_str()` needs a valid package-name to load.' . "\n\n");
  }
  if ( ref($lc_pkg) )
  {
    die("\n" . 'You must specify a string of a package name to `require_str()`.' . "\n\n");
  }
  
  if ( !(eval "require $lc_pkg; 1;") )
  {
    die "\nCould not load module $lc_pkg.\n$@\n";
  }
}

1;
