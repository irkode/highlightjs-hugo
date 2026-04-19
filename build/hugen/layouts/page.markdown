{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "PAG(MD)  %s - %s" $pagePath $tpl }}

{{- with resources.FromString $pagePath .RawContent }}
  {{- with resources.ExecuteAsTemplate $pagePath $.Params . }}
    {{- .Content }}
  {{- end }}
{{- end }}
