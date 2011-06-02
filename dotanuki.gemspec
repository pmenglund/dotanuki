# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dotanuki/version"

Gem::Specification.new do |s|
  s.name        = "dotanuki"
  s.version     = Dotanuki::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Martin Englund"]
  s.email       = ["martin@englund.nu"]
  s.homepage    = "https://github.com/pmenglund/dotanuki"
  s.summary     = %q{Command executioner}
  s.description = %q{A command executioner which doesn't blindly stumble on when a command fails'}

  s.rubyforge_project = "dotanuki"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "popen4"

  s.add_development_dependency "rspec"
  s.add_development_dependency "metric_fu"

end
