# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveErosion
      module Helpers
        class Channel
          attr_reader :channel_id, :formation_id, :agent, :depth, :width,
                      :flow_rate, :created_at, :updated_at, :last_active_at

          def initialize(formation_id:, agent:, depth: 0.0, width: 0.1, flow_rate: 0.0, **)
            raise ArgumentError, "invalid agent: #{agent}" unless Constants::EROSION_AGENTS.include?(agent)

            @channel_id     = SecureRandom.uuid
            @formation_id   = formation_id
            @agent          = agent
            @depth          = depth.clamp(0.0, 1.0).round(10)
            @width          = width.clamp(0.0, 1.0).round(10)
            @flow_rate      = flow_rate.clamp(0.0, 1.0).round(10)
            @created_at     = Time.now.utc
            @updated_at     = Time.now.utc
            @last_active_at = nil
          end

          def deepen!(force)
            force = force.clamp(0.0, 1.0)
            @depth          = (@depth + force).clamp(0.0, 1.0).round(10)
            @flow_rate      = [@flow_rate + (force * 0.1), 1.0].min.round(10)
            @last_active_at = Time.now.utc
            @updated_at     = Time.now.utc
            { depth: @depth, flow_rate: @flow_rate }
          end

          def widen!(amount = 0.05)
            amount  = amount.clamp(0.0, 1.0)
            @width  = (@width + amount).clamp(0.0, 1.0).round(10)
            @updated_at = Time.now.utc
            { width: @width }
          end

          def dormant?
            return true if @last_active_at.nil?

            (Time.now.utc - @last_active_at) > 3600
          end

          def active?
            !dormant?
          end

          def depth_label
            Constants::CHANNEL_DEPTH_LABELS.each do |range, label|
              return label if range.cover?(@depth)
            end
            :surface_scratch
          end

          def to_h
            {
              channel_id:     @channel_id,
              formation_id:   @formation_id,
              agent:          @agent,
              depth:          @depth,
              width:          @width,
              flow_rate:      @flow_rate,
              depth_label:    depth_label,
              dormant:        dormant?,
              active:         active?,
              created_at:     @created_at,
              updated_at:     @updated_at,
              last_active_at: @last_active_at
            }
          end
        end
      end
    end
  end
end
