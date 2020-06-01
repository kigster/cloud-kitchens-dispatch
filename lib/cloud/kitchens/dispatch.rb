# frozen_string_literal: true

require 'pastel'

module Cloud
  module Kitchens
    module Dispatch
      class << self
        attr_accessor :launcher, :in_test, :stdout, :stderr
      end

      self.stderr = StringIO.new
      self.stdout = StringIO.new
      self.in_test = false
    end
  end
end

require 'cloud/kitchens/dispatch/logging'
require 'cloud/kitchens/dispatch/app/launcher'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/module_methods'

module Cloud
  module Kitchens
    module Dispatch
      PASTEL = ::Pastel.new.freeze
      COLOR  = ::Pastel::Color.new(enabled: true).freeze

      GEM_ROOT = File.expand_path('../', __dir__).freeze
      BINARY   = "#{GEM_ROOT}/bin/kitchen-ctl"

      extend ModuleMethods
    end
  end
end

require_relative 'dispatch/identity'
require_relative 'dispatch/app/config'
require_relative 'dispatch/logging'
require_relative 'dispatch/types'

require_relative 'dispatch/kitchen'
require_relative 'dispatch/dispatcher'
require_relative 'dispatch/order'
require_relative 'dispatch/kitchen'
require_relative 'dispatch/courier'

require_relative 'dispatch/events'

require_relative 'dispatch/app/commands'
