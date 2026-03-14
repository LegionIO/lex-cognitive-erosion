# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Client do
  let(:engine) { Legion::Extensions::CognitiveErosion::Helpers::ErosionEngine.new }
  let(:client) { described_class.new(engine: engine) }

  describe '#initialize' do
    it 'accepts injected engine' do
      expect(client).to respond_to(:create_formation)
    end

    it 'creates its own engine when none injected' do
      c = described_class.new
      result = c.create_formation(material_type: :limestone, domain: 'd', content: 'c')
      expect(result[:success]).to be(true)
    end
  end

  describe '#create_formation' do
    it 'creates a formation' do
      result = client.create_formation(material_type: :sandstone, domain: 'morality', content: 'lying is wrong')
      expect(result[:success]).to be(true)
      expect(result[:formation_id]).to match(/\A[0-9a-f-]{36}\z/)
    end
  end

  describe '#erode' do
    it 'erodes an existing formation' do
      id = client.create_formation(material_type: :chalk, domain: 'taste', content: 'jazz is noise')[:formation_id]
      result = client.erode(formation_id: id, agent: :water, force: 0.4)
      expect(result[:success]).to be(true)
    end
  end

  describe '#weather_all' do
    it 'weathers all formations in the engine' do
      client.create_formation(material_type: :clay, domain: 'd1', content: 'c1')
      client.create_formation(material_type: :chalk, domain: 'd2', content: 'c2')
      result = client.weather_all
      expect(result[:weathered]).to eq(2)
    end
  end

  describe '#deepest_channels' do
    it 'returns channels' do
      result = client.deepest_channels
      expect(result[:channels]).to be_an(Array)
    end
  end

  describe '#most_eroded' do
    it 'returns formations' do
      result = client.most_eroded
      expect(result[:formations]).to be_an(Array)
    end
  end

  describe '#erosion_report' do
    it 'returns a report' do
      result = client.erosion_report
      expect(result[:success]).to be(true)
      expect(result).to include(:total_formations, :total_channels)
    end
  end

  describe 'full erosion lifecycle' do
    it 'creates formation, erodes repeatedly, and reports canyon' do
      id = client.create_formation(material_type: :clay, domain: 'belief', content: 'hard work always pays off')[:formation_id]

      10.times { client.erode(formation_id: id, agent: :water, force: 0.8) }

      report = client.erosion_report
      expect(report[:canyons]).to be >= 1

      channels = client.deepest_channels(limit: 3)
      expect(channels[:channels].first[:depth]).to be > 0.3
    end

    it 'tracks multiple independent erosion channels per formation' do
      id = client.create_formation(material_type: :limestone, domain: 'politics', content: 'markets self-regulate')[:formation_id]

      client.erode(formation_id: id, agent: :water, force: 0.3)
      client.erode(formation_id: id, agent: :wind, force: 0.3)
      client.erode(formation_id: id, agent: :chemical, force: 0.3)

      report = client.erosion_report
      expect(report[:total_channels]).to be >= 3
    end
  end
end
