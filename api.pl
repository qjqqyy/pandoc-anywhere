#!/usr/bin/env perl
# we old school

use strict;
use warnings;
use feature 'switch';
no warnings qw(uninitialized experimental);
use utf8;
use constant PANDOC_PATH => '/home/chiya/.cabal/bin/pandoc';

use Apache2::SubProcess ();
use CGI '-utf8';
use CGI::Carp;
$CGI::POST_MAX=32*1024;

binmode STDOUT, ":utf8";

my $r = shift;
my $q = new CGI;

if ($r->method() ne 'POST') {
    $r->status(400);
    return;
}

my %webmath = (
    mathjax => '--mathjax',
    webtex => '--webtex=https://latex.codecogs.com/svg.latex?',
);
# default values
my ($standalone, $mathlib, $numbersections) = (0, 'mathjax', 0);
# parse query string
for my $kv (split '&', $r->args) {
    $kv =~ /([^=]*)(?:=(.*))?/;
    given ($1) {
        when ('standalone') {
            $standalone = 1;
        }
        when ('numbersections') {
            $numbersections = 1;
        }
        when ('webmath') {
            if (exists $webmath{$2}) {
                $mathlib = $2;
            }
        }
    }
}

# build @PANDOC_ARGS
my @PANDOC_ARGS = ('--quiet', '--from', 'markdown+emoji');
push @PANDOC_ARGS, '--number-sections' if $numbersections;
push @PANDOC_ARGS, '--standalone',
    '--css=https://fonts.googleapis.com/css?family=Inconsolata|PT+Sans|PT+Sans+Narrow:700',
    '--css=https://b0ss.net/pandoc.css' if $standalone;
push @PANDOC_ARGS, $webmath{$mathlib};

### OUTPUT STARTS HERE ###
print "Content-type: text/html; charset=utf-8\n\n";

# UGLY HACK: extract title & author
my @markdown = split "\n", scalar($q->param('POSTDATA')), 3;
unless ($standalone) {
    print qq(<h1 class="title">$1</h1>\n) if $markdown[0] =~ /^%(.*)$/;
    print qq(<p class="author">$1</p>\n)  if $markdown[1] =~ /^%(.*)$/;
}

my($p_in, $p_out, $p_err) = $r->spawn_proc_prog(PANDOC_PATH, \@PANDOC_ARGS);
# why can't UTF-8 just be default everywhere?
use Encode qw(encode_utf8 decode_utf8);
binmode $p_in, ":utf8";
binmode $p_out, ":utf8";
binmode $p_err, ":utf8";

# dump everything in the pipe
print $p_in decode_utf8(join "\n", @markdown);
close $p_in;

# then slurp whatever pandoc shits out
undef $/;
print <$p_out>;
#print "ERR:\n";
#print <$p_err>;
