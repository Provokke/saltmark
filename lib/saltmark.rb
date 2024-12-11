require_relative "saltmark/version"
require_relative "saltmark/inline"
require_relative "saltmark/converter"

module Saltmark
  def self.convert(text)
    Converter.new(text).call
  end
end
