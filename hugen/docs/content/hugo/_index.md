+++
title = "Hugo & Chroma"
+++

# Usage with Hugo

It's possible to use the module with Hugo, too. You just could turn off Chroma and completely switch
to [Highlight.JS][].

But we want most of the stuff rendered by Chroma and just benefit from the advanced styling for Hugo
templates you can go with a hybrid approach -- producing nice templates like

```
{{- with $tpl := templates.Current.Name }} {{- $ctx := slice . $ $var $.prop }}`
```

## Highlighting with Chroma

Here's how it looks like with static rendering using Chroma with a style "borrowed" from hugoDocs,
so you can easily see the visual sugar. Nothing special here, it just works out of the box.

```go-html-template
{{- $tpl := templates.Current.Name }}
{{- $ctx := slice . $ $var $.prop }}
{{- try true -}} {{- /* that's not working code */ -}}
{{- with range site.RegularPages.ByDate.Reverse -}}
   {{- .RenderShortcodes }}
   <link rel="stylesheet" href="{{ .RelPermalink }}" />
{{- else }}
   {{- errorf "Shortcode [ %s ]: snippet [ %s ] not found at [ %s ]" $.Name . $.Position }}
{{- end }}
```

The rendered HTML looks like that one:

```html
<div class="highlight">
   <pre tabindex="0" class="chroma">>
</div>
```

The above `<pre><code>` will then also trigger HighlightJS which results in double rendering and
strange effects on the output (additionally lot's of warnings in highlight.js). The result would
like this one:

```html
<div class="highlight">
   <pre tabindex="0" class="chroma">>
</div>
```

### Default rendering with Hugo and Chroma

We use explicit language setting with Chroma because auto detection has nearly no support within.
The results are:

- Chroma highlighted the code block: `go-html-template`

   ```html
   <div class="highlight">
      <pre tabindex="0" class="chroma"></pre>
   </div>
   ```

- Chroma could not highlight the code block: `hugo-html`

   ```html
   <pre tabindex="0"></pre>
   ```

Which results in

- double highlighting for processed code
- auto detection for non processed code

## Adding Highlight.js

Because the standard Hugo/Chroma output disables auto detection we choose to address both issues on
their side. No customizing of HighlightJS necessary.

Just add the usual simple HighlightJS code

```html
<script src="js/highlight-hugo.min.js"></script>
...
<script>
   hljs.highlightAll();
</script>
```

We add a code block render hook to address the missing language and the nohighlight class for chroma
processed code blocks.

The hook checks if Chroma can highlight that language and if chage the default wrapper to use
`nohighlight`. In case it cannot, it will print a wrapper keeping the language. so it's ready to be
processed by our second engine.

And the final result looks like

```hugo-text
{{- if transform.CanHighlight .Type }}
   {{- $result := transform.HighlightCodeBlock . -}}
   <pre tabindex="0" class="chroma"><code class="nohighlight" data-lang="{{ .Type }}">
      {{- $result.Inner  -}}
   </code></pre>
{{- else }}
   <pre tabindex="0" class="highlightjs"><code class="{{ .Type }}" data-lang="{{ .Type }}">
      {{- .Inner -}}
   </code></pre>
{{- end }}
```

Here's the code block from the start of the document styled with `hugo-html`

```hugo-html
{{- $tpl := templates.Current.Name }}
{{- $ctx := slice . $ $var $.prop }}
{{- try true -}} {{- /* that's not working code */ -}}
{{- with range site.RegularPages.ByDate.Reverse -}}
   {{- .RenderShortcodes }}
   <link rel="stylesheet" href="{{ .RelPermalink }}" />
{{- else }}
   {{- errorf "Shortcode [ %s ]: snippet [ %s ] not found at [ %s ]" $.Name . $.Position }}
{{- end }}
```

{{% content-snippet "license-link-shortcode.md" %}}

{{% content-snippet "authors.md" %}}

{{% content-snippet "links.md" %}}

[^1]:
    we know that from problems as
    [Prism - One Password](https://discourse.gohugo.io/t/issue-with-code-blocks-for-1password-users/56442?u=irkode)
