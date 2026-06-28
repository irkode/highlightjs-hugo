/**
 * convert-chroma-styles.mjs
 *
 * completely written by https://claude.ai/chat/
 *
 * Merges two Chroma CSS files (light + dark) into a single
 * CSS file using CSS custom properties and light-dark() for theming.
 *
 * Usage:
 *   node convert-chroma.mjs [options]
 *
 * Options:
 *   --baseDir <path>   Base directory for all files. Defaults to cwd.
 *   --light   <file>   Light theme source file. Defaults to <baseDir>/light.css
 *   --dark    <file>   Dark theme source file.  Defaults to <baseDir>/dark.css
 *   --output  <file>   Output file.             Defaults to <baseDir>/chroma-colors.css
 *
 * All file paths are resolved relative to cwd if not absolute.
 *
 * Example:
 *    hugo gen chromastyles --style theme-dark
 *    hugo gen chromastyles --style theme-light
 *    convert-chroma-styles --light theme-light --dark theme-dark --output merged.css
 *
 * Notes:
 *    You may also use chroma styles with definitions in the form `light: ".chroma CLASS"`
 *    `dark:  ".dark .chroma CLASS"`. this supports vonverion from theme files which rely
 *    on a default light mode and a ".dark" class for the prefers-dark media query.
 */

import { readFileSync, writeFileSync } from "fs";
import { resolve } from "path";

// ---------------------------------------------------------------------------
// CLI argument parsing
// ---------------------------------------------------------------------------
function parseArgs(argv) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith("--") && i + 1 < argv.length && !argv[i + 1].startsWith("--")) {
      args[argv[i].slice(2)] = argv[i + 1];
      i++;
    }
  }
  return args;
}

const args    = parseArgs(process.argv.slice(2));
const baseDir = resolve(process.cwd(), args.baseDir ?? ".");
// File args are resolved relative to baseDir so that --baseDir is a true root.
// Absolute paths passed via --light/--dark/--output are used as-is (resolve handles that).
const LIGHT_FILE = resolve(baseDir, args.light  ?? "light.css");
const DARK_FILE  = resolve(baseDir, args.dark   ?? "dark.css");
const COLORS_OUT = resolve(baseDir, args.output ?? "chroma-colors.css");

console.log("Settings:");
console.log(`  baseDir : ${baseDir}`);
console.log(`  light   : ${LIGHT_FILE}`);
console.log(`  dark    : ${DARK_FILE}`);
console.log(`  output  : ${COLORS_OUT}`);
console.log("");

// ---------------------------------------------------------------------------
// Config: CSS variable name mapping
// key   = variable name as it appears in source (without -- and without var())
// value = variable name to use in output (without -- and without var())
// var(--IN) -> var(--OUT) substitution; result goes directly into light-dark(),
// bypassing the --light-chroma-* / --dark-chroma-* token system entirely
// Add an entry here whenever a new CSS variable appears in the source files.
// ---------------------------------------------------------------------------
const VAR_MAP = {
  light: {
    "bg":         "bg",       // identity — var(--bg) -> var(--bg)  (no change)
  },
  dark: {
    "color-dark": "bg",       // var(--color-dark) -> var(--bg)
    "bg":         "bg",       // identity — in case the dark file also uses --bg
  },
};

// ---------------------------------------------------------------------------
// Config: fallback variables used when only one theme defines a color.
// These should point to your global code block default colors.
// ---------------------------------------------------------------------------
const FALLBACK = {
  "color":            "code-text",   // --code-text  (base code foreground)
  "background-color": "code-bg",     // --code-bg    (base code background)
};

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Convert an rgb(r,g,b) string to a lowercase hex #rrggbb value */
function rgbToHex(rgb) {
  const m = rgb.match(/rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)/i);
  if (!m) throw new Error(`Cannot parse rgb value: ${rgb}`);
  return (
    "#" +
    [m[1], m[2], m[3]]
      .map((n) => parseInt(n, 10).toString(16).padStart(2, "0"))
      .join("")
  );
}

