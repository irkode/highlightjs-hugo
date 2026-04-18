{{- $lang := .Params.hljs.language -}}
{{- $aliases := .Params.hljs.aliases -}}

# Highlight {{ title $lang }} templates

A language grammar to highlight [Hugo][]'s templating language with [Highlight.js][].

- [CSS class reference](hugo-css-class-reference)

![preview]({{ add $lang ".png" }})

## Requirements

The module has been implemented using [Highlight.js][] version 11.11.1. It will most likely not work
with an older version.

## Download

The module has not been published to any CDN right now., you will have to clone or download the
stuff you need.

- release packages can be downloaded from our [Releases] page.

## Usage

Include the `highlight.js` library in your webpage or Node app, then load this module.

### Static website or simple usage

Load the module after loading `highlight.js`.

```html
<script type="text/javascript" src="/path/to/highlight.min.js"></script>
<script type="text/javascript" src="/path/to/{{$lang}}.min.js"></script>
<script type="text/javascript">
   hljs.highlightAll();
</script>
```

### Using a CDN

The module has not been published to any CDN right now. But you may pick a module from our
[Releases][] page.

<!--
### Using directly from the UNPKG CDN

```html
<script
  type="text/javascript"
  src="https://unpkg.com/highlightjs-{{$lang}}@0.1.0/dist/{{$lang}}.min.js"
></script>
```

- More info: <https://unpkg.com>
-->

### With Node or another build system

> The Node stuff is untested, just an adapted copy from some other highlight.js module!!!

If you're using Node / Webpack / Rollup / Browserify, etc, simply require the language module, then
register it with `highlight.js`.

```javascript
var hljs = require("highlight.js");
var hljsHugo = require("{{$lang}}");
hljs.registerLanguage("{{$lang}}", hljsHugo);
hljs.highlightAll();
```

### Example code

Enclose your code in `<pre><code>` tags and at best set the language with `class="{{$lang}}"`. If
you want to rely on auto detection, read the section about that below.

{{ with .Params.aliases }} {{ printf "Instead of `%s` you can use the defined aliases: %s." $lang
(delimit . "`, `" ) }} {{ end }}

```html
<pre><code class="hugo-html">
<title>{{ `{{.Title}}` }}</title>
</code></pre>
```

## A word on auto detection

_Handlebars_ and _Go templates_ (used by [Hugo][]) have similar template tags. Without additional
relevance settings Hugo grammars will loose most of the time. We use the following relevance
settings to beat _Handlebars_ auto-detection -- doing our best to make it possible to have both
grammars loaded at the same time. Importing both `hugo-text` and `hugo-html` may result in
undetermined auto-detection. To be on the safe side specify the language you want for every code
block.

- Go template comments get relevance = 10.

   comments start with {{ printf "`{{/*` or `{{- /*`" }} and end with `*/}}` or `\*/ -}}`

- Functions in the _hugo_ namespace get relevance = 10 (e.g. hugo.IsDevelopment)

- The following _Handlebars_ opening template tags are set to _invalid_ for hugo:
  {{ "`{{#`, `{{>`, `{{!--`, `{{!`" }}

   `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the
   hugo module.

## Build your own

The module works with the standard [Highlight.js][] extra build system. Download the grammar source
from our [Releases][] page and copy it to the `highlight.js/extra` directory. Check out the
[Highlight.js][] documentation for more details.
