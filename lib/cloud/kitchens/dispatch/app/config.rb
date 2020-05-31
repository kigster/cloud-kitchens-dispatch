# frozen_string_literal: true

require 'dry-configurable'

module Cloud
  module Kitchens
    module Dispatch
      module App
        class Config
          extend ::Dry::Configurable

          setting :total, reader: true do
            setting :couriers
            setting :shelf_capacity, 10
          end

          setting :logging, reader: true do
            setting :loglevel, default: :debug
            setting :logfile, default: nil
            setting :quiet, default: false
            setting :trace, default: false
          end

          setting :incoming_orders_per_second, 2
        end
      end
    end
  end
end
