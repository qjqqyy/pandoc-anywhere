pandoc-anywhere
===============

`pandoc-anywhere` exposes your local `pandoc` installation over the web so you can do useful (or in my case, stupid) things with it.

<aside class="warning">
If you do run this software, you are exposing your `pandoc` installation to
whoever who can access your web server, making any local vulnerabilities remote!
</aside>


API
---

Usage example:

```sh
curl --compressed http://host/api.pl -H 'Content-Type: text/plain' --data-binary @file.md
```

`api.pl` accepts the following parameters via query string,

* `standalone` -- generates a standalone HTML if specified, snippet otherwise.
* `webmath` -- either `mathjax`(default) or `webtex`.


Markdown Scratchpad
-------------------

Basic markdown editor that uses API to auto-update, try it at <https://scratch.b0ss.net>.
There's also a less functional [no JS version](https://scratch.b0ss.net/nojs.pl) which defaults to `webtex`.


Setup
-----

* The `.pl` files require Apache 2 with `mod_perl` 2.0, I think no extra modules are needed.
* The rest are static files which you may serve any way you wish.
* The user that `httpd` runs as must have execute permissions on your `pandoc` binary.