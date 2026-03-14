# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveErosion
      module Helpers
        module Constants
          MATERIAL_TYPES = %i[granite sandstone limestone chalk clay].freeze

          EROSION_AGENTS = %i[water wind ice pressure chemical].freeze

          RESISTANCE = {
            granite:   0.9,
            sandstone: 0.5,
            limestone: 0.4,
            chalk:     0.2,
            clay:      0.1
          }.freeze

          MAX_FORMATIONS = 200

          CHANNEL_DEPTH_LABELS = {
            (0.0...0.1)  => :surface_scratch,
            (0.1...0.3)  => :shallow_groove,
            (0.3...0.5)  => :carved_channel,
            (0.5...0.7)  => :deep_channel,
            (0.7...0.9)  => :ravine,
            (0.9..1.0)   => :canyon
          }.freeze

          FORMATION_LABELS = {
            (0.9..1.0)   => :pristine,
            (0.7...0.9)  => :intact,
            (0.5...0.7)  => :weathered,
            (0.3...0.5)  => :eroded,
            (0.1...0.3)  => :crumbling,
            (0.0...0.1)  => :ruins
          }.freeze
        end
      end
    end
  end
end
