+++
title = "Examples - Highlight.js Grammars"
description = "Live examples of the go-html, go-text, hugo-html, and hugo-text Highlight.js grammars, styled with Hugo's documentation theme."
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

## Comprehensive examples

Real world examples from our docs layouts

### baseof.html styled with hugo-html

```hugo-html {style="hugodocs"}
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- $idx := math.Counter }}
{{- with .Params.keywords }}
	{{- warnf "[%04d][ %-20s ] : %s :: %s" $idx $tpl $pagePath . }}
{{- else }}
	{{- warnf "[%04d][ %-20s ] : %s" $idx $tpl $pagePath }}
{{- end }}
{{ $tag := or site.Params.Tag "unreleased" }}
{{ $buildDate := or site.Params.BuildDate ((. | time.AsTime).Format "2006-01-02") }}
<!doctype html>
<html lang="{{ site.Language.Locale }}" dir="{{ or site.Language.Direction `ltr` }}">
	<head>
		{{- partialCached "head.html" . .Path }}
		<title>
			{{- if .IsHome }}
				{{- site.Title }}
			{{- else }}
				{{- printf "%s | %s" (or .Title $.Title) site.Title }}
			{{- end }}
		</title>
	</head>
	<body{{ if not (in (slice "home" "404") .Kind) }} class="no-hl_img-mobile"{{ end }}>
		<a class="skip-link" href="#main-content">Skip to main content</a>
		<header class="site-header">
			<div class="header-left">
				{{- $filter := "" }}
				{{- $path := "img/highlightjs-icon.png" }}
				{{- with resources.Get $path }}
					{{- with .Resize "20x" }}
						{{ $filter = images.Overlay . 0 28 }}
					{{- else }}
						{{- errorf "Unable to resize overlay %q" $path }}
					{{ end }}
				{{- else }}
					{{- errorf "Unable to get overlay %q" $path }}
				{{- end }}
				{{- with default "img/huggingface-logo-48x48.png" site.Params.huggingface.siteLogo }}
					{{- with $logo := resources.Get . }}
						{{ with $logo.Filter $filter }}
							<a href="{{ absURL "" }}">
								<img src="{{ .RelPermalink }}" id="site-logo" class="header-icon" alt="Home" />
							</a>
						{{- else }}
							<a href="{{ absURL "" }}">
								<img src="{{ $logo.RelPermalink }}" id="site-logo" class="header-icon" alt="Home" />
							</a>
						{{- end }}
					{{- end }}
				{{- end }}
			</div>
			<div class="header-center">
				<input type="checkbox" id="burger-toggle" aria-label="Toggle navigation menu" />
				<label for="burger-toggle" id="burger-label">
					<span></span>
					<span></span>
					<span></span>
				</label>
				{{- partial "header/menu.html" (dict "menuID" "main" "page" .) -}}
			</div>
			<div class="header-right">
				{{- with site.Params.h4h.repository }}
					<a href="{{ . }}"><img id="github-mark" class="header-icon" alt="View on GitHub" /></a>
				{{- end }}
				<button type="button" id="theme-toggle" class="icon-button">
					<img id="theme-toggle-icon" class="header-icon" alt="Toggle Theme" />
				</button>
			</div>
		</header>

		<main id="main-content" class="site-main" tabindex="-1">
			{{- block "main" . }}{{- end }}
		</main>

		<footer class="site-footer">
			<div class="footer-left">
				<p>{{- with .GitInfo }}<a href="{{ add site.Params.h4h.repository "/commit/" .Hash }}" aria-label="View commit {{ .AbbreviatedHash }} on GitHub">#{{- .AbbreviatedHash }}</a> &mdash; {{ end }}{{ .Lastmod.Format "2006-01-02" }}</p>
			</div>
			<div class="footer-center">
				<p>&copy; {{ now.Year }}. Irkode &lt;github.com/irkode&gt;</p>
			</div>
			<div class="footer-right">
				<p>{{- $tag }} &mdash; {{ $buildDate -}}</p>
			</div>
		</footer>

		{{- if and (.Param "huggingface.markup.enableHighlightJS") (.Store.Get "loadHighlightJS") }}
			{{- with resources.Get "js/highlight-hugo-docs.min.js" }}
				{{- warnf "[%04d][ %-20s ] : %s :: LOAD %s" $idx $tpl $.Path . }}
				<script src="{{ .RelPermalink }}"> </script>
			{{- else }}
				{{- warnf "JS not found: js/theme-toggle.js" . }}
			{{- end }}
			<script>
				hljs.configure({ cssSelector: 'pre:not(.chroma) code' });
				hljs.highlightAll();
			</script>
		{{- end }}
	</body>
</html>
```

