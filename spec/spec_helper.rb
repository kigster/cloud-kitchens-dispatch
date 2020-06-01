# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'simplecov'
require 'aruba'
require 'aruba/rspec'

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

SimpleCov.start

require 'cloud/kitchens/dispatch'
require 'dry/configurable/test_interface'

module Cloud
  module Kitchens
    module Dispatch
      module App
        class Config
          enable_test_interface
        end
      end
    end

    Dispatch.in_test = true
  end
end

require 'cloud/kitchens/dispatch/app/launcher'

RSpec.configure do |config|
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.syntax                                               = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles        = true
  end

  config.before reset_config: true do
    Cloud::Kitchens::Dispatch::App::Config.reset_config
  end

  config.include Aruba::Api

  config.before(:each) do
    ::Cloud::Kitchens::Dispatch.in_test = true
  end

  config.before(:each) do
    ::Cloud::Kitchens::Dispatch.launcher = nil
  end
end

Aruba.configure do |config|
  config.command_launcher = :in_process # :spawn is for forking each integration test. Slow!
  config.main_class       = ::Cloud::Kitchens::Dispatch::App::Launcher
end

::Dir.glob(::File.expand_path('../support/**/*.rb', __FILE__)).each { |f| require(f) }
