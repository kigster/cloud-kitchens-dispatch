# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    module Dispatch
      RSpec.describe Dispatcher do
        subject(:dispatcher) { described_class.new }

        its(:kitchen) { is_expected.to be_a_kind_of(Kitchen) }
      end
    end
  end
end
