# Advanced syntax highlighting for HuGo templates

Did you ever wonder why hugo templates seem to be randomly highlighted in [Discourse][]. The answer
is dead simple: _Discourse_ uses [Highlight.js][] for syntax highlighting which does not support Go
and Hugo templates.

It could look so nice

![preview](img/highlightjs-hugo.png)

To improve that we implemented

- [Highlight.js grammars](/highlightjs)
- [Discourse theme components](/discourse)

Both supporting the full set of Hugo's template keywords, built-in functions and aliases.

## Provided plugins

Currently we provide the following components

- Highlight.js

   Two grammars for _Hugo_'s [Hugo Html](/highlightjs/hugo-html) and
   [Hugo Text](/highlightjs/hugo-text) templates with auto detection[^1] and full keyword support.

- Discourse

   Two [Discourse theme components](/discourse) based the above grammars.

## Download

Ready to use modules are available as artifacts on our [Releases][] Page.

## Usage and documentation

Follow the instructions included in each artifact's `README.md` or browse our Documentation.

## Usage

For standard use cases just download teh provided artifact and follow the instructions.

### Custom Highlight.js build

To build your own customized _Highlight.js_ installation grab the _highlightjs-hugo_ artifact and
place it in the extra folder of your _Highlight.js_ clone. Build that just as any other
_Highlight.js_ grammar or a customized build.

With a customized build, we add the _Hugo_ keyword tables to the _Highlight.js_ core so these will
get packed only once. The result saves around 10KB for the final engine if you use both grammars.

### Build from source

We build our stuff using custom scripts -- a combination of powershell, node and _Hugo_. These
scripts work fine for us. May work for you but no guarantee.

We are on Windows 11 Professional. Could be working for unix like systems, but that is untested.
Have a look at our CI workflow script for the bare commands on a GitHub Ubuntu runner.

- Components that have to be there
   - Hugo - 0.160.1+
   - Go 1.26.1+
   - Node 22.14.0 (highlight.js requirement)

- Components automatically provided by the build scripts
   - _Highlight.js_ 11.11.1 (as a clone)
   - hugoDocs (as a hugo module)

- Build all

   ```powershell
   git clone https://github.com/irkode/highlightjs-hugo/ highlightjs-hugo
   set-location highlightjs-hugo
   .\build.ps1 -Verbose
   ```

- grab the results from `release` folder

The Powershell script provides a `Get-Help`.

Be aware that that is in no way a general purpose build script. It just provides shorthands for our
local development process. For special _Highlight.js_ build configurations you will need to directly
use the standard _Node_ and _npm_ scripts.

## Contributing and Issues

Never say never, but currently it's our working playground, nothing where one could do stable
contributions right now.

Use the [Issue tracker][] for reporting bugs, asking question or raise ideas.

## Hugo as a generator

Hugo is a powerful templating engine, and we utilize it to generate and assemble our grammars and
discourse plugins.

- fetch function and aliases from hugoDocs
- generate keyword tables for the plugins
- generate the hugo-lib module (grammar and keyword Javascript module)
- generate Javascript code and supplementary files
- create READMEs
- generate tests
- create source structure for our release assets
- generate Discourse plugins based on the build results

- and ofc for the standard use case - the documentation pages

Take it as a nifty showcase to use Hugo as a generic templating and publishing engine -- beyond web
sites.

If you want to dig in, you can find that here
[](https://github.com/irkode/highlightjs-hugo/tree/main/build/hugen)

{{% content-snippet "license-file.md" %}}

{{% content-snippet "authors.md" %}}

{{% content-snippet "links.md" %}}
