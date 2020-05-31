# frozen_string_literal: true

require 'tty-logger'
require 'cloud/kitchens/dispatch'

module Cloud
  module Kitchens
    module Dispatch
      module Logging
        class << self
          def included(base)
            base.include(LoggingMethods)
          end
        end

        module LoggingMethods
          class << self
            def included(base)
              LOGGING_METHODS.each do |log_method|
                base.define_method log_method do |msg, *args|
                  logger.send(log_method, ::Cloud::Kitchens::Dispatch.colorize(msg, :yellow), *args)
                end
              end

              base.instance_eval do
                def logger
                  ::Cloud::Kitchens::Dispatch.logger
                end
              end

              return unless base.is_a?(Class)

              base.class_eval do
                def logger
                  ::Cloud::Kitchens::Dispatch.logger
                end
              end
            end
          end
        end

        LOGGING_TYPES = {
          cooking: { level: :info },
          ready: { level: :info },
          delivering: { level: :info },
          expired: { level: :warning },
          event: { level: :info },
          invalid: { level: :error },
        }.freeze

        DEFAULT_LOGGING_METHODS = %i[
          debug
          info
          success
          wait
          warn
          error
          fatal
        ].freeze

        LOGGING_METHODS = (DEFAULT_LOGGING_METHODS + LOGGING_TYPES.keys).freeze

        CONSOLE_LOG_HANDLER = -> {
          [:console, {
            styles: {
              event: {
                symbol: ' 💬 ',
                label: 'event',
                color: :cyan,
                levelpad: 7
              },
              cooking: {
                symbol: ' 👩‍🍳 ',
                label: 'cooking',
                color: :yellow,
                levelpad: 5
              },
              ready: {
                symbol: ' 🍜 ',
                label: 'ready',
                color: :green,
                levelpad: 7
              },
              delivering: {
                symbol: ' 🚙 ',
                label: 'delivering',
                color: :green,
                levelpad: 2
              },
              expired: {
                symbol: ' ⛔️ ',
                label: 'expired',
                color: :red,
                levelpad: 5
              },
              invalid: {
                symbol: ' 🧨 ',
                label: ::Cloud::Kitchens::Dispatch.colorize('INVALID', :white, :on_red),
                color: :red,
                levelpad: 5
              },
            }
          }]
        }

        FILE_LOG_HANDLER = ->(filename) do
          [:stream, output: File.open(filename, 'a'), level: :info]
        end
      end
    end
  end
end
