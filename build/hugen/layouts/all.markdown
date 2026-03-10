{{- /*
  catch all template to get rid of warnings for missing templates

  Hugo won't create any outputs for templates producing an empty string.
*/ -}}
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "ALL( MD )  %s - %s" $pagePath $tpl }}
{{- /* remove all trailing whitespace */ -}}