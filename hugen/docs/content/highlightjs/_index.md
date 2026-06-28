+++
title = "Highlight.js"
+++

# Highlight.js Grammars

Highlight _Hugo templates_ using Highlight.js with additional styles for _HuGo_ specific tokens.

```hugo-html {style="colorful"}
{{ printf "Autodetect Hello %s -> %s" $World .}}
{{- /*  printf "ONE second line */ -}}
<div class="help"/>
{{ range $k, $v := hugo.Generator $ $.Method -}}
{{ site.Language.Label }}
{{ hugo.Sites.Pages }}
```

You don't have to be that colorful. If you have a a working setup, just adding new scopes will be a good choice.
Have a look at the [Discourse examples](/discourse/examples) and [Hugo examples](/hugo/examples) to see how it could look like.

## Provided Grammars

The modules support Html Text Templates and the _Hugo_ variant has full Hugo keyword and built_in support.

- [hugo-html](hugo-html/) and [go-html](go-html/)

   Highlight template code and style surrounding HTML using [Highlight.js][]
   standard _XML_ grammar.

- [hugo-text](hugo-text/) and [go-text](go-text/)

   Highlight template code and just dump out surrounding text unstyled.

## Library files

- hugo-lib

   The shared library containing grammar and keyword definitions.

   This one is created based on Hugo's (or Go) keywords and contains the _token, regex_ part of the grammars.

   With this one referenced from outside the grammar a custom Highlight.js build will pack it only
   once to the core. Saves around 10kB uncompressed in the final engine if both Hugo grammars.

## Download

Packages can be downloaded from: [Releases](https://github.com/irkode/highlightjs-hugo/releases/latest)[^1].

- Ready to use javascripts: [highlightjs-hugo-jsmodules.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-js-modules.zip)
- Grammar sources to build on your own: [highlightjs-hugo-extra-src.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-extra-src.zip)

### Custom Highlight.js build

To build your own customized _Highlight.js_ installation grab the _highlightjs-hugo.zip_ release asset and
extract it in the extra folder of your _Highlight.js_ clone. Build using Highlight.js standard extra build.

## Usage

The language plugins work just like any other extra one.

### Extended use cases

* [Use on Discourse](../discourse)
* [Use with Hugo](../hugo)

[^1]: Draft- and pre-releases have to be manually browsed and downloaded.