require "cgi"

module Saltmark
  module Inline
    CODE = /(`[^`\n]+`)/
    LINK = /\[([^\]\n]+)\]\(([^)\s]+)\)/
    STRONG = /\*\*(?!\s)(.+?)(?<!\s)\*\*|__(?!\s)(.+?)(?<!\s)__/
    EMPHASIS = /\*(?![\s*])(.+?)(?<![\s*])\*|(?<![[:alnum:]])_(?![\s_])(.+?)(?<![\s_])_(?![[:alnum:]])/
    SAFE_URL = %r{\A(?:https?://|mailto:|/|\x23|\./|\.\./|[\w.-]+(?:/|\z))}i
    PLACEHOLDER = /\u0000(\d+)\u0000/

    module_function

    def escape(text)
      CGI.escapeHTML(text)
    end

    def render(text)
      text.split(CODE).each_with_index.map do |part, index|
        if index.odd?
          "<code>#{escape(part[1..-2])}</code>"
        else
          spans(part)
        end
      end.join
    end

    def spans(text)
      stash = []
      escaped = escape(text).gsub(LINK) do
        label = Regexp.last_match(1)
        url = Regexp.last_match(2)
        stash << anchor(label, url)
        "\u0000#{stash.size - 1}\u0000"
      end
      emphasise(escaped).gsub(PLACEHOLDER) { stash[Regexp.last_match(1).to_i] }
    end

    def emphasise(escaped)
      strong = escaped.gsub(STRONG) { "<strong>#{Regexp.last_match(1) || Regexp.last_match(2)}</strong>" }
      strong.gsub(EMPHASIS) { "<em>#{Regexp.last_match(1) || Regexp.last_match(2)}</em>" }
    end

    def anchor(label, url)
      label = emphasise(label)
      return label unless safe_url?(CGI.unescapeHTML(url))

      "<a href=\"#{url}\">#{label}</a>"
    end

    def safe_url?(url)
      SAFE_URL.match?(url)
    end
  end
end

