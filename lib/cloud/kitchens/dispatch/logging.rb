# frozen_string_literal: true

require 'tty-logger'

module Cloud
  module Kitchens
    module Dispatch
      module Logging
        module InstanceMethods
          def logger
            ::Cloud::Kitchens::Dispatch.logger
          end

          class << self
            def included(base)
              base.instance_eval do
                LOGGING_METHODS.each do |log_method|
                  define_method log_method do |*args|
                    logger.send(log_method, *args)
                  end
                end
              end
            end
          end
        end

        class << self
          def included(base)
            base.include(InstanceMethods)
            base.extend(InstanceMethods)
          end
        end

        LOGGING_TYPES = {
          cooking: { level: :info },
          ready: { level: :info },
          delivering: { level: :info },
          expired: { level: :warning },
          event: { level: :info },
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
