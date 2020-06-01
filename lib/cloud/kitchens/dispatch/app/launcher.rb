# frozen_string_literal: true

require 'forwardable'
require 'dry/cli'
require 'tty/box'
require 'tty/screen'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/ui'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/app/commands'

# rubocop: disable Style/GuardClause
module Cloud
  module Kitchens
    module Dispatch
      module App
        class Launcher
          attr_accessor :argv, :stdin, :stdout, :stderr, :kernel

          include UI

          def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil)
            clear_screen! unless test?

            raise(ArgumentError, "Another instance of CLI Launcher was detected, aborting.") if ::Cloud::Kitchens::Dispatch.launcher

            ::Cloud::Kitchens::Dispatch.launcher = self

            self.argv   = argv
            self.stdin  = stdin
            self.stdout = stdout
            self.stderr = stderr
            self.kernel = kernel
          end

          def execute!
            if argv.empty? || argv?(%w(--help -h))
              print_header unless test?
              puts cursor.down(2) unless test?
              argv << '--help' if argv.empty?
            end

            # noinspection RubyYardParamTypeMatch
            ::Dry::CLI.new(::Cloud::Kitchens::Dispatch::App::Commands).call(arguments: argv, out: stdout, err: stderr)
            2.times { puts }
            exit(0) unless test?
          rescue StandardError => e
            if test?
              raise(e)
            else
              stderr.print error_box(e)
              exit 1
            end
          ensure
            unless test?
              2.times { puts }
            end
          end

          def print_header
            box_opts = box_args(bg: :green, fg: :black)
            stdout.puts TTY::Box.frame(
              *Identity::HEADER,
              **box_opts
            )
          end

          def argv?(*flags)
            flags = Array(flags)
            !(flags & argv).empty?
          end

          def error_box(error)
            TTY::Box.frame(**box_args(h: 5)) do
              (error.is_a?(StandardError) ? error.message : error)
            end
          end

          def box_args(bg: :red, fg: :black, w: TTY::Screen.width - 10)
            { width: w,
              padding: 1,
              align: :left,
              left: 5,
              top: 2,
              title: { top_left: Time.now.to_s, top_right: Identity::VERSION_LABEL },
              style: {
                bg: bg,
                fg: fg,
                border: { bg: bg, fg: :white },
              }, }
          end

          def test?
            ::Cloud::Kitchens::Dispatch.in_test
          end
        end
      end
    end
  end
end
# rubocop: enable Style/GuardClause
