package Cartovanta::Os_Spc;

sub pick {
  my $this;
  my $lc_ret;
  
  $this = shift(@_);
  
  $lc_ret = 'Cartovanta::Unix';
  
  if ( $^O eq 'MSWin32' )
  {
    $lc_ret = 'Cartovanta::Win32';
  }
  
  if ( !(eval('require ' . $lc_ret . ";\n\n1;\n")) )
  {
    die("\nCould not load Cartovanta backend " . $lc_ret . ".\n" . $@ . "\n");
  }
  return $lc_ret;
}

1;
