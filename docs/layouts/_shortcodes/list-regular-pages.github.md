{{- /*
  This shortcode returns markdown content. Which depends on whitespace
  DO NOT AUTOFORMAT
*/ -}}
{{- $page := cond (.IsNamedParams) (.Get "path") (.Get 0) }}
{{- with $page }}
  {{- $page = site.GetPage $page }}
{{- else }}
  {{- $page := .Page }}
{{- end -}}
{{- with $page -}}
  {{- range .Page.RegularPages -}}
{{/* blank */}}
- [{{ .LinkTitle }}]({{ path.Join .File.Dir "README.md" }})

  {{ .Description | .RenderString }}
{{- end }}
{{- end -}}