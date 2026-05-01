/*
{{- $lang := .Section }}
Language: {{ title $lang }}
{{- with .Params.requires }}{{ printf "\nRequires: %s\n" . }}{{ end }}
Author: {{ site.Params.author }}
Description: Syntax highlighting for {{ title $lang }} templates.
Website: {{ absURL "" }}
Category: template
License: {{ site.Params.license }}
*/
import { H4HGRAMMAR_mainContains } from "../../../h4h-lib/{{- .Params.keywords -}}/grammar.js";
export default function (hljs) {

  const languageDefinition = {
    case_insensitive: false,
    {{- with $lang }} {{- printf "\n    name: '%s'," (title .) }}{{ end }}
    {{- with .Params.aliases }}{{- printf "\n    aliases: %s," (jsonify .) }}{{ end }}
    {{- with .Params.disableAutodetect }}{{- printf "\n    disableAutodetect: %s," (jsonify .) }}{{ end }}
    {{- with .Params.subLanguages }}{{- printf "\n    subLanguage: %s," . }}{{ end }}
    contains: H4HGRAMMAR_mainContains
  };
  return languageDefinition;
}
