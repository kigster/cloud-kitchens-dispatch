# frozen_string_literal: true

require 'spec_helper'

require "cloud/kitchens/dispatch/logging"

module App
  class Logrande
    include ::Cloud::Kitchens::Dispatch::Logging
  end
end

RSpec.describe ::Cloud::Kitchens::Dispatch::Logging do
  context 'class methods' do
    subject(:logger) { App::Logrande.logger }

    it { is_expected.to respond_to(:debug) }
  end

  context 'instance methods' do
    subject(:logger) { App::Logrande.new.logger }

    it { is_expected.to respond_to(:debug) }
  end
end
