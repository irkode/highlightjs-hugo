# Hugo - CSS Class reference

This class reference is valid for all _Hugo_ and _Go_ grammars.[^1]

## Core modes used

- `hljs.NUMBER_MODE`
- `hljs.QUOTE_STRING_MODE`
- `hljs.APOS_STRING_MODE`
- `hljs.COMMENT`

## Standard scopes (classes)

The following standard scopes are used to style the output. Make sure your style has a definition
for them.

- `comment`

   Used for opening and closing comment tags and comment text `{{/*`, `{{- /*`, `*/ -}}`, `*/}}`

- `number`

   all kind of numbers

- `operator`

  Used for the following items : `|`, `,`, `=`, `:=`

- `property`

  We style every dot word chain as property **except** if it starts with a _built_in_. In these
  cases we use _built_in_ for the start (one or two words). see also _property.method_ below.

  With *_Go_* grammars there's nothing like that, `a.b` is a property just `a` is not.

- `punctuation`

  Used for opening and closing parenthesis of sub expressions: `(`, `)`

- `string`

  Strings (single and double quoted). Maybe we should skip singe quoted strings?

- `template-tag`

  Used for opening and closing template tags. `{{`, `{{-`, `-}}`, `}}`

- `template-variable`

  Used for template variables starting with a `$` (example `$myVar`)

## New scopes (classes)

Themes out in the wild won't define styles for these[^2]. Define your style or live with the standard _Highlight.js_ fallback mechanism.

- `property.method` (valid for _Hugo_ only)

  If _context_, _variable_ or _built_in_ is followed by a _dot_ it must be an object and the next is a method call.
  Knowing it's something special and it definitely calls something else we assign property.method. Up-to-date themes may
  have a style configured and will use _property_ style. Create your own or live with the fallback.

- `template-variable.context`

  The _Context_ -- a leading `.` or `$.` -- is a special thing in Go/Hugo templating. We use a
  dedicated class here to allow emphasis. Use it in your CSS to create a different visual appearance
  for _Context_. keep in mind, that all styles out there do not define this one. If you want it,
  define a style or take the fallback which is `template-variable`.

- `string.raw`

  A raw string in Go/Hugo templates is a sequence of characters enclosed in backticks. All
  characters enclosed are taken literally.

## Nested selectors

Each nested scope gets an own class with added underscores for each nesting level.

Here's a layout for _property.method_.

* Scope: `property.method`

* Classes assigned: `class="hljs-property method_"`

* CSS Selector: `hljs-property.method_ { ... }`

## Keywords

We divide Go/Hugo keywords into the following standard scopes.

- `literal`

  not many with _Hugo_, just: `false`, `true` and `nil`

- `keyword`

  For Hugo as documented in [Hugo - go template functions](https://gohugo.io/functions/go-template/)

  For Go as documented in [Go template actions](https://pkg.go.dev/text/template#hdr-Actions) and
  `define`[^3]

  For both `urlquery` is moved to _built_ins_. [^4] 

- `built_in`

  For Hugo as documented in [Hugo - Functions](https://gohugo.io/functions/) excluding the keywords
  from above. We include both -- the real _namespaced_ function name and aliases.

  For Go as documented in [Go Template-Text Predefined template functions](https://pkg.go.dev/text/)

> HINT: We generate the Keywords for Hugo at build time using a recent version of the docs. Means
> highlighting old code won't detect ancient keywords/built_ins. The Go template
> keywords are handcrafted from the docs. Hopefully that's a complete fetch.

## Sub modes

The HTML grammars use Highlight.js _XML_ grammar as subLanguage. Check the official documentation for scopes used there.

[Highlight.js]: https://highlightjs.readthedocs.io/

[^1]: we add this file to every source module to have that complete. Watch out for special mentions.
[^2]: also the `template-...` scopes may be missing in some popular styles.
[^3]: which is mentioned deeper down in the go template docs.
[^4]: A more natural fit for us. 
