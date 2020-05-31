# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        RSpec.describe Commands, type: :aruba do
          include_context 'aruba setup'

          context '--help' do
            let(:args) { %w(--help) }

            subject { output }

            it { should match /#{::Cloud::Kitchens::Dispatch::Identity::NAME}/ }

            it { should match /#{::Cloud::Kitchens::Dispatch::Identity::VERSION}/ }

            it { should match /MIT License/ }
          end
        end
      end
    end
  end
end
