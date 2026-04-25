package Toolchartic::Os_Spc;

sub pick {
  my $this;
  my $lc_ret;
  
  $this = shift(@_);
  
  $lc_ret = 'Toolchartic::Unix';
  
  if ( $^O eq 'MSWin32' )
  {
    $lc_ret = 'Toolchartic::Win32';
  }
  
  if ( !(eval('require ' . $lc_ret . ";\n\n1;\n")) )
  {
    die("\nCould not load Toolchartic backend " . $lc_ret . ".\n" . $@ . "\n");
  }
  return $lc_ret;
}

1;
