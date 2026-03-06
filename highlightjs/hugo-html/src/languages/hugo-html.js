/*
Language: Hugo-Html
Requires: xml.js

Author: Irkode <irkode@rikode.de>
Description: Syntax highlighting for Hugo-Html templates.
Website: https://irkode.github.io/highlightjs-hugo/
Category: template
License: MIT
*/
import { H4HGRAMMAR_mainContains } from "../../../hugo-lib/hugo-grammar.js";
export default function (hljs) {

  const languageDefinition = {
    case_insensitive: false, 
    name: 'Hugo-Html',
    subLanguage: 'xml',
    contains: H4HGRAMMAR_mainContains
  };
  return languageDefinition;
}
