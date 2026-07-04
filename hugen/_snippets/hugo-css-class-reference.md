# HuGo - CSS Class reference

This class reference is valid for all _Hugo_ and _Go_ grammars. Exceptions are mentioned in
the respective sections.

## Core modes used

- `hljs.NUMBER_MODE`
- `hljs.QUOTE_STRING_MODE`
- `hljs.APOS_STRING_MODE` (as base for string.rune)
- `hljs.COMMENT`

## Standard scopes (classes)

The following standard scopes are used to style the output. Make sure your style has a definition
for them.

- `comment`

   Used for opening and closing comment tags and inner text `{{/*`, `{{- /*`, `*/ -}}`, `*/}}`

- `number`

   all kind of numbers

- `operator`

  Used for the following items : `|`, `,`, `=`, `:=`

- `property`

  Used for dot chained words **except** if the chain starts with a _built_in_. In that case the
  beginning of the chain gets _built_in_ (one or two words). see also _property.method_ below.

  With *_Go_* grammars there's nothing like that, `a.b` is a property just `a` is not.

- `punctuation`

  Used for opening and closing parenthesis of sub expressions: `(`, `)`

- `string`

  Strings (single and double quoted).

- `template-tag`

  Used for opening and closing template tags. `{{`, `{{-`, `-}}`, `}}`

- `template-variable`

  Used for template variables starting with a `$` (example `$myVar`)

## New scopes (classes)

Themes out in the wild won't have styles for these. If you do not define any for these special
subclasses, _Highlight.js_ will fallback to the parent style.

- `property.method` (valid for _Hugo_ only)

  A _context_, _variable_ or _built_in_ followed by a _dot_ should be a method call. Target this with the
  `.hljs-property.method_` selector.

- `template-variable.context`

  The _Context_ -- a leading `.` or `$.` -- is a special thing in Go/Hugo templating. Target this with the
  `.hljs-template-variable.context_` selector.

- `string.raw`

  A raw string in Go/Hugo templates is a sequence of characters enclosed in backticks. Target this with the
  `.hljs-string.raw_` selector.

- `string.rune`

  A rune literal in Go/Hugo templates is a sequence of characters enclosed in single quotes. Target this with the
  `.hljs-string.rune_` selector.

## Keywords

We divide Go/Hugo keywords into the following standard scopes.

- `literal`

  not many with _Hugo_, just: `false`, `nil`, `true`

- `keyword`

  For Hugo as documented in [Hugo - go template functions](https://gohugo.io/functions/go-template/)

  For Go as documented in [Go template actions](https://pkg.go.dev/text/template#hdr-Actions) and
  `define`[^1]

  For both `urlquery` is moved to _built_ins_. [^2]

- `built_in`

  For Hugo as documented in [Hugo - Functions](https://gohugo.io/functions/) excluding the keywords
  from above. Both -- the real _namespaced_ function name and it's aliases are available.

  For Go as documented in [Go Template-Text Predefined template functions](https://pkg.go.dev/text/)

> HINT: Keywords for _Hugo_ are  generated at build time from a recent version of the docs. For older
> template code bases this may result in missing highlighting ancient keywords/built_ins.
> The Go template keywords are manually picked from the docs.

## Sub modes

The HTML grammars use _XML_ as subLanguage. Check the official documentation for scopes used there.

[Highlight.js]: https://highlightjs.readthedocs.io/

[^1]: mentioned deeper down in the go template docs.
[^2]: better match than _keyword_.
