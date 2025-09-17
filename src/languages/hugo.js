/*
Language: highlightjs-hugo
Requires: xml.js
Author: Irkode <irkode@rikode.de>
Description: Syntax highlighting for Hugo templates.
Website: https://irkode.github.io/highlightjs-hugo
Category: template
License: MIT
*/

import * as kw from "./keywords.js";

export default function (hljs) {

  // action comments
  const re_COMMENT_OPEN = /\s*(\{\{- \/\*|\{\{\/\*)/;
  const re_COMMENT_CLOSE = /\*\/ -\}\}|\*\/\}\}/;

  // action commands
  const re_ACTION_OPEN = /\{\{- |\{\{(?!-)/;
  const re_ACTION_CLOSE = / -\}\}|(?<! -)\}\}/;

  // simple string matcher used for template names
  const re_STRING = /""|"[^"]+"/;

  // simple modes, -> always list last to not capture begin of complex modes
  const PIPE_OPERATOR_MODE = { scope: 'operator', match: /[|,=]|:=/, };
  const CONTEXT_ONLY_MODE = { scope: 'template-variable.context', match: /\.|\$/ };
  const DOT_PROPERTY_CHAIN = { scope: 'property', match: /(\.\w+)+/ };

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

  const PIPELINE_KEYWORDS = {
    $pattern: /\w+/,
    'built_in': kw.BUILT_INS,
    'literal': kw.LITERALS,
  };
  const FUNCTION_KEYWORDS = {
    $pattern: /\w+\.\w+/,
    'built_in': kw.FUNCTIONS,
  };

  const PIPE_FUNCTION_MODE = {
    // scope: 'PIPE_FUNCTION_MODE',
    begin: kw.re_FUNCTIONS,
    keywords: FUNCTION_KEYWORDS,
    contains: [METHOD_CHAIN_HELPER]
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
    PIPE_FUNCTION_MODE,
    PIPE_BUILTIN_MODE,
    PIPE_CONTEXT_MODE,
    PIPE_VARIABLE_MODE,
    PIPE_OPERATOR_MODE,
    CONTEXT_ONLY_MODE,
    SUB_EXPRESSION,
  ];

  SUB_EXPRESSION.contains = PIPELINE;

  const ACTION_BLOCK = {
    // scope: "ACTION_BLOCK",
    relevance: 10,
    begin: [/template|block/, /\s+/, re_STRING], beginScope: { 1: 'keyword', 3: 'string' },
    contains: PIPELINE,
  };

  const ACTION_DEFINE = {
    // scope: "ACTION_DEFINE",
    relevance: 10,
    begin: [/define/, /\s+/, re_STRING], beginScope: { 1: 'keyword', 3: 'string' },
    // swallow all after
    starts: { begin: /.*/, end: re_ACTION_CLOSE, returnEnd: true },
  };

  const ACTION_KEYWORD_ONLY = {
    // scope: "ACTION_KEYWORD_ONLY",
    relevance: 10,
    begin: /continue|else|end/, beginScope: 'keyword',
    // swallow all after
    starts: { begin: /.*/, end: re_ACTION_CLOSE, returnEnd: true },
  };

  const ACTION_KEYWORD_PIPELINE = {
    // scope: "ACTION_KEYWORD_PIPELINE",
    relevance: 10,
    begin: /else\s+with|else\s+if|return|range|with|try|if/, beginScope: 'keyword',
    contains: PIPELINE
  };

  return {
    name: 'highlightjs-hugo',
    aliases: [
      'hugo',
      'hugo-html',
      'hugo-text'
    ],
    case_insensitive: false,
    subLanguage: 'xml',
    contains: [
      hljs.COMMENT(re_COMMENT_OPEN, re_COMMENT_CLOSE, { relevance: 10, }),
      // stop highlighting if a handlebars begin tag is found
      { begin: /\{\{(#|>|!--|!)/, end: /\}\}/, illegal: /.*/, },
      {
        begin: [re_ACTION_OPEN], beginScope: { 1: 'template-tag' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
        contains: [
          ACTION_KEYWORD_PIPELINE,
          ACTION_KEYWORD_ONLY,
          ACTION_DEFINE,
          ACTION_BLOCK,
        ].concat(PIPELINE),
      }
    ]
  };
}
