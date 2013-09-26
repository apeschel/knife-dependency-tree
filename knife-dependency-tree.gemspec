# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'knife-dependency-tree/version'

Gem::Specification.new do |s|
  s.name         = 'knife-dependency-tree'
  s.version      = Knife::DependencyTree::VERSION
  s.authors      = ['Aaron Peschel']
  s.email        = ['aaron.peschel@gmail.com']
  s.homepage     = 'https://github.com/apeschel/knife-dependency-tree'
  s.summary      = %q{Generates a dependency tree of roles and cookbooks.}
  s.description  = s.summary
  s.license      = 'BSD'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables  = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_development_dependency("rspec")
  s.add_development_dependency("rake")

  s.require_paths = ['lib']
end

