{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "SEC(MARKDOWN)  %s - %s" $pagePath $tpl }}

{{- /* create reference documents */}}
{{- range slice "package.json" }}
  {{- partial "create-and-publish" (dict "base" "grammars" "source" . "page" $) }}
{{- end }}

{{- /* create the language javascript module based on keyword definition */}}
{{- $javascript := partial "get-javascript" $ }}
{{- $target := add "src/languages/" .Params.h4h.language ".js" }}
{{- partial "create-and-publish" (dict "base" "grammars" "source" "src/languages/language.js" "target" $target "page" $ "params" $javascript) }}
{{- /* remove all trailing whitespace */ -}}