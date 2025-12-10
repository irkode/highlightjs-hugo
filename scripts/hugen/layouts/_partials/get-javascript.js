{{- warnf "PARTIAL: %s" templates.Current.Name }}

{{- $dataLang := .Params.hljs.keywords }}

{{- $keywords := partial "get-keywords.html" $dataLang }}

{{- $dataKeywords := index site.Data.keywords $dataLang }}

{{- $pad := newScratch }}

{{- /* generate keyword base patterns for the action root modes */ -}}
{{- range $regexName, $regexWords := index $dataKeywords "patterns" }}
  {{- $pad.SetInMap "js" $regexName (printf "const re_%s = /%s/;" $regexName (delimit $regexWords "|")) }}
{{- end }}

{{- range $scope, $words := $keywords }}
  {{- range index $dataKeywords.generate $scope }}
    {{- if eq "kw" . }}
      {{- $wordsWithRelevance := slice }}
      {{- range $words }}
        {{- $wordsWithRelevance = $wordsWithRelevance  | append (printf "'%s'" (cond (hasPrefix . "hugo.") (add . "|10") .)) }}
      {{- end }}
      {{- $const := add "kw_" (upper $scope) }}
      {{- $pad.SetInMap "js" $const (printf "const %s = [%s];" $const (delimit $wordsWithRelevance ",")) }}
    {{- else if eq "re" . }}
      {{- $const := add "re_" (upper $scope) }}
      {{- $pad.SetInMap "js" $const (printf "const %s = /\\b(%s)\\b/;" $const (replace (delimit $words "|") "." `\.`)) }}
    {{- end }}
  {{- end }}
{{- end }}
{{- return $pad.Values }}
{{- /* remove all trailing whitespace */ -}}