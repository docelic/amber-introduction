#!/usr/bin/env perl

use warnings;
use strict;
use Perl6::Slurp qw/slurp/;
use Fatal qw/open/;

my @toc;

my $tpl= slurp 'README.md.tpl';

$tpl=~ s{^(#+)\s+(.*)}{
  my( $one, $two) = ($1,$2);
  (my $anchor_name= lc $two)=~ s/\W/_/g;
  push @toc, ("\t" x (length($one)-1)). '1. ['. $two. "](#$anchor_name)\n";
  qq{$one $two<a name="$anchor_name"></a>}
}gem;
$tpl=~ s/^#: /# /gm;

$tpl=~ s/\[\[\[(.*?)\]\]\]/`$1`/ge;
$tpl=~ s/\{\{\{TOC\}\}\}/"# Table of Contents\n\n". join( '', @toc)/ge;

open my $out, "> ../README.md";
print $out $tpl
