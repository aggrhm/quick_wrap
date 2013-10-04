Gem::Specification.new do |s|
  s.name        = "quick_wrap"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Alan Graham"]
  s.email       = ["alan@productlab.com"]
  s.homepage    = ""
  s.summary     = %q{Web Application Framework}
  s.description = %q{Framework for single-page web applications}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #s.require_paths = ["lib"]
end
