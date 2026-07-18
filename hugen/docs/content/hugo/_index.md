+++
title = "Using with Hugo & Chroma"
description = "Combine Chroma's fast build-time highlighting with Highlight.js for Hugo templates: a minimal setup passing what Chroma cannot highlight to Highlight.js."
+++

You could switch completely to Highlight.js. To get the best of both worlds

- fast static rendering using Chroma at build time
- dynamic but beautiful code highlighting for Hugo templates

here's a minimal setup how to pass everything Hugo/Chroma cannot highlight to HighlightJS.

## Identifying Chroma output

When Hugo/Chroma renders a fenced code block it will be wrapped in `<pre><code>` tags like this[^1].
That's the standard, if you configure it differently (eg custom wrappers) you have to adjust.

- Known language that gets highlighted by Chroma

   ```html
   <div class="highlight">
      <pre tabindex="0" class="chroma">
         <code class="language-go-html-template" data-lang="go-html-template">...</code>
      </pre>
   </div>
   ```

- unknown language

   ```html
   <pre tabindex="0">
      <!-- unknown stands for the language passed to the fenced code block -->
      <code class="language-unknown" data-lang="unknown">...</code>
   </pre>
   ```

- no language

   ```html
   <pre tabindex="0">
      <code>...</code>
   </pre>
   ```

## Configure Highlight JS

In it's default configuration HighlightJS will pick up `<pre><code>` and highlight it's content.
Good for the latter two but the first would be double highlighted with strange effects.

HighlightJS provides options to tweak things like that[^2]. Using teh standard `nohighlight` class
to the code tag would need much more setup.

The key here is the `chroma`-class on the `pre` tag which is only added when Chroma has done
highlighting.

We just use `hljs.configure to change the selector and exclude the elements highlighted by Chroma.

Play this at the end of your body:

```html
<body>
   ...
   <script src="js/highlight-hugo.min.js"></script>
   <script>
      hljs.configure({ cssSelector: "pre:not(.chroma) code" });
      hljs.highlightAll();
   </script>
</body>
```

## CSS

CSS styles can be used as usual. Simple Example for a _keyword_

- Chroma for keyword
   ```css
   .chroma .k {
      color: blue;
   }
   .chroma {
      color: light-dark(#015692, #88aece);
   }
   ```
- _Highlightjs_
   ```css
   .hljs-keyword {
      color: blue;
   }
   .hljs-keyword {
      color: light-dark(#015692, #88aece);
   }
   ```

The exact way depends on how you style these things, especially dark/light, prefers or complete
color themes.

[^1]: There are some more variants but the general layout is like that.

[^2]: Unfortunately there's no common standard for this all over the highlighters. All Highlanders.
