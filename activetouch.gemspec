# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_touch/version'

Gem::Specification.new do |spec|
  spec.name          = 'activetouch'
  spec.version       = ActiveTouch::VERSION
  spec.authors       = ['Kevin Pheasey']
  spec.email         = ['kevin@kpheasey.com']
  spec.licenses      = ['MIT']

  spec.summary       = %q{A more robust touch for ActiveRecord associations.}
  spec.description   = %q{Touch specific associations when specific attributes change.  Call an optional method on those touched records.  Perform the touch synchronously or asynchronously.}
  spec.homepage      = 'https://github.com/kpheasey/active_touch'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_dependency 'rails', '~> 4.2'
end
