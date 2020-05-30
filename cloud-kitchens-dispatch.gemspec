# frozen_string_literal: true

require_relative 'lib/cloud/kitchens/dispatch/identity'

Gem::Specification.new do |spec|
  spec.name = Cloud::Kitchens::Dispatch::Identity::NAME
  spec.version = Cloud::Kitchens::Dispatch::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Konstantin Gredeskoul']
  spec.email = ['kigster@gmail.com']
  spec.homepage = 'https://github.com/kigster/cloud-kitchens-dispatch'
  spec.summary = 'Order fulfillment simulation'
  spec.license = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/kigster/cloud-kitchens-dispatch',
    'changelog_uri' => 'https://github.com/kigster/cloud-kitchens-dispatch/blob/master/CHANGES.md',
    'bug_tracker_uri' => 'https://github.com/kigster/cloud-kitchens-dispatch/issues'
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.add_dependency 'dry-cli'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'asciidoctor'

  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README*', 'LICENSE*']
  spec.executables << 'cloud-kitchens-dispatch'

  spec.require_paths = ['lib']
end
