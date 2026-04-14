# Copyright (c) 2026 - Sophia Elizabeth Shapira
# This library is free software; you may redistribute it and/or modify
# it under the same terms as Perl itself.

package Cartovanta;

our $VERSION = '0.00_1';

use strict;
use warnings;
use Exporter 'import';
use Cartovanta::Unix;

our @EXPORT_OK = qw(
  cr_alloc_get
  cr_alloc_init
  cr_alloc_ready
  cr_eval_with_rg
  cr_file_eval_with_rg
  cr_home_refresh
  cr_pk_eval
  cr_resloc
  cr_settings
  infile
  shell_captr
  shell_qt
  slurp_file
);

# DECLARE THE HELPER VARIABLES:
my $_alloc_nspace = undef; # Namespace for ad-hoc package names
my $_alloc_numid = 0; # ID-number of last allocated ad-hoc package name



# Get value for `$_homedir`
cr_home_refresh();
sub cr_home_refresh {
  return( Cartovanta::Unix::cr_home_refresh(@_) );
}


sub shell_qt {
  return( Cartovanta::Unix::shell_qt(@_) );
}



# Loads an entire file into one Perl string and returns it.
# Returns undef if no filename was provided or if the file
# could not be opened for reading.
sub slurp_file {
  my $lc_file;  # Pathname of the file to load
  my $lc_ret;   # File contents to be returned
  
  if ( (scalar @_) < 1.5 ) { return undef; }
  
  $lc_file = $_[0];
  if ( !(-f $lc_file) ) { return undef; }
  if ( !(-r $lc_file) ) { return undef; }
  
  $lc_ret = '';
  open(my $lc_fh,'<',$lc_file) or return undef;
  local $/;
  $lc_ret = <$lc_fh>;
  close($lc_fh);
  
  return($lc_ret);
}



# Loads the contents of a file into a PERL string.
sub infile {
  my $lc_a;
  my $lc_b;
  if ( !@_ ) { return undef; }
  $lc_a = '';
  if ( open($lc_b,'<',$_[0]) )
  {
    local $/ = undef;
    $lc_a = <$lc_b>;
    close($lc_b);
  }
  return $lc_a;
}

# Takes as its first argument a PERL string to be `eval`ed.
# Any additional arguments are passed to the code-reference
# returned by that `eval`.
# If the `eval` fails to return a code-reference, `undef` is
# returned.
# Otherwise, the return value is whatever is returned by the
# generated code-reference.
sub cr_eval_with_rg {
  my $lc_code;
  my $lc_bld;
  if ( !@_ ) { return undef; }
  $lc_code = shift(@_);
  $lc_bld = eval($lc_code);
  if ( ref($lc_bld) ne 'CODE' ) { return undef; }
  return($lc_bld->(@_));
}

# Takes as its first argument the pathname of a file whose
# contents are to be loaded as a PERL string and `eval`ed.
# Any additional arguments are passed to the code-reference
# returned by that `eval`.
# If the file cannot be loaded, or if the `eval` fails to
# return a code-reference, `undef` is returned.
# Otherwise, the return value is whatever is returned by the
# generated code-reference.
sub cr_file_eval_with_rg {
  my $lc_file;
  my $lc_code;
  if ( !@_ ) { return undef; }
  $lc_file = shift(@_);
  $lc_code = infile($lc_file);
  return(cr_eval_with_rg($lc_code,@_));
}


sub shell_captr {
  my $lc_comd;
  my $lc_ret;
  $lc_comd = shell_qt(@_);
  $lc_ret = `$lc_comd`;
  chomp($lc_ret);
  return $lc_ret;
}

sub cr_resloc {
  return( Cartovanta::Unix::cr_resloc(@_) );
}

sub cr_settings {
  
  # The argument must be a hashref.
  if ( ref($_[0]) ne 'HASH' ) { return 0; }
  
  return( Cartovanta::Unix::cr_settings(@_) );
}

# Initialize the Ad-Hoc Package Namespace Allocator
sub cr_alloc_init {
  my $lc_nspace; # Temporary storage for considered namespace
  
  # Only valid initializations are allowed 
  $lc_nspace = $_[0];
  if ( !defined($lc_nspace) ) { return 0; }
  if ( ref($lc_nspace) ) { return 0; }
  if ( !($lc_nspace =~ /^[a-zA-Z_]\w*(?:::[a-zA-Z_]\w*)*$/) )
  {
    return 0;
  }
  
  # First initialization wins. However, additional
  # attempts (as long as they pass the tests that come
  # up to this point) still are identified as "success".
  if ( defined($_alloc_nspace) ) { return 1; }
  
  # Looks like we have a winner.
  $_alloc_nspace = $lc_nspace;
  return 1;
}

# This function allocates one ad-hoc package name.
sub cr_alloc_get {
  # This will only work if the allocator has been
  # initiated.
  if ( !defined($_alloc_nspace) ) { return undef; }
  
  # Let us assemble the new allocee.
  $_alloc_numid = int($_alloc_numid + 1.2);
  return($_alloc_nspace . '::X' . $_alloc_numid . 'z');
}

# Queries to see if the allocator has been initiated.
# Returns `1` for yes and `0` for no.
sub cr_alloc_ready {
  return ( defined($_alloc_nspace) ? 1 : 0 );
}

# Does an `eval` on code after slapping on an ad-hoc
# package name. Returns hashref with the following fields:
# 'package' -- The ad-hoc package name (`undef` if the
#     allocator hasn't been initiated, which causes this
#     function without even calling `eval`)
# 'evret' -- Return value of `eval`
# 'err' -- The error message (empty-string upon success)
sub cr_pk_eval {
  my $lc_ret; # The in-progress return value
  my $lc_code; # The code that will get `eval`ed
  
  # Construct initial value
  $lc_ret = {
    'package' => undef,
    'evret' => undef,
    'err' => "Namespace allocator uninitiated.\n",
  };
  
  # And that's what we return if the allocator hasn't
  # been initiated.
  if ( !cr_alloc_read() ) { return $lc_ret; }
  
  # Now we allocate a namespace and prep code
  $lc_ret->{'package'} = cr_alloc_get();
  $lc_code = 'package ' . $lc_ret->{'package'} . '; ' . $_[0];
  
  # And finally, the evaluation.
  $lc_ret->{'evret'} = eval($lc_code);
  $lc_ret->{'err'} = $@;
  
  # And we're done!
  return $lc_ret;
}



1;
