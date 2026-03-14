# lex-cognitive-erosion

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-erosion`

## Purpose

Models the gradual wearing-away of cognitive structures through repeated exposure to eroding forces. Belief formations, established patterns, or ingrained assumptions are represented as geological formations with material-dependent resistance. Erosion agents (water, wind, ice, pressure, chemical) carve channels through formations over time, producing progressively deeper grooves that become harder to redirect.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-erosion` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveErosion` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-erosion |

## File Structure

```
lib/legion/extensions/cognitive_erosion/
  cognitive_erosion.rb              # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Material types, resistance, labels
    formation.rb                    # Formation value object
    channel.rb                      # Channel value object
    erosion_engine.rb               # Engine: formations + channels
  runners/
    cognitive_erosion.rb            # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MATERIAL_TYPES` | array | `[:granite, :sandstone, :limestone, :chalk, :clay]` |
| `EROSION_AGENTS` | array | `[:water, :wind, :ice, :pressure, :chemical]` |
| `RESISTANCE` | hash | Natural resistance per material (granite: 0.9 → clay: 0.1) |
| `MAX_FORMATIONS` | 200 | Formation store cap |
| `CHANNEL_DEPTH_LABELS` | hash | `surface_scratch` through `canyon` |
| `FORMATION_LABELS` | hash | `pristine` through `ruins` based on integrity |

## Helpers

### `Formation`

Represents a cognitive structure with material-based resistance.

- `initialize(material_type:, domain:, content:, resistance: nil)` — generates UUID; `resistance` defaults from `RESISTANCE` table
- `erode!(agent, force)` — reduces `integrity` and increases `erosion_depth` by `force * (1.0 - resistance)`; raises `ArgumentError` for invalid agent
- `resist!(amount)` — partially restores integrity
- `weathered?` — `integrity < 0.7`
- `canyon?` — `erosion_depth >= 0.7`
- `pristine?` — `integrity >= 0.9`
- `integrity_label`, `depth_label` — resolve from constants tables
- `to_h`

### `Channel`

Tracks a persistent groove carved by repeated erosion along a formation+agent pair.

- `initialize(formation_id:, agent:, depth: 0.0, width: 0.1, flow_rate: 0.0)`
- `deepen!(force)` — increases depth and flow_rate proportionally
- `widen!(amount = 0.05)` — increases width when depth >= 0.3
- `dormant?` — `last_active_at` nil or > 3600s ago
- `depth_label` — resolves from `CHANNEL_DEPTH_LABELS`
- `to_h`

### `ErosionEngine`

Manages the full set of formations and channels.

- `create_formation(material_type:, domain:, content:, resistance: nil)` — validates material; returns `{ success:, formation_id:, formation: }` or error hash
- `erode(formation_id:, agent:, force:)` — applies formation erosion and carves/deepens channel in one call
- `carve_channel(formation_id:, agent:, force: 0.1)` — finds or creates channel; widens if deep enough
- `weather_all!(force: 0.05, agent: :wind)` — applies erosion to every formation
- `deepest_channels(limit: 5)`, `most_eroded(limit: 5)`
- `erosion_report` — full stats: formations, channels, canyons, averages
- `get_formation(formation_id)`, `formation_count`, `channel_count`

## Runners

**Module**: `Legion::Extensions::CognitiveErosion::Runners::CognitiveErosion`

| Method | Key Args | Returns |
|---|---|---|
| `create_formation` | `material_type:`, `domain:`, `content:`, `resistance: nil` | `{ success:, formation_id:, formation: }` |
| `erode` | `formation_id:`, `agent:`, `force:` | `{ success:, erosion:, channel: }` |
| `weather_all` | `force: 0.05`, `agent: :wind` | `{ success:, weathered:, results: }` |
| `deepest_channels` | `limit: 5` | `{ channels:, count: }` |
| `most_eroded` | `limit: 5` | `{ formations:, count: }` |
| `erosion_report` | — | Full stats hash |
| `get_formation` | `formation_id:` | `{ found:, formation: }` |

Private: `default_engine` — memoized `ErosionEngine`. Runner accepts optional `engine:` parameter to inject a test engine.

## Integration Points

- **`lex-memory`**: Erosion provides a metaphorical model for how repeated challenges wear down established memory traces. Not a direct dependency, but architecturally related to decay.
- **`lex-tick`**: Could be wired into the `memory_consolidation` phase to apply periodic weathering to outdated beliefs.

## Development Notes

- The engine accepts `extend self` pattern in the runner; the runner is a module not a class. All runner methods pass `engine:` as an optional parameter, making unit testing straightforward without mocking.
- `erode` and `carve_channel` are automatically coordinated: calling `erode` always calls `carve_channel` internally.
- In-memory only. No persistence. Process restart clears all formations and channels.

---

**Maintained By**: Matthew Iverson (@Esity)
