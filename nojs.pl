#!/usr/bin/env perl
# perl CGI is so 2000s, but I already have Apache so...

use strict;
use warnings;
use feature 'switch';
no warnings qw(uninitialized experimental);
use constant PANDOC_PATH => '/home/chiya/.cabal/bin/pandoc';

use Apache2::SubProcess ();
use CGI '-utf8';
use CGI::Carp;
$CGI::POST_MAX=32*1024;

binmode STDOUT, ":utf8";

my $r = shift;
my $q = new CGI;

# build @PANDOC_ARGS
my @PANDOC_ARGS = ('--quiet', '--from', 'markdown+emoji', '--webtex=https://latex.codecogs.com/svg.latex?');
my $numbersections = 0;
$numbersections = !!(scalar $q->param('numbersections')) if defined $q->param('numbersections');
push @PANDOC_ARGS, '--number-sections' if $numbersections;

### OUTPUT STARTS HERE ###
print "Content-type: text/html; charset=utf-8\n\n";

# I'm gonna piss off so many people with this lazy shit
print << 'END_FIRST_THIRD';
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  <title>Markdown Scratchpad (no JS)</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inconsolata|PT+Sans|PT+Sans+Narrow:700">
  <link rel="stylesheet" href="scratch.css">
  <style>
form { height: 100%;}
textarea#markdown_textarea { height: calc(100% - 3em); margin-bottom: .3em;}
  </style>
</head>
<body><div id="bigwrap">
<header>
  <h1 class="title">Markdown Scratchpad (no JS)</h1>
  <p><a href="./">JS-enabled version</a>.</p>
</header>
<div class="row">
<div class="col left">
  <form action="nojs.pl" method="post">
  <textarea name="md" id="markdown_textarea" placeholder="% Title (optional)
% Author (optional)

\newcommand{\R}{\mathbb{R}}

...">
END_FIRST_THIRD
print scalar $q->param('md') if defined $q->param('md');

print '</textarea>';
print q(<input type="checkbox" name="numbersections" id="box_numbersections" value="1");
print q( checked="true" ) if $numbersections;   # god i hate this
print q(>);
print << 'END_2ND_THIRD';
  <label for="box_numbersections">Number Sections</label>
  <input type="submit" value="Preview">
  </form>
</div><!-- /.left -->
<div class="col right" id="pandoc_output">
END_2ND_THIRD

if (defined $q->param('md')){
    # UGLY HACK: extract title & author
    my @markdown = split "\n", scalar($q->param('md')), 3;
    print qq(<h1 class="title">$1</h1>\n) if $markdown[0] =~ /^%(.*)$/;
    print qq(<p class="author">$1</p>\n)  if $markdown[1] =~ /^%(.*)$/;
    my($p_in, $p_out, $p_err) = $r->spawn_proc_prog(PANDOC_PATH, \@PANDOC_ARGS);
    # why can't UTF-8 just be default everywhere?
    use Encode qw(encode_utf8 decode_utf8);
    binmode $p_in, ":utf8";
    binmode $p_out, ":utf8";
    binmode $p_err, ":utf8";

    # dump everything in the pipe
    print $p_in join "\n", @markdown;
    close $p_in;

    # then slurp whatever pandoc shits out
    undef $/;
    print <$p_out>;
    #print "ERR:\n";
    #print <$p_err>;
}

print << 'IM_DONE';
</div><!-- /.right -->
</div><!-- /.row -->
<footer>
  <p>
    <a href="https://github.com/qjqqyy/pandoc-anywhere">Source code</a>.
    Math rendering by <a href="https://latex.codecogs.com" target="_blank">WebTex</a>,
    markdown rendering by <a href="https://pandoc.org" target="_blank">Pandoc</a>,
    page layout is blatantly inspired by <a href="http://mathb.in" target="_blank">mathb.in</a>.
  </p>
  <p>&copy; 2018 Qi Ji. This is free software, you're free to redistribute or whatever under the terms of the
  <a href="LICENSE.txt" target="_blank">ISC License</a>.</p>
</footer>
</div><!-- /.bigwrap --> </body>
</html>
IM_DONE
