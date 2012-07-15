# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spreadshirt_client/version"

Gem::Specification.new do |s|
  s.name        = "spreadshirt_client"
  s.version     = SpreadshirtClient::VERSION
  s.authors     = ["Benjamin Vetter"]
  s.email       = ["vetter@flakks.com"]
  s.homepage    = ""
  s.summary     = %q{Communicate with the spreadshirt API}
  s.description = %q{Communicate with the spreadshirt API using a DSL similar to the one of RestClient}

  s.rubyforge_project = "spreadshirt_client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_dependency "rest-client"
  s.add_dependency "active_support", "~> 2.3"
end

