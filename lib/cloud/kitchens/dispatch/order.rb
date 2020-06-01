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
        extend Forwardable

        STATES = [:received,
                  :cooking,
                  :ready,
                  :picked_up,
                  :delivered,
                  :expired].freeze

        # @description Class that captures timings for all order states
        StateChangeTimeLog = Struct.new(*STATES)

        include ::AASM

        attr_reader :id,
                    :name,
                    :temperature,
                    :shelf_life,
                    :state_time_log,
                    :decay_rate

        def_delegators :@state_time_log, *STATES

        # @param [OrderStruct] order_struct
        def initialize(order_struct)
          @id             = order_struct.id
          @name           = order_struct.name
          @temperature    = order_struct.temp
          # noinspection RubyResolve
          @shelf_life     = order_struct.shelfLife.to_f
          # noinspection RubyResolve
          @decay_rate     = order_struct.decayRate.to_f
          @state_time_log = StateChangeTimeLog.new(Time.now.to_f)
        end

        def update_state_change
          state_time_log.send("#{aasm.to_state}=", Time.now.to_f)
        end

        def order_value(shelf_decay_modifier = 1)
          (0.0 + shelf_life - age * decay_rate * shelf_decay_modifier).to_f / shelf_life
        end

        # @return [Float] number of seconds since the order has been received
        def age
          now - state_time_log.received
        end

        # @return [Float] EPOCH time as a floating point number
        def now
          Time.now.to_f
        end

        aasm do
          after_all_transitions :update_state_change

          state :received, initial: true
          state(*(STATES - [:received]))

          event :cook do
            transitions from: :received, to: :cooking
          end

          event :prepared do
            transitions from: :cooking, to: :ready
          end

          event :pick_up do
            transitions from: :ready, to: :picked_up
          end

          event :deliver do
            transitions from: :picked_up, to: :delivered
          end

          event :expire do
            transitions from: :ready, to: :expired
          end
        end
      end
    end
  end
end
