{{- /*
  For pages defining JS output format we will add a keywords.js
  This contains needed tables and regexes for parsing plugin specific stuff
  */
-}}
{{- $tpl := templates.Current.Name }}
{{- $pagePath := .Path }}
{{- warnf "XX TPL  %s - %s" $pagePath $tpl }}

{{- $dataLang := .Params.hljs.keywords }}

{{- $keywords := partialCached "get-keywords.html" $dataLang $dataLang }}

{{- $dataKeywords := index site.Data.keywords $dataLang }}

{{- /* generate keyword base patterns for the action root modes */ -}}
{{- range $regexName, $regexWords := index $dataKeywords "patterns" }}
  {{- printf "export const H4HBASE_%s_REGEX = /%s/;\n" $regexName (delimit $regexWords "|") }}
{{- end }}

{{- /* generate exports for keyword lists and keyword regex */ -}}
{{- range $scope, $words := $keywords }}
  {{- range index $dataKeywords.generate $scope }}
    {{- if eq "kw" . }}
      {{- $wordsWithRelevance := slice }}
      {{- range $words }}
        {{- $wordsWithRelevance = $wordsWithRelevance  | append (printf "'%s'" (cond (hasPrefix . "hugo.") (add . "|10") .)) }}
      {{- end }}
      {{- printf "export const H4HBASE_%s = [%s];\n" $scope (delimit $wordsWithRelevance ",") }}
    {{- else if eq "re" . }}
      {{- printf "export const H4HBASE_%s_REGEX = /\\b(%s)\\b/;\n" $scope (replace (delimit $words "|") "." `\.`) }}
      {{- /* we create a grouped regex variant for functions namespace.function */}}
      {{- if eq "FUNCTIONS" $scope }}
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
        {{- printf "export const H4HBASE_%s_REGEX_GROUPED = /\\b(%s)\\b/;\n" $scope (delimit $groups "|")}}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- /* remove all trailing whitespace */ -}}
