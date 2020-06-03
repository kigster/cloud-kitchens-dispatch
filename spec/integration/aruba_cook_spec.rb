# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        RSpec.describe Commands, type: :aruba do
          include_context 'aruba setup'

          context 'help' do
            let(:args) { %w(help) }

            context 'printed to standard output' do
              subject { stderr }

              it { should match /Commands:/ }
            end

            context 'printed to standard error' do
              subject { stderr }

              it { should match /cook ORDERS/ }
            end
          end

          context 'cook' do
            describe 'output to stdout' do
              let(:args) { ['cook', Fixtures.file] }

              context 'printed to standard output' do
                subject { stdout }

                it { should match /Orders have been imported from/ }
              end
            end

            describe 'output to a file' do
              let(:args) { ['cook', '--logfile', log_file, Fixtures.file] }

              context 'printed to standard output' do
                subject { log_file }

                its(:path) { is_expected.to be_an_existing_file }

                #   its(:read) { is_expected.to_not be_empty }
              end
            end
          end
        end
      end
    end
  end
end
