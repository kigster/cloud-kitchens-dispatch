# frozen_string_literal: true

require 'ventable'

module Cloud
  module Kitchens
    module Dispatch
      module Events
      end
    end
  end
end

require_relative 'events/abstract_order_event'
require_relative 'events/order_received_event'
require_relative 'events/order_prepared_event'
require_relative 'events/order_ready_event'
require_relative 'events/order_picked_up_event'
