+++
title = 'CSS Classes'
+++
# Hugo class reference

This class reference is valid for all _Hugo_ grammars. They share the common styles.

## Core modes used

- `hljs.NUMBER_MODE`
- `hljs.QUOTE_STRING_MODE`
- `hljs.APOS_STRING_MODE`
- `hljs.COMMENT`

## Standard scopes (classes)

The following standard scopes are used to style the output. Make sure your style has a definition
for them.

- `operator`

  Used for the following items : `|`, `,`, `=`, `:=`

- `property`

  We style every dot word chain as property **except** if it starts with a _built_in_. In these
  cases we use _built_in_ for the start (one or two words). see also _title.function.invoke_ below.

- `punctuation`

  Used for opening and closing parenthesis of sub expressions: `(`, `)`

- `string`

  Strings and used for Names used in `block`, `define`, and `partial` actions.

- `template-tag`

  Used for opening and closing template tags. {{ printf "`{{` `{{-` `-}}` `}}`" }}

- `template-variable`

  Used for template variables starting with a `$` (example `$myvar`)

- `title.function.invoke` (special)

  If a _built_in_ is followed by a _dot_ it must return an object. Knowing it's something special
  and it definitely calls something else we assign _title.function.invoke_. Up-to-date themes may
  have a style configured. If not you can create your own or live with the fallback.

## New scopes (classes)

- `template-variable.context`

  The _Context_ -- a leading `.` or `$.` -- is a special thing in Go/Hugo templating. We use a
  dedicated class here to allow emphasis. Use it in your CSS to create a different visual appearance
  for _Context_. keep in mind, that all styles out there do not define this one. If you want it,
  define a style or take the fallback which is `template-variable`.

- `string.raw`

  A raw string in Go/Hugo templates is a sequence of characters enclosed in backticks. All
  characters enclosed are taken literally.

## Keywords

We divide Go/Hugo keywords into the following standard scopes.

- `literal`

  not many with _Hugo_, just: `false`, `true` and `nil`

- `keyword`

  For Hugo as documented in [Hugo - go template functions](https://gohugo.io/functions/go-template/)
  except `urlquery`[^1]

  For Go as documented in [Go template actions](https://pkg.go.dev/text/template#hdr-Actions) and
  `define`[^2]

- `_built_in_`

  For Hugo as documented in [Hugo - Functions](https://gohugo.io/functions/) excluding the keywords
  from above. We include both -- the real _namespaced_ function name and aliases.

  For Go as documented in [Go Template-Text Predefined template functions](https://pkg.go.dev/text/)

> HINT: We generate the Keywords for Hugo at build time using the recent version of the docs. Means
> highlighting old code won't detect ancient keywords/buildtins.all keywords. The Go template
> keywords are handcrafted from the docs. Hupefull thts a complete fetch.

## Submodes

_highlighjs-hugo-html_ uses [Highlight.js][]'s _XML_ grammar for highlighting HTML as subLanguage.
Check the official documentation for scopes used.

[Highlight.js]: https://highlightjs.readthedocs.io/

[^1]: which sounds like a candidate for the _fmt_ namespace in Hugo

[^2]: which is mentioned deeper down in the go template docs.
