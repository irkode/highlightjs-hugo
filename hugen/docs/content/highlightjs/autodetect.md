+++
title = "A word on auto detection"
description = "How the Go and Hugo grammars use Highlight.js relevance settings to win auto-detection against Handlebars and other similar template languages."
+++

_Handlebars_ and _Go templates_ -- used by [Hugo](https://gohugo.io/) -- have similar template tags.
Without additional relevance settings Hugo grammars will loose most of the time. Relevance settings
are used to beat _Handlebars_ auto-detection for Go/Hugo templates.

If you import both languages flavours -- Hugo and Go there's no way to be sure the right variant is
taken. For templates having special Hugo stuff (like try, or hugo built_ins) it will work, but
expect for templates without you might get the wrong flavor.

- Go template comments get relevance = 10.

   comments start with `{{/*` or `{{- /*` and end with `*/}}` or `*/ -}}`

- Functions in the _hugo_ namespace get relevance = 10 (e.g. hugo.IsDevelopment)

- The following _Handlebars_ opening template tags are set to _invalid_ for HuGo: `{{#`, `{{>`,
  `{{!--`, `{{!`

   `IgnoreIllegals` default value is `false` since version 11. So this stops highlighting with the
   hugo module.

- Built_ins only available in Hugo will get relevance 1.

## Handlebars is a winner

The above worked well in our test scenarios, but real live examples showed handlebars beats us most
of the time.

Constructs like this one: `{{- "hello" -}}` may work. You can get that pass the
[Handlebars Playground](https://handlebarsjs.com/playground.html) if

- "-" is defined as item in the json data
- a helper named "-" has been defined

with that you could even do

- handlebars: `{{- -}}`
- json: `{ "-": "oops" }`
- javascript: `Handlebars.registerHelper('-', function (aString) { return aString.toUpperCase() })`

Although a JSON field "-" and a function named "-" even more. but some like it short and it's legal.

## We need a magic wand

The
[Highlight.js documentation](https://highlightjs.readthedocs.io/en/latest/language-guide.html#relevance)
about relevance is quite unspecific.

> - "it tries to highlight a fragment with all the language definitions and the one that yields
>   most"
> - "specific modes and keywords wins. If your language breaks auto-detection, it should be fixed by
>   improving relevance, which is a black art in and of itself"

Highlight.js language grammar for Handlebars is too permissive. Some will shift it to the overall
discussion where _Syntax_ ends and _Semantic_ starts.

The above simple "hello" scores 5 in handlebars, with three _Scopes_ identified where two are nested
within the first one.

```html
<span class="hljs-template-variable"
   >{{ <span class="hljs-name">-</span> <span class="hljs-string">"hello"</span> -}}
</span>
```

with hugo-html that scores 2, with just three scopes in a row

```html
<span class="hljs-template-tag">{{- </span>
<span class="hljs-string">"hello"</span>
<span class="hljs-template-tag"> -}}</span>
```

Nesting seems to raise relevance here.

### What we currently do

- just keep as is: handlebars and HuGo templates most likely won't be used together.
   - Use a custom build without handlebars
   - if you need both, always specify a language for HuGo's templates

### If we would want to tackle this:

- raising relevance: needs ofc the specific constructs present and
   - raise HuGo's comment syntax (may affect fe markdown detection).
   - fine tune hugo specific constructs like `{{ with try }}` selectively.
   - raise all Hugo specific keywords, built_ins ...

- a redesign of our scanner to raise relevance with added nesting

we might also analyze the possibility to detect hugo-html vs hugo-text
