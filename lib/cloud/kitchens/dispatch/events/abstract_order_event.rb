# frozen_string_literal: true

require 'ventable'

module Cloud
  module Kitchens
    module Events
      class << self
        def transaction
          @transaction ||= ->(b) {
            ActiveRecord::Base.transaction do
              b.call
            end
          }
        end

        def event_logger; end
      end

      class AbstractOrderEvent
        attr_reader :order

        def initialize(order)
          @order = order
        end

        class << self
          def inherited(base)
            base.instance_eval do
              include Ventable::Event
              group :transaction, ::Cloud::Kitchens::Events.transaction

              notifies ->(event) { metrics.handle_event(event) }
            end
          end
        end
      end
    end
  end
end
