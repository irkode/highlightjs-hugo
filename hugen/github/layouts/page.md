<!-- this README is generated with hugen/github -->
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- $idx := math.Counter }}
{{- with .Params.keywords }}
   {{- warnf "[%04d][ %-20s ] : %s :: %s" $idx $tpl $pagePath . }}
{{- else }}
   {{- warnf "[%04d][ %-20s ] : %s" $idx $tpl $pagePath }}
{{- end }}
<img align="left" src="huggingface-96x96.png" style="width:96px;"/>
<aside style="flex:1; padding-left:12px;">
<h1>Advanced syntax highlighting for HuGo templates<br/></h1>
</aside><br/>

<img align="center" src="highlightjs-hugo.png">
{{ .Content | transform.HTMLToMarkdown }}
{{- /**/ -}}
