# frozen_string_literal: true

module Cloud
  module Kitchens
    module Dispatch
      module Errors
        class Error < StandardError; end

        class InvalidEventError < Error; end
      end
    end
  end
end
