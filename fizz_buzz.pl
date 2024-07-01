use strict;
use warnings;

for (my $i = 1; $i <= 100; $i++) {
  my $message;
  if ($i % 15 == 0) {
    $message = "FizzBuzz";
  } elsif ($i % 3 == 0) {
    $message = "Fizz";
  } elsif ($i % 5 == 0) {
    $message = "Buzz";
  } else {
    $message = $i;
  }
  printf "%s\n", $message;
}
