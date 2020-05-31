# frozen_string_literal: true

require 'ventable'
require_relative 'abstract_order_event'

module Cloud
  module Kitchens
    module Events
      class OrderReadyEvent < AbstractEvent
      end
    end
  end
end
