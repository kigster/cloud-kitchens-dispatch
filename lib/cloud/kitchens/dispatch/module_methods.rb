# frozen_string_literal: true

module Cloud
  module Kitchens
    module Dispatch
      module ModuleMethods
        def colorize(string, *colors)
          COLOR.decorate(string, *colors)
        end

        def configure
          yield(app_config)
        end

        def app_config
          App::Config.config
        end

        def log_event(event)
          logger.info("order event ❯ #{event.order}", event: event_name(event), from: event.producer)
        end

        def logger
          return @logger if @logger

          if ::Cloud::Kitchens::Dispatch.stderr.nil?
            raise ArgumentError,
                  "Please configure #stdout and #stderr on Dispatch module"
          end

          @logger = TTY::Logger.new(
            output: ::Cloud::Kitchens::Dispatch.stderr,
            fields: { thread: Thread.current.name }
          ) do |config|
            config.metadata = [:time]
            config.level    = :debug
            config.types    = Logging::LOGGING_TYPES
          end
        end

        def reconfigure_logger!(cfg)
          TTY::Logger.configure do |config|
            config.output   = ::Cloud::Kitchens::Dispatch.stderr
            config.level    = cfg.logging&.loglevel&.to_sym || :debug
            config.handlers = []
            config.handlers << Logging::CONSOLE_LOG_HANDLER[] unless cfg.logging.quiet

            if cfg.logging.logfile
              config.handlers << Logging::FILE_LOG_HANDLER[cfg.logging.logfile]
            end
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
