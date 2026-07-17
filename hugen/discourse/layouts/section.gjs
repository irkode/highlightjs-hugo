{{- $tpl := templates.Current.Name }}
{{- $idx := math.Counter }}
{{- $lang := .Section }}
{{- warnf "[%04d][ %-20s ] : %s :: %s" $idx $tpl .Path $lang }}
{{- $entrySrc := printf `import { apiInitializer } from "discourse/lib/api";
import hljsGrammar from "highlightjs/%s/dist/%s.es.min";
import * as params from "@params";

export default apiInitializer((api) => {
  api.registerHighlightJSLanguage(params.lang, hljsGrammar);
});
` $lang $lang }}
{{- $entry := resources.FromString (printf "%s/entry.gjs.js" $lang) $entrySrc }}
{{- with $entry | js.Build (dict
       "targetPath" (printf "%s/theme-initializer.gjs" $lang)
       "format"     "esm"
       "target"     "esnext"
       "minify"     true
       "externals"  (slice "discourse/lib/api")
       "params"     (dict "lang" $lang)
   ) }}
   {{- .Content }}
{{- end }}