### baseof.html styled with hugo-text

```hugo-text {style="hugodocs"}
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- $idx := math.Counter }}
{{- with .Params.keywords }}
	{{- warnf "[%04d][ %-20s ] : %s :: %s" $idx $tpl $pagePath . }}
{{- else }}
	{{- warnf "[%04d][ %-20s ] : %s" $idx $tpl $pagePath }}
{{- end }}
{{ $tag := or site.Params.Tag "unreleased" }}
{{ $buildDate := or site.Params.BuildDate ((. | time.AsTime).Format "2006-01-02") }}
<!doctype html>
<html lang="{{ site.Language.Locale }}" dir="{{ or site.Language.Direction `ltr` }}">
	<head>
		{{- partialCached "head.html" . .Path }}
		<title>
			{{- if .IsHome }}
				{{- site.Title }}
			{{- else }}
				{{- printf "%s | %s" (or .Title $.Title) site.Title }}
			{{- end }}
		</title>
	</head>
	<body{{ if not (in (slice "home" "404") .Kind) }} class="no-hl_img-mobile"{{ end }}>
		<a class="skip-link" href="#main-content">Skip to main content</a>
		<header class="site-header">
			<div class="header-left">
				{{- $filter := "" }}
				{{- $path := "img/highlightjs-icon.png" }}
				{{- with resources.Get $path }}
					{{- with .Resize "20x" }}
						{{ $filter = images.Overlay . 0 28 }}
					{{- else }}
						{{- errorf "Unable to resize overlay %q" $path }}
					{{ end }}
				{{- else }}
					{{- errorf "Unable to get overlay %q" $path }}
				{{- end }}
				{{- with default "img/huggingface-logo-48x48.png" site.Params.huggingface.siteLogo }}
					{{- with $logo := resources.Get . }}
						{{ with $logo.Filter $filter }}
							<a href="{{ absURL "" }}">
								<img src="{{ .RelPermalink }}" id="site-logo" class="header-icon" alt="Home" />
							</a>
						{{- else }}
							<a href="{{ absURL "" }}">
								<img src="{{ $logo.RelPermalink }}" id="site-logo" class="header-icon" alt="Home" />
							</a>
						{{- end }}
					{{- end }}
				{{- end }}
			</div>
			<div class="header-center">
				<input type="checkbox" id="burger-toggle" aria-label="Toggle navigation menu" />
				<label for="burger-toggle" id="burger-label">
					<span></span>
					<span></span>
					<span></span>
				</label>
				{{- partial "header/menu.html" (dict "menuID" "main" "page" .) -}}
			</div>
			<div class="header-right">
				{{- with site.Params.h4h.repository }}
					<a href="{{ . }}"><img id="github-mark" class="header-icon" alt="View on GitHub" /></a>
				{{- end }}
				<button type="button" id="theme-toggle" class="icon-button">
					<img id="theme-toggle-icon" class="header-icon" alt="Toggle Theme" />
				</button>
			</div>
		</header>

		<main id="main-content" class="site-main" tabindex="-1">
			{{- block "main" . }}{{- end }}
		</main>

		<footer class="site-footer">
			<div class="footer-left">
				<p>{{- with .GitInfo }}<a href="{{ add site.Params.h4h.repository "/commit/" .Hash }}" aria-label="View commit {{ .AbbreviatedHash }} on GitHub">#{{- .AbbreviatedHash }}</a> &mdash; {{ end }}{{ .Lastmod.Format "2006-01-02" }}</p>
			</div>
			<div class="footer-center">
				<p>&copy; {{ now.Year }}. Irkode &lt;github.com/irkode&gt;</p>
			</div>
			<div class="footer-right">
				<p>{{- $tag }} &mdash; {{ $buildDate -}}</p>
			</div>
		</footer>

		{{- if and (.Param "huggingface.markup.enableHighlightJS") (.Store.Get "loadHighlightJS") }}
			{{- with resources.Get "js/highlight-hugo-docs.min.js" }}
				{{- warnf "[%04d][ %-20s ] : %s :: LOAD %s" $idx $tpl $.Path . }}
				<script src="{{ .RelPermalink }}"> </script>
			{{- else }}
				{{- warnf "JS not found: js/theme-toggle.js" . }}
			{{- end }}
			<script>
				hljs.configure({ cssSelector: 'pre:not(.chroma) code' });
				hljs.highlightAll();
			</script>
		{{- end }}
	</body>
</html>
```
