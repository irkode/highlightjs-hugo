{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "PAG(JS)  %s - %s" $pagePath $tpl }}
{{ .Content }}
{{- /**/ -}}