# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis_knock/version"

Gem::Specification.new do |s|
  s.name        = "redis_knock"
  s.version     = RedisKnock::VERSION
  s.authors     = ["Marcelo Correia Pinheiro"]
  s.email       = ["salizzar@gmail.com"]
  s.homepage    = "https://github.com/salizzar/redis_knock"
  s.summary     = %q{A Ruby HTTP Throttle Control}
  s.description = %q{The gem redis_knock implements a HTTP Throttle Control engine using Redis to store rate-limiting IP's.}

  s.rubyforge_project = "redis_knock"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency  'rake'
  s.add_development_dependency  'rspec'
  s.add_development_dependency  'rack-test'
  s.add_runtime_dependency      'redis'
end
