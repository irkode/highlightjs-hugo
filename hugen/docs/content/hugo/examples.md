+++
title = "Example - HugoDocs"
+++

# Hybrid Highlighting with Chroma and Highlight.js

Example how Hugo's documentation could look like styled with _highlighjs-hugo_`

* Rendered with Chroma (go-template)

```go-html-template {style="hugodocs"}
{{ warnf `%s` templates.Current.Name }}
{{ with (templates.Defer (dict "key" "global")) }}
  {{ $theme := $.Site.Params.colorScheme | default "slate" }}
  {{ with resources.Get (printf "css/%s.css" $theme) }}
  {{/* with resources.Get "css/test.css" */}}
    {{ $opts := dict "minify" (not hugo.IsDevelopment) "inlineImports" true }}
    {{ with . | css.TailwindCSS $opts }}
      {{ if hugo.IsDevelopment }}
        <link rel="stylesheet" href="{{ .RelPermalink }}">
      {{ else }}
        {{ with . | fingerprint }}
          <link rel="stylesheet" href="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}">
        {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
{{ end }}
```

* Rendered with HighlightJS (hugo-html)

```hugo-html {style="hugodocs_bare"}
{{ warnf `%s` templates.Current.Name }}
{{ with (templates.Defer (dict "key" "global")) }}
  {{ $theme := $.Site.Params.colorScheme | default "slate" }}
  {{ with resources.Get (printf "css/%s.css" $theme) }}
  {{/* with resources.Get "css/test.css" */}}
    {{ $opts := dict "minify" (not hugo.IsDevelopment) "inlineImports" true }}
    {{ with . | css.TailwindCSS $opts }}
      {{ if hugo.IsDevelopment }}
        <link rel="stylesheet" href="{{ .RelPermalink }}">
      {{ else }}
        {{ with . | fingerprint }}
          <link rel="stylesheet" href="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}">
        {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
{{ end }}
```

* Rendered with HighlightJS (hugo-html) plus additional classes

```hugo-html {style="hugodocs"}
{{ warnf `%s` templates.Current.Name }}
{{ with (templates.Defer (dict "key" "global")) }}
  {{ $theme := $.Site.Params.colorScheme | default "slate" }}
  {{ with resources.Get (printf "css/%s.css" $theme) }}
  {{/* with resources.Get "css/test.css" */}}
    {{ $opts := dict "minify" (not hugo.IsDevelopment) "inlineImports" true }}
    {{ with . | css.TailwindCSS $opts }}
      {{ if hugo.IsDevelopment }}
        <link rel="stylesheet" href="{{ .RelPermalink }}">
      {{ else }}
        {{ with . | fingerprint }}
          <link rel="stylesheet" href="{{ .RelPermalink }}" integrity="{{ .Data.Integrity }}">
        {{ end }}
      {{ end }}
    {{ end }}
  {{ end }}
{{ end }}
```
