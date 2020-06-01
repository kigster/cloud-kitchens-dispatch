# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        RSpec.describe Commands, type: :arubac do
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
            let(:args) { ['cook', Fixtures.file] }

            context 'printed to standard output' do
              subject { stdout }
              it { should match /Dispatcher starting/ }
            end
          end
        end
      end
    end
  end
end
