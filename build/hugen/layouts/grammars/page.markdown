{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "PAG(GRAMMAR)  %s - %s\n%s" $pagePath $tpl (debug.Dump .Params) }}

{{- with .File }}
   {{- with .BaseFileName }}
      {{- if eq . "hugo-css-class-reference" }}
         {{ $.RawContent }}
      {{- else }}
         {{- $.Content -}}
      {{- end }}
   {{- end }}
{{- end }}
