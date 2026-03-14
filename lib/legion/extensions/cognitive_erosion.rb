# frozen_string_literal: true

require 'securerandom'
require_relative 'cognitive_erosion/version'
require_relative 'cognitive_erosion/helpers/constants'
require_relative 'cognitive_erosion/helpers/formation'
require_relative 'cognitive_erosion/helpers/channel'
require_relative 'cognitive_erosion/helpers/erosion_engine'
require_relative 'cognitive_erosion/runners/cognitive_erosion'
require_relative 'cognitive_erosion/client'

module Legion
  module Extensions
    module CognitiveErosion
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
