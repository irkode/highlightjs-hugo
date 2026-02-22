{{- $lang := .page.Params.hljs.language -}}
import { apiInitializer } from "discourse/lib/api";
export default apiInitializer((api) => {
  {{- $varName := "" }}
  {{- with resources.Get (printf "/dist/%s/dist/%s.min.js" $lang $lang) }}
    {{- with $content := .Content }}
      {{- with findRESubmatch `var\s+(\w+)` . 1 }}
        {{ $varName = index (index . 0) 1 }}
      {{- end }}
      {{- . | replaceRE `^(?s)(.*?)(?:\(\(\)=>\{)(.*?);hljs\.registerLanguage.*$` "$1$2" }}
    {{- end }}
  {{- end }}
  api.registerHighlightJSLanguage("{{ $lang }}", {{ $varName }});
});
