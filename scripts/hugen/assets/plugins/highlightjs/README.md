# Highlight.js Hugo - Highlight.js Plugin (dual mode)

[![license](https://badgen.net/badge/license/MIT/blue)](LICENSE)

> This is the README for the _downsized_ Highlight.js variant of the suite.
> For more details have a look at our [repository README]({{ site.Params.repository }}).

A language grammar to highlight [Hugo][]'s templating language with [Highlight.js][].

Including both modules - [hugo-text][] and [hugo-html][] results in larger Javascript footprint. Highlight.js
does not support reusing language components between different plugins.

To overcome this, we created a custom plugin which is close to 50% in size, supporting `text`and `html`templates.

![preview](plugins.png)

## Requirements

The module has been implemented using [Highlight.js][] version 11.11.1. It will most likely not work with an older version.

## Download

The module has not been published to any CDN right now. You will have to clone or download the stuff you need.
- latest version from the [dist folder][]
- a released package from our [releases page]({{ .site.Params.releases}}).

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

<!-- TODO: publish to a CDN
### Using a CDN

The module has not been published to any CDN right now. just download it from the dist folder

### Using directly from the UNPKG CDN

```html
<script
   type="text/javascript"
   src="https://unpkg.com/highlightjs-hugo-highlightjs-plugin@0.1.0/dist/hugo-highlightjs-plugin.min.js"
></script>
```

-  More info: <https://unpkg.com>
-->

### With Node or another build system

> I suppose these instructions from the docs won't work for this patched plugin.
> In fact _this_ customized_ plugin is only tested visually in the browser.

If you're using Node / Webpack / Rollup / Browserify, etc, simply require the language module, then register it with
`highlight.js`.

```javascript
var hljs = require("highlight.js");
var hljsHugo = require("hugo-highlightjs-plugin.js");
/* guess the registration is done when importing the plugin */
/* hljs.registerLanguage("???", hljs-???); */
hljs.highlightAll();
```

### Example code

Enclose your code in `<pre><code>` tags and at best set the language with `class="hugo-(html|text)"`. If you want to rely on
auto detection, read the section about that below.

```html
<pre><code class="hugo-html">
<title>{{ `{{.Title}}` }}</title>
</code></pre>
```

_Handlebars_ and _Go templates_ (used by [Hugo][]) have similar template tags. Without additional
relevance settings Hugo modules will loose most of the time. We use the following relevance settings
to beat _Handlebars_ auto-detection but doing our best to make it possible to have both modules
loaded at the same time. Importing `hugo-text` and `hugo-html` plugins may result in undetermined
auto-detection. To be on the safe side specify the language you want for every code block.

- Go template comments get relevance = 10.

  comments start with {{ "`{{/*` or `{{- /*` and end with `*/}}` or `*/ -}}`" }}

- Functions in the _hugo_ namespace get relevance = 10 (e.g. hugo.IsDevelopment)

- The following _Handlebars_ opening template tags are set too _invalid_ for hugo: {{ "`{{#`, `{{>`, `{{!--`, `{{!`" }}
 
  `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the hugo module.

## Build your own

This is a post build patched plugin that merges _hugo-html_ and _hugo-text_ into one plugin using the same keyword table.

It cannot in any way build with a standard _Highlight.js_ build.

## License

This package is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Author & Maintainer

- Irkode <irkode@rikode.de>

## Links

- [highlightjs-hugo][] : The main repository with additional grammars and plugins. Have a look
- [Highlight.js][] : The Internet's favorite JavaScript syntax highlighter supporting Node.js and the web
- [Hugo][] : The world’s fastest framework for building websites
- [Go HTML template](https://pkg.go.dev/html/template) : Go's html template package
- [Go TEXT template](https://pkg.go.dev/text/template) : Go's text template package

[highlightjs-hugo]: {{ site.Params.repository }}
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[dist folder]: {{ site.Params.blobs }}/dist/plugins/dist/highlightjs
