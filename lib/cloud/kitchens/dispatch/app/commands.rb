# frozen_string_literal: true

require 'json'
require 'dry/cli'
require 'pastel'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/logging'
require 'active_support/core_ext/hash/keys'

require_relative '../order_struct.rb'

module Cloud
  module Kitchens
    module Dispatch
      PASTEL = Pastel.new.freeze

      module App
        module Commands
          extend Dry::CLI::Registry

          class << self
            include ::Cloud::Kitchens::Dispatch::Logging
          end

          class AbstractOrderCommand < Dry::CLI::Command
            class << self
              def inherited(base)
                super(base)
                base.instance_eval do
                  option :loglevel, values: Logging::DEFAULT_LOGGING_METHODS.map(&:to_s), desc: 'Logging level'
                  option :logfile, default: nil, desc: 'Log also into the specified file'
                  option :quiet, default: nil, desc: 'Stops logging to the console'
                  option :trace, default: nil, desc: 'Print full stack trace, if an error occurs'
                end
              end
            end

            def call(**opts)
              %i[loglevel logfile quiet trace].each do |setting|
                logging_options_to_config setting, **opts
              end
            end

            protected

            def logging_options_to_config(option, **opts)
              value = opts[option] unless opts&.empty?
              config.logging.send("#{option}=", value) if value
            end

            def logger
              ::Cloud::Kitchens::Dispatch.logger
            end

            def config
              App::Config.config
            end
          end

          class Version < Dry::CLI::Command
            desc PASTEL.yellow('Print version')

            def call(*)
              puts PASTEL.white.bold.on_blue("  #{Identity::NAME}  ") + PASTEL.black.on_bright_green("  (v#{Identity::VERSION})   ")
            end
          end

          class Cook < AbstractOrderCommand
            desc PASTEL.yellow('Open the kitchen to process a given set of orders in a JSON file')

            argument :orders,
                     type: :string,
                     required: true,
                     desc: 'File path to the orders.json file'

            # noinspection RubyYardParamTypeMatch
            example(['--orders data.json'].map { |e| PASTEL.bold.green(e) })

            def call(orders:, **opts)
              super(**opts)
              JSON.parse(File.read(orders)).each do |order|
                order.symbolize_keys!
                pp order
                Events::OrderReceivedEvent.new(OrderStruct.new(**order), self).fire!
              end
            end
          end

          register 'version', Version, aliases: %w[v --version -v]
          register 'cook', Cook, aliases: %w[c cook]
        end
      end
    end
  end
end
