{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "SEC( MD )  %s - %s" $pagePath $tpl }}

{{- range $lang := .Params.plugins }}
   {{- range resources.Match "discourse/**" }}
      {{- warnf "Execute: %s - %s" $lang . }}
      {{- with resources.ExecuteAsTemplate (printf "discourse/%s/%s" $lang .Name) (dict "lang" $lang) . }}
         {{- $noop := .Publish }}
      {{- end }}
   {{- end }}
{{- end }}
{{- /* remove all trailing whitespace */ -}}
