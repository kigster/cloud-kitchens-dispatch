# frozen_string_literal: true

require 'ventable'
require 'active_support/inflections'
require 'cloud/kitchens/dispatch/errors'
module Cloud
  module Kitchens
    module Dispatch
      module Events
      end

      module EventPublisher
        def publish(event, **opts)
          event_class_name = "#{event.camelize}Event"
          unless Events.const_defined?(event_class_name)
            raise Errors::InvalidEventError, "event name #{event} does not map to an event class"
          end

          event_class = Events.const_get(event_class_name)
          event_class.new(**opts).fire!
        end
      end
    end
  end
end

require_relative 'events/abstract_order_event'
require_relative 'events/order_received_event'
require_relative 'events/order_prepared_event'
require_relative 'events/order_ready_event'
require_relative 'events/order_picked_up_event'

Cloud::Kitchens::Dispatch::Events::OrderReceivedEvent.configure do
  notifies Cloud::Kitchens::Dispatch::Dispatcher
end
