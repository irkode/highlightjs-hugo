/*
Language: Hugo-Embed
Author: Irkode <irkode@rikode.de>
Description: Syntax highlighting for Hugo-Embed templates.
Website: https://irkode.github.io/highlightjs-hugo/
Category: template
License: MIT
*/
import { H4HGRAMMAR_mainContains } from "../../../hugo-lib/hugo-grammar.js";
export default function (hljs) {

  const languageDefinition = {
    case_insensitive: false, 
    name: 'Hugo-Embed',
    disableAutodetect: true,
    contains: H4HGRAMMAR_mainContains
  };
  return languageDefinition;
}
