{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "PAG(MD)  %s - %s\n%s" $pagePath $tpl (debug.Dump .Params) }}

{{- with resources.FromString $pagePath .RawContent }}
  {{- with resources.ExecuteAsTemplate $pagePath $.Params . }}
    {{- .Content }}
  {{- end }}
{{- end }}
