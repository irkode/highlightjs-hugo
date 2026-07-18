+++
Description = "Discourse theme components that wrap the Highlight.js Go and Hugo grammars for correct template highlighting in Discourse forums."
Title = "Discourse"
+++

Wrapped [HighlightJS grammars](/highlightjs) in _Discourse theme components_.

```hugo-html {style="colorful"}
{{ printf "discourse Hello %s -> %s" $World .}}
{{- /*  printf "ONE second line */ -}}
<div class="help"/>
{{ range $k, $v := hugo.Generator $ $.Method -}}
{{ site.Language.Label }}
{{ hugo.Sites.Pages }}
```

You don't have to be that colorful. Adding new wanted styles to your working styles will be a good
choice. Have a look at the [Discourse Example](/discourse/examples) and
[Hugo examples](/hugo/examples) to see how it could look like.

## Download

Packages can be downloaded from:
[Releases](https://github.com/irkode/highlightjs-hugo/releases/latest).

- Discourse theme components
  [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)

## Usage

- you must have Highlight.js configured in your Instance
- Download
  [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)
- Extract to a folder of your choice. You will get all four components as archive file.
- create a new _Theme Component_
   - either import an archive of your choice

   or
   - extract one of the archives and copy the content of `theme-initializer.gjs` to the JS section
     of your new _Theme component_.

You should have the styles for the standard scopes available. To take advantage of the special
scopes have a look [CSS class reference](/highlightjs/css-class-reference).[^1]

Even without you will gain immediate effect of proper highlighted templates.

## Discourse Requirements

The theme components are tested in virtual machines hosted on Windows 11 Professional

- [Discourse Dev Container](https://meta.discourse.org/t/developing-discourse-using-a-dev-container/336366?silent=true)
   - Discourse 2026.6.0-latest
   - Ubuntu 26.04 Desktop
   - Hyper-V

- [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)[^2]
   - Discourse 3.6.0.beta3-latest (end Oct 2025)
   - Ubuntu 22.04
   - WSL

- References:
   - [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
   - [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)

## Support

Use the issue tracker for feedback, issues, ideas

https://github.com/irkode/highlightjs-hugo/issues

[^1]: add the styles to one of the components or create a pure styling one.

[^2]: deprecated, but much faster than the dev container in a VM
