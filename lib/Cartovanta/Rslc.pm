package Toolchartic::Rslc;
use strict;
use warnings;
use Toolchartic::Os_Spc;

my $_backpack = Toolchartic::Os_Spc->pick();

sub p_rsid {
  my $this;
  my $lc_newls;
  my $lc_oblis;
  
  $this = shift(@_);
  
  # Obtain the partial path based on argumentry
  $lc_newls = $_backpack->rsid_path(@_);
  
  # Prepend it to the search path.
  $lc_oblis = $this->{'path'};
  @{$lc_oblis} = (@{$lc_newls},@{$lc_oblis});
  
  # We are done!
  return 1;
}


1;
