package Toolchartic::Utl::File;

# Usual package imports:
use strict;
use warnings;
use Exporter 'import';


our @EXPORT_OK = qw(
  slurp_file
  slurp_t_file
);



# Loads an entire file into one Perl string and returns it.
# Returns undef if no filename was provided or if the file
# could not be opened for reading.
sub slurp_file {
  my $lc_file;  # Pathname of the file to load
  my $lc_ret;   # File contents to be returned
  
  if ( (scalar @_) < 0.5 ) { return undef; }
  
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

# Slurps in a text file and assures that the text gets
# normalized to Unix-style.
sub slurp_t_file {
  my $lc_text;
  
  $lc_text = slurp_file($_[0]);
  if ( !(defined($lc_text)) ) { return undef; }
  
  # NOW WE NORMALIZE THE TEXT:
  # First, we remove UTF-8 BOM if present.
  $lc_text =~ s/\A\x{FEFF}//;
  # Next, we change Windows line-endings to Unix-style
  $lc_text =~ s/\r\n/\n/g;
  # Finally, we change old-style Mac line-endings
  # to Unix-style
  $lc_text =~ s/\r/\n/g;
  
  # And we are done!
  return $lc_text;
}

1;
