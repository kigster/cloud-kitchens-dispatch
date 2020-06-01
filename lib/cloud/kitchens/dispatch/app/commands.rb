# frozen_string_literal: true

require 'forwardable'
require 'json'
require 'dry/cli'
require 'pastel'
require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/logging'
require 'active_support/core_ext/hash/keys'

require_relative '../order_struct.rb'
require_relative '../events'
require_relative '../ui'

module Cloud
  module Kitchens
    module Dispatch
      module App
        module Commands
          extend ::Dry::CLI::Registry

          class << self
            include ::Cloud::Kitchens::Dispatch::Logging
          end

          class AbstractOrderCommand < Dry::CLI::Command
            include EventPublisher
            include UI

            class << self
              def inherited(base)
                super(base)
                base.extend(Forwardable)
                base.instance_eval do
                  def_delegators ::Cloud::Kitchens::Dispatch, :colorize, :app_config, :logger

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

              ::Cloud::Kitchens::Dispatch.logger(true)
            end

            protected

            def logging_options_to_config(option, **opts)
              value = opts[option] unless opts&.empty?
              app_config.logging.send("#{option}=", value) if value
            end
          end

          class Version < Dry::CLI::Command
            desc PASTEL.yellow('Print version')

            def call(*)
              puts
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
                order_struct = parse_order(order)
                publish :order_received, order: order_struct
              end
            rescue Errno::ENOENT => e
              error("Can't open file #{orders.bold.green}", e.message.red.italic)
            end

            private

            def parse_order(order)
              OrderStruct.new(**order.symbolize_keys)
            rescue Dry::Types::SchemaError, Dry::Struct::Error => e
              logger.invalid(colorize("Can't parse file — #{order.green}: #{e.message}", :bold, :red))
            end
          end

          register 'version', Version, aliases: %w[v --version -v]
          register 'cook', Cook, aliases: %w[c cook]
        end
      end
    end
  end
end
