+++
title = "Highlight.js"
+++

# Highlight.js components

Highlight Hugo templates using Highlight.js also available as a Discourse Theme Component

![preview](img/highlightjs-hugo.png)

## Provided Grammars

- [hugo-html](hugo-html/)

   Highlight template code using our plugin and style surrounding HTML using [Highlight.js][]
   standard _XML_ grammar.

- [hugo-text](hugo-text/)

   Highlight template code using our plugin and just dump out surrounding text unstyled.

## Library files

- [hugo-lib](hugo-lib/)

   The shared library containing the grammar and keyword definitions. Needed to build on your own.
   Having that outside of the grammars results in just one copy if you use both grammars.

## Download

The grammars have not been published to any CDN right now. You will have to clone or download the
stuff you need.

- latest version of the grammars in the respective dist folders.
- a released package from our
  [releases page](https://github.com/irkode/highlightjs-hugo/releases/latest). Just grab the
  Highlight.js grammar or Discourse plugin you need

## Usage and Build

Please refer to the respective modules README.md.

## Contributing and Issues

Never say never, but currently it's our working playground so it's nothing where one could do stable
contributions right now.

If you find a bug, have a question or an idea, please use the _source repositories_ [Issue
tracker][].

{{% content-snippet "license-file.md" %}}

{{% content-snippet "authors.md" %}}

{{% content-snippet "links.md" %}}
