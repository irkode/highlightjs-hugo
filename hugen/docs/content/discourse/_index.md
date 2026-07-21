+++
Description = "Discourse theme components that wrap the Highlight.js Go and Hugo grammars for correct template highlighting in Discourse forums."
Title = "Discourse Theme Components"
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

You don't have to be that colorful. Have a look at the [Discourse Example](/discourse/examples) and
[Hugo examples](/hugo/examples) to see how it could look like.

## Download

Packages can be downloaded from:
[Releases](https://github.com/irkode/highlightjs-hugo/releases/latest).

- Discourse theme components
  [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)

  The archive contains all four theme components -- packed ready for import into discourse.

## Usage

- you must have Highlight.js configured in your Instance
- Download
  [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)
- Extract to the downloaded archive to a folder of your choice. After extraction the folder contains the ready-to-import theme component archives -- also zip files.
- login as admin to discourse and create a new theme component.
   - either import one of the archives extracted before

   or
   - select your archive, extract it and copy the content of the contained `theme-initializer.gjs` to the JS section
     of your new _Theme component_.

Standard Styles should already be active in your instance. To take advantage of the special
scopes (eg _template variables or _context_ have a look [CSS class reference](/highlightjs/css-class-reference). Add these to
- your standard CSS
- the just created theme component
- to an own dedicated component just for styling.

Even without you will gain immediate effect of proper highlighted templates.

## Discourse Requirements

The theme components are tested in virtual machines hosted on Windows 11 Professional

- [Discourse Dev Container](https://meta.discourse.org/t/developing-discourse-using-a-dev-container/336366?silent=true)
   - Discourse 2026.6.0-latest
   - Ubuntu 26.04 Desktop
   - Hyper-V

- [Install a DEV Environment on Windows 11](https://meta.discourse.org/t/guide-to-setting-up-discourse-development-environment-windows-11/282227)[^1]
   - Discourse 3.6.0.beta3-latest (end Oct 2025)
   - Ubuntu 22.04
   - WSL

- References:
   - [API mentioned here](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480).
   - [add language using theme component](https://meta.discourse.org/t/install-a-new-language-for-highlight-js-via-a-theme-component/292480)

## Support

Use the [issue tracker](https://github.com/irkode/highlightjs-hugo/issues) for feedback, issues, ideas...

[^1]: deprecated, but much faster than the dev container in a VM
