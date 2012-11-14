# -*- encoding: utf-8 -*-
require File.expand_path("../lib/creators/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "creators"
  s.version     = Creators::VERSION
  s.authors     = ["Itay Adler", "Shay Davidson", "Yonatan Bergman"]
  s.email       = ["itayadler@gmail.com", "shay.h.davidson@gmail.com", "lighthawky@gmail.com"]
  s.homepage    = "https://github.com/TheGiftsProject/creators"
  s.summary     = %q{Making it even nicer to manage Form data params in your Controller, for }
  s.description = %q{A Creator is a class that let's you manage }

  s.files         = `git ls-files`.split("\n")
  s.require_path  = "lib"
  s.test_files = Dir.glob('spec/lib/*_spec.rb')


  s.add_dependency 'rails'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end