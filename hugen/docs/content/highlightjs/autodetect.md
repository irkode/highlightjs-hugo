+++
title = "A word on auto detection"
description = "How the Go and Hugo grammars use Highlight.js relevance settings to win auto-detection against Handlebars and other similar template languages."
+++

_Handlebars_ and _Go templates_ (used by [Hugo][]) have similar template tags. Without additional
relevance settings Hugo grammars will loose most of the time. Relevance settings are used to beat
_Handlebars_ auto-detection for Go/Hugo templates.

If you import both languages flavours -- Hugo and Go there's no way to be sure the right variant is
taken. For templates having special Hugo stuff (like try, or hugo built_ins) it will work, but
expect for templates without you might get the wrong flavor.

- Go template comments get relevance = 10.

   comments start with {{ printf "`{{/*` or `{{- /*`" }} and end with `*/}}` or `*/ -}}`

- Functions in the _hugo_ namespace get relevance = 10 (e.g. hugo.IsDevelopment)

- The following _Handlebars_ opening template tags are set to _invalid_ for HuGo:
  {{ "`{{#`, `{{>`, `{{!--`, `{{!`" }}

   `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the
   hugo module.

- Built_ins only available in Hugo will get relevance 1.

The module works with the standard [Highlight.js][] extra build system. Download the grammar source
from our [Releases][] page and copy it to the `highlight.js/extra` directory. Check out the
[Highlight.js][] documentation for more details.
