require_relative "lib/saltmark/version"

Gem::Specification.new do |spec|
  spec.name = "saltmark"
  spec.version = Saltmark::VERSION
  spec.authors = ["Provokke"]
  spec.summary = "A small Markdown subset to HTML converter"
  spec.description = "Converts headings, paragraphs, emphasis, code, links, lists and blockquotes to escaped HTML."
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"
  spec.files = Dir["lib/**/*.rb"] + Dir["bin/*"] + ["LICENSE", "README.md"]
  spec.bindir = "bin"
  spec.executables = ["saltmark"]
  spec.require_paths = ["lib"]
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
