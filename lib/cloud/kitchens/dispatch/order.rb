# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'
require_relative 'types'
require 'aasm'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class Order
        include ::AASM

        aasm do
          state :received, initial: true
          state :cooking, :ready, :picked_up, :delivered, :expired

          event :cook do
            transitions from: :new, to: :cooking
          end

          event :prepared do
            transitions from: :cooking, to: :ready
          end

          event :pick_up do
            transitions from: :prepared, to: :picked_up
          end

          event :deliver do
            transitions from: :picked_up, to: :delivered
          end
        end
      end
    end
  end
end
