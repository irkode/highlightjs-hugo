# Highlightjs Hugo - Advanced syntax highlighting for Hugo templates using Highlight.js

Every time a read a [Discourse topic](https://discourse.gohugo.io/) I wondered about the random
look of highlighted template code. [Highlight.js][] has no support for Go and Hugo templates.

But it could look so nice

![preview](highlightjs-hugo.png)

## Introduction

To improve that the first was to implement standard [Highlight.js][] plugins.
I digged in Highlight.JS and came up with two syntax modules for _text_ and _html_ templates.

Our keyword tables are hugo cause we support to style _Hugo_ functions as _built-in_. So we also provide a patched plugin with both language variants but sharing the same keyword table.

Bringing that to _Discourse_ was a different story but I wanted to be able to do my own tests there.

## Provided plugins

Here's the list of our provided plugins. browse the folders to dig into details.

- [hugo-html](dist/hugo-html/)

  highlight template code using our plugin and style surrounding HTML using [Highligh.js][] standard _xml_

- [hugo-text](dist/hugo-text/)

  highlight template code using our plugin and just dump out surrounding text unstyled.

- [hugo-highlightjs-plugin](dist/plugins/highlightjs/)

  downsized variant as a standalone plugin.

- [hugo-discourse-plugin](dist/plugins/discourse/)

  downsized variant bundled as Discourse plugin.

## Download

The module has not been published to any CDN right now. You will have to clone or download the stuff you need.
- latest version from the [dist folder][dist/]
- a released package from our [releases page](https://github.com/irkode/highlightjs-hugo/releases/latest).

## Usage

Please refer to the respective README.md.

## Build your own

The two language modules work with the standard [Highlight.js][] custom build system. Check out their docs for details.bundling these (or just one) and other languages you need.

The other two are patched variants of the both above. We generate these based on a standard build results. The build process works, but it heavily depends on _undocumented internals_.

## Hugo as a generator

Hugo is a powerful templating engine, and we utilize it to generate and assemble our plugins:
- fetch function names from hugoDocs pages
- generate keyword tables for the plugins
- generate plugin javascript code
- generate supplementary files needed for the [Highlight.js][] build system
- generate tests
- generate README

Take it as a hacky showcasehow to use Hugo to generate _any_ files from content templates.

If you want to dig in, you'll find the site source at [scripts\hugen](scripts\hugen)

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
