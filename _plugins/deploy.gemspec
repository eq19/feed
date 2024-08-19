require 'rake'
Gem::Specification.new do |spec|
  spec.name          = "jekyll-rtd-theme"
  spec.version       = "2.0.10"
  spec.authors       = ["saowang"]
  spec.email         = ["saowang@outlook.com"]

  spec.summary       = "Just another documentation theme compatible with GitHub Pages"
  spec.homepage      = "https://github.com/rundocs/jekyll-rtd-theme"
  spec.files         = FileList['assets/*','_*/*','[A-Z]*'].to_a
  spec.license       = "MIT"

  spec.add_runtime_dependency "github-pages", "~> 232"
end
