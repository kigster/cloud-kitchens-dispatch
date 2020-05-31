# frozen_string_literal: true

require "cloud/kitchens/dispatch/identity"
require "cloud/kitchens/dispatch/app/config"
require "cloud/kitchens/dispatch/app/commands"

module Cloud
  module Kitchens
    module Dispatch
      class << self
        def configure
          yield(config)
        end

        def config
          App::Config.config
        end
      end
    end
  end
end

require_relative 'dispatch/types'
require_relative 'dispatch/dispatcher'
require_relative 'dispatch/kitchen'
