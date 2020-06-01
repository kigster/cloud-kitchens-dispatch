# frozen_string_literal: true

require 'forwardable'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/types'
require 'cloud/kitchens/dispatch/order'
require 'cloud/kitchens/dispatch/kitchen'

module Cloud
  module Kitchens
    module Dispatch
      Counter = Struct.new(:received, :cooked, :picked_up, :delivered) do
        attr_reader :mutex

        def initialize(*args)
          super(*args)
          @mutex    = Mutex.new
          @received = @cooked = @picked_up = @delivered = 0
        end

        def increment(attribute, amount = 1)
          raise ArgumentError unless respond_to?(attribute)

          mutex.synchronize do
            send("#{attribute}=", send(attribute) + amount)
          end
        end
      end

      # Gem identity information.
      class Dispatcher
        attr_reader :kitchen, :orders_incoming, :mutex

        extend Forwardable
        def_delegators :@orders_incoming, :each

        include Enumerable
        include Logging

        def initialize
          @kitchen         = Kitchen.new
          @orders_incoming = Queue.new
          @counter         = Counter.new
          @mutex           = Mutex.new
        end

        def on_order_prepared(order)
          (orders_incoming << order).tap do
            counter.increment :received
          end
        end
      end
    end
  end
end
