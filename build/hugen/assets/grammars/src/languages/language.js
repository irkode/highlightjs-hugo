/*
{{- $lang := .page.Params.hljs.language }}
Language: {{ title $lang }}
{{- with .page.Params.hljs.requires }}{{ printf "\nRequires: %s\n" . }}{{ end }}
Author: {{ .site.Params.author }}
Description: Syntax highlighting for {{ title $lang }} templates.
Website: {{ site.Home.Permalink }}
Category: template
License: {{ .site.Params.license }}
*/
import { H4HGRAMMAR_mainContains } from "../../../hugo-lib/hugo-grammar.js";
export default function (hljs) {

  const languageDefinition = {
    case_insensitive: false,
    {{- with .page.Params.hljs.language }} {{ printf "\n    name: '%s'," (title .) }}{{ end }}
    {{- with .page.Params.hljs.aliases }}{{ printf "\n    aliases: %s," (jsonify .) }}{{ end }}
    {{- with .page.Params.hljs.disableAutodetect }}{{ printf "\n    disableAutodetect: %s," (jsonify .) }}{{ end }}
    {{- with .page.Params.hljs.subLanguages }}{{ printf "\n    subLanguage: %s," . }}{{ end }}
    contains: H4HGRAMMAR_mainContains
  };
  return languageDefinition;
}
