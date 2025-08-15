<div align="center">

# saltmark

A small Markdown subset to HTML converter for Ruby, with a command line tool. No gems beyond the standard library.

![License](https://img.shields.io/badge/LICENSE-MIT-blue?style=for-the-badge)  ![Language](https://img.shields.io/badge/RUBY-CC342D?style=for-the-badge&logo=ruby&logoColor=white)  ![Tests](https://img.shields.io/badge/TESTS-16-brightgreen?style=for-the-badge)

Refer to [LICENSE](LICENSE) for the legal bits.

</div>

## What's in it

- Block elements: headings (`#` to `######`), paragraphs, fenced code blocks (with an optional language class), unordered and ordered lists, and blockquotes that can contain other blocks.
- Inline elements: strong, emphasis, inline code and links.
- Safe by default. All text is HTML-escaped, and link targets with schemes other than http, https and mailto are dropped, so untrusted input can be rendered.
- `bin/saltmark`, which reads files or standard input and writes HTML to standard output.

```ruby
require "saltmark"

Saltmark.convert("# Hello\n\nSome *text* with `code`.")
```

## 🏗️ Architecture

```
 bin/saltmark                files or stdin ─▶ Saltmark.convert ─▶ stdout
 lib/saltmark.rb             Saltmark.convert(text)
  ├─ saltmark/converter.rb   Converter   line-by-line block parser
  │      fence | heading | quote | bullet | number | paragraph
  │      quote ─▶ Converter.new(inner lines).call      (recursion)
  └─ saltmark/inline.rb      Inline      text ─▶ HTML spans
         split on `code` ─▶ escape ─▶ lift links into placeholders
         ─▶ strong, then emphasis ─▶ put links back
 saltmark/version.rb         VERSION
```

- `Converter` works through an array of lines, looking at the first one to decide which block it starts. A paragraph ends at a blank line or at the start of any other block.
- Blockquotes strip the `>` prefix and convert the remaining lines again, so a quote can hold headings, lists or more quotes.
- `Inline.render` splits on code spans first so their contents are never touched. Links are lifted out before emphasis is applied, so underscores inside URLs survive.
- Link URLs are checked against an allow-list pattern (http, https, mailto, relative paths and anchors). An unsafe link keeps its label and loses its anchor.

## 🚀 Quick start

```
rake test
```

or, without rake:

```
ruby -Ilib -Itest test/saltmark_test.rb
```

From the shell:

```
echo "- one\n- two" | bin/saltmark
bin/saltmark README.md > README.html
```

A small document:

```
# Hello

Some *text* with `code` and [a link](https://example.com).

- one
- two
```

comes out as:

```
<h1>Hello</h1>
<p>Some <em>text</em> with <code>code</code> and <a href="https://example.com">a link</a>.</p>
<ul>
<li>one</li>
<li>two</li>
</ul>
```

## 🧪 Testing

16 Minitest tests, all passing (23 assertions):

- Blocks (9): headings, paragraphs splitting on blank lines, fenced code blocks with and without a language (blank lines kept), unordered and ordered lists, blockquotes containing other blocks, a list ending a paragraph, and empty input.
- Inline (4): emphasis, inline code staying literal, links, and link URLs being escaped.
- Safety (2): unsafe link schemes are dropped and raw HTML is escaped.
- The CLI reading from standard input (1).

## ⚠️ Honest limits

- It's a subset on purpose: no nested lists, reference links, images, raw HTML, tables or hard line breaks.
- Where it differs from CommonMark in edge cases, it follows the simpler rule.

## Licence

MIT.
