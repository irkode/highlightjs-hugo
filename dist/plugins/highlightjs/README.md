# Highlight.js 4 Hugo - Highlight.js Plugin (dual mode)

[![license](https://badgen.net/badge/license/MIT/blue)](LICENSE)

This is the README for the downsized Highlight.js plugin of the suite.

A language grammar to highlight [Hugo][]'s templating language with [Highlight.js][].

Including both modules - [hugo-text][] and [hugo-html][] results in larger Javascript footprint. Highlight.js
does not support reusing language components between different plugins.

To overcome this, we created a custom highlight.js plugin which is close to 50% in size.

![preview](preview.png)

## Disclaimer

I will try to fix bugs, and handle enhancement requests. But please understand, that for issues
falling in these areas ... I cannot help. I'm
- totally bare with anything around Discourse (just an end user)
- not experienced in Highlight.JS (beyond these modules)

## Requirements

The module has been implemented using [Highlight.js][] version 11.11.1.

It will most likely not work with an older version.

## Usage

Include the `highlight.js` library in your webpage or Node app, then load this module.

### Static website or simple usage

Load the module after loading `highlight.js`. Take the minified version from `dist` directory.

```html
<script type="text/javascript" src="/path/to/highlight.min.js"></script>
<!->
<script type="text/javascript" src="/path/to/hugo-highlightjs-plugin.js"></script>
<script type="text/javascript">
  hljs.highlightAll();
</script>
```

### Using a CDN

The module has not been published to any CDN right now. just download it from the dist folder

<!-- TODO: publish to a CDN

### Using directly from the UNPKG CDN

```html
<script
   type="text/javascript"
   src="https://unpkg.com/highlightjs-{{$lang}}@0.1.0/dist/{{$lang}}.min.js"
></script>
```

-  More info: <https://unpkg.com>
-->

### With Node or another build system

> The Node stuff is untested !!!

If you're using Node / Webpack / Rollup / Browserify, etc, simply require the language module, then register it with
`highlight.js`.

```javascript
var hljs = require("highlight.js");
var hljsHugo = require("{{$lang}}");
hljs.registerLanguage("{{$lang}}", hljs-{{title $lang}});
hljs.highlightAll();
```

### Example code

Enclose your code in `<pre><code>` tags and at best set the language with `class="{{$lang}}"`. If you want to rely on
auto detection, read the section about that below.

{{ with .page.Params.hljs.aliases }}
Instead of `{{$lang}}` you can use the defined aliases: `{{ delimit . "`, `" }}`.
{{ end }}

```html
<pre><code class="hugo-html">
<title>{{ `{{.Title}}` }}</title>
</code></pre>
```

## A word on auto detection

> We have both modules included, so **do not** rely on auto detection but specify language names inh the class attribute.

_Handlebars_ and _Go templates_ (used by [Hugo][]) have similar template tags. Without additional relevance settings the
Hugo modules will loose most of the time. To beat Handlebars auto-detection for _Hugo_ templates we add relevance
settings. Doing our best to make it possible to have both modules loaded at the same time. Importing `hugo-text` and
`hugo-html` plugins may result in undetermined auto selection.
To be on the safe side specify the language you want for every code block.

- for Go template comments we use relevance = 10.

  comments start with {{ "`{{/*` or `{{- /*` and end with `*/}}` or `*/ -}}`" }}

- functions in the _hugo_ namespace use relevance = 10 (e.g. hugo.IsDevelopment)

- We mark the following _Handlebars_ opening template tags as invalid for us: {{ "`{{#`, `{{>`, `{{!--`, `{{!`" }}

  `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the hugo module

## Build your own

This plugin is created from the standard Highlight.js build results. Which means, you cannot include izt in a custom Highlight.js build.

## License

This package is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Author & Maintainer

- Irkode <irkode@rikode.de>

### Other references

- [Highlight.js][]
- [Hugo][]
- [Go HTML template](https://pkg.go.dev/html/template)
- [Go TEXT template](https://pkg.go.dev/text/template)

[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
