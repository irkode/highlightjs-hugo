# Highlight.js Hugo - Discourse highlighting plugin for Hugo templates

Every time a read a [Discourse topic](https://discourse.gohugo.io/) I wondered about the random
look of highlighted template code. [Highlight.js][] has no support for Go and Hugo templates.

To improve that the first was to implement standard [Highlight.js][] plugins.
I digged in Highlight.JS and came up with two syntax modules for _text_ and _html_ templates.

Bringing that to _Discourse_ was a different story but I wanted to be able to do my own tests there.
And here it is: A discourse plugin adding highlighting support for hugo text and html templates.

This is a brief overview of the Discourse plugin. Please check out the modules documentation for
details about `hugo-text` and `hugo-html`

![preview](plugins.png)

## Disclaimer

I will try to fix bugs, and handle enhancement requests. But please understand, that I cannot
support _Discourse_ or _Highlight.js in general. I'am
- totally bare with anything around Discourse (just an end user). My knowledge is shown below ;-)
- not experienced in Highlight.JS (beyond these modules)

## Discourse Requirements

Actually I don't know. Here's how I tested it on my machine:

* Windows 11 Professional
* installed WSL2 - Ubuntu 22.04
* followed this guide: [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)
  resulting in a runnable developer installation version 3.6.0.beta3-latest (end Oct 2025)
* followed this guide [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)
  to add the plugin

* [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
  That's a post from Jan 2019, so I expect most Instances will support it.

* Played around and felt I need some sort of customization.

## Trickery

We have some small problems here.
* Autodetect Hugo may be unreliable if other plugins (handlebars, go templates) are installed.
* The instance uses a selection box for the language in a code-block. But this only supports
  the registered languages and no alias. Might be that alias is supported when typing, but I found no option to manually specify that while editing a topic.
* So we have to include hugo-html and hugo-text.
* Due to enhances highlighting these modules are quite large in size cause all hugo functions are included and du to the separated nature of _Highlight.js_ plugins size will double.

## Use it like all the other plugins for Highlight.JS

If you have a running Discourse using Highlight.JS you may just
* just add as any standard plugin.
* build a custom Highlight.js variant containing our plugins as extra.

### Use as Theme component

We provide a special build which includes the header and footer of the official API but reuses common components.
This will result in close to 50% smaller javascript size.

Installation:
* you must have Highlight.js configured in your Instance
* create a new theme component
* copy paste the content of our [plugins/hugo-discourse-plugin.js]() to the JS section of your plugin.
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

[highlightjs-hugo]: {{ site.Params.repository }}
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
