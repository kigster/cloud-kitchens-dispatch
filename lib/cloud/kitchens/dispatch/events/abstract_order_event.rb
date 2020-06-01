# frozen_string_literal: true

require 'ventable'

module Cloud
  module Kitchens
    module Dispatch
      module Events
        include Dispatch::Logging

        class << self
          include Dispatch::Logging

          def transaction
            @transaction ||= ->(b) {
              b.call
            }
          end
        end

        class AbstractOrderEvent
          attr_reader :order, :producer

          def initialize(producer, order:)
            @order    = order
            @producer = (producer.is_a?(Class) ? producer.name : producer.class.name).gsub(/.*::/, '').underscore
          end

          class << self
            def inherited(base)
              base.instance_eval do
                include Ventable::Event

                notifies ->(event) { ::Cloud::Kitchens::Dispatch.log_event(event) }
              end
            end
          end
        end
      end
    end
  end
end
