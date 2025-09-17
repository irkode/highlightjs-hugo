---
title: Class reference
---

# Highlight-JS Hugo - Class reference

## Core modes used

- hljs.NUMBER_MODE
- hljs.QUOTE_STRING_MODE
- hljs.APOS_STRING_MODE
- hljs.COMMENT

## Scopes (Classes) used by highlightjs-hugo

The following classes are used to style the output. Make sure your style has a definition for them.

- operator

  Used for the following items : `|`, `,`, `=`, `:=`

- property

  We style every dot word chain as property **except** if it starts with a _built_in_. In these cases we use _built_in_
  for the start (one or two words). see also _title.function.invoke_ below.

- punctuation

  Used for opening and closing parenthesis of sub expressions: `(`, `)`

- string

  Used for Names used in `block`, `define`, and `partial` actions.

- template-tag

  Used for opening and closing template tags. `{{`, `{{-`, `}}`, `-}}`,

- template-variable

  Used for template variables starting with a `$` (example `$myvar`)

- title.function.invoke (special)

  If a _built_in_ is followed by a _dot_ this must be an object. Knowing it's something special and it definitely calls
  something we style it using the `invoke` subclass of _title.function_. Up-to-date styles may define this. If not
  standard fallback rules apply.

## Scopes (Classes) added by highlightjs-hugo

- template-variable.context

  The _Context_ is a special thing in Hugo templating so we added a special class here. Use that in your CSS to create a
  different visual appearance for _Context_. Ofc all, styles out there do not define this one. Without adding something
  special it will be styled as `template-variable` which is the standard HighlightJS fallback method.

## Keywords used

We use the following keyword settings based on Go templating plus all functions added by Hugo.

- literal

  `false`, `true` and `nil`

- keyword

  Documented in [Hugo - Go template functions](https://gohugo.io/functions/go-template/)

- built_in

  Documented in [Hugo - Functions](https://gohugo.io/functions/) except the _keywords_ above.

  Hugo's functions are namespaced and some aliases to a -- non prefixed -- simple name. We style **both** as _built_in_.
  Example `strings.Replace` and it's alias `replace`.
  
## Submodes

`Highlightjs-hugo` uses Hightlight.JS submode `xml`. Have a look at that module to see which scopes are used within.
