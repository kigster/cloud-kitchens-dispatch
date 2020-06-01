# frozen_string_literal: true

require 'pastel'
require 'stringio'
require 'cloud/kitchens/dispatch/module_methods'

module Cloud
  module Kitchens
    module Dispatch
      class << self
        attr_accessor :launcher, :in_test, :stdout, :stderr
      end

      PASTEL = ::Pastel.new.freeze
      COLOR  = ::Pastel::Color.new(enabled: true).freeze

      GEM_ROOT = File.expand_path('../', __dir__).freeze
      BINARY   = "#{GEM_ROOT}/bin/kitchen-ctl"

      extend ModuleMethods

      self.stderr = ::StringIO.new
      self.stdout = ::StringIO.new
      self.in_test = false
    end
  end
end

require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/logging'

require 'cloud/kitchens/dispatch/app/config'
require 'cloud/kitchens/dispatch/app/commands'
require 'cloud/kitchens/dispatch/app/launcher'

require 'cloud/kitchens/dispatch/logging'
require 'cloud/kitchens/dispatch/events'

require 'cloud/kitchens/dispatch/types'
require 'cloud/kitchens/dispatch/dispatcher'
require 'cloud/kitchens/dispatch/order'
require 'cloud/kitchens/dispatch/kitchen'
require 'cloud/kitchens/dispatch/courier'
