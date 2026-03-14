# Highlightjs Hugo - Advanced syntax highlighting for Hugo templates

Did you ever wonder why hugo templates seem to be randomly highlighted in [Discourse][].
The answer is dead simple: _Discourse_ uses [Highlight.js][] for syntax highlighting and this does not support Go and  Hugo templates.

It could look so nice

![preview](highlightjs-hugo.png)

## Introduction

To achieve that, we implemented

* _Highlight.js_ grammars
* _Discourse_ theme components.

Both supporting the full set of Hugo's template keywords, built-in functions and aliases.

> Grab plugins from our [Releases](https://github.com/irkode/highlightjs-hugo/releases/latest).
> Read more in our [Documentation][].

## Provided plugins

Each module is available in two variants:

* HTML - Uses the standard _XML_ grammar for highlighting surrounding Html code.

* TEXT - This will keep surrounding text unstyled.

## Download

Ready to use modules are available as artifacts on our [Releases][] Page.

## Usage and documentation

Follow the instructions included in each artifact's `README.md`. To read before downloading, check out our [Documentation][]

## Build

For normal usecases see _Download_ above.

### Build customized Highlight.js

To build your own customized _Highlight.js_ installation grab the source artifact and playe it in the extra folder. of your _Highlight.js_ clone. Now you can build that just as any other _Highlight.js_ grammar. 

### Build our sources

We build our stuff using custom scripts; a combination of powershell, node and _Hugo_. These scripts work fine for us. May work for you but no guarantee. Listed Version numbers are the on we use, might work with others.

We are on Windows 11 Professional. Could be working on *nix system, but that is untested. Have a look at our CI workflow script for the bare commands on a GitHub Ubuntu runner.

* You'll need some preinstalled components.
  * Go 1.25.5
  * Hugo 0.157.0
  * Node 22.14.0
* These are downloaded by the scripts
  * Highlight.js 11.11.1
  * hugoDocs (as a hugo module)

* Build all
  ```powershell
  git clone https://github.com/irkode/highlightjs-hugo/ highlightjs-hugo
  set-location highlightjs-hugo
  .\build.ps1 -Verbose
  ```

* grab the results from highlightjs-hugo/release

* use `Get-Help`to get more options.

Be aware that that is in no way a general purpose script but only support us in local development. Special use cases will require you to utilize the _Highlight.js_ provided _Node_ and _npm_ scripts.

## Contributing and Issues

Never say never, but currently it's our working playground, nothing where one could do stable contributions right now.

Use the [Issue tracker][] for reporting bugs, asking question or raise ideas.

## Hugo as a generator

Hugo is a powerful templating engine, and we utilize it to generate and assemble our grammars and discourse plugins.

- fetch function names from hugoDocs pages
- generate keyword tables for the plugins
- generate the hugo-lib module (grammar and keyword Javascript module)
- generate Javascript code and supplementary files
- create READMEs
- generate tests
- create source structure for our release assets
- generate Discourse plugins based on the build results

- and ofc for the standard use case - generate the documentation site

Take it as a nifty showcase to use Hugo as a generic templating and publishing engine -- beyond web sites.

If you want to dig in, you'll find the site source at [build\hugen](build\hugen)

## License

This package is released under the MIT License. See [LICENSE](LICENSE) file for details.

### Author & Maintainer

- Irkode <irkode@rikode.de>

## Links

- [highlightjs-hugo][] : The main repository with additional grammars and plugins. Have a look
- [Documentation][] : All about Highlightjs - Hugo
- [Highlight.js][] : The Internet's favorite JavaScript syntax highlighter supporting Node.js and the web
- [Hugo][] : The world’s fastest framework for building websites
- [Go HTML template](https://pkg.go.dev/html/template) : Go's html template package
- [Go TEXT template](https://pkg.go.dev/text/template) : Go's text template package

[highlightjs-hugo]: https://github.com/irkode/highlightjs-hugo/
[Documentation]: https://irkode.github.com/highlightjs-hugo/
[Issue tracker]: https://github.com/irkode/highlightjs-hugo/issues
[Highlight.js]: https://highlightjs.org/
[Hugo]: https://gohugo.io/
[Discourse]: https://discourse.gohugo.io/
[Releases]: https://github.com/irkode/highlightjs-hugo/releases/latest