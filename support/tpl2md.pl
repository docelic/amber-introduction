#!/usr/bin/env perl

use warnings;
use strict;
use Perl6::Slurp qw/slurp/;
use Fatal qw/open/;

my $tpl= slurp 'README.md.tpl';
$tpl=~ s/\[\[\[(.*?)\]\]\]/`$1`/ge;

open my $out, "> ../README.md";
print $out $tpl
