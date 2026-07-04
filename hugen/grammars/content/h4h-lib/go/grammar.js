import * as h4hbase from "./keywords.js";
import { COMMENT, NUMBER_MODE, QUOTE_STRING_MODE, APOS_STRING_MODE } from '../../../src/lib/modes.js';
import { inherit } from '../../../src/lib/utils.js';

// action comments
const H4H_GRAMMAR_COMMENT_OPEN = /\s*(\{\{- \/\*|\{\{\/\*)/;
const H4H_GRAMMAR_COMMENT_CLOSE = /\*\/ -\}\}|\*\/\}\}/;
// action commands
const H4H_GRAMMAR_ACTION_OPEN = /\{\{- |\{\{(?!-)/;
const H4H_GRAMMAR_ACTION_CLOSE = / -\}\}|(?<! -)\}\}/;
// simple modes, -> always list last to not capture begin of complex modes
const H4H_GRAMMAR_PIPE_OPERATOR_MODE = { scope: 'operator', match: /[|,=]|:=/, };
const H4H_GRAMMAR_CONTEXT_ONLY_MODE = { scope: 'template-variable.context', match: /\.|\$/ };
const H4H_GRAMMAR_DOT_PROPERTY_CHAIN = { scope: 'property', match: /(\.\w+)+/ };

// everything between two backticks
const H4H_GRAMMAR_RAW_STRING_MODE = {
   scope: 'string.raw',
   match: /`[^`]*`/,
   keywords: [],
};
const H4H_GRAMMAR_RUNE_STRING_MODE = inherit(APOS_STRING_MODE, { scope: 'string.rune'});

const H4H_GRAMMAR_PIPELINE_KEYWORDS = {
   $pattern: /\w+/,
   'built_in': h4hbase.H4HBASE_BUILTINS,
   'literal': h4hbase.H4HBASE_LITERALS,
};

// method chain - starting with a context DOT
const H4H_GRAMMAR_PIPE_CONTEXT_MODE = {
   // scope: 'PIPE_CONTEXT_MODE',
   begin: [/\.(?=\w+)/, /\w+(\.\w+)*/ ], beginScope: { 1: 'template-variable.context', 2: 'property' },
};

// one word identifier followed by a DOT is a method call of an object
const H4H_GRAMMAR_PIPE_BUILTIN_MODE = {
   // scope: 'H4H_GRAMMAR_PIPE_BUILTIN_MODE',
   variants: [
      { begin: [ /\w+(?=\.)/, ], beginScope: {1: 'property', }, contains: [H4H_GRAMMAR_DOT_PROPERTY_CHAIN] },
      { match: /\w+/, scope: ''}
   ],
   keywords: H4H_GRAMMAR_PIPELINE_KEYWORDS,
};

// template variable
const H4H_GRAMMAR_PIPE_VARIABLE_MODE = {
   // scope: 'PIPE_VARIABLE_MODE',
   variants: [
      { begin: [/\$\w+(?=\.)/], beginScope: { 1: 'template-variable', }, contains: [H4H_GRAMMAR_DOT_PROPERTY_CHAIN] },
      { match: /\$\w+/, scope: 'template-variable' },
   ],
};

const H4H_GRAMMAR_SUB_EXPRESSION = {
   // scope: 'SUB_EXPRESSION',
   begin: [/\(/], beginScope: { 1: 'punctuation', },
   end: [/\)/], endScope: { 1: 'punctuation', },
   // contains added after all modes are defined
};

const H4H_GRAMMAR_PIPELINE = [
   NUMBER_MODE,
   QUOTE_STRING_MODE,
   H4H_GRAMMAR_RUNE_STRING_MODE,
   H4H_GRAMMAR_RAW_STRING_MODE,
   H4H_GRAMMAR_PIPE_BUILTIN_MODE,
   H4H_GRAMMAR_PIPE_CONTEXT_MODE,
   H4H_GRAMMAR_PIPE_VARIABLE_MODE,
   H4H_GRAMMAR_PIPE_OPERATOR_MODE,
   H4H_GRAMMAR_CONTEXT_ONLY_MODE,
   H4H_GRAMMAR_SUB_EXPRESSION,
];

H4H_GRAMMAR_SUB_EXPRESSION.contains = H4H_GRAMMAR_PIPELINE;

export const H4H_GRAMMAR_mainContains = [
   COMMENT(H4H_GRAMMAR_COMMENT_OPEN, H4H_GRAMMAR_COMMENT_CLOSE, { relevance: 10, }),
   // stop highlighting if a handlebars begin tag is found
   { begin: /\{\{(#|>|!--|!)/, end: /\}\}/, illegal: /.*/, },
   {
      begin: [H4H_GRAMMAR_ACTION_OPEN, /\s*/, h4hbase.H4HBASE_KEYWORDS_PIPELINE_REGEX], beginScope: { 1: 'template-tag', 3: 'keyword' },
      end: [H4H_GRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
      contains: H4H_GRAMMAR_PIPELINE,
   },
   {
      begin: [H4H_GRAMMAR_ACTION_OPEN, /\s*/, h4hbase.H4HBASE_KEYWORDS_STANDALONE_REGEX], beginScope: { 1: 'template-tag', 3: 'keyword' },
      end: [H4H_GRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
   },
   {
      begin: [H4H_GRAMMAR_ACTION_OPEN], beginScope: { 1: 'template-tag' },
      end: [H4H_GRAMMAR_ACTION_CLOSE], endScope: { 1: 'template-tag' },
      contains: H4H_GRAMMAR_PIPELINE,
   }
];
