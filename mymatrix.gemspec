# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mymatrix/version"

Gem::Specification.new do |s|
  s.name        = "mymatrix"
  s.version     = MyMatrix::VERSION
  s.authors     = ["yukihico"]
  s.email       = ["yukihico@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{MS Excel and  csv/tsv text handling library}
  s.description = %q{mymatrix is a handling library for MS Excel and  csv/tsv text.}

  s.rubyforge_project = "mymatrix"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
