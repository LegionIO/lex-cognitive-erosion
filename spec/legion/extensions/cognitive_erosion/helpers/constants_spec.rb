# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Helpers::Constants do
  describe 'MATERIAL_TYPES' do
    it 'includes granite' do
      expect(described_class::MATERIAL_TYPES).to include(:granite)
    end

    it 'includes sandstone' do
      expect(described_class::MATERIAL_TYPES).to include(:sandstone)
    end

    it 'includes limestone' do
      expect(described_class::MATERIAL_TYPES).to include(:limestone)
    end

    it 'includes chalk' do
      expect(described_class::MATERIAL_TYPES).to include(:chalk)
    end

    it 'includes clay' do
      expect(described_class::MATERIAL_TYPES).to include(:clay)
    end

    it 'is frozen' do
      expect(described_class::MATERIAL_TYPES).to be_frozen
    end

    it 'has 5 material types' do
      expect(described_class::MATERIAL_TYPES.size).to eq(5)
    end
  end

  describe 'EROSION_AGENTS' do
    it 'includes water' do
      expect(described_class::EROSION_AGENTS).to include(:water)
    end

    it 'includes wind' do
      expect(described_class::EROSION_AGENTS).to include(:wind)
    end

    it 'includes ice' do
      expect(described_class::EROSION_AGENTS).to include(:ice)
    end

    it 'includes pressure' do
      expect(described_class::EROSION_AGENTS).to include(:pressure)
    end

    it 'includes chemical' do
      expect(described_class::EROSION_AGENTS).to include(:chemical)
    end

    it 'is frozen' do
      expect(described_class::EROSION_AGENTS).to be_frozen
    end

    it 'has 5 agents' do
      expect(described_class::EROSION_AGENTS.size).to eq(5)
    end
  end

  describe 'RESISTANCE' do
    it 'granite has highest resistance' do
      expect(described_class::RESISTANCE[:granite]).to eq(0.9)
    end

    it 'clay has lowest resistance' do
      expect(described_class::RESISTANCE[:clay]).to eq(0.1)
    end

    it 'sandstone resistance is between granite and limestone' do
      expect(described_class::RESISTANCE[:sandstone]).to be_between(
        described_class::RESISTANCE[:limestone],
        described_class::RESISTANCE[:granite]
      )
    end

    it 'chalk has lower resistance than limestone' do
      expect(described_class::RESISTANCE[:chalk]).to be < described_class::RESISTANCE[:limestone]
    end

    it 'covers all material types' do
      described_class::MATERIAL_TYPES.each do |mat|
        expect(described_class::RESISTANCE).to have_key(mat)
      end
    end
  end

  describe 'MAX_FORMATIONS' do
    it 'is 200' do
      expect(described_class::MAX_FORMATIONS).to eq(200)
    end
  end

  describe 'CHANNEL_DEPTH_LABELS' do
    it 'labels depth 0.0 as surface_scratch' do
      label = described_class::CHANNEL_DEPTH_LABELS.find { |range, _| range.cover?(0.0) }&.last
      expect(label).to eq(:surface_scratch)
    end

    it 'labels depth 0.95 as canyon' do
      label = described_class::CHANNEL_DEPTH_LABELS.find { |range, _| range.cover?(0.95) }&.last
      expect(label).to eq(:canyon)
    end

    it 'labels depth 0.4 as carved_channel' do
      label = described_class::CHANNEL_DEPTH_LABELS.find { |range, _| range.cover?(0.4) }&.last
      expect(label).to eq(:carved_channel)
    end

    it 'covers the full 0.0-1.0 range' do
      [0.0, 0.15, 0.35, 0.55, 0.75, 0.95, 1.0].each do |val|
        found = described_class::CHANNEL_DEPTH_LABELS.any? { |range, _| range.cover?(val) }
        expect(found).to be(true), "no label covers depth #{val}"
      end
    end
  end

  describe 'FORMATION_LABELS' do
    it 'labels integrity 1.0 as pristine' do
      label = described_class::FORMATION_LABELS.find { |range, _| range.cover?(1.0) }&.last
      expect(label).to eq(:pristine)
    end

    it 'labels integrity 0.0 as ruins' do
      label = described_class::FORMATION_LABELS.find { |range, _| range.cover?(0.0) }&.last
      expect(label).to eq(:ruins)
    end

    it 'labels integrity 0.55 as weathered' do
      label = described_class::FORMATION_LABELS.find { |range, _| range.cover?(0.55) }&.last
      expect(label).to eq(:weathered)
    end
  end
end
