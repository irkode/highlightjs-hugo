# Highlightjs Hugo - Advanced syntax highlighting for Hugo templates

Every time a read a [Discourse topic](https://discourse.gohugo.io/) I wondered about the random look of
highlighted template code. [Highlight.js][] has no support for Go and Hugo templates.

But it could look so nice

![preview](highlightjs-hugo.png)

## Introduction

To improve that the first was to implement [Highlight.js][] grammars. I digged in Highlight.JS and came up with
two syntax modules for _text_ and _html_ templates.

Both supporting the full set of Hugo's template keywords, built-in functions and aliases.

## Provided plugins

Here's the list of our provided plugins. browse the folders to dig into details.

### Standard Highlight.js grammars

These can be used as any other extra grammar. Just dump that to your extra folder and do a custom Highlight.js build.

- [hugo-html](dist/hugo-html/)

  Highlight template code using our plugin and style surrounding HTML using [Highligh.js][] standard _xml_

- [hugo-text](dist/hugo-text/)

  Highlight template code using our plugin and just dump out surrounding text unstyled.

- [hugo-embed](dist/hugo-embed/)

  Same as _hugo-text_ but with autodetection disabled. This plugin is reserved for internal and future use.

### Discourse theme components

These can be used by either copying the initializer to a theme component or import the distribution zip file.

- [discourse/hugo-html](dist/discourse/hugo-html/)

  Highlight template code using our plugin and style surrounding HTML using [Highligh.js][] standard _xml_

- [discourse/hugo-text](dist/discourse/hugo-text/)

  Highlight template code using our plugin and just dump out surrounding text unstyled.

## Download

The modules have not been published to any CDN right now.

- a released package from our [releases page](https://github.com/irkode/highlightjs-hugo/releases/latest).
  Just grad the Highlight.js language or Discourse plugin you need
- build them yourself

## Usage

Please refer to the respective modules README.md.

## Build your own

The two language modules work with the standard [Highlight.js][] custom build system. Check out their docs for
details.

Please make sure to also copy the hugo-lib content to the extra folder. this is the language base for the plugins.

## Contributing and Issues

I would never say never, but currently it's our working playground so it's nothing where one could do stable
contributions right now.

If you find a bug, have a question or an idea, please use the [Issue tracker][].

## Hugo as a generator

Hugo is a powerful templating engine, and we utilize it to generate and assemble our grammars and discourse plugins.

- fetch function names from hugoDocs pages
- generate keyword tables for the plugins
- generate the hugo-lib module (grammar and keyword tables)
- generate javascript code and supplementary files
- create github READMEs
- generate tests
- push the highlight.JS build results to our dist folder
- generate Discourse plugins based on the build results

- and ofc as the standard use case - generate a documentation site

Take it as a nifty showcase for utilizing Hugo as a templating and publishing engine beyond web sites.

If you want to dig in, you'll find the site source at [build\hugen](build\hugen)

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

[highlightjs-hugo]: https://github.com/irkode/highlightjs-hugo/
[Issue tracker]: https://github.com/irkode/highlightjs-hugo/issues
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