/** Normalize a color token to lowercase and convert rgb() to hex */
function normalizeColor(raw) {
  const trimmed = raw.trim();
  if (/^rgb\(/i.test(trimmed)) return rgbToHex(trimmed);
  return trimmed.toLowerCase();
}

// ---------------------------------------------------------------------------
// Parsing
// ---------------------------------------------------------------------------

/**
 * Parse a single CSS line into a structured object.
 *
 * Handles both plain Chroma output and HugoDocs-style output:
 *   Plain:    .chroma .cls { prop: val; }
 *   HugoDocs: .dark .chroma .cls { prop: val; }
 *
 * The .dark prefix is stripped unconditionally — the caller already knows
 * which file is dark and which is light, so the prefix carries no information.
 *
 * Skip rule: skip any line whose selector contains no .chroma.
 *
 * Returns null for skipped or unparseable lines.
 */
function parseLine(line) {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith("//")) return null;

  // Extract comment
  const commentMatch = trimmed.match(/^\/\*([^*]*)\*\//);
  const comment = commentMatch ? commentMatch[1].trim() : "";

  // Extract selector and declaration block
  const ruleMatch = trimmed.match(/\*\/\s*([^{]*)\{([^}]*)\}/);
  if (!ruleMatch) return null;

  const declarationBlock = ruleMatch[2].trim();

  // Strip optional .dark prefix — both file formats are supported
  let selector = ruleMatch[1].trim();
  if (selector.startsWith(".dark")) selector = selector.replace(/^\.dark\s*/, "").trim();

  // Skip anything without .chroma (e.g. bare ".bg {}" lines)
  if (!selector.startsWith(".chroma")) return null;
  selector = selector.replace(/^\.chroma\s*/, "").trim();

  // Parse declarations into key/value pairs
  const declarations = [];
  if (declarationBlock) {
    for (const decl of declarationBlock.split(";")) {
      const d = decl.trim();
      if (!d) continue;
      const colon = d.indexOf(":");
      if (colon === -1) continue;
      declarations.push({
        prop: d.slice(0, colon).trim(),
        value: d.slice(colon + 1).trim(),
      });
    }
  }

  // Build stable class key: "chroma" for the wrapper, "k" / "nf" etc. for sub-classes
  const classKey = selector ? selector.replace(/^\./, "").trim() : "chroma";

  return { comment, classKey, declarations };
}

/**
 * Parse an entire CSS file into a Map<classKey, parsedLine>.
 */
function parseFile(filePath) {
  const src = readFileSync(filePath, "utf8");
  const map = new Map();

  for (const line of src.split("\n")) {
    const parsed = parseLine(line);
    if (!parsed) continue;
    if (map.has(parsed.classKey)) {
      console.warn(`  [WARN] Duplicate class "${parsed.classKey}" in ${filePath} — keeping first`);
      continue;
    }
    map.set(parsed.classKey, parsed);
  }
  return map;
}

// ---------------------------------------------------------------------------
// Color processing
// ---------------------------------------------------------------------------

/**
 * Process a single color value.
 *
 * var(--NAME): look up in VAR_MAP[theme], error if missing.
 *   Returns { type: "var", resolved: "var(--OUT)" }
 *   — used directly in light-dark(), no token registered.
 *
 * Literal color: normalise to lowercase hex.
 *   Returns { type: "color", normalized: "#rrggbb" }
 *   — registered as a --light/dark-chroma-* token.
 */
function processColorValue(value, theme, classKey, prop) {
  const varMatch = value.match(/^var\(--([^)]+)\)$/);
  if (varMatch) {
    const inName = varMatch[1];
    const mapping = VAR_MAP[theme];
    if (!mapping || !(inName in mapping)) {
      console.error(
        `\n[ERROR] No mapping defined for CSS variable "--${inName}" ` +
        `(found in ${theme} file, class "${classKey}", prop "${prop}").\n` +
        `Add an entry to VAR_MAP.${theme}["${inName}"] in the script config.\n`
      );
      process.exit(1);
    }
    return { type: "var", resolved: `var(--${mapping[inName]})` };
  }

  return { type: "color", normalized: normalizeColor(value) };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

console.log("Parsing light file…");
const lightMap = parseFile(LIGHT_FILE);

console.log("Parsing dark file…");
const darkMap  = parseFile(DARK_FILE);

// ---------------------------------------------------------------------------
// Cross-check: report classes that exist in only one file (informational —
// missing classes are filled via token hierarchy fallback below)
// ---------------------------------------------------------------------------
console.log("\nCross-checking classes…");
let crossCheckOk = true;

for (const key of lightMap.keys()) {
  if (!darkMap.has(key)) {
    console.warn(`  [WARN] Class "${key}" exists in light file but not in dark file`);
    crossCheckOk = false;
  }
}
for (const key of darkMap.keys()) {
  if (!lightMap.has(key)) {
    console.warn(`  [WARN] Class "${key}" exists in dark file but not in light file`);
    crossCheckOk = false;
  }
}
if (crossCheckOk) console.log("  All classes matched ✓");

// ---------------------------------------------------------------------------
// Token hierarchy helpers
// ---------------------------------------------------------------------------

// "Line" classes (structural, not token hierarchy) — identified by their
// comment starting with "Line". These get no parent-token fallback.
const LINE_CLASS_COMMENTS = new Set([
  "LineLink", "LineTableTD", "LineTable", "LineHighlight",
  "LineNumbersTable", "LineNumbers", "Line", "CodeLine",
]);

/**
 * Return the parent class key for a Chroma token class, or null if none.
 * A subtype key like "na" has parent "n" (strip last letter).
 * Single-letter keys and structural Line classes have no parent.
 */
function parentKey(key, comment) {
  if (LINE_CLASS_COMMENTS.has(comment)) return null;  // structural class
  if (key.length <= 1) return null;                   // already top-level token
  return key.slice(0, -1);
}

/**
 * Walk up the token hierarchy within a single theme map looking for a color value.
 * Starts at the parent of key (not key itself — caller already checked direct).
 * Returns { resolvedKey } referencing the ancestor that has the value, or null.
 * resolvedKey is the key to use for building a var(--theme-chroma-resolvedKey) reference.
 */
function lookupParent(key, comment, prop, themeMap) {
  let current = parentKey(key, comment);
  while (current !== null) {
    const entry = themeMap.get(current);
    if (entry) {
      const byProp = new Map(entry.declarations.map((d) => [d.prop, d.value]));
      if (byProp.has(prop)) return { resolvedKey: current };
    }
    const parentEntry = themeMap.get(current) ?? lightMap.get(current) ?? darkMap.get(current);
    current = parentKey(current, parentEntry?.comment ?? comment);
  }
  return null;
}

// ---------------------------------------------------------------------------
// Process rules
// ---------------------------------------------------------------------------

// Shared color palette: hex -> var name (e.g. "#268bd2" -> "--chroma-color-268bd2")
// Collected during processing; emitted as section 0 before light/dark tokens.
const colorPalette = new Map();

/**
 * Register a hex color in the shared palette and return its var() reference.
 * Only hex values (#rrggbb / #rgb) are registered — other color keywords
 * like "inherit" are returned unchanged.
 * Idempotent — registering the same hex twice returns the same var name.
 */
function paletteVar(color) {
  if (!color.startsWith("#")) return color;  // keyword — pass through as-is
  if (!colorPalette.has(color)) colorPalette.set(color, `--chroma-color-${color.slice(1)}`);
  return `var(${colorPalette.get(color)})`;
}

// Color token registries: tokenKey -> { val, comment, inherited }
const lightColorDefs = new Map();
const darkColorDefs  = new Map();

// Chroma CSS rules for the output: Array<{ comment, selector, outDecls }>
const chromaRules = [];

const COLOR_PROPS = new Set(["color", "background-color"]);

const allKeys = new Set([...lightMap.keys(), ...darkMap.keys()]);

for (const key of allKeys) {
  const light = lightMap.get(key);
  const dark  = darkMap.get(key);

  const comment    = light?.comment || dark?.comment || key;
  const lightDecls = light?.declarations || [];
  const darkDecls  = dark?.declarations  || [];

  const lightByProp = new Map(lightDecls.map((d) => [d.prop, d.value]));
  const darkByProp  = new Map(darkDecls.map((d) => [d.prop, d.value]));

  // All props that appear in either file for this class
  const allProps = new Set([...lightByProp.keys(), ...darkByProp.keys()]);

  // Also include color props that may only exist in a parent — we need to emit
  // a rule for this class if either theme resolves a color via hierarchy.
  // Only relevant for token classes (not structural Line classes).
  if (!LINE_CLASS_COMMENTS.has(comment) && key !== "chroma") {
    for (const prop of COLOR_PROPS) {
      if (!allProps.has(prop)) {
        // Check if either theme has an ancestor with this prop
        if (lookupParent(key, comment, prop, lightMap) ||
            lookupParent(key, comment, prop, darkMap)) {
          allProps.add(prop);
        }
      }
    }
  }

  const outDecls = [];

  for (const prop of allProps) {
    const lVal = lightByProp.get(prop);
    const dVal = darkByProp.get(prop);

    if (COLOR_PROPS.has(prop)) {
      const isBg     = prop === "background-color";
      const tokenKey = `${isBg ? "bg-" : ""}${key}`;
      const prefix   = isBg ? "bg-" : "";

      let lightResolved = null;  // final var() reference for light side
      let darkResolved  = null;  // final var() reference for dark side

      // ------------------------------------------------------------------
      // Resolve LIGHT value
      // Priority: 1) direct  2) parent in light theme  3) var(--code-*)
      // ------------------------------------------------------------------
      if (lVal) {
        // Direct definition
        const r = processColorValue(lVal, "light", key, prop);
        if (r.type === "color") {
          // Register in shared palette; token points to palette var
          lightColorDefs.set(tokenKey, { val: paletteVar(r.normalized), comment, inherited: null });
        } else {
          // CSS variable reference (from VAR_MAP) — use as-is, no palette entry
          lightColorDefs.set(tokenKey, { val: r.resolved, comment, inherited: null });
        }
        lightResolved = `var(--light-chroma-${tokenKey})`;
      } else {
        const parentHit = lookupParent(key, comment, prop, lightMap);
        if (parentHit) {
          // Inherit from parent in same theme — store as var() reference
          const parentTokenKey = `${prefix}${parentHit.resolvedKey}`;
          lightColorDefs.set(tokenKey, {
            val: `var(--light-chroma-${parentTokenKey})`,
            comment,
            inherited: `light .${parentHit.resolvedKey}`,
          });
          lightResolved = `var(--light-chroma-${tokenKey})`;
          console.log(`  [INFO] light: '${key}' '${prop}' inherited from light .${parentHit.resolvedKey}`);
        } else {
          // No light value anywhere — use global default
          const defaultVar = `var(--${FALLBACK[prop]})`;
          lightColorDefs.set(tokenKey, {
            val: defaultVar,
            comment,
            inherited: `default`,
          });
          lightResolved = `var(--light-chroma-${tokenKey})`;
          console.log(`  [INFO] light: '${key}' '${prop}' — no value found, using default '${FALLBACK[prop]}'`);
        }
      }

      // ------------------------------------------------------------------
      // Resolve DARK value
      // Priority: 1) direct  2) parent in dark theme  3) same class in light  4) var(--code-*)
      // No further hierarchy walk after crossing to light — classic cascade model.
      // ------------------------------------------------------------------
      if (dVal) {
        // Direct definition
        const r = processColorValue(dVal, "dark", key, prop);
        if (r.type === "color") {
          // Register in shared palette; token points to palette var
          darkColorDefs.set(tokenKey, { val: paletteVar(r.normalized), comment, inherited: null });
        } else {
          // CSS variable reference (from VAR_MAP) — use as-is, no palette entry
          darkColorDefs.set(tokenKey, { val: r.resolved, comment, inherited: null });
        }
        darkResolved = `var(--dark-chroma-${tokenKey})`;
      } else {
        const parentHit = lookupParent(key, comment, prop, darkMap);
        if (parentHit) {
          // Inherit from parent in dark theme
          const parentTokenKey = `${prefix}${parentHit.resolvedKey}`;
          darkColorDefs.set(tokenKey, {
            val: `var(--dark-chroma-${parentTokenKey})`,
            comment,
            inherited: `dark .${parentHit.resolvedKey}`,
          });
          darkResolved = `var(--dark-chroma-${tokenKey})`;
          console.log(`  [INFO] dark: '${key}' '${prop}' inherited from dark .${parentHit.resolvedKey}`);
        } else if (lightResolved) {
          // Cross to same class in light theme (classic cascade: light is the base)
          darkColorDefs.set(tokenKey, {
            val: `var(--light-chroma-${tokenKey})`,
            comment,
            inherited: `light .${key}`,
          });
          darkResolved = `var(--dark-chroma-${tokenKey})`;
          console.log(`  [INFO] dark: '${key}' '${prop}' inherited from light .${key}`);
        } else {
          // No value found anywhere — use global default
          const defaultVar = `var(--${FALLBACK[prop]})`;
          darkColorDefs.set(tokenKey, {
            val: defaultVar,
            comment,
            inherited: `default`,
          });
          darkResolved = `var(--dark-chroma-${tokenKey})`;
          console.log(`  [INFO] dark: '${key}' '${prop}' — no value found, using default '${FALLBACK[prop]}'`);
        }
      }

      outDecls.push({ prop, value: `light-dark(${lightResolved}, ${darkResolved})` });

    } else {
      // Non-color property — take from light; warn if dark differs
      if (lVal && dVal && lVal !== dVal) {
        console.warn(
          `  [WARN] Non-color prop mismatch for ".chroma .${key}" / "${prop}": ` +
          `light="${lVal}" dark="${dVal}" — using light value`
        );
      }
      const val = lVal || dVal;
      if (val) outDecls.push({ prop, value: val });
    }
  }

  const selector = key === "chroma" ? ".chroma" : `.chroma .${key}`;

  // PreWrapper (.chroma) is always hardcoded to the global code theme variables.
  // Any color/background-color defined in the source files is reported and discarded.
  if (key === "chroma") {
    for (const d of outDecls) {
      if (d.prop === "color" || d.prop === "background-color") {
        const target = d.prop === "color" ? FALLBACK["color"] : FALLBACK["background-color"];
        // Determine which theme(s) contributed this value
        const inLight = lightByProp.get(d.prop);
        const inDark  = darkByProp.get(d.prop);
        if (inLight) console.log(`  [INFO] light: .chroma '${d.prop}' changed from '${inLight}' to 'var(--${target})'`);
        if (inDark)  console.log(`  [INFO] dark:  .chroma '${d.prop}' changed from '${inDark}' to 'var(--${target})'`);
      }
    }
    // Replace all color decls with hardcoded defaults; keep non-color attributes
    const nonColorDecls = outDecls.filter((d) => d.prop !== "color" && d.prop !== "background-color");
    outDecls.length = 0;
    outDecls.push({ prop: "color",            value: `var(--${FALLBACK["color"]})` });
    outDecls.push({ prop: "background-color", value: `var(--${FALLBACK["background-color"]})` });
    outDecls.push(...nonColorDecls);
  }

  chromaRules.push({ comment, selector, outDecls });
}

// ---------------------------------------------------------------------------
// Render 001-chroma-colors.css
// ---------------------------------------------------------------------------
console.log("\nGenerating 001-chroma-colors.css…");

const lines = [];

lines.push("/* ==========================================================================");
lines.push("   Chroma syntax highlighting — color tokens and CSS rules");
lines.push("   Auto-generated by convert-chroma.mjs — do not edit manually");
lines.push("   Requires color-scheme to be set on <html> for light-dark() to work.");
lines.push("   ========================================================================== */");
lines.push("");
lines.push(":root {");
lines.push("");

// Section 0: shared color palette — one entry per unique hex value
lines.push("   /* --- Color palette --- */");
for (const [hex, varName] of [...colorPalette.entries()].sort()) {
  lines.push(`   ${varName}: ${hex};`);
}
lines.push("");

lines.push("   /* --- Light theme tokens --- */");
for (const [key, { val, comment, inherited }] of lightColorDefs) {
  const suffix = inherited ? `  /* ${inherited} */` : "";
  lines.push(`   /* ${comment} */ --light-chroma-${key}: ${val};${suffix}`);
}
lines.push("");

lines.push("   /* --- Dark theme tokens --- */");
for (const [key, { val, comment, inherited }] of darkColorDefs) {
  const suffix = inherited ? `  /* ${inherited} */` : "";
  lines.push(`   /* ${comment} */ --dark-chroma-${key}: ${val};${suffix}`);
}
lines.push("");

// Section 3: combined --chroma-* light-dark() vars — both sides are always
// defined by this point (direct, inherited, or default), so no fallback needed.
lines.push("   /* --- Combined light-dark() tokens --- */");
const allTokenKeys = new Set([...lightColorDefs.keys(), ...darkColorDefs.keys()]);
for (const key of allTokenKeys) {
  const lightEntry = lightColorDefs.get(key);
  const darkEntry  = darkColorDefs.get(key);
  const comment    = (lightEntry || darkEntry).comment;
  const lightVal   = `var(--light-chroma-${key})`;
  const darkVal    = `var(--dark-chroma-${key})`;
  lines.push(`   /* ${comment} */ --chroma-${key}: light-dark(${lightVal}, ${darkVal});`);
}
lines.push("");

lines.push("}");
lines.push("");

// Chroma CSS rules — colors reference --chroma-* combined vars
lines.push("/* --- Chroma syntax highlighting rules --- */");
lines.push("");

for (const { comment, selector, outDecls } of chromaRules) {
  if (outDecls.length === 0) {
    lines.push(`/* ${comment} */ ${selector} {  }`);
  } else {
    // Replace --light-chroma-* and --dark-chroma-* references with --chroma-*
    const declStr = outDecls.map((d) => {
      const val = d.value.replace(
        /light-dark\(var\(--light-chroma-([^)]+)\),\s*var\(--dark-chroma-([^)]+)\)\)/g,
        (_, lk, dk) => lk === dk ? `var(--chroma-${lk})` : `light-dark(var(--light-chroma-${lk}), var(--dark-chroma-${dk}))`
      ).replace(
        /light-dark\(var\(--light-chroma-([^)]+)\),\s*(var\(--[^)]+\))\)/g,
        (_, lk, fb) => `var(--chroma-${lk})`  // fallback case — key only has light side
      ).replace(
        /light-dark\((var\(--[^)]+\)),\s*var\(--dark-chroma-([^)]+)\)\)/g,
        (_, fb, dk) => `var(--chroma-${dk})`  // fallback case — key only has dark side
      );
      return `${d.prop}: ${val}`;
    }).join("; ");
    lines.push(`/* ${comment} */ ${selector} { ${declStr} }`);
  }
}
lines.push("");

writeFileSync(COLORS_OUT, lines.join("\n"), "utf8");
console.log(`  Written: ${COLORS_OUT}`);

console.log("\nDone ✓");
