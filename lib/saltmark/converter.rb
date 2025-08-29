module Saltmark
  class Converter
    FENCE = /\A```\s*([\w+-]+)?\s*\z/
    HEADING = /\A(\x23{1,6})\s+(.*?)(?:\s+\x23+)?\s*\z/
    QUOTE = /\A>\s?/
    BULLET = /\A[-*+]\s+/
    NUMBER = /\A\d+[.)]\s+/

    def initialize(text)
      @lines = text.to_s.gsub(/\r\n?/, "\n").split("\n", -1)
      @out = []
    end

    def call
      consume until @lines.empty?
      @out.join("\n")
    end

    private

    def consume
      line = @lines.first
      if line.strip.empty?
        @lines.shift
      elsif (match = FENCE.match(line))
        fenced(match[1])
      elsif (match = HEADING.match(line))
        @lines.shift
        level = match[1].length
        @out << "<h#{level}>#{Inline.render(match[2])}</h#{level}>"
      elsif QUOTE.match?(line)
        quote
      elsif BULLET.match?(line)
        list("ul", BULLET)
      elsif NUMBER.match?(line)
        list("ol", NUMBER)
      else
        paragraph
      end
    end

    def fenced(language)
      @lines.shift
      body = []
      body << @lines.shift until @lines.empty? || FENCE.match?(@lines.first) && @lines.first.strip == "```"
      @lines.shift
      attribute = language ? " class=\"language-#{Inline.escape(language)}\"" : ""
      @out << "<pre><code#{attribute}>#{Inline.escape(body.join("\n"))}\n</code></pre>"
    end

    def quote
      inner = []
      inner << @lines.shift.sub(QUOTE, "") while @lines.first && QUOTE.match?(@lines.first)
      @out << "<blockquote>\n#{Converter.new(inner.join("\n")).call}\n</blockquote>"
    end

    def list(tag, pattern)
      items = []
      items << @lines.shift.sub(pattern, "") while @lines.first && pattern.match?(@lines.first)
      body = items.map { |item| "<li>#{Inline.render(item.strip)}</li>" }
      @out << "<#{tag}>\n#{body.join("\n")}\n</#{tag}>"
    end

    def paragraph
      text = [@lines.shift]
      text << @lines.shift while @lines.first && !@lines.first.strip.empty? && !block_start?(@lines.first)
      @out << "<p>#{Inline.render(text.map(&:strip).join("\n"))}</p>"
    end

    def block_start?(line)
      [FENCE, HEADING, QUOTE, BULLET, NUMBER].any? { |pattern| pattern.match?(line) }
    end
  end
end

