+++
title = "Examples - Discourse"
+++

The styles are _borrowed_ from Hugo's Discourse forum to have identifiable visible changes.

## Rendered with Python[^1]

```hljs-python {style="discourse"}
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

## Rendered with Hugo-HTML

```hugo-html {style="discourse_bare"}
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

## Rendered with Hugo-HTML plus additional classes

```hugo-html {style="discourse"}
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

[^1]: Other frequently _detected_ languages for HuGo template code are _Ruby_ or _Bash_
