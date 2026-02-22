# Highlight.js Hugo - Discourse highlighting plugin for Hugo templates

Every time a read a [Discourse topic](https://discourse.gohugo.io/) I wondered about the random
look of highlighted template code. The answer is dead simple: Discourse uses [Highlight.js][] which
has no support for Go and Hugo templates.

To get highlighting, we first needed [Highlight.js][] grammars for Hugo templates. These are also available in our [highlightjs-hugo][] repository.

Discourse provides some "extension points" where you can add your own functionality. The easiest I came up was a _Theme component_ where you can add some piece of javascript to a _Theme_.

And here we are: Two Discourse theme components based on our [Highlight.js][] grammars, adding support for _text_ and _html_ sources.

This is a brief overview of the Discourse plugin. Please check out the grammars documentation for
details about `hugo-text` and `hugo-html`

![preview](plugins.png)

## Disclaimer

The plugins are provided AS-IS and only tested with the below dev installation of discourse.

If these don't work for you, we're most likely not able to support. 

- totally bare with anything around Discourse (just an end user). The complete Discourse knowledge is shown within the plugin.

## Discourse Requirements

Actually No idea - Here's how we installed a development version:

* Windows 11 Professional
* WSL2 - Ubuntu 22.04
* Installed using This guide: [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)

  resulting in a runnable developer installation version 3.6.0.beta3-latest (end Oct 2025)

* Add Theme Component [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)
  to add the plugin

* [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
  That's a post from Jan 2019, so I expect most Instances will support it.

### Use as Theme component

We provide ready to use _Discourse Plugins_ to be used as -Theme Components_

Installation:
* you must have Highlight.js configured in your Instance
* create a new _Theme Component_
* either upload the zip from the our [releases page]({{ .site.Params.releases}})
  or
* copy paste the content of our the `theme-initializer.gjs` to the JS section of your component.
* if you want to style the special classes provided. Add your classes to the CSS part of the theme component.

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

[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[highlightjs-hugo]: {{ site.Params.repository }}
