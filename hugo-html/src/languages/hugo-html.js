/*
Language: highlightjs-hugo-html
Author: Irkode <irkode@rikode.de>
Description: Syntax highlighting for Hugo-Html templates.
Website: https://irkode.github.io/hugo4fun-highlightJShighlightjs-hugo-html
Category: template
License: MIT
*/
export default function (hljs) {

  // action comments
  const re_COMMENT_OPEN = /\s*(\{\{- \/\*|\{\{\/\*)/;
  const re_COMMENT_CLOSE = /\*\/ -\}\}|\*\/\}\}/;

  // action commands
  const re_ACTION_OPEN = /\{\{- |\{\{(?!-)/;
  const re_ACTION_CLOSE = / -\}\}|(?<! -)\}\}/;

  const re_PIPELINE_KEYWORDS = /block|define|else\swith|else\s+if|range|return|template|try|with|if/;
  const re_STANDALONE_KEYWORDS = /break|continue|else|end/;

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
  const kw_LITERAL = ['false','true','nil'];
  const kw_FUNCTION = ['transform.HighlightCodeBlock','resources.ExecuteAsTemplate','strings.ContainsNonSpace','transform.HTMLToMarkdown','lang.FormatNumberCustom','collections.Complement','collections.Dictionary','collections.NewScratch','partials.IncludeCached','strings.FindRESubmatch','transform.CanHighlight','transform.HTMLUnescape','transform.PortableText','collections.Intersect','encoding.Base64Decode','encoding.Base64Encode','lang.FormatAccounting','resources.Fingerprint','resources.PostProcess','transform.Markdownify','resources.FromString','transform.HTMLEscape','collections.Delimit','collections.KeyVals','collections.Querify','collections.Reverse','collections.Shuffle','collections.SymDiff','compare.Conditional','hugo.IsMultilingual|10','images.ColorBalance','images.GaussianBlur','inflect.Singularize','lang.FormatCurrency','resources.GetRemote','strings.ContainsAny','strings.SliceString','transform.Highlight','transform.Remarshal','transform.Unmarshal','transform.XMLEscape','collections.Append','hugo.IsDevelopment|10','images.UnsharpMask','lang.FormatPercent','openapi3.Unmarshal','resources.GetMatch','strings.CountRunes','strings.CountWords','strings.FirstUpper','strings.TrimPrefix','strings.TrimSuffix','time.ParseDuration','transform.Plainify','collections.After','collections.Apply','collections.First','collections.Group','collections.Index','collections.IsSet','collections.Merge','collections.Slice','collections.Union','collections.Where','hugo.IsProduction|10','images.AutoOrient','images.Brightness','images.Saturation','inflect.Pluralize','lang.FormatNumber','resources.PostCSS','strings.HasPrefix','strings.HasSuffix','strings.ReplaceRE','strings.RuneCount','strings.TrimRight','strings.TrimSpace','templates.Current','transform.Emojify','collections.Last','collections.Sort','collections.Uniq','encoding.Jsonify','hugo.Environment|10','hugo.IsMultihost|10','images.Grayscale','inflect.Humanize','partials.Include','resources.ByType','resources.Concat','resources.Minify','strings.Contains','strings.TrimLeft','strings.Truncate','templates.Exists','transform.ToMath','collections.Seq','compare.Default','css.TailwindCSS','hugo.CommitHash|10','hugo.IsExtended|10','hugo.WorkingDir|10','images.Colorize','images.Contrast','images.Pixelate','reflect.IsSlice','resources.Babel','resources.Match','resources.ToCSS','strings.Replace','strings.ToLower','strings.ToUpper','templates.Defer','urls.AbsLangURL','urls.RelLangURL','collections.In','hugo.BuildDate|10','hugo.Generator|10','hugo.GoVersion|10','images.Opacity','images.Overlay','images.Padding','images.Process','images.Sigmoid','lang.Translate','math.ToDegrees','math.ToRadians','resources.Copy','strings.FindRE','strings.Repeat','strings.Substr','urls.Anchorize','cast.ToString','collections.D','crypto.FNV32a','crypto.SHA256','diagrams.Goat','hugo.IsServer|10','images.Config','images.Dither','images.Filter','images.Invert','math.MaxInt64','os.FileExists','path.BaseName','reflect.IsMap','resources.Get','safe.HTMLAttr','strings.Chomp','strings.Count','strings.Split','strings.Title','time.Duration','urls.JoinPath','cast.ToFloat','data.GetJSON','fmt.Erroridf','hugo.Version|10','images.Gamma','images.Sepia','math.Counter','math.ModBool','math.Product','strings.Diff','strings.Trim','crypto.HMAC','crypto.SHA1','css.PostCSS','data.GetCSV','debug.Timer','fmt.Println','fmt.Warnidf','hash.FNV32a','hash.XxHash','images.Mask','images.Text','os.ReadFile','time.AsTime','time.Format','urls.AbsURL','urls.RelRef','urls.RelURL','urls.URLize','cast.ToInt','compare.Eq','compare.Ge','compare.Gt','compare.Le','compare.Lt','compare.Ne','crypto.MD5','debug.Dump','fmt.Errorf','fmt.Printf','hugo.Store|10','images.Hue','lang.Merge','math.Atan2','math.Floor','math.Round','os.ReadDir','path.Clean','path.Split','safe.JSStr','urls.Parse','fmt.Print','fmt.Warnf','hugo.Deps|10','images.QR','math.Acos','math.Asin','math.Atan','math.Ceil','math.Rand','math.Sqrt','os.Getenv','path.Base','path.Join','safe.HTML','css.Sass','js.Babel','js.Batch','js.Build','math.Abs','math.Add','math.Cos','math.Div','math.Log','math.Max','math.Min','math.Mod','math.Mul','math.Pow','math.Sin','math.Sub','math.Sum','math.Tan','path.Dir','path.Ext','safe.CSS','safe.URL','time.Now','urls.Ref','math.Pi','os.Stat','safe.JS','time.In'];
  const kw_BUILT_IN = ['findRESubmatch','partialCached','base64Decode','base64Encode','htmlUnescape','safeHTMLAttr','fingerprint','markdownify','singularize','absLangURL','complement','countrunes','countwords','dateFormat','fileExists','htmlEscape','newScratch','relLangURL','anchorize','hasPrefix','hasSuffix','highlight','intersect','pluralize','replaceRE','safeJSStr','unmarshal','duration','erroridf','humanize','plainify','readFile','safeHTML','slicestr','truncate','urlquery','default','delimit','emojify','getJSON','jsonify','keyVals','modBool','partial','postCSS','println','querify','readDir','replace','safeCSS','safeURL','shuffle','symdiff','warnidf','absURL','append','errorf','findRE','getCSV','getenv','minify','printf','relref','relURL','safeJS','sha256','string','substr','urlize','xxhash','after','apply','babel','chomp','first','float','group','index','isset','lower','merge','print','slice','split','title','toCSS','union','upper','warnf','where','cond','dict','hmac','i18n','last','page','sha1','site','sort','time','trim','uniq','add','and','div','int','len','md5','mod','mul','not','now','pow','ref','seq','sub','eq','ge','gt','in','le','lt','ne','or','T'];
  const re_FUNCTION = /\b(transform\.HighlightCodeBlock|resources\.ExecuteAsTemplate|strings\.ContainsNonSpace|transform\.HTMLToMarkdown|lang\.FormatNumberCustom|collections\.Complement|collections\.Dictionary|collections\.NewScratch|partials\.IncludeCached|strings\.FindRESubmatch|transform\.CanHighlight|transform\.HTMLUnescape|transform\.PortableText|collections\.Intersect|encoding\.Base64Decode|encoding\.Base64Encode|lang\.FormatAccounting|resources\.Fingerprint|resources\.PostProcess|transform\.Markdownify|resources\.FromString|transform\.HTMLEscape|collections\.Delimit|collections\.KeyVals|collections\.Querify|collections\.Reverse|collections\.Shuffle|collections\.SymDiff|compare\.Conditional|hugo\.IsMultilingual|images\.ColorBalance|images\.GaussianBlur|inflect\.Singularize|lang\.FormatCurrency|resources\.GetRemote|strings\.ContainsAny|strings\.SliceString|transform\.Highlight|transform\.Remarshal|transform\.Unmarshal|transform\.XMLEscape|collections\.Append|hugo\.IsDevelopment|images\.UnsharpMask|lang\.FormatPercent|openapi3\.Unmarshal|resources\.GetMatch|strings\.CountRunes|strings\.CountWords|strings\.FirstUpper|strings\.TrimPrefix|strings\.TrimSuffix|time\.ParseDuration|transform\.Plainify|collections\.After|collections\.Apply|collections\.First|collections\.Group|collections\.Index|collections\.IsSet|collections\.Merge|collections\.Slice|collections\.Union|collections\.Where|hugo\.IsProduction|images\.AutoOrient|images\.Brightness|images\.Saturation|inflect\.Pluralize|lang\.FormatNumber|resources\.PostCSS|strings\.HasPrefix|strings\.HasSuffix|strings\.ReplaceRE|strings\.RuneCount|strings\.TrimRight|strings\.TrimSpace|templates\.Current|transform\.Emojify|collections\.Last|collections\.Sort|collections\.Uniq|encoding\.Jsonify|hugo\.Environment|hugo\.IsMultihost|images\.Grayscale|inflect\.Humanize|partials\.Include|resources\.ByType|resources\.Concat|resources\.Minify|strings\.Contains|strings\.TrimLeft|strings\.Truncate|templates\.Exists|transform\.ToMath|collections\.Seq|compare\.Default|css\.TailwindCSS|hugo\.CommitHash|hugo\.IsExtended|hugo\.WorkingDir|images\.Colorize|images\.Contrast|images\.Pixelate|reflect\.IsSlice|resources\.Babel|resources\.Match|resources\.ToCSS|strings\.Replace|strings\.ToLower|strings\.ToUpper|templates\.Defer|urls\.AbsLangURL|urls\.RelLangURL|collections\.In|hugo\.BuildDate|hugo\.Generator|hugo\.GoVersion|images\.Opacity|images\.Overlay|images\.Padding|images\.Process|images\.Sigmoid|lang\.Translate|math\.ToDegrees|math\.ToRadians|resources\.Copy|strings\.FindRE|strings\.Repeat|strings\.Substr|urls\.Anchorize|cast\.ToString|collections\.D|crypto\.FNV32a|crypto\.SHA256|diagrams\.Goat|hugo\.IsServer|images\.Config|images\.Dither|images\.Filter|images\.Invert|math\.MaxInt64|os\.FileExists|path\.BaseName|reflect\.IsMap|resources\.Get|safe\.HTMLAttr|strings\.Chomp|strings\.Count|strings\.Split|strings\.Title|time\.Duration|urls\.JoinPath|cast\.ToFloat|data\.GetJSON|fmt\.Erroridf|hugo\.Version|images\.Gamma|images\.Sepia|math\.Counter|math\.ModBool|math\.Product|strings\.Diff|strings\.Trim|crypto\.HMAC|crypto\.SHA1|css\.PostCSS|data\.GetCSV|debug\.Timer|fmt\.Println|fmt\.Warnidf|hash\.FNV32a|hash\.XxHash|images\.Mask|images\.Text|os\.ReadFile|time\.AsTime|time\.Format|urls\.AbsURL|urls\.RelRef|urls\.RelURL|urls\.URLize|cast\.ToInt|compare\.Eq|compare\.Ge|compare\.Gt|compare\.Le|compare\.Lt|compare\.Ne|crypto\.MD5|debug\.Dump|fmt\.Errorf|fmt\.Printf|hugo\.Store|images\.Hue|lang\.Merge|math\.Atan2|math\.Floor|math\.Round|os\.ReadDir|path\.Clean|path\.Split|safe\.JSStr|urls\.Parse|fmt\.Print|fmt\.Warnf|hugo\.Deps|images\.QR|math\.Acos|math\.Asin|math\.Atan|math\.Ceil|math\.Rand|math\.Sqrt|os\.Getenv|path\.Base|path\.Join|safe\.HTML|css\.Sass|js\.Babel|js\.Batch|js\.Build|math\.Abs|math\.Add|math\.Cos|math\.Div|math\.Log|math\.Max|math\.Min|math\.Mod|math\.Mul|math\.Pow|math\.Sin|math\.Sub|math\.Sum|math\.Tan|path\.Dir|path\.Ext|safe\.CSS|safe\.URL|time\.Now|urls\.Ref|math\.Pi|os\.Stat|safe\.JS|time\.In)\b/;

  const FUNCTION_KEYWORDS = {
    $pattern: /\w+\.\w+/,
    'built_in': kw_FUNCTION,
  };
  const PIPE_FUNCTION_MODE = {
    // scope: 'PIPE_FUNCTION_MODE',
    begin: re_FUNCTION,
    keywords: FUNCTION_KEYWORDS,
    contains: [METHOD_CHAIN_HELPER]
  };

  const PIPELINE_KEYWORDS = {
    $pattern: /\w+/,
    'built_in': kw_BUILT_IN,
    'literal': kw_LITERAL,
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
        begin: [re_ACTION_OPEN, /\s*/, re_STANDALONE_KEYWORDS], beginScope: { 1: 'template-tag', 3: 'keyword' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
      },
      {
        begin: [re_ACTION_OPEN, /\s*/, re_PIPELINE_KEYWORDS], beginScope: { 1: 'template-tag', 3: 'keyword' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
        contains: PIPELINE,
      },
      {
        begin: [re_ACTION_OPEN], beginScope: { 1: 'template-tag' },
        end: [re_ACTION_CLOSE], endScope: { 1: 'template-tag' },
        contains: PIPELINE,
      }
    ];
  const languageDefinition = {
    name: 'highlightjs-hugo-html',
    case_insensitive: false,
    aliases: ["hugo"],
    subLanguage: ["xml"],
    contains: mainContains
  };
  return languageDefinition;
}
