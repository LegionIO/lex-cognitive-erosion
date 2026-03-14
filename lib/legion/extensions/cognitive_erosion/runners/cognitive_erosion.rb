# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveErosion
      module Runners
        module CognitiveErosion
          extend self

          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def create_formation(material_type:, domain:, content:, resistance: nil, engine: nil, **)
            eng = engine || default_engine
            result = eng.create_formation(
              material_type: material_type,
              domain:        domain,
              content:       content,
              resistance:    resistance
            )
            Legion::Logging.debug "[cognitive_erosion] formation created: #{result[:formation_id]}" if result[:success]
            result
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_erosion] create_formation failed: #{e.message}"
            { success: false, error: e.message }
          end

          def erode(formation_id:, agent:, force:, engine: nil, **)
            eng = engine || default_engine
            result = eng.erode(formation_id: formation_id, agent: agent, force: force)
            if result[:success]
              Legion::Logging.debug "[cognitive_erosion] eroded #{formation_id[0..7]} agent=#{agent} force=#{force.round(3)}"
            end
            result
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_erosion] erode failed: #{e.message}"
            { success: false, error: e.message }
          end

          def weather_all(force: 0.05, agent: :wind, engine: nil, **)
            eng = engine || default_engine
            result = eng.weather_all!(force: force, agent: agent)
            Legion::Logging.debug "[cognitive_erosion] weather_all: #{result[:weathered]} formations weathered" if result[:success]
            result
          rescue ArgumentError => e
            Legion::Logging.warn "[cognitive_erosion] weather_all failed: #{e.message}"
            { success: false, error: e.message }
          end

          def deepest_channels(limit: 5, engine: nil, **)
            eng = engine || default_engine
            channels = eng.deepest_channels(limit: limit)
            { success: true, channels: channels, count: channels.size }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def most_eroded(limit: 5, engine: nil, **)
            eng = engine || default_engine
            formations = eng.most_eroded(limit: limit)
            { success: true, formations: formations, count: formations.size }
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def erosion_report(engine: nil, **)
            eng = engine || default_engine
            result = eng.erosion_report
            Legion::Logging.debug "[cognitive_erosion] report: formations=#{result[:total_formations]} channels=#{result[:total_channels]} canyons=#{result[:canyons]}"
            result
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          def get_formation(formation_id:, engine: nil, **)
            eng = engine || default_engine
            eng.get_formation(formation_id)
          rescue ArgumentError => e
            { success: false, error: e.message }
          end

          private

          def default_engine
            @default_engine ||= Helpers::ErosionEngine.new
          end
        end
      end
    end
  end
end
