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
              subject { stdout }

              it { should match /#{::Cloud::Kitchens::Dispatch::Identity::VERSION}/ }
            end

            context 'printed to standard error' do
              subject { stderr }

              it { should match /cook ORDERS/ }
            end
          end
        end
      end
    end
  end
end
