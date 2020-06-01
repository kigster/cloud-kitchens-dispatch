# frozen_string_literal: true

require 'forwardable'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/types'
require 'cloud/kitchens/dispatch/order'
require 'cloud/kitchens/dispatch/kitchen'
require 'cloud/kitchens/dispatch/events'
require 'cloud/kitchens/dispatch/ui'

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
        class << self
          def dispatcher(order_source:)
            @dispatcher ||= new(order_source: order_source)
            @dispatcher.start!
          end
        end

        attr_reader :kitchen, :couriers, :shelves
        attr_reader :queues
        attr_reader :mutex, :launcher
        attr_reader :counter, :order_source

        extend Forwardable

        def_delegators :@mutex, :synchronize
        def_delegators :@launcher, :stdout, :stderr

        include EventPublisher
        include Logging
        include UI

        def initialize(order_source: nil)
          @kitchen      = Kitchen.new
          @counter      = Counter.new
          @mutex        = Mutex.new
          @couriers     = Set.new
          @queues       = Order.stateful_queues
          @order_source = order_source

          @launcher = ::Cloud::Kitchens::Dispatch.launcher

          Events::OrderReceivedEvent.notifies(self)
          Events::OrderReadyEvent.notifies(self)
          Events::OrderPickedUpEvent.notifies(self)
          Events::OrderDeliveredEvent.notifies(self)

          box("Dispatcher starting", "Orders are sourced from: #{order_source}", stream: ::Cloud::Kitchens::Dispatch.stdout)
        end

        def start!
          import_orders_from_file if order_source.is_a?(String) && File.exist?(order_source)
        end

        def on_order_received(event)
          queue(:received) << event.order
        end

        private

        def import_orders_from_file
          JSON.parse(File.read(order_source)).each do |order_hash|
            order = parse_order(order_hash)
            publish :order_received, order: order
          end
        end

        def queue(state)
          queues[state]
        end

        def parse_order(order)
          Order.new(OrderStruct.new(**order.symbolize_keys))
        rescue Dry::Types::SchemaError, Dry::Struct::Error => e
          logger.invalid(colorize("Can't parse file — #{order}: #{e.message}", :bold, :red))
        end

        def test?
          ::Cloud::Kitchens::Dispatch.in_test
        end
      end
    end
  end
end
