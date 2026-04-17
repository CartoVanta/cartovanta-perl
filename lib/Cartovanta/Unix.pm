# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Cartovanta::Unix;
use strict;
use warnings;


# DECLARE THE HELPER VARIABLES:
my $_homedir;  # Home directory for the current user
my $_refresh_home = 1; # Is the home auto-refreshed when applicable?


# Let the calling program change settings for
# this library.
sub cr_settings {
  
  # These back-end functions are called like methods
  shift(@_);
  
  # The argument must be a hashref.
  if ( ref($_[0]) ne 'HASH' ) { return 0; }
  
  # Auto-refreshing of home-directory (and possibly
  # other things in the future) when applicable.
  if ( defined($_[0]->{'refresh'}) )
  {
    if ( $_[0]->{'refresh'} )
    {
      $_refresh_home = 1;
    } else {
      $_refresh_home = 0;
    }
  }
}

sub shell_qt {
  my $lc_ret;
  my $lc_ech;
  
  # These back-end functions are called like methods
  shift(@_);
  
  $lc_ret = ' ';
  foreach $lc_ech (@_)
  {
    $lc_ret .= ( _shell_quote($lc_ech) . ' ' );
  }
  return $lc_ret;
}

sub _shell_quote {
  my $lc_strg;
  ($lc_strg) = @_;
  return "''" if !defined($lc_strg) || $lc_strg eq '';
  $lc_strg =~ s/'/'"'"'/g;
  return "'$lc_strg'";
}

sub cr_home_refresh
{
  # These back-end functions are called like methods
  shift(@_);
  
  if ( defined($ENV{'HOME'}) && ($ENV{'HOME'} ne '') )
  {
    $_homedir = $ENV{'HOME'};
  }
  else
  {
    $_homedir = (getpwuid($<))[7];
  }
}

1;
