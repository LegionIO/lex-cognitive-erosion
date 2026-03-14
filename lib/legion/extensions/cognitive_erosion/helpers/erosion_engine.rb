# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveErosion
      module Helpers
        class ErosionEngine
          def initialize
            @formations = {}
            @channels   = {}
          end

          def create_formation(material_type:, domain:, content:, resistance: nil, **)
            raise ArgumentError, "maximum formations (#{Constants::MAX_FORMATIONS}) reached" if @formations.size >= Constants::MAX_FORMATIONS
            raise ArgumentError, "invalid material_type: #{material_type}" unless Constants::MATERIAL_TYPES.include?(material_type)

            formation = Formation.new(
              material_type: material_type,
              domain:        domain,
              content:       content,
              resistance:    resistance
            )
            @formations[formation.formation_id] = formation
            { success: true, formation_id: formation.formation_id, formation: formation.to_h }
          end

          def erode(formation_id:, agent:, force:, **)
            formation = @formations[formation_id]
            return { success: false, error: :formation_not_found } unless formation
            return { success: false, error: :invalid_agent } unless Constants::EROSION_AGENTS.include?(agent)

            result = formation.erode!(agent, force)
            channel = carve_channel(formation_id: formation_id, agent: agent, force: force)

            { success: true, formation_id: formation_id, erosion: result, channel: channel }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def carve_channel(formation_id:, agent:, force: 0.1, **)
            existing = find_channel(formation_id, agent)
            if existing
              existing.deepen!(force.clamp(0.0, 1.0))
              existing.widen! if existing.depth >= 0.3
              existing.to_h
            else
              channel = Channel.new(formation_id: formation_id, agent: agent)
              channel.deepen!(force.clamp(0.0, 1.0))
              @channels[channel.channel_id] = channel
              channel.to_h
            end
          end

          def weather_all!(force: 0.05, agent: :wind, **)
            results = @formations.map do |id, formation|
              erosion = formation.erode!(agent, force)
              ch      = carve_channel(formation_id: id, agent: agent, force: force)
              { formation_id: id, erosion: erosion, channel: ch }
            end
            { success: true, weathered: results.size, results: results }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def deepest_channels(limit: 5, **)
            limit = limit.clamp(1, @channels.size > 0 ? @channels.size : 1)
            sorted = @channels.values.sort_by { |c| -c.depth }
            sorted.first(limit).map(&:to_h)
          end

          def most_eroded(limit: 5, **)
            limit = limit.clamp(1, @formations.size > 0 ? @formations.size : 1)
            sorted = @formations.values.sort_by { |f| f.erosion_depth }.reverse
            sorted.first(limit).map(&:to_h)
          end

          def erosion_report(**)
            canyons   = @formations.values.count(&:canyon?)
            weathered = @formations.values.count(&:weathered?)
            pristine  = @formations.values.count(&:pristine?)
            avg_depth = if @formations.empty?
                          0.0
                        else
                          (@formations.values.sum(&:erosion_depth) / @formations.size.to_f).round(10)
                        end
            avg_integrity = if @formations.empty?
                               1.0
                             else
                               (@formations.values.sum(&:integrity) / @formations.size.to_f).round(10)
                             end

            {
              success:           true,
              total_formations:  @formations.size,
              total_channels:    @channels.size,
              canyons:           canyons,
              weathered:         weathered,
              pristine:          pristine,
              average_depth:     avg_depth,
              average_integrity: avg_integrity,
              deepest_channels:  deepest_channels(limit: 3),
              most_eroded:       most_eroded(limit: 3)
            }
          end

          def get_formation(formation_id)
            formation = @formations[formation_id]
            return { found: false } unless formation

            { found: true, formation: formation.to_h }
          end

          def formation_count
            @formations.size
          end

          def channel_count
            @channels.size
          end

          private

          def find_channel(formation_id, agent)
            @channels.values.find { |c| c.formation_id == formation_id && c.agent == agent }
          end
        end
      end
    end
  end
end
