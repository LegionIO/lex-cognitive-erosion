# lex-cognitive-erosion

Geological erosion model for cognitive structures in brain-modeled agentic AI within the LegionIO ecosystem.

## What It Does

Cognitive structures — beliefs, patterns, established assumptions — wear down under repeated exposure to destabilizing forces. This extension models that process using a geological metaphor: formations of varying material (granite through clay) resist erosion agents (water, wind, ice, pressure, chemical) to different degrees. Repeated erosion carves channels through formations that progressively deepen and widen. A granite belief erodes slowly; a chalk assumption collapses quickly.

Each formation tracks its integrity (0.0 = ruins, 1.0 = pristine) and erosion depth. Channels track depth, width, and flow rate. The `weather_all` runner applies background erosion across every formation in one call.

## Usage

```ruby
require 'legion/extensions/cognitive_erosion'

client = Legion::Extensions::CognitiveErosion::Client.new

# Create a formation — a sandstone belief about user preferences
result = client.create_formation(
  material_type: :sandstone,
  domain:        'user_preferences',
  content:       'Users prefer brief responses'
)
formation_id = result[:formation_id]

# Apply erosion — contradictory evidence acts like water
client.erode(formation_id: formation_id, agent: :water, force: 0.3)

# Apply background weathering to all formations
client.weather_all(force: 0.05, agent: :wind)

# Report on erosion state
client.erosion_report
# => { total_formations: 1, canyons: 0, weathered: 0, average_depth: 0.1, ... }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
