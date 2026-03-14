# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Runners::CognitiveErosion do
  let(:engine) { Legion::Extensions::CognitiveErosion::Helpers::ErosionEngine.new }

  let(:formation_id) do
    described_class.create_formation(
      material_type: :limestone, domain: 'economy', content: 'growth is always good', engine: engine
    )[:formation_id]
  end

  describe '.create_formation' do
    it 'returns success: true' do
      result = described_class.create_formation(
        material_type: :granite, domain: 'science', content: 'vaccines work', engine: engine
      )
      expect(result[:success]).to be(true)
    end

    it 'returns formation_id' do
      result = described_class.create_formation(
        material_type: :chalk, domain: 'culture', content: 'tradition matters', engine: engine
      )
      expect(result[:formation_id]).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'returns failure for invalid material_type' do
      result = described_class.create_formation(
        material_type: :diamond, domain: 'd', content: 'c', engine: engine
      )
      expect(result[:success]).to be(false)
    end
  end

  describe '.erode' do
    it 'returns success: true' do
      id = formation_id
      result = described_class.erode(formation_id: id, agent: :water, force: 0.3, engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'returns erosion details' do
      id = formation_id
      result = described_class.erode(formation_id: id, agent: :wind, force: 0.2, engine: engine)
      expect(result[:erosion]).to include(:effective_force)
    end

    it 'returns failure for unknown formation' do
      result = described_class.erode(formation_id: 'nope', agent: :water, force: 0.3, engine: engine)
      expect(result[:success]).to be(false)
    end

    it 'returns failure for invalid agent' do
      id = formation_id
      result = described_class.erode(formation_id: id, agent: :laser, force: 0.3, engine: engine)
      expect(result[:success]).to be(false)
    end
  end

  describe '.weather_all' do
    it 'returns success: true' do
      result = described_class.weather_all(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'weathers all formations' do
      described_class.create_formation(material_type: :chalk, domain: 'd1', content: 'c1', engine: engine)
      described_class.create_formation(material_type: :clay, domain: 'd2', content: 'c2', engine: engine)
      result = described_class.weather_all(engine: engine)
      expect(result[:weathered]).to eq(2)
    end

    it 'accepts custom force and agent' do
      described_class.create_formation(material_type: :sandstone, domain: 'd', content: 'c', engine: engine)
      result = described_class.weather_all(force: 0.3, agent: :ice, engine: engine)
      expect(result[:success]).to be(true)
    end
  end

  describe '.deepest_channels' do
    it 'returns success: true' do
      result = described_class.deepest_channels(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'returns channels array' do
      result = described_class.deepest_channels(engine: engine)
      expect(result[:channels]).to be_an(Array)
    end

    it 'includes count' do
      result = described_class.deepest_channels(engine: engine)
      expect(result).to have_key(:count)
    end

    it 'returns populated channels after erosion' do
      id = formation_id
      described_class.erode(formation_id: id, agent: :water, force: 0.4, engine: engine)
      result = described_class.deepest_channels(limit: 5, engine: engine)
      expect(result[:count]).to be >= 1
    end
  end

  describe '.most_eroded' do
    it 'returns success: true' do
      result = described_class.most_eroded(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'returns formations array' do
      result = described_class.most_eroded(engine: engine)
      expect(result[:formations]).to be_an(Array)
    end

    it 'returns populated formations after erosion' do
      id = formation_id
      3.times { described_class.erode(formation_id: id, agent: :water, force: 0.5, engine: engine) }
      result = described_class.most_eroded(limit: 5, engine: engine)
      expect(result[:count]).to be >= 1
    end
  end

  describe '.erosion_report' do
    it 'returns success: true' do
      result = described_class.erosion_report(engine: engine)
      expect(result[:success]).to be(true)
    end

    it 'includes formation and channel counts' do
      result = described_class.erosion_report(engine: engine)
      expect(result).to include(:total_formations, :total_channels, :canyons, :weathered)
    end

    it 'reflects formations created' do
      described_class.create_formation(material_type: :limestone, domain: 'd', content: 'c', engine: engine)
      result = described_class.erosion_report(engine: engine)
      expect(result[:total_formations]).to be >= 1
    end
  end

  describe '.get_formation' do
    it 'returns found: true for existing formation' do
      id = formation_id
      result = described_class.get_formation(formation_id: id, engine: engine)
      expect(result[:found]).to be(true)
    end

    it 'returns found: false for unknown id' do
      result = described_class.get_formation(formation_id: 'ghost', engine: engine)
      expect(result[:found]).to be(false)
    end
  end
end
