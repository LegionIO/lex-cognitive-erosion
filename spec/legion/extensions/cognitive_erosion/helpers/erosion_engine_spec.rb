# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Helpers::ErosionEngine do
  let(:engine) { described_class.new }

  let(:limestone_id) do
    result = engine.create_formation(material_type: :limestone, domain: 'politics', content: 'taxes are necessary')
    result[:formation_id]
  end

  let(:clay_id) do
    result = engine.create_formation(material_type: :clay, domain: 'taste', content: 'pineapple on pizza is wrong')
    result[:formation_id]
  end

  describe '#create_formation' do
    it 'returns success: true' do
      result = engine.create_formation(material_type: :granite, domain: 'science', content: 'gravity exists')
      expect(result[:success]).to be(true)
    end

    it 'returns formation_id' do
      result = engine.create_formation(material_type: :sandstone, domain: 'd', content: 'c')
      expect(result[:formation_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns formation hash' do
      result = engine.create_formation(material_type: :chalk, domain: 'd', content: 'c')
      expect(result[:formation]).to include(:formation_id, :material_type, :integrity)
    end

    it 'tracks formation_count' do
      engine.create_formation(material_type: :limestone, domain: 'd', content: 'c')
      expect(engine.formation_count).to eq(1)
    end

    it 'returns error for invalid material_type' do
      result = engine.create_formation(material_type: :marble, domain: 'd', content: 'c')
      expect(result[:success]).to be(false)
    end

    it 'returns error when MAX_FORMATIONS is reached' do
      stub_const('Legion::Extensions::CognitiveErosion::Helpers::Constants::MAX_FORMATIONS', 2)
      engine.create_formation(material_type: :chalk, domain: 'd', content: 'c')
      engine.create_formation(material_type: :clay, domain: 'd2', content: 'c2')
      result = engine.create_formation(material_type: :granite, domain: 'd3', content: 'c3')
      expect(result[:success]).to be(false)
    end
  end

  describe '#erode' do
    it 'returns success: true for valid erosion' do
      id = limestone_id
      result = engine.erode(formation_id: id, agent: :water, force: 0.3)
      expect(result[:success]).to be(true)
    end

    it 'returns erosion details' do
      id = limestone_id
      result = engine.erode(formation_id: id, agent: :water, force: 0.3)
      expect(result[:erosion]).to include(:effective_force, :integrity)
    end

    it 'returns channel details' do
      id = limestone_id
      result = engine.erode(formation_id: id, agent: :water, force: 0.3)
      expect(result[:channel]).to include(:depth, :agent)
    end

    it 'returns formation_not_found for unknown id' do
      result = engine.erode(formation_id: 'nope', agent: :water, force: 0.3)
      expect(result[:error]).to eq(:formation_not_found)
    end

    it 'returns invalid_agent for bad agent' do
      id = limestone_id
      result = engine.erode(formation_id: id, agent: :laser, force: 0.3)
      expect(result[:error]).to eq(:invalid_agent)
    end

    it 'creates a channel on first erosion' do
      id = limestone_id
      engine.erode(formation_id: id, agent: :wind, force: 0.2)
      expect(engine.channel_count).to be >= 1
    end

    it 'deepens existing channel on repeated erosion' do
      id = limestone_id
      engine.erode(formation_id: id, agent: :water, force: 0.2)
      result1 = engine.erode(formation_id: id, agent: :water, force: 0.2)
      result2 = engine.erode(formation_id: id, agent: :water, force: 0.2)
      expect(result2[:channel][:depth]).to be >= result1[:channel][:depth]
    end

    it 'does not create duplicate channels for same agent' do
      id = limestone_id
      3.times { engine.erode(formation_id: id, agent: :water, force: 0.1) }
      expect(engine.channel_count).to eq(1)
    end
  end

  describe '#carve_channel' do
    it 'creates a new channel' do
      id = limestone_id
      engine.carve_channel(formation_id: id, agent: :ice, force: 0.3)
      expect(engine.channel_count).to be >= 1
    end

    it 'returns channel hash' do
      id = limestone_id
      result = engine.carve_channel(formation_id: id, agent: :wind)
      expect(result).to include(:channel_id, :depth, :agent)
    end

    it 'reuses existing channel for same agent' do
      id = limestone_id
      engine.carve_channel(formation_id: id, agent: :water)
      engine.carve_channel(formation_id: id, agent: :water)
      expect(engine.channel_count).to eq(1)
    end

    it 'widens channel when depth >= 0.3' do
      id = clay_id
      engine.carve_channel(formation_id: id, agent: :water, force: 0.5)
      engine.carve_channel(formation_id: id, agent: :water, force: 0.5)
      result = engine.carve_channel(formation_id: id, agent: :water, force: 0.5)
      expect(result[:width]).to be > 0.1
    end
  end

  describe '#weather_all!' do
    it 'weathers all formations' do
      3.times { |i| engine.create_formation(material_type: :chalk, domain: "d#{i}", content: "c#{i}") }
      result = engine.weather_all!
      expect(result[:weathered]).to eq(3)
    end

    it 'returns success: true' do
      engine.create_formation(material_type: :limestone, domain: 'd', content: 'c')
      result = engine.weather_all!
      expect(result[:success]).to be(true)
    end

    it 'returns empty results when no formations' do
      result = engine.weather_all!
      expect(result[:weathered]).to eq(0)
    end

    it 'reduces integrity of formations' do
      id = limestone_id
      before = engine.get_formation(id)[:formation][:integrity]
      engine.weather_all!(force: 0.5, agent: :wind)
      after = engine.get_formation(id)[:formation][:integrity]
      expect(after).to be < before
    end
  end

  describe '#deepest_channels' do
    before do
      id1 = engine.create_formation(material_type: :clay, domain: 'd1', content: 'c1')[:formation_id]
      id2 = engine.create_formation(material_type: :chalk, domain: 'd2', content: 'c2')[:formation_id]
      3.times { engine.erode(formation_id: id1, agent: :water, force: 0.4) }
      engine.erode(formation_id: id2, agent: :wind, force: 0.1)
    end

    it 'returns channels sorted deepest first' do
      channels = engine.deepest_channels(limit: 5)
      depths = channels.map { |c| c[:depth] }
      expect(depths).to eq(depths.sort.reverse)
    end

    it 'respects limit' do
      channels = engine.deepest_channels(limit: 1)
      expect(channels.size).to eq(1)
    end

    it 'returns channel hashes' do
      channels = engine.deepest_channels
      expect(channels.first).to include(:depth, :agent, :formation_id)
    end
  end

  describe '#most_eroded' do
    before do
      id1 = engine.create_formation(material_type: :clay, domain: 'd1', content: 'c1')[:formation_id]
      id2 = engine.create_formation(material_type: :granite, domain: 'd2', content: 'c2')[:formation_id]
      5.times { engine.erode(formation_id: id1, agent: :water, force: 0.5) }
      engine.erode(formation_id: id2, agent: :water, force: 0.1)
    end

    it 'returns formations sorted by erosion_depth descending' do
      formations = engine.most_eroded(limit: 5)
      depths = formations.map { |f| f[:erosion_depth] }
      expect(depths).to eq(depths.sort.reverse)
    end

    it 'respects limit' do
      formations = engine.most_eroded(limit: 1)
      expect(formations.size).to eq(1)
    end
  end

  describe '#erosion_report' do
    it 'returns success: true' do
      result = engine.erosion_report
      expect(result[:success]).to be(true)
    end

    it 'includes total_formations count' do
      engine.create_formation(material_type: :limestone, domain: 'd', content: 'c')
      result = engine.erosion_report
      expect(result[:total_formations]).to eq(1)
    end

    it 'includes total_channels count' do
      id = limestone_id
      engine.erode(formation_id: id, agent: :water, force: 0.2)
      result = engine.erosion_report
      expect(result[:total_channels]).to be >= 1
    end

    it 'counts canyons correctly' do
      id = clay_id
      10.times { engine.erode(formation_id: id, agent: :water, force: 1.0) }
      result = engine.erosion_report
      expect(result[:canyons]).to be >= 1
    end

    it 'includes average_depth' do
      result = engine.erosion_report
      expect(result).to have_key(:average_depth)
    end

    it 'reports average_depth 0.0 with no formations' do
      result = engine.erosion_report
      expect(result[:average_depth]).to eq(0.0)
    end

    it 'includes deepest_channels and most_eroded' do
      result = engine.erosion_report
      expect(result).to include(:deepest_channels, :most_eroded)
    end
  end

  describe '#get_formation' do
    it 'returns found: true for existing formation' do
      id = limestone_id
      result = engine.get_formation(id)
      expect(result[:found]).to be(true)
    end

    it 'returns formation hash' do
      id = limestone_id
      result = engine.get_formation(id)
      expect(result[:formation]).to include(:formation_id, :material_type)
    end

    it 'returns found: false for unknown id' do
      result = engine.get_formation('nonexistent')
      expect(result[:found]).to be(false)
    end
  end
end
