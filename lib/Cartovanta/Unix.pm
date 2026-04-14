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
  $lc_ret = ' ';
  foreach $lc_ech (@_)
  {
    $lc_ret .= ( shell_quote($lc_ech) . ' ' );
  }
  return $lc_ret;
}

sub shell_quote {
  my $lc_strg;
  ($lc_strg) = @_;
  return "''" if !defined($lc_strg) || $lc_strg eq '';
  $lc_strg =~ s/'/'"'"'/g;
  return "'$lc_strg'";
}




sub cr_home_refresh
{
  if ( defined($ENV{'HOME'}) && ($ENV{'HOME'} ne '') )
  {
    $_homedir = $ENV{'HOME'};
  }
  else
  {
    $_homedir = (getpwuid($<))[7];
  }
}





sub cr_resloc {
  my $lc_found;
  
  # Refresh the home -- unless calling program has opted out
  if ( $_refresh_home ) { cr_home_refresh(); }
  
  # At default, it is _not_ found.
  $lc_found = undef;
  
  # First, let's try searching the custom search path.
  if ( defined $ENV{'CARTOVANTA_RES_PATH'} )
  {
    my @lc2_path;
    my $lc2_each;
    @lc2_path = split(/:/,$ENV{'CARTOVANTA_RES_PATH'});
    foreach $lc2_each (@lc2_path)
    {
      $lc_found = _check_res_dir($lc2_each,@_);
      if ( defined($lc_found) ) { return $lc_found; }
    }
  }
  
  # Now we search default user-specific installs
  $lc_found = _check_res_dir(($_homedir . '/local/cartovanta-res'),@_);
  if ( defined($lc_found) ) { return $lc_found; }
  
  # Now we search for a default-loc systemwide install
  return(_check_res_dir('/usr/local/cartovanta-res',@_));
}

sub _check_res_dir {
  my $lc_chkdir; # The directory to check
  my $lc_chktyp; # The type of directory
  my $lc_chkres; # The resource to check for
  my $lc_ret;    # Tentative return value
  my $lc_each;
  
  # Make sure we have enough arguments.
  if ( (scalar @_) < 2.5 )
  {
    return undef;
  }
  
  # Load special variables from function arguments:
  $lc_chkdir = shift(@_);
  $lc_chktyp = shift(@_);
  $lc_chkres = shift(@_);
  
  # Preliminary check:
  $lc_ret = _check_preliminary($lc_chkdir,$lc_chktyp,$lc_chkres);
  if ( !defined($lc_ret) ) { return undef; }
  
  # If we got this far, we do the stricter tests.
  foreach $lc_each (@_)
  {
    if ( ref($lc_each) eq 'ARRAY' )
    {
      if ( _fail_extra_test($lc_ret,@$lc_each) ) { return undef; }
    }
  }
  
  # We made it!
  return $lc_ret;
}

sub _check_preliminary {
  my $lc_ret;
  
  # Reject all empty-string directories on path:
  if ( $_[0] eq '' ) { return undef; }
  
  # Find the tentative result:
  $lc_ret = ( $_[0] . '/' . $_[2] );
  
  # Check if resource exists if it is a file
  if ( $_[1] eq 'f' )
  {
    if ( -f $lc_ret ) { return($lc_ret); }
    return undef;
  }
  
  # Check if resource exists if it is a directory
  if ( $_[1] eq 'd' )
  {
    if ( -d $lc_ret ) { return($lc_ret); }
    return undef;
  }
  
  # Unidentified resource type -- fail:
  return undef;
}


# This function is set to return 1 in case of a test
# failing and 0 if it succeeds -- because that is
# easier for the calling function to process.
sub _fail_extra_test {
  my $lc_lookfor;
  
  # Got we enough arguments?
  if ( (scalar @_) < 2.5 ) { return 1; }
  
  # What must exist to pass?
  $lc_lookfor = ( $_[0] . '/' . $_[2] );
  
  # File check
  if ( $_[1] eq 'f' )
  {
    if ( -f $lc_lookfor ) { return 0; }
    return 1;
  }
  
  # Directory check
  if ( $_[1] eq 'd' )
  {
    if ( -d $lc_lookfor ) { return 0; }
    return 1;
  }
  
  # Unidentified test must be a failure.
  return 1;
}


1;
