+++
title = "Advanced syntax highlighting for HuGo templates"
+++

Did you ever wonder why hugo templates seem to be randomly highlighted in [Hugo's Discourse Forum](https://discourse.gohugo.io/)?

This is due to the use of [Highlight.js](https://highlightjs.org/), which does not natively support Go or Hugo templates. As a result, automatic language detection selects a best match, leading to incorrect or misleading highlighting.

## Features

<!--more-->

### Highlight.js Grammars

* Support for:

  * Hugo and Go templates
  * Html and Text templates
* Full coverage of:

  * Template keywords
  * Built-in functions
  * Aliases
* Improved automatic language detection[^1]
* Advanced highlighting scopes
* Prebuilt **browser bundle** for immediate use

### Discourse Integration

* Theme components built on the provided grammars
* Enables proper syntax highlighting in Discourse environments

## Download

Packages can be downloaded from: [Releases](https://github.com/irkode/highlightjs-hugo/releases/latest)][^2].

- Discourse theme Components: [highlightjs-hugo-discourse.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-discourse.zip)
- Highlight.js extra sources to build your own: [highlightjs-hugo-extra-src.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-extra-src.zip)
- Ready to use Browser Javascripts: [highlightjs-hugo-js-modules.zip](https://github.com/irkode/highlightjs-hugo/releases/latest/download/highlightjs-hugo-js-modules.zip)
- repository sources - GitHub release standard assets

As of now we do not publish anything to a CDN.

## Documentation

* https://irkode.github.io/highlightjs-hugo/

Each artifact includes its own `README.md` with usage instructions.

## Build from Source

Build scripts are included to generate all artifacts. These scripts are tailored to the project’s internal workflow and environment and not intended as a general-purpose build system.

Development Environment is a Windows 11 Professional with a recent _Powershell Core_ installation.

- Components that have to be there

   - Powershell Core
   - Hugo ≥ v0.163.3
   - Go ≥ 1.26.3
   - Node 22.14.0 (highlight.js requirement)

- Components automatically pulled by the build script

   - Highlight.js 11.11.1 (as a clone)
   - hugoDocs (as a hugo module)

- Build all

   ```text
   git clone https://github.com/irkode/highlightjs-hugo/ highlightjs-hugo
   Set-Location highlightjs-hugo
   .\build.ps1 -Verbose
   ```

- Build results are Artifacts are generated in the `/release` directory.

### Notes

* Scripts are optimized for the current development setup
* Custom Highlight.js builds should use standard Node/npm tooling after module generation

## Project Scope

This project currently serves as a development workspace. Stability and contribution workflows are not yet formalized.

Feedback, issues, and ideas are welcome:

https://github.com/irkode/highlightjs-hugo/issues

## Hugo as a Generator

Hugo is used as a general-purpose generation engine to:

* Extract functions and aliases from hugoDocs
* Generate keyword tables
* Build grammar modules and JavaScript libraries
* Generate tests
* Create Discourse plugins

* Produce documentation and README files

Take it as a nifty but hacky showcase to use Hugo as a generic templating and publishing engine – extended beyond static WEB web sites.

If you want to dig in, here's the source: https://github.com/irkode/highlightjs-hugo/tree/main/hugen

## License

* Code: MIT License (see [License](/LICENSE))
* Assets (logos, images, etc.): © 2026 Irkode (not MIT licensed)

Licenses for foreign assets may be different:

- Highlight.js icon: © 2006, Ivan Sagalaev. (BSD-Clause-3)
- Hugo _borrowed_ styles:  © Hugo Authors (Apache-2.0)

## Author

- Irkode <irkode@rikode.de>

## References

- Repository: https://github.com/irkode/highlightjs-hugo/
- Documentation : https://irkode.github.io/highlightjs-hugo/
- Highlight.js : https://highlightjs.org/
- Hugo : https://gohugo.io/
- Hugo Forum: https://discourse.gohugo.io/

[^1]: Check out details here: [A word on auto detection](https://irkode.github.io/highlightjs-hugo/highlightjs/hugo-html#a-word-on-auto-detection)
[^2]: Draft- and pre-releases have to be manually browsed and downloaded.
