#!/usr/bin/env perl

use warnings;
use strict;
use Perl6::Slurp qw/slurp/;
use Fatal qw/open/;

my @toc;

my $tpl= slurp 'README.md.tpl';

$tpl=~ s{^(#+)\s+(.*)}{
	(my $anchor_name= lc $2)=~ s/\W/_/;
  push @toc, ("\t" x (length($1)-1)). '1. ['. $2. "](#$anchor_name)\n";
	"$1 [$2](#$anchor_name)"
}gee;

$tpl=~ s/\{\{\{TOC\}\}\}/"# Table of Contents\n\n". join( '', @toc)/ge;
$tpl=~ s/\[\[\[(.*?)\]\]\]/`$1`/ge;
$tpl=~ s/^#: /# /gm;

open my $out, "> ../README.md";
print $out $tpl
