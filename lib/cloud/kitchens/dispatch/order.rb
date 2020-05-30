# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'
require_relative 'types'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class Order < ::Dry::Struct
        attribute :id, Types::String
        attribute :name, Types::String
        attribute :temperature, Types::Temperature
        attribute :state, Types::OrderState
        attribute :shelf_life, Types::Integer
        attribute :decay_rate, Types::Float
        attribute :received_at, Types::DateTime.default(DateTime.now.freeze)
        attribute :ready_at, Types::DateTime.optional
        attribute :picked_up_at, Types::DateTime.optional
        attribute :delivered_at, Types::DateTime.optional
      end
    end
  end
end
