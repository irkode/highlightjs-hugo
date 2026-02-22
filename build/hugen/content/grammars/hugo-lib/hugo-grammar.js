import * as h4hbase from "./hugo-keywords.js";
import { COMMENT, NUMBER_MODE, QUOTE_STRING_MODE, APOS_STRING_MODE } from '../../src/lib/modes.js';

// action comments
const H4HGRAMMAR_COMMENT_OPEN = /\s*(\{\{- \/\*|\{\{\/\*)/;
const H4HGRAMMAR_COMMENT_CLOSE = /\*\/ -\}\}|\*\/\}\}/;
// action commands
const H4HGRAMMAR_ACTION_OPEN = /\{\{- |\{\{(?!-)/;
const H4HGRAMMAR_ACTION_CLOSE = / -\}\}|(?<! -)\}\}/;
// simple modes, -> always list last to not capture begin of complex modes
const H4HGRAMMAR_PIPE_OPERATOR_MODE = { scope: 'operator', match: /[|,=]|:=/, };
const H4HGRAMMAR_CONTEXT_ONLY_MODE = { scope: 'template-variable.context', match: /\.|\$/ };
const H4HGRAMMAR_DOT_PROPERTY_CHAIN = { scope: 'property', match: /(\.\w+)+/ };

// everything between two backticks
const H4HGRAMMAR_RAW_STRING_MODE = {
  scope: 'string.raw',
  match: /`[^`]*`/,
  keywords: [],
};

const H4HGRAMMAR_METHOD_CHAIN_HELPER = {
  // scope: METHOD_CHAIN_HELPER',
  variants: [
    // used after a builtin or function has been detected
    { begin: [/\./, /\w+/], beginScope: { 1: 'property', 2: 'title.function.invoke', }, },
    // method submode - starting with a WORD
    { begin: [/\w+/], beginScope: { 1: 'title.function.invoke', }, },
  ],
  contains: [H4HGRAMMAR_DOT_PROPERTY_CHAIN],
};

const H4HGRAMMAR_FUNCTION_KEYWORDS = {
  $pattern: /\w+\.\w+/,
  'built_in': h4hbase.H4HBASE_FUNCTIONS,
};
const H4HGRAMMAR_PIPE_FUNCTION_MODE = {
  // scope: 'PIPE_FUNCTION_MODE',
  begin: h4hbase.H4HBASE_FUNCTIONS_REGEX_GROUPED,
  keywords: H4HGRAMMAR_FUNCTION_KEYWORDS,
  contains: [H4HGRAMMAR_METHOD_CHAIN_HELPER]
};

const H4HGRAMMAR_PIPELINE_KEYWORDS = {
  $pattern: /\w+/,
  'built_in': h4hbase.H4HBASE_BUILTINS,
  'literal': h4hbase.H4HBASE_LITERALS,
};

// method chain - starting with a context DOT
const H4HGRAMMAR_PIPE_CONTEXT_MODE = {
  // scope: 'PIPE_CONTEXT_MODE',
  begin: [/\.(?=\w+)/], beginScope: { 1: 'template-variable.context' },
  contains: [H4HGRAMMAR_METHOD_CHAIN_HELPER],
};

// one word identifier followed by a DOT is a method call of an object
const H4HGRAMMAR_PIPE_BUILTIN_MODE = {
  // scope: 'PIPE_BUILTIN_MODE',
  variants: [
    { begin: /\w+(?=\.)/, contains: [H4HGRAMMAR_METHOD_CHAIN_HELPER] },
    { match: /\w+/ }
  ],
  keywords: H4HGRAMMAR_PIPELINE_KEYWORDS,
};

// template variable
const H4HGRAMMAR_PIPE_VARIABLE_MODE = {
  // scope: 'PIPE_VARIABLE_MODE',
  variants: [
    { begin: [/\$\w+(?=\.)/], beginScope: { 1: 'template-variable', }, contains: [H4HGRAMMAR_METHOD_CHAIN_HELPER] },
    { match: /\$\w+/, scope: 'template-variable' },
  ],
};

const H4HGRAMMAR_SUB_EXPRESSION = {
  // scope: 'SUB_EXPRESSION',
  begin: [/\(/], beginScope: { 1: 'punctuation', },
  end: [/\)/], endScope: { 1: 'punctuation', },
  // contains added after all modes are defined
};

const H4HGRAMMAR_PIPELINE = [
  NUMBER_MODE,
  QUOTE_STRING_MODE,
  APOS_STRING_MODE,
  H4HGRAMMAR_RAW_STRING_MODE,
  H4HGRAMMAR_PIPE_FUNCTION_MODE,
  H4HGRAMMAR_PIPE_BUILTIN_MODE,
  H4HGRAMMAR_PIPE_CONTEXT_MODE,
  H4HGRAMMAR_PIPE_VARIABLE_MODE,
  H4HGRAMMAR_PIPE_OPERATOR_MODE,
  H4HGRAMMAR_CONTEXT_ONLY_MODE,
  H4HGRAMMAR_SUB_EXPRESSION,
];

H4HGRAMMAR_SUB_EXPRESSION.contains = H4HGRAMMAR_PIPELINE;

export const H4HGRAMMAR_mainContains = [
  COMMENT(H4HGRAMMAR_COMMENT_OPEN, H4HGRAMMAR_COMMENT_CLOSE, { relevance: 10, }),
  // stop highlighting if a handlebars begin tag is found
  { begin: /\{\{(#|>|!--|!)/, end: /\}\}/, illegal: /.*/, },
  {
    begin: [H4HGRAMMAR_ACTION_OPEN, /\s*/, h4hbase.H4HBASE_KEYWORDS_PIPELINE_REGEX], beginScope: { 1: 'template-tag', 3: 'keyword' },
    end: [H4HGRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
    contains: H4HGRAMMAR_PIPELINE,
  },
  {
    begin: [H4HGRAMMAR_ACTION_OPEN, /\s*/, h4hbase.H4HBASE_KEYWORDS_STANDALONE_REGEX], beginScope: { 1: 'template-tag', 3: 'keyword' },
    end: [H4HGRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
  },
  {
    begin: [H4HGRAMMAR_ACTION_OPEN], beginScope: { 1: 'template-tag' },
    end: [H4HGRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
    contains: H4HGRAMMAR_PIPELINE,
  }
];
