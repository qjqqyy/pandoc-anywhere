#!/usr/bin/env perl
# I have no mood to fix this ad-hoc mess

use strict;
use warnings;
use feature 'switch';
no warnings qw(uninitialized experimental);
use constant PANDOC_PATH => '/home/chiya/bin/pandoc';

use Apache2::SubProcess ();
use CGI '-utf8';
use CGI::Carp;
$CGI::POST_MAX=32*1024;

binmode STDOUT, ":utf8";

my $r = shift;
my $q = new CGI;

# "argument parsing"
my($force_mathjax, $numbersections);
$numbersections = !!(scalar $q->param('numbersections')) if defined $q->param('numbersections');
$force_mathjax = !!(scalar $q->param('force_mathjax')) if defined $q->param('force_mathjax');

# build @PANDOC_ARGS
my @PANDOC_ARGS = ('--quiet', '--from', 'markdown+emoji'); 
push @PANDOC_ARGS, $force_mathjax ?'--mathjax' : '--webtex=https://latex.codecogs.com/svg.latex?';
push @PANDOC_ARGS, '--number-sections' if $numbersections;

### OUTPUT STARTS HERE ###
print "Content-type: text/html; charset=utf-8\n\n";

# I'm gonna piss off so many people with this lazy shit
print << 'END_PRE_MATHJAX';
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
  <title>Markdown Scratchpad (no JS)</title>
  <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Inconsolata|PT+Sans|PT+Sans+Narrow:700">
  <link rel="stylesheet" href="scratch.css">
END_PRE_MATHJAX
print '<script src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-AMS_CHTML-full" type="text/javascript"></script>',"\n" if $force_mathjax;
print << 'END_FIRST_THIRD';
  <style>
form { height: 100%;}
textarea#markdown_textarea { width: 100%; height: calc(100% - 3em); margin-bottom: .3em;}
  </style>
</head>
<body><div id="bigwrap">
<header>
  <h1 class="title">Markdown Scratchpad (no JS)</h1>
  <p><a href="./">JS-enabled version</a>.</p>
</header>
<div class="row" id="smallwrap">
<div class="col left">
  <form method="post">
  <textarea name="md" id="markdown_textarea" placeholder="% Title (optional)
% Author (optional)

\newcommand{\R}{\mathbb{R}}

...">
END_FIRST_THIRD
print scalar $q->param('md') if defined $q->param('md');

print '</textarea>';
print q(<input type="checkbox" name="numbersections" id="box_numbersections" value="1");
print q( checked="true" ) if $numbersections;   # god i hate this
print q(><label for="box_numbersections"> Number Sections </label>);
print q(<input type="checkbox" name="force_mathjax" id="box_force_mathjax" value="1");
print q( checked="true" ) if $force_mathjax;   # god i hate this
print q(><label for="box_force_mathjax"> Force MathJax (JS) </label>);
print << 'END_2ND_THIRD';
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

print << 'IM_ALMOST_DONE';
</div><!-- /.right -->
</div><!-- /.row -->
<footer>
  <p>
    <a href="https://github.com/qjqqyy/scratch">Source code</a>.
    Math rendering by 
IM_ALMOST_DONE
if ($force_mathjax) { print '<a href="https://www.mathjax.org/" target="_blank">MathJax</a>,'; }
else { print '<a href="https://latex.codecogs.com" target="_blank">WebTex</a>,'; }
print << 'IM_DONE';
    markdown rendering by <a href="https://pandoc.org" target="_blank">Pandoc</a>,
    page layout is blatantly inspired by <a href="http://mathb.in" target="_blank">mathb.in</a>.
  </p>
  <p>&copy; 2018 Qi Ji. This is free software, you're free to redistribute or whatever under the terms of the
  <a href="LICENSE.txt" target="_blank">ISC License</a>.</p>
</footer>
</div><!-- /.bigwrap --> </body>
</html>
IM_DONE
