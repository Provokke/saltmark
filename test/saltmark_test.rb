require_relative "test_helper"
require "open3"

class SaltmarkTest < Minitest::Test
  def html(text)
    Saltmark.convert(text)
  end

  def test_headings
    assert_equal "<h1>Title</h1>", html("\x23 Title")
    assert_equal "<h3>Sub</h3>", html("\x23\x23\x23 Sub \x23\x23")
    assert_equal "<p>\x23nothing</p>", html("\x23nothing")
  end

  def test_paragraphs_split_on_blank_lines
    assert_equal "<p>one\ntwo</p>\n<p>three</p>", html("one\ntwo\n\nthree")
  end

  def test_emphasis
    assert_equal "<p><strong>bold</strong> and <em>soft</em></p>", html("**bold** and *soft*")
    assert_equal "<p><strong>a</strong> <em>b</em></p>", html("__a__ _b_")
    assert_equal "<p>snake_case_name</p>", html("snake_case_name")
    assert_equal "<p>2 * 3 * 4</p>", html("2 * 3 * 4")
  end

  def test_inline_code_is_literal
    assert_equal "<p>use <code>a *b* &lt;c&gt;</code> here</p>", html("use `a *b* <c>` here")
  end

  def test_links
    assert_equal "<p><a href=\"https://example.com/a_b\">site</a></p>", html("[site](https://example.com/a_b)")
    assert_equal "<p><a href=\"/x\"><em>go</em></a></p>", html("[*go*](/x)")
  end

  def test_unsafe_link_schemes_are_dropped
    assert_equal "<p>click</p>", html("[click](javascript:void)")
  end

  def test_link_urls_are_escaped
    assert_equal "<p><a href=\"/p?a=1&amp;b=2\">q</a></p>", html("[q](/p?a=1&b=2)")
  end

  def test_fenced_code_block
    source = "```ruby\nputs \"<hi>\" + *not em*\n```"
    expected = "<pre><code class=\"language-ruby\">puts &quot;&lt;hi&gt;&quot; + *not em*\n</code></pre>"
    assert_equal expected, html(source)
  end

  def test_fenced_block_without_language_keeps_blank_lines
    assert_equal "<pre><code>a\n\nb\n</code></pre>", html("```\na\n\nb\n```")
  end

  def test_unordered_list
    assert_equal "<ul>\n<li>one</li>\n<li><strong>two</strong></li>\n</ul>", html("- one\n* **two**")
  end

  def test_ordered_list
    assert_equal "<ol>\n<li>a</li>\n<li>b</li>\n</ol>", html("1. a\n2. b")
  end

  def test_blockquote_contains_blocks
    assert_equal "<blockquote>\n<p>quoted</p>\n<ul>\n<li>x</li>\n</ul>\n</blockquote>", html("> quoted\n>\n> - x")
  end

  def test_html_is_escaped
    assert_equal "<p>&lt;script&gt;alert(1)&lt;/script&gt; &amp; more</p>", html("<script>alert(1)</script> & more")
  end

  def test_list_ends_paragraph
    assert_equal "<p>intro</p>\n<ul>\n<li>a</li>\n</ul>", html("intro\n- a")
  end

  def test_empty_input
    assert_equal "", html("")
  end

  def test_cli_reads_stdin
    exe = File.expand_path("../bin/saltmark", __dir__)
    out, status = Open3.capture2(RbConfig.ruby, exe, stdin_data: "\x23 Hi\n")
    assert status.success?
    assert_equal "<h1>Hi</h1>\n", out
  end
end
