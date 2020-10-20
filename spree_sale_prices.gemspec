# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_sale_prices'
  s.version     = '4.1.0'
  s.summary     = 'Adds sale pricing functionality to Spree Commerce'
  s.description = 'Adds sale pricing functionality to Spree Commerce. It enables timed sale planning for different currencies.'
  s.required_ruby_version = '>= 2.2.7'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }

  s.author            = 'Renuo GmbH, Jonathan Dean'
  s.email             = 'info@renuo.ch'
  s.homepage          = 'https://github.com/superchell/spree_sale_prices'
  s.license           = 'BSD-3'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.2.0', '< 5.0'
  s.add_dependency 'spree_core', spree_version
  s.add_dependency 'spree_api', spree_version
  s.add_dependency 'spree_backend', spree_version
  s.add_dependency 'spree_extension'

  s.add_dependency 'slim-rails', '~> 3.1.0'
  s.add_dependency 'memoist', '~> 0.14'

  s.add_development_dependency 'spree_dev_tools'


end
