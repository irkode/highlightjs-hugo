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
import * as hugo from "./lib/keywords.js";
export default function (hljs) {

  // action comments
  const re_COMMENT_OPEN = /\s*(\{\{- \/\*|\{\{\/\*)/;
  const re_COMMENT_CLOSE = /\*\/ -\}\}|\*\/\}\}/;

  // action commands
  const re_ACTION_OPEN = /\{\{- |\{\{(?!-)/;
  const re_ACTION_CLOSE = / -\}\}|(?<! -)\}\}/;
  // simple modes, -> always list last to not capture begin of complex modes
  const PIPE_OPERATOR_MODE = { scope: 'operator', match: /[|,=]|:=/, };
  const CONTEXT_ONLY_MODE = { scope: 'template-variable.context', match: /\.|\$/ };
  const DOT_PROPERTY_CHAIN = { scope: 'property', match: /(\.\w+)+/ };

  // everything between two backticks
  const RAW_STRING_MODE = {
    scope: 'string.raw',
    match: /`[^`]*`/,
    keywords: [],
  };

  const METHOD_CHAIN_HELPER = {
    // scope: METHOD_CHAIN_HELPER',
    variants: [
      // used after a builtin or function has been detected
      { begin: [/\./, /\w+/], beginScope: { 1: 'property', 2: 'title.function.invoke', }, },
      // method submode - starting with a WORD
      { begin: [/\w+/], beginScope: { 1: 'title.function.invoke', }, },
    ],
    contains: [DOT_PROPERTY_CHAIN],
  };

  const FUNCTION_KEYWORDS = {
    $pattern: /\w+\.\w+/,
    'built_in': hugo.kw_FUNCTION,
  };
  const PIPE_FUNCTION_MODE = {
    // scope: 'PIPE_FUNCTION_MODE',
    begin: hugo.re_g_FUNCTION,
    keywords: FUNCTION_KEYWORDS,
    contains: [METHOD_CHAIN_HELPER]
  };

  const PIPELINE_KEYWORDS = {
    $pattern: /\w+/,
    'built_in': hugo.kw_BUILT_IN,
    'literal': hugo.kw_LITERAL,
  };

  // method chain - starting with a context DOT
  const PIPE_CONTEXT_MODE = {
    // scope: 'PIPE_CONTEXT_MODE',
    begin: [/\.(?=\w+)/], beginScope: { 1: 'template-variable.context' },
    contains: [METHOD_CHAIN_HELPER],
  };

  // one word identifier followed by a DOT is a method call of an object
  const PIPE_BUILTIN_MODE = {
    // scope: 'PIPE_BUILTIN_MODE',
    variants: [
      { begin: /\w+(?=\.)/, contains: [METHOD_CHAIN_HELPER] },
      { match: /\w+/ }
    ],
    keywords: PIPELINE_KEYWORDS,
  };

  //template variable
  const PIPE_VARIABLE_MODE = {
    // scope: 'PIPE_VARIABLE_MODE',
    variants: [
      { begin: [/\$\w+(?=\.)/], beginScope: { 1: 'template-variable', }, contains: [METHOD_CHAIN_HELPER] },
      { match: /\$\w+/, scope: 'template-variable' },
    ],
  };

  const SUB_EXPRESSION = {
    // scope: 'SUB_EXPRESSION',
    begin: [/\(/], beginScope: { 1: 'punctuation', },
    end: [/\)/], endScope: { 1: 'punctuation', },
    // contains added after all modes are defined
  };

  const PIPELINE = [
    hljs.NUMBER_MODE,
    hljs.QUOTE_STRING_MODE,
    hljs.APOS_STRING_MODE,
    RAW_STRING_MODE,
    PIPE_FUNCTION_MODE,
    PIPE_BUILTIN_MODE,
    PIPE_CONTEXT_MODE,
    PIPE_VARIABLE_MODE,
    PIPE_OPERATOR_MODE,
    CONTEXT_ONLY_MODE,
    SUB_EXPRESSION,
  ];

  SUB_EXPRESSION.contains = PIPELINE;

  const mainContains = [
      hljs.COMMENT(re_COMMENT_OPEN, re_COMMENT_CLOSE, { relevance: 10, }),
      // stop highlighting if a handlebars begin tag is found
      { begin: /\{\{(#|>|!--|!)/, end: /\}\}/, illegal: /.*/, },
      {
        begin: [re_ACTION_OPEN, /\s*/, hugo.re_PIPELINE_KEYWORDS], beginScope: { 1: 'template-tag', 3: 'keyword' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
        contains: PIPELINE,
      },
      {
        begin: [re_ACTION_OPEN, /\s*/, hugo.re_STANDALONE_KEYWORDS], beginScope: { 1: 'template-tag', 3: 'keyword' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
      },
      {
        begin: [re_ACTION_OPEN], beginScope: { 1: 'template-tag' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
        contains: PIPELINE,
      }
    ];
  const languageDefinition = {
    case_insensitive: false,
    {{- with .page.Params.hljs.aliases }}{{ printf "\n    aliases: %s," (jsonify .) }}{{ end }}
    {{- with .page.Params.hljs.subLanguages }}{{ printf "\n    subLanguage: %s," . }}{{ end }}
    contains: mainContains
  };
  return languageDefinition;
}
