# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Toolchartic::Unix;
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

# This method conditionally refreshes the home
# directory depending on whether or not the
# preference says to and on whether or not the
# home directory has previously been refreshed.
sub qcr_home_refresh {
  my $this;
  
  $this = shift(@_);
  
  if ( (!defined($_homedir)) || $_refresh_home )
  {
    $this->cr_home_refresh();
  }
  
  return $_homedir;
}

# This method generates a list (in the form of an
# arrayref) of directories to go into a path -- and
# does it based on a resource-ID string.
sub rsid_path {
  my $this;
  my @lc_set;
  my $lc_each;
  my $lc_hme;
  
  $this = shift(@_);
  
  # Query the homedir
  $lc_hme = $this->qrc_home_refresh();
  
  # Return path is clear by default
  @lc_set = ();
  
  # Add the local stuff.
  foreach $lc_each (@_)
  {
    @lc_set = ( @lc_set,($lc_hme . '/local/' . $lc_each));
  }
  
  # Add the systemwide stuff.
  foreach $lc_each (@_)
  {
    @lc_set = (@lc_set,('/usr/local/' . $lc_each));
  }
  
  # Wrap and return.
  return [ @lc_set ];
}


1;
