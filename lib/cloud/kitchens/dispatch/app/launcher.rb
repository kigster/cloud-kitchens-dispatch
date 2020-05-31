# frozen_string_literal: true

require 'forwardable'
require 'dry/cli'
require 'tty/box'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/app/commands'

module Cloud
  module Kitchens
    module Dispatch
      module App
        class Launcher
          BANNER = <<~TEXT
            #{::Cloud::Kitchens::Dispatch.program_header}

            © 2020 Konstantin Gredeskoul, All rights reserved. MIT License.

          TEXT

          attr_accessor :argv, :stdin, :stdout, :stderr, :kernel

          def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = nil)
            raise(ArgumentError, "Another instance of CLI Launcher was detected, aborting.") if ::Cloud::Kitchens::Dispatch.launcher

            ::Cloud::Kitchens::Dispatch.launcher = self

            self.argv   = argv
            self.stdin  = stdin
            self.stdout = stdout
            self.stderr = stderr
            self.kernel = kernel
          end

          def execute!
            if argv.empty? || !(%w(--help -h) & argv).empty?
              stdout.puts BANNER
            end

            # noinspection RubyYardParamTypeMatch
            ::Dry::CLI.new(::Cloud::Kitchens::Dispatch::App::Commands).call(arguments: argv, out: stdout, err: stderr)
            exit 0
          rescue StandardError => e
            stderr.print box(e)
            exit 1
          end

          private

          def box(error)
            TTY::Box.frame('ERROR:',
                           ' ',
                           error.message,
                           padding: 1,
                           align: :left,
                           title: { top_center: BANNER },
                           width: 80,
                           style: {
                             bg: :red,
                             border: {
                               fg: :bright_yellow,
                               bg: :red
                             }
                           })
          end
        end
      end
    end
  end
end
