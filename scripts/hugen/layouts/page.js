{{- /*
  For pages defining JS output format we will add a keywords.js
  This contains needed tables and regexes for parsing plugin specific stuff
  */
-}}
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "TPL  %s - %s" $pagePath $tpl }}

{{- $dataLang := .Params.hljs.keywords }}

{{- $keywords := partialCached "get-keywords.html" $dataLang $dataLang }}

{{- $dataKeywords := index site.Data.keywords $dataLang }}

{{- /* generate keyword base patterns for the action root modes */ -}}
{{- range $regexName, $regexWords := index $dataKeywords "patterns" }}
  {{- printf "export const re_%s = /%s/;\n" $regexName (delimit $regexWords "|") }}
{{- end }}

{{- /* generate exports for keyword lists and keyword regex */ -}} 
{{- range $scope, $words := $keywords }}
  {{- range index $dataKeywords.generate $scope }}
    {{- if eq "kw" . }}
      {{- $wordsWithRelevance := slice }}
      {{- range $words }}
        {{- $wordsWithRelevance = $wordsWithRelevance  | append (printf "'%s'" (cond (hasPrefix . "hugo.") (add . "|10") .)) }}
      {{- end }}
      {{- $const := add "kw_" (upper $scope) }}
      {{- printf "export const %s = [%s];\n" $const (delimit $wordsWithRelevance ",") }}
    {{- else if eq "re" . }}
      {{- $const := add "re_" (upper $scope) }}
      {{- printf "export const %s = /\\b(%s)\\b/;\n" $const (replace (delimit $words "|") "." `\.`) }}
      {{- /* we create a grouped regex variant for functions namespace.function */}}
      {{- if eq "function" $scope }}
        {{- $const = add "re_g_" (upper $scope) }}
        {{- $pad := newScratch }}
        {{- range $words }}
          {{- $splittedWord := split . "." }}
          {{- $ns := index $splittedWord 0 }}
          {{- $name := index $splittedWord 1 }}
          {{- with $pad.Get $ns }}
            {{- $pad.Add $ns $name }}
          {{- else }}
            {{- $pad.Set $ns (slice $name) }}
          {{- end }}
        {{- end }}
        {{- $groups := slice }}
        {{- range $ns, $names := $pad.Values }}
          {{- $groups = $groups | append (printf "%s\\.(?:%s)" $ns (delimit $names "|")) }}
        {{- end }}
        {{- printf "export const %s = /\\b(%s)\\b/;\n" $const (delimit $groups "|")}}
      {{- end }}
      {{- /* $pad.SetInMap "js" $const (printf "export const %s = /\\b(%s)\\b/;" $const (replace (delimit $words "|") "." `\.`)) */ -}}
    {{- end }}
  {{- end }}
{{- end }}

{{- /* generate scope definitions that use the above */ -}}

{{- /* remove all trailing whitespace */ -}}
