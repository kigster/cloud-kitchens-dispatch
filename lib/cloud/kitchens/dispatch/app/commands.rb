# frozen_string_literal: true

require 'dry/cli'
require 'pastel'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      PASTEL = Pastel.new.freeze

      module App
        module Commands
          extend Dry::CLI::Registry

          class Version < Dry::CLI::Command
            desc PASTEL.yellow('Print version')

            def call(*)
              puts PASTEL.white.bold.on_blue("  #{Identity::NAME}  ") + PASTEL.black.on_bright_green("  (v#{Identity::VERSION})   ")
            end
          end

          class Process < Dry::CLI::Command
            desc PASTEL.yellow('Open the kitchen to process a given set of orders in a JSON file')

            argument :file,
                     type: :string,
                     required: true,
                     desc: 'Process a single orders.json file'

            # noinspection RubyYardParamTypeMatch
            example(['--file orders.json'].map { |e| PASTEL.bold.green(e) })

            def call(file:, **)
              puts "lets process file #{file}"
            end
          end

          class Watch < Dry::CLI::Command
            desc PASTEL.yellow("Open the kitchen, watch a given directory for new JSON Orders")
            argument :directory,
                     type: :string,
                     required: true,
                     desc: 'Process all files in a directory, sorted by date created'

            # noinspection RubyYardParamTypeMatch
            example(['--directory /usr/local/var/incoming-orders'].map { |e| PASTEL.bold.green(e) })

            def call(directory:, **)
              puts "lets watch directory #{directory}"
            end
          end

          register 'version', Version, aliases: %w[v --version -v]
          register 'process', Process, aliases: %w[p --ingest -p]
          register 'watch',   Watch,   aliases: %w[w --watch-directory -w]
        end
      end
    end
  end
end
