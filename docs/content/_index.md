+++
Title = "Highlight.js HuGo - Syntax grammar plugins for Highlight.js"
+++

Have you ever wondered why highlighted Hugo templates seem to be styled randomly in our [Hugo
Discourse Forum][].

The answer is dead simple: Discourse uses [Highlight.js][] which lacks the support for _Go_ and
_Hugo_ templates. Automatic language detection takes the _best match_ by relevance which varies on
code block contents.

It could look so nice:

![](/docs/static/highlightjs-hugo.png "Highlighting preview")

## Overview

To change that _HighlightJS Hugo_ delivers both necessary components:

- A [Highlight.js][] grammar for Hugo supporting HTML and TEXT templates.
- A [Discourse][] plugin for our custom grammar

We played a little and the result is a set of plugins that you may use depending on your
requirements.

## Standard plugins

These plugins follow the standard
[Highlight.js contribution checklist](https://highlightjs.readthedocs.io/en/latest/language-contribution.html).
Just drop the code in the `extra` folder and do
[build and test](https://highlightjs.readthedocs.io/en/latest/building-testing.html#building). Ready
to use plugins are available in the `dist` subfolder.
{{< list-regular-pages "dist" >}}

## Special plugins

The main intent is to reduce the size footprint when using both the HTML and TEXT variants. Our
keyword tables are huge because we support to styling _Hugo_ functions as _built-in_. This plugins
are about 50% in size compared to separately include both.

You have used them as-is. To be clear, they cannot be used in a custom highlight.js build. They have
been build based on the highlight.js build results and patched after. There's no aliasing here, just
two languages, no CSS tricks neccessary.
{{< list-regular-pages "plugins" >}}

## Download

We haven't published anything to a CDN for now. You have the following options

- Clone the [repository](https://github.com/irkode/highlightjs-hugo.git)

  You will find all ready to use plugins in our [dist
  folder][https://github.com/irkode/highlightjs-hugo/tree/main/dist]. Keep in mind that these are
  only updated when tagging. The main branches HEAD could be ahead.

  Clone a tag if you want to have the sources match the dist folder.

* Download from [Releases](https://github.com/irkode/highlightjs-hugo/releases/latest)

  Choose a Release and download your needed plugins from the attachment.

## Usage

General browser usage would be:

- include highlight.js standard build
- include the plugin you want.
- call HighlightAll.

Please check out the plugins documentation or the [Highlight.js][] docs.

## Build your own

Standard grammar plugins work with the
[highlight.js build system](https://highlightjs.readthedocs.io/en/latest/building-testing.html#building)

Special ones are patched variants that won't work with a normal highlight.js build.

## Contributing and Issues

We are on a 0.0.x development version for now. Expect things to change in any possible way. All
tagged versions should work as documented - and we also try to have our main branch in a working
state.

We never say never, but currently it's our working playground. We try to keep the results stable,
but will do heavy changes to the underlying framework without notice.

Nothing where one could do stable contributions right now.

If you find a bug, have a question or an idea, please use our [Issue tracker][].

## Hugo as a generator

Hugo is a powerful templating engine, and we utilize it to generate and assemble our plugins:

- fetch function names from hugoDocs pages
- generate keyword tables for the plugins
- generate plugin javascript code
- generate supplementary files needed for the [Highlight.js][] build system
- generate tests
- generate github README
- generate documentation

Take it as a nifty showcase how to use Hugo to generate _any_ type of file from content templates.

If you want to dig in, you'll find that stuff in
[build\hugen](https://github.com/irkode/highlightjs-hugo/tree/main/build/hugen)

## License ![License](/docs/static/site/MIT_blue_8456175678697763628.svg)

Release under [The MIT License (MIT)](https://mit-license.org/). See [LICENSE file](/docs/static/site/LICENSE) for details.

### External Components

These typically have their own license and copyright. Check out the their sites to get details.

- image and link render hooks: (c) [Veriphor][] - Apache 2.0 -
  [[source code](https://www.veriphor.com/articles/link-and-image-render-hooks/)]

## Author & Maintainer

- Irkode <irkode@rikode.de>

## Links

- [highlightjs-hugo][] : The main repository with additional grammars and plugins.
- [Highlight.js][] : The Internet's favorite JavaScript syntax highlighter supporting Node.js and
  the web
- [Hugo][] : The world’s fastest framework for building websites
- [Hugo Discourse Forum][] : The Hugo community - discussions and support
- [Go HTML template](https://pkg.go.dev/html/template) : Go's html template package
- [Go TEXT template](https://pkg.go.dev/text/template) : Go's text template package

[highlightjs-hugo]: https://github.com/irkode/highlightjs-hugo/
[Issue tracker]: https://github.com/irkode/highlightjs-hugo/issues
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[Hugo Discourse Forum]: https://discourse.gohugo.io/
[Discourse]: https://www.discourse.org/
[Veriphor]: https://www.veriphor.com/
