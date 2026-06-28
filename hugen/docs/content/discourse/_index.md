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

The theme components are tested in virtual machines hosted on Windows 11 Professional

- [Discourse Dev Container](https://meta.discourse.org/t/developing-discourse-using-a-dev-container/336366?silent=true)

   - Discourse 2026.6.0-latest
   - Ubuntu 26.04 Desktop
   - Hyper-V

- [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)

   - Discourse 3.6.0.beta3-latest (end Oct 2025)
   - Ubuntu 22.04
   - WSL

### References:

- [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
- [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)

## Support

Feedback, issues[^2], and ideas are welcome

https://github.com/irkode/highlightjs-hugo/issues


[^1]: Draft- and pre-releases have to be manually browsed and downloaded.
[^2]: component related issues only