# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveErosion
      module Helpers
        class Formation
          attr_reader :formation_id, :material_type, :domain, :content,
                      :resistance, :integrity, :erosion_depth, :created_at, :updated_at

          def initialize(material_type:, domain:, content:, resistance: nil, **)
            raise ArgumentError, "invalid material_type: #{material_type}" unless Constants::MATERIAL_TYPES.include?(material_type)

            @formation_id = SecureRandom.uuid
            @material_type = material_type
            @domain        = domain
            @content       = content
            @resistance    = resistance || Constants::RESISTANCE.fetch(material_type)
            @integrity     = 1.0
            @erosion_depth = 0.0
            @created_at    = Time.now.utc
            @updated_at    = Time.now.utc
          end

          def erode!(agent, force)
            raise ArgumentError, "invalid agent: #{agent}" unless Constants::EROSION_AGENTS.include?(agent)

            force = force.clamp(0.0, 1.0)
            effective_force = (force * (1.0 - @resistance)).round(10)

            @integrity     = (@integrity - effective_force).clamp(0.0, 1.0).round(10)
            @erosion_depth = (@erosion_depth + effective_force).clamp(0.0, 1.0).round(10)
            @updated_at    = Time.now.utc

            { agent: agent, force: force, effective_force: effective_force, integrity: @integrity, erosion_depth: @erosion_depth }
          end

          def resist!(amount = nil)
            amount ||= @resistance * 0.1
            amount = amount.clamp(0.0, 1.0)
            @integrity  = (@integrity + amount).clamp(0.0, 1.0).round(10)
            @updated_at = Time.now.utc
            { integrity: @integrity, recovered: amount }
          end

          def weathered?
            @integrity < 0.7
          end

          def canyon?
            @erosion_depth >= 0.7
          end

          def pristine?
            @integrity >= 0.9
          end

          def integrity_label
            Constants::FORMATION_LABELS.each do |range, label|
              return label if range.cover?(@integrity)
            end
            :ruins
          end

          def depth_label
            Constants::CHANNEL_DEPTH_LABELS.each do |range, label|
              return label if range.cover?(@erosion_depth)
            end
            :surface_scratch
          end

          def to_h
            {
              formation_id:   @formation_id,
              material_type:  @material_type,
              domain:         @domain,
              content:        @content,
              resistance:     @resistance,
              integrity:      @integrity,
              erosion_depth:  @erosion_depth,
              integrity_label: integrity_label,
              depth_label:    depth_label,
              weathered:      weathered?,
              canyon:         canyon?,
              pristine:       pristine?,
              created_at:     @created_at,
              updated_at:     @updated_at
            }
          end
        end
      end
    end
  end
end
