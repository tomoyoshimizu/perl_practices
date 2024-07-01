use strict;
use warnings;

## windows文字コード対策
# use utf8;
# binmode STDIN,  ':encoding(cp932)';
# binmode STDOUT, ':encoding(cp932)';
# binmode STDERR, ':encoding(cp932)';

my $message1 = "Hello World!";
my $str1 = "こんにちは、";
my $str2 = "世界！";
my $message2 = << "EOF";
${str1}
${str2}
EOF

printf "%s\n", $message1;
print $message2;
