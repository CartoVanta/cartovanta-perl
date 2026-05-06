package Toolchartic::Resrg;

use JSON;
use strict;
use warnings;

# Save the JSON context
my $_jscontext = shift(@ARGV);

# Try to decode JSON context
my $_context = decode_json($_jscontext);


# This method provides the script's context record
# to the calling program.
sub ctx {
  return(decode_json($_jscontext));
}

1;

