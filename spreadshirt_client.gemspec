# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spreadshirt_client/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Benjamin Vetter"]
  gem.email         = ["vetter@flakks.com"]
  gem.description   = %q{Communicate with the spreadshirt API}
  gem.summary       = %q{Communicate with the spreadshirt API using a DSL similar to the one of RestClient}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "spreadshirt_client"
  gem.require_paths = ["lib"]
  gem.version       = SpreadshirtClient::VERSION

  gem.add_dependency "rest-client"
  gem.add_development_dependency "rake"
end
