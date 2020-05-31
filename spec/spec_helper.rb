# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'simplecov'

if ENV['CI']
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

SimpleCov.start { enable_coverage :branch }

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
  end
end


RSpec.configure do |config|
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles = true
  end

  config.before reset_config: true do
    Cloud::Kitchens::Dispatch::App::Config.reset_config
  end
end

