# frozen_string_literal: true
require 'dry-configurable'

module Cloud
  module Kitchens
    module Dispatch
      module App
        class Config
          extend ::Dry::Configurable

          setting :total, reader: true do
            # Can pass a default value
            setting :couriers
            setting :shelf_capacity, 10
          end

          setting :incoming_orders_per_second, 2
        end
      end
    end
  end
end
