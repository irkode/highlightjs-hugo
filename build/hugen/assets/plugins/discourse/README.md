# Discourse highlighting plugin for Hugo templates

Have you ever wondered why Hugo templates receive random highlighting with topics in the [Hugo
Forum][].

The answer is dead simple: Discourse uses [Highlight.js][] which lacks the support for _Go_ and
_Hugo_ templates. Due to automatic language detection the _best fit_ is taken which varies depends
on the content of the code block.

But it could look so nice:

![preview](plugins.png)

This is a brief overview of the Discourse plugin utilizing `hugo-text` and `hugo-html`. Refer to
these for details.

## Disclaimer

We will try to fix bugs, and handle enhancement requests. But please understand, that we cannot
support _Discourse_ or _Highlight.js_ in general. We are:

- totally bare with anything around Discourse (just using it). All the Knowledge is shown below ;-)
- not experienced in Highlight.JS (beyond these modules)

## Discourse Requirements

Actually we don't know. Here's the setup used for testing it:

- Windows 11 Professional
- installed WSL2 - Ubuntu 22.04
- followed this guide:
  [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)
  resulting in a runnable developer installation version 3.6.0.beta3-latest (end Oct 2025)
- followed this guide
  [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)
  to add the plugin

- [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
  That's a post from Jan 2019, so I expect most Instances will support it.

- Played around and felt we need to adjust something here.

## Trickery

We have some small glitches here.

- Autodetect _Hugo_ may be unreliable if other plugins (handlebars, go templates) are installed.
- The Discourse instance uses a selection box for the language in a code-block. But this only shows
  the registered languages but no aliases. Might be that alias is supported when typing, but we
  found no option to manually specify that while editing a topic.
- So we have to include hugo-html and hugo-text.
- Due to advanced highlighting these modules are quite large in size. Due to the separated nature of
  _Highlight.js_ plugins size will double.

## Download

The module has not been published to any CDN right now. You will have to clone or download the stuff
you need.

- tagged versions push back the highlight.js build results to the [dist folder][dist/] folder. You
  may use that with a custom build or take the CDN plugin from inside directly.
- Releases additionally provide artifacts for the standard pluginsreleased package from our
  [releases page](https://github.com/irkode/highlightjs-hugo/releases/latest).

## Use as Theme component

THis is a special build which includes the header and footer of the official API but reuses common
components. This will result in close to 50% smaller javascript.

Installation:

- you must have Highlight.js configured in your Instance
- create a new theme component
- copy paste the content of our [plugins/hugo-discourse-plugin.js]() to the JS section of your
  plugin.
- if you want to style the special classes provided. Add your classes to the CSS part of the theme
  component.

## License

This package is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Author & Maintainer

- Irkode <irkode@rikode.de>

## Links

- [highlightjs-hugo][] : The main repository with additional grammars and plugins. Have a look
- [Highlight.js][] : The Internet's favorite JavaScript syntax highlighter supporting Node.js and
  the web
- [Hugo][] : The world’s fastest framework for building websites
- [Go HTML template](https://pkg.go.dev/html/template) : Go's html template package
- [Go TEXT template](https://pkg.go.dev/text/template) : Go's text template package

[highlightjs-hugo]: {{ site.Params.repository }} [Highlight.js]: https://highlightjs.org/ [Hugo]:
https://gohugo.io/
