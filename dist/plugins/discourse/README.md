# Highlight.js 4 Hugo - Discourse Plugin for Hugo templates

Being an active member in the Hugo Discourse Forum for quite a while I always wondered why
there's no syntax highlighting for It's templates in the Forum. Shouldn't be a problem I thought.
So I digged in Highlight.JS and came up with two syntax modules for text and html templates of Hugo.

Bringing that to discourse was another Story but I wanted to be able to do my own tests there.
Finally here it is: A discourse plugin adding highlighting support for hugo text and html templates.

This is a brief overview of the Discourse plugin. Please check out the modules documentation for
details about `hugo-text` and `hugo-html`

![preview](preview.png)

## Disclaimer

I will try to fix bugs, and handle enhancement requests. But please understand, that for issues
falling in these areas ... I cannot help. I'm
- totally bare with anything around Discourse (just an end user)
- not experienced in Highlight.JS (beyond these modules)

## Discourse Requirements

Actually I don't know. Here's how I tested it on my machine:

* installed WSL2 - Ubuntu 22.04
* followed this guide: [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)
  which lead to a developer installation version 3.6.0.beta3-latest (end Oct 2025)
* followed this guide [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)
  to add the plugin

* [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
  That's a post from Jan 2019, so I expect most Instances will support it.

* Played around and felt I need some sort of customization.

## Trickery

We have some small problems here.
* Autodetect Hugo may be unreliable if other plugins (handlebars, go templates) are installed.
* The instance uses a selection box for the language in a code-block. But this only supports
  the registered languages and no alias. So we have to include hugo-html and hugo-text.
* We are quite large in size cause all hugo functions are included and a two time installation will double it.
  Using all available aliases raises that to three.

## Use it like all the other plugins for Highlight.JS

If you have a running Discourse using Highlight.JS you may just
* use our CDN plugins as you do with others.
* build a custom Highlight.js variant containing our plugins as extra.

### Use as Theme component

We provide a special build which includes the header and footer for the official API but reuses common components.
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

### Other references

- [Highlight.js][]
- [Hugo][]
- [Go HTML template](https://pkg.go.dev/html/template)
- [Go TEXT template](https://pkg.go.dev/text/template)

[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
