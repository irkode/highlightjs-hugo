+++
title = "Highlight.js"
weight = "20"
+++

# Highlight.js components

Highlight Hugo templates using Highlight.js also available as a Discourse Theme Component

![preview](highlightjs-hugo.png)

This is the release repository of [highlightjs-hugo][].

For details check out each grammars README or consult our [Documentation][]

## Provided Grammars

- [hugo-html](hugo-html/)

  Highlight template code using our plugin and style surrounding HTML using [Highlight.js][]
  standard _xml_

- [hugo-text](hugo-text/)

  Highlight template code using our plugin and just dump out surrounding text unstyled.

## Library files

- [hugo-lib](hugo-lib/)

  The shared library containing the grammar and keyword definitions. Needed to build on your own.
  Having that outside of the grammars results in just one copy if you use both grammars.

## Discourse Theme Components

- [Discourse hugo-html](discourse/hugo-html/)

  Theme Component for Hugo HTML templates.

- [Discourse hugo-text](discourse/hugo-text/)

  Theme Component for Hugo TEXT templates.

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

## License

This package is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Author & Maintainer

- Irkode <irkode@rikode.de>

## Links

- [highlightjs-hugo][] : The source and documentation repository

- [Highlight.js][] : The Internet's favorite JavaScript syntax highlighter supporting Node.js and
  the web
- [Hugo][] : The world’s fastest framework for building websites
- [Go HTML template](https://pkg.go.dev/html/template) : Go's html template package
- [Go TEXT template](https://pkg.go.dev/text/template) : Go's text template package

[highlightjs-hugo]: https://github.com/irkode/highlightjs-hugo/
[Documentation]: https://irkode.github.io/highlightjs-hugo/
[Issue tracker]: https://github.com/irkode/highlightjs-hugo/issues
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[Discourse]: https://discourse.gohugo.io/
[Releases]: https://github.com/irkode/highlightjs-hugo/releases/latest
