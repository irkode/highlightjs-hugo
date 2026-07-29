+++
title = "Discourse adds lang-auto"
description = "Thoughts about the 'lang-auto' sometimes added by Discourse which totally breaks autodetection"
+++

## The 'lang-auto' problem

Sometimes we don't get any highlighting in Discourse. That's true for our HuGo grammars as well.

Searching for a reason we found the code to be highlighted is wrapped in `code class="lang-auto"` on
the page. Highlight.JS just does nothing with that one cause it does not know such a language.

Research revealed that this is just a marker for the live browser rendering implementation of
Discourse. Discourse will first remove that class and then call the Discourse way of "auto
highlighting" with Highlight.JS.

The way Discourse is embedding highlight.JS is quite complex with lots of security and magic under
the hood. So no exact clue why for now. We already tried to add a Plugin with breaks on that import
strategy where each call is a promise... what ever that means.

With browser and node execution we could not generate a `lang-auto` and that string is no where in
the sources. So we doubt it's a highlight.js problem.

Around 2013 there was a discussion for same kind of problem blamed to using markdown classes and
then curly braces (mainly C or C++) which was planned to be solved with markdown-it. Looks like it's
back in 2026 because our HuGo templates trigger that in a new way.

More here in the
[Issue on Discourse](https://meta.discourse.org/t/automatic-highlighting-fails-for-some-fenced-code-blocks/408503).

We could not yet track it down to a definite root cause, but since

- it does not happen always
- it happens reproducible for the same code (known til now)
- it perfectly works without Discourse way of doing this

Might be a timing or async problem caused by how Highlight.JS is integrated with Discourse.

## Root Cause

Sometimes it's as simple as it can be: A hard cap of 1K bytes for auto detection in Discourse.
[408503-post8](https://meta.discourse.org/t/automatic-highlighting-fails-for-some-fenced-code-blocks/408503/8)

## Solution

And here is a PR that should solve the problem:
[FIX: Reliably highlight fenced code blocks with no language](https://github.com/discourse/discourse/pull/42106/)

- Still a hard limit on 30000 bytes
- raise the autodetect limit to 2K
- if it’s longer, use the first 2000 bytes to try autodetect
- if it still can't figure it out remove the 'lang-auto' class

As of today 2026-07-29 the fix is live in Hugo's discourse forum.
