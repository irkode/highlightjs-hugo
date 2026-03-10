{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "SEC(HTML)  %s - %s" $pagePath $tpl }}

{{- range resources.Match "highlightjs/**"}}
  {{- warnf "%s " .}}
  {{- $noop := .Publish }}
{{- end }}

{{- /* remove all trailing whitespace */ -}}