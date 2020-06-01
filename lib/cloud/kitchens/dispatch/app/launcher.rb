# frozen_string_literal: true

require 'active_support/core_ext/string'

require 'forwardable'
require 'stringio'
require 'dry/cli'
require 'dry/cli/parser'
require 'tty/box'
require 'tty/screen'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/ui'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/app/commands'

::Dry::CLI.class_eval do
  def exit(*)
    nil
  end
end
module Cloud
  module Kitchens
    module Dispatch
      module App
        class << self
          def screen_width
            @screen_width ||= [TTY::Screen.width, 150].min - 10
          end
        end

        class Launcher
          class << self
            attr_accessor :launcher
          end

          attr_accessor :argv, :stdin, :stdout, :stderr, :kernel, :trace

          include UI

          def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil)
            if ::Cloud::Kitchens::Dispatch.launcher
              raise(ArgumentError, 'Another instance of CLI Launcher was detected, aborting.')
            end

            Launcher.launcher = self

            ::Cloud::Kitchens::Dispatch.stdout = stdout
            ::Cloud::Kitchens::Dispatch.stderr = stderr

            decorate_dispatcher

            ::Cloud::Kitchens::Dispatch.launcher = self
            ::Cloud::Kitchens::Dispatch.logger.instance_variable_set(:@output, stdout)

            self.argv   = argv
            self.stdin  = stdin
            self.stdout = stdout
            self.stderr = stderr
            self.kernel = kernel

            self.trace = !ENV['TRACE'].nil?
          end

          def decorate_dispatcher
            Dispatch.module_eval do
              class << self
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

                  @logger = TTY::Logger.new(
                    output: ::Cloud::Kitchens::Dispatch.stderr,
                    fields: { thread: Thread.current.name }
                  ) do |config|
                    config.metadata = [:time]
                    config.level    = :debug
                    config.types    = Logging::LOGGING_TYPES
                  end
                end

                def reconfigure_logger!
                  TTY::Logger.configure do |config|
                    config.output   = ::Cloud::Kitchens::Dispatch.stderr
                    config.level    = app_config.logging&.loglevel&.to_sym || :debug
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

          def execute!
            stdout.puts

            if argv.empty? || argv?(%w(--help -h help version -v --version))
              print_header(stream: stdout) unless test?
              stdout.puts cursor.down(2) unless test?
              argv << '--help' if argv.empty?
            end

            self.trace = true if argv?('-t')
            argv << '--trace' if argv?('-t') && !argv?('--trace')

            # noinspection RubyYardParamTypeMatch
            ::Dry::CLI.new(
              ::Cloud::Kitchens::Dispatch::App::Commands
            ).call(arguments: argv,
                   out: stdout,
                   err: stderr)
            nil
          rescue StandardError => e
            process_error(e, stream: stderr); e
          ensure
            2.times { stdout.puts } unless test?
          end
        end
      end
    end
  end
end
