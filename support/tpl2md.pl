#!/usr/bin/env perl

use warnings;
use strict;
use Perl6::Slurp qw/slurp/;
use Fatal qw/open/;

my @toc;

my $tpl= slurp 'README.md.tpl';

while( $tpl=~ /^(#+)\s+(.*)/gm) {
  push @toc, ("\t" x (length($1)-1)). '1. '. $2. "\n";
}

$tpl=~ s/\{\{\{TOC\}\}\}/join '', @toc/ge;
$tpl=~ s/\[\[\[(.*?)\]\]\]/`$1`/ge;
$tpl=~ s/^#: /# /g;

open my $out, "> ../README.md";
print $out $tpl
