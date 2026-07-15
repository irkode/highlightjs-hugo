+++
title = "Highlight.js Grammars"
+++

Highlight _HuGo_ templates using Highlight.js with additional styles for _HuGo_ specific tokens.

```hugo-html {style="colorful"}
{{ printf "Autodetect Hello %s -> %s" $World .}}
{{- /*  printf "ONE second line */ -}}
<div class="help"/>
{{ range $k, $v := hugo.Generator $ $.Method -}}
{{ site.Language.Label }}
{{ hugo.Sites.Pages }}
```

You don't have to be that colorful. If you have a a working setup, just adding new scopes will be a
good choice. Have a look at the [Discourse examples](/discourse/examples) and
[Hugo examples](/hugo/examples) to see how it could look like.

## Requirements

The modules need Highlight.js v11.11.1 and are tested to work with v11.11.2.

## Usage

Include the `highlight.js` library in your webpage or Node app, then load this module.

> Replace LANGUAGE with the language name of the grammar you want to use.

### Static website or simple usage

Load the module after loading `highlight.js`.

```html
<script type="text/javascript" src="/path/to/highlight.min.js"></script>
<script type="text/javascript" src="/path/to/LANGUAGE.min.js"></script>
<script type="text/javascript">
   hljs.highlightAll();
</script>
```

### Using a CDN

No CDN published version.

### With Node or another build system

> There's no official node packages. But guess you can combine a node installation and our plugins.
> have a look at the highlight.js source Asset. Maybe that fits for you The Node stuff is untested,
> just an adapted copy from some other highlight.js module!!!

If you're using Node / Webpack / Rollup / Browserify, etc, simply require the language module, then
register it with `highlight.js`.

```javascript
global.hljs = require("highlight.js");
require("./extra/LANGUAGE/dist/LANGUAGE.min.js");
hljs.highlightAll();
```

## Example

Enclose your code in `<pre><code>` tags and at best set the language with `class="LANGUAGE"`. If you
want to rely on auto detection, read the section about that below.

```html
<pre><code class="hugho-html">
<title>{{ `{{.Title}}` }}</title>
</code></pre>
```

## Extended use cases

- [Use on Discourse](../discourse)
- [Use with Hugo](../hugo)

## Download

Packages can be downloaded from:
[Releases](https://github.com/irkode/highlightjs-hugo/releases/latest).

- Ready to use javascripts:
  [highlightjs-hugo-jsmodules.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-js-modules.zip)
- Grammar sources to build on your own:
  [highlightjs-hugo-extra-src.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-extra-src.zip)

## Custom Highlight.js build

The module works with the standard Highlight.js extra build system. Download the grammar source from
Releases and extract to `highlight.js/extra` directory. Check the
[Highlight.js documentation](https://highlightjs.readthedocs.io/en/latest/index.html) for more
details.

### h4h-lib

The shared library containing grammar and keyword definitions. Make sure it's also in the _extra_
folder.

This one is created based on Hugo's (or Go) keywords and contains the _token, regex_ part of the
grammars.

With this one referenced from outside the grammar a custom Highlight.js build will pack it only once
to the core. Saves around 10kB uncompressed in the final engine if both Hugo grammars.
