package Cartovanta::Shell;
use IPC::Open3;
use IO::Select;
use Symbol qw(gensym);
use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);
use strict;
use warnings;
use Exporter 'import';


# BEGIN LOADING BACKEND
sub _backend_package {
  if ( $^O eq 'MSWin32' ) { return('Cartovanta::Win32'); }
  return('Cartovanta::Unix');
}
sub _load_backend {
  my $lc_pkg;
  $lc_pkg = _backend_package();
  if ( !(eval "require $lc_pkg; 1;") )
  {
    die "\nCould not load Cartovanta backend $lc_pkg.\n$@\n";
  }
  return($lc_pkg);
}
_load_backend();
# FINISH LOADING BACKEND


our @EXPORT_OK = qw(
  shell_qt
  shell_captr_s
  shell_captr
  shell_captr_e
);




sub shell_qt {
  return( _backend_package()->shell_qt(@_) );
}


sub shell_captr_s {
  my $lc_fh_in;   # Handle for child's STDIN (unused here)
  my $lc_fh_out;  # Handle for child's STDOUT
  my $lc_err;     # Handle for child's STDERR
  my $lc_out;     # Captured STDOUT
  my $lc_pid;     # Child PID
  
  $lc_err = gensym();
  
  $lc_pid = open3($lc_fh_in, $lc_fh_out, $lc_err, @_);
  {
    local $/ = undef;
    $lc_out = <$lc_fh_out>;
  }
  
  waitpid($lc_pid, 0);
  return $lc_out;
}


sub shell_captr {
  my $lc_fh_in;   # Handle for child's STDIN (unused here)
  my $lc_fh_out;  # Handle for child's STDOUT
  my $lc_out;     # Captured STDOUT
  my $lc_pid;     # Child PID
  
  $lc_pid = open3($lc_fh_in, $lc_fh_out, undef, @_);
  {
    local $/ = undef;
    $lc_out = <$lc_fh_out>;
  }
  
  waitpid($lc_pid, 0);
  return $lc_out;
}


sub shell_captr_e {
  my $lc_fh_in;    # Handle for child's STDIN (unused here)
  my $lc_fh_out;   # Handle for child's STDOUT
  my $lc_fh_err;   # Handle for child's STDERR
  my $lc_out;      # Captured STDOUT
  my $lc_err;      # Captured STDERR
  my $lc_pid;      # Child PID
  my $lc_sel;      # IO::Select object
  my $lc_buf;      # Temporary read buffer
  my $lc_flags;    # File-status flags for a handle
  my $lc_fh;       # One ready filehandle
  my $lc_bytes;    # Number of bytes read
  
  $lc_fh_err = gensym();
  $lc_out = '';
  $lc_err = '';
  
  $lc_pid = open3($lc_fh_in, $lc_fh_out, $lc_fh_err, @_);
  close($lc_fh_in);
  
  foreach $lc_fh ($lc_fh_out, $lc_fh_err)
  {
    $lc_flags = fcntl($lc_fh, F_GETFL, 0);
    fcntl($lc_fh, F_SETFL, ($lc_flags | O_NONBLOCK));
  }
  
  $lc_sel = IO::Select->new();
  $lc_sel->add($lc_fh_out);
  $lc_sel->add($lc_fh_err);
  
  while ( $lc_sel->count() )
  {
    foreach $lc_fh ( $lc_sel->can_read() )
    {
      $lc_bytes = sysread($lc_fh, $lc_buf, 4096);
      
      if ( !defined($lc_bytes) ) { }
      elsif ( $lc_bytes == 0 )
      {
        $lc_sel->remove($lc_fh);
        close($lc_fh);
      }
      elsif ( $lc_fh == $lc_fh_out )
      {
        $lc_out .= $lc_buf;
      }
      else
      {
        $lc_err .= $lc_buf;
      }
    }
  }
  
  waitpid($lc_pid, 0);
  return [ $lc_out, $lc_err ];
}



1;
