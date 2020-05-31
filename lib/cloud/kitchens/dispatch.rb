# frozen_string_literal: true

require 'pastel'
require_relative 'dispatch/logging'
require_relative 'dispatch/identity'
require 'pp'

module Cloud
  module Kitchens
    module Dispatch
      PASTEL = ::Pastel.new.freeze
      COLOR = ::Pastel::Color.new(enabled: true).freeze

      class << self
        attr_accessor :launcher

        def colorize(string, *colors)
          COLOR.decorate(string, *colors)
        end

        def configure
          yield(app_config)
        end

        def program_header
          PASTEL.white.bold.on_blue("  #{Identity::NAME}  ") + PASTEL.black.on_bright_green("  (v#{Identity::VERSION})   ")
        end

        def app_config
          App::Config.config
        end

        def log_event(event)
          logger.event("order event ❯ #{event.order}", event: event_name(event), from: event.producer)
        end

        def logger(memoized = true)
          return @logger if @logger && memoized

          @logger = TTY::Logger.new(fields: { thread: Thread.current.name } ) do |config|
            config.metadata = [:time]
            config.level    = app_config.logging&.loglevel&.to_sym || :debug
            config.types    = Logging::LOGGING_TYPES
            config.handlers = []
            config.handlers << Logging::CONSOLE_LOG_HANDLER[] unless app_config.logging.quiet
            config.handlers << Logging::FILE_LOG_HANDLER[app_config.logging.logfile] if app_config.logging.logfile
          end
        end

        private

        def event_name(event)
          (event.is_a?(Class) ? event.name : event.class.name).
            gsub(/.*Events/, '').
            gsub(/Event$/, '').
            underscore
        end
      end
    end
  end
end

require_relative 'dispatch/identity'
require_relative 'dispatch/app/config'
require_relative 'dispatch/logging'
require_relative 'dispatch/types'

require_relative 'dispatch/kitchen'
require_relative 'dispatch/dispatcher'
require_relative 'dispatch/order'
require_relative 'dispatch/kitchen'
require_relative 'dispatch/courier'

require_relative 'dispatch/events'

require_relative 'dispatch/app/commands'
