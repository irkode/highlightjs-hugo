+++
title = "Hugo-Tpl"
description = """
  Surrounding text is highlighted using [Highlight.js][] standard XML grammar.
  This plugin defines `hugo-html` and `hugo-text` as aliases, which allows to remove the highlighting of the surrounding HTML by adding CSS rules.
"""
+++

> This is the README for the **Hugo-Tpl** variant of the suite.\
> there are some other variants. Check out our [repository README](https://github.com/irkode/highlightjs-hugo) for details.

A language grammar to highlight [Hugo][]'s templating language with [Highlight.js][].

- [CSS class reference](css-class-reference.md)

![](hugo-tpl.png "Highlighting preview for HTML+TEXT dual mode")

## Requirements

The module has been implemented using [Highlight.js][] version 11.11.1. It will most likely not work with an older version.

## Download

The module has not been published to any CDN right now., you will have to clone or download the stuff you need.

- tagged versions are pushed to the dist folder of our repo [dist folder][]
- release packages can be downloaded from our [releases page](https://github.com/irkode/highlightjs-hugo/releases/latest) per module.

## Usage

Include the `highlight.js` library in your webpage or Node app, then load this module.

### Static website or simple usage

Load the module after loading `highlight.js`.

```html
<script type="text/javascript" src="/path/to/highlight.min.js"></script>
<script type="text/javascript" src="/path/to/hugo-tpl.min.js"></script>
<script type="text/javascript">
  hljs.highlightAll();
</script>
```

<!-- TODO: publish to a CDN

### Using a CDN

The module has not been published to any CDN right now. Download the latest working build from the [dist folder][] or a release package from our [released page](https://github.com/irkode/highlightjs-hugo/releases/latest).

### Using directly from the UNPKG CDN

```html
<script
   type="text/javascript"
   src="https://unpkg.com/highlightjs-hugo-tpl@0.1.0/dist/hugo-tpl.min.js"
></script>
```

-  More info: <https://unpkg.com>
-->

### With Node or another build system

> The Node stuff is untested and straight from some other highlight.js module!!!

If you're using Node / Webpack / Rollup / Browserify, etc, simply require the language module, then register it with `highlight.js`.

```javascript
var hljs = require("highlight.js");
var hljsHugo = require("hugo-tpl");
hljs.registerLanguage("hugo-tpl", hljsHugo);
hljs.highlightAll();
```

### Examples

Instead of `hugo-tpl` we recommend to use tha aliases `hugo-html` and `hugo-text`.
Auto detection with both languages available might not be the best idea.
If you still want to rely on [auto detection](#a-word-on-auto-detection), read the section about that below.

### Example code with HTML highlighting

Enclose your code in `<pre><code class="hugo-html">` tags to force HTML highlighting.

```html
<div class="html example">
  <pre>
    <code class="hugo-html">
      <title>{{.Title}}</title>
    </code>
  </pre>
</div>
```

### Example code without HTML highlighting

Enclose your code in `<pre><code class="hugo-text">` tags to allow suppression of HTML highlighting.

```html
<div class="text example">
  <pre>
    <code class="hugo-text">
      <title>{{.Title}}</title>
    </code>
  </pre>
</div>
```

To suppress the styling of the generated language-xml classes, add CSS styling for `hugo-text`.
Something like that will do. Adjust the values to match your _unstyled_ settings.

  ```css
  /* change these to match your 'standard' for non-highlighted code */
  code.hugo-text span.language-xml {
    text-decoration: none;
  }
  code.hugo-text span.language-xml * {
    font-style: none;
    font-weight: normal;
    background: darkgray;
    color: #444;
  }
  ```

## A word on auto detection

_Handlebars_ and _Go templates_ (used by [Hugo][]) have similar template tags. Without giving some hints,
Hugo modules will loose most of the time.

We use the following relevance settings to beat _Handlebars_ auto-detection, doing our best to make it
possible to have both modules loaded at the same time.

- Go template comments get relevance = 10.

  comments start with `{{/*` or `{{- /*` and end with `*/}}` or `*/ -}}`

- Functions in the _hugo_ namespace get relevance = 10 (e.g. hugo.IsDevelopment)

- The following _Handlebars_ opening template tags are set to _invalid_ in a hugo grammar: `{{#`, `{{>`, `{{!--`, `{{!`

  `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the hugo module.

When importing `hugo-text` and `hugo-html` plugins auto-detection result is undetermined. To be on the safe side
specify the language you want for every code block especially.

## Build your own

The module works with the standard [Highlight.js][] custom build system. Copy needed folders from your download or -- if
you cloned our repo -- to the highlight.js extra directory. Check out the [Highlight.js][] documentation for more
details.

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

[highlightjs-hugo]: https://github.com/irkode/highlightjs-hugo
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[dist folder]: https://github.com/irkode/highlightjs-hugo/blob/main/dist/hugo-tpl/dist/
