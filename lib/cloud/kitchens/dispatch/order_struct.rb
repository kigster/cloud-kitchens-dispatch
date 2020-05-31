# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'
require_relative 'types'
require 'awesome_print'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class OrderStruct < ::Dry::Struct
        transform_keys(&:to_sym)

        attribute :id, Types::String
        attribute :name, Types::String
        attribute :temp, Types::Temperature
        # attribute :state, Types::String # OrderState
        attribute :shelfLife, Types::Integer
        attribute :decayRate, Types::Float
        attribute :received_at, Types::DateTime.default(DateTime.now.freeze)
        # attribute :ready_at, Types::DateTime.optional
        # attribute :picked_up_at, Types::DateTime.optional
        # attribute :delivered_at, Types::DateTime.optional
        #
        def to_s
          "\n" + to_hash.awesome_inspect + "\n"
        end
      end
    end
  end
end
