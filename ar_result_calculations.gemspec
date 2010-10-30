# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ar_result_calculations/version"

Gem::Specification.new do |s|
  s.name        = "ar_result_calculations"
  s.version     = ArResultCalculations::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kip Cole"]
  s.email       = ["kipcole9@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/ar_result_calculations"
  s.summary     = %q{Calculations on ActiveRecord result sets.}
  s.description = <<-EOF
    Defines Array#calculation methods for ActiveRecord result sets. Provides
    #sum, #min, #max, #count, #mean, #regression, #slope.  Delegates to super()
    if not an AR result set where appropriate.
  EOF

  s.rubyforge_project = "ar_result_calculations"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
