+++
title = "Examples - Highlight.js Grammars"
+++

The styles are _borrowed_ from Hugo's documentation to have identifiable visible changes.

## Hugo HTML

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

## Hugo TEXT

```hugo-text {style="hugodocs"}
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

## Go HTML

```go-html {style="hugodocs"}
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

## Go TEXT

```go-text {style="hugodocs"}
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
