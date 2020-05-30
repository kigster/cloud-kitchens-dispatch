# frozen_string_literal: true

require_relative 'kitchen'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class Dispatcher
        attr_reader :kitchen

        def initialize
          @kitchen = Kitchen.new
          @kitchen.add_order_prepared_observer(self)
        end

        def on_order_prepared(order); end
      end
    end
  end
end
