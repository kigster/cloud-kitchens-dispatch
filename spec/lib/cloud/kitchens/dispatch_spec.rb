# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    RSpec.describe Dispatch, reset_config: true do
      context '.config' do
        subject { described_class.app_config }

        its(:incoming_orders_per_second) { is_expected.to eq 2 }
      end
    end
  end
end
