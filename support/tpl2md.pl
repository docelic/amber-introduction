#!/usr/bin/env perl

use warnings;
use strict;
use Perl6::Slurp qw/slurp/;
use Fatal qw/open/;

my @toc;
my %terms= (
  'ameba'       => 'veelenga/ameba                        - Static code analysis (development)',
  'radix'       => 'luislavena/radix                      - Radix Tree implementation',
  'kilt'        => 'jeromegn/kilt                         - Generic template interface',
  'slang'       => 'jeromegn/slang                        - Slang template language',
  'redis'       => 'stefanwille/crystal-redis             - ',
  'cli'         => 'amberframework/cli                    - Building cmdline apps (based on mosop)',
  'teeplate'    => 'amberframework/teeplate               - Rendering multiple template files',
  'micrate'     => 'juanedi/micrate                       - Database migration tool',
  'shell-table' => 'jwaldrip/shell-table.cr               - Creates textual tables in shell',
  'spinner'     => 'askn/spinner                          - Spinner for the shell',
  'mysql'       => 'crystal-lang/crystal-mysql            - ',
  'sqlite3'     => 'crystal-lang/crystal-sqlite3          - ',
  'pg'          => 'will/crystal-pg                       - PostgreSQL driver',
  'db'          => 'crystal-lang/crystal-db               - Common DB API',
  'optarg'                      =>  'mosop/optarg                          - Parsing cmdline args',
  'callback'                    =>  'mosop/callback                        - Defining and invoking callbacks',
  'string_inflection'           =>  'mosop/string_inflection               - Word plurals, counts, etc.',
  'crystal-db'                  =>  'crystal-lang/crystal-db               - Common DB API',
  'smtp.cr'                     =>  'amberframework/smtp.cr                - SMTP client (to be replaced with arcage/crystal-email)',
  'selenium-webdriver-crystal'  =>  'ysbaddaden/selenium-webdriver-crystal - Selenium Webdriver client',
);

our @shards= `cd amber && shards list | tail -n +2 | awk '{ print \$2 }' | sort |uniq`;

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
$tpl=~ s/\{\{\{SHARDS\}\}\}/replace_keywords( @shards)/ge;

open my $out, "> ../README.md";
print $out $tpl;
exit 0;

###################################
# Helpers below

sub replace_keywords {
  for( @_){
    s/^\s+//;
    s/\s+$//;
    if( $terms{$_}) {
      $_= $terms{$_}
    }
    $_.= "\n";
  }
  join '', @_
}
