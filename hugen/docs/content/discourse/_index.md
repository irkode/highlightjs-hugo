+++
title = "Discourse"
+++

# Discourse components

Wrapped [HighlightJS grammars](/highlightjs) in _Discourse theme components_.

```hugo-html {style="colorful"}
{{ printf "discourse Hello %s -> %s" $World .}}
{{- /*  printf "ONE second line */ -}}
<div class="help"/>
{{ range $k, $v := hugo.Generator $ $.Method -}}
{{ site.Language.Label }}
{{ hugo.Sites.Pages }}
```

You don't have to be that colorful. Adding new wanted styles to your working styles will be a good choice.
Have a look at the [Discourse Example](/discourse/examples) and [Hugo examples](/hugo/examples) to see how it could look like.

## Download

Packages can be downloaded from: [Releases](https://github.com/irkode/highlightjs-hugo/releases/latest)[^1].

- Discourse theme components [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)

## Usage

- you must have Highlight.js configured in your Instance
- create a new _Theme Component_
- either grab a zip from our [Releases][] page and import.

   or

- download the above zip and just copy the content of the `theme-initializer.gjs` to the JS section
  of your _Theme component_.
- To style the custom scopes add your stylesheet to the CSS section.

## Discourse Requirements

Actually No idea - Here's the one and only test environment:

- Windows 11 Professional
- WSL2 - Ubuntu 22.04
- Installed using this guide:
  [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)
  resulting in a runnable developer installation version 3.6.0.beta3-latest (end Oct 2025)

- [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
  That's a post from Jan 2019, expected to be widely supported.

- Follow [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)
  to add the plugin

## Disclaimer

The plugins are provided AS-IS and only tested with the below dev installation of Discourse.

If these don't work for you, please raise an issu providing as many details as you can.
At best you tracked down the problem and can point somewhere to fix.

[^1]: Draft- and pre-releases have to be manually browsed and downloaded.