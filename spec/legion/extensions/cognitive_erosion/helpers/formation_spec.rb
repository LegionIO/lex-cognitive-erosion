# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Helpers::Formation do
  let(:formation) { described_class.new(material_type: :limestone, domain: 'politics', content: 'taxes are bad') }
  let(:granite_formation) { described_class.new(material_type: :granite, domain: 'science', content: 'gravity is real') }
  let(:clay_formation) { described_class.new(material_type: :clay, domain: 'taste', content: 'chocolate is best') }

  describe '#initialize' do
    it 'assigns a UUID formation_id' do
      expect(formation.formation_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets material_type' do
      expect(formation.material_type).to eq(:limestone)
    end

    it 'sets domain' do
      expect(formation.domain).to eq('politics')
    end

    it 'sets content' do
      expect(formation.content).to eq('taxes are bad')
    end

    it 'sets resistance from constants by default' do
      expect(formation.resistance).to eq(
        Legion::Extensions::CognitiveErosion::Helpers::Constants::RESISTANCE[:limestone]
      )
    end

    it 'accepts an explicit resistance override' do
      f = described_class.new(material_type: :chalk, domain: 'd', content: 'c', resistance: 0.75)
      expect(f.resistance).to eq(0.75)
    end

    it 'starts with integrity 1.0' do
      expect(formation.integrity).to eq(1.0)
    end

    it 'starts with erosion_depth 0.0' do
      expect(formation.erosion_depth).to eq(0.0)
    end

    it 'raises ArgumentError for invalid material_type' do
      expect do
        described_class.new(material_type: :diamond, domain: 'd', content: 'c')
      end.to raise_error(ArgumentError, /invalid material_type/)
    end
  end

  describe '#erode!' do
    it 'reduces integrity' do
      before_integrity = formation.integrity
      formation.erode!(:water, 0.5)
      expect(formation.integrity).to be < before_integrity
    end

    it 'increases erosion_depth' do
      formation.erode!(:water, 0.5)
      expect(formation.erosion_depth).to be > 0.0
    end

    it 'returns a result hash with effective_force' do
      result = formation.erode!(:wind, 0.3)
      expect(result).to include(:agent, :force, :effective_force, :integrity, :erosion_depth)
    end

    it 'clamps force to 1.0 max' do
      result = formation.erode!(:water, 5.0)
      expect(result[:force]).to eq(1.0)
    end

    it 'clamps force to 0.0 min' do
      result = formation.erode!(:water, -1.0)
      expect(result[:force]).to eq(0.0)
    end

    it 'granite resists more than clay' do
      granite_result = granite_formation.erode!(:water, 0.5)
      clay_result    = clay_formation.erode!(:water, 0.5)
      expect(granite_result[:effective_force]).to be < clay_result[:effective_force]
    end

    it 'raises ArgumentError for invalid agent' do
      expect { formation.erode!(:laser, 0.5) }.to raise_error(ArgumentError, /invalid agent/)
    end

    it 'does not reduce integrity below 0.0' do
      10.times { formation.erode!(:chemical, 1.0) }
      expect(formation.integrity).to be >= 0.0
    end

    it 'does not increase erosion_depth above 1.0' do
      10.times { formation.erode!(:chemical, 1.0) }
      expect(formation.erosion_depth).to be <= 1.0
    end

    it 'updates updated_at' do
      original = formation.updated_at
      sleep(0.001)
      formation.erode!(:water, 0.1)
      expect(formation.updated_at).to be >= original
    end
  end

  describe '#resist!' do
    it 'increases integrity' do
      formation.erode!(:water, 0.5)
      before = formation.integrity
      formation.resist!
      expect(formation.integrity).to be > before
    end

    it 'accepts a custom recovery amount' do
      formation.erode!(:water, 0.5)
      before = formation.integrity
      formation.resist!(0.2)
      expect(formation.integrity).to be_within(0.001).of(before + 0.2)
    end

    it 'clamps integrity to 1.0' do
      formation.resist!(2.0)
      expect(formation.integrity).to eq(1.0)
    end

    it 'returns a hash with integrity and recovered' do
      result = formation.resist!
      expect(result).to include(:integrity, :recovered)
    end
  end

  describe '#weathered?' do
    it 'returns false for pristine formation' do
      expect(formation.weathered?).to be(false)
    end

    it 'returns true after significant erosion' do
      formation.erode!(:chemical, 1.0)
      formation.erode!(:chemical, 1.0)
      formation.erode!(:chemical, 1.0)
      expect(formation.weathered?).to be(true)
    end
  end

  describe '#canyon?' do
    it 'returns false for fresh formation' do
      expect(formation.canyon?).to be(false)
    end

    it 'returns true when erosion_depth >= 0.7' do
      10.times { clay_formation.erode!(:water, 1.0) }
      expect(clay_formation.canyon?).to be(true)
    end
  end

  describe '#pristine?' do
    it 'returns true for new formation' do
      expect(formation.pristine?).to be(true)
    end

    it 'returns false after erosion reduces integrity below 0.9' do
      formation.erode!(:chemical, 1.0)
      expect(formation.pristine?).to be(false)
    end
  end

  describe '#integrity_label' do
    it 'returns :pristine for new formation' do
      expect(formation.integrity_label).to eq(:pristine)
    end

    it 'returns :ruins for fully eroded formation' do
      10.times { clay_formation.erode!(:chemical, 1.0) }
      expect(clay_formation.integrity_label).to eq(:ruins)
    end
  end

  describe '#depth_label' do
    it 'returns :surface_scratch for new formation' do
      expect(formation.depth_label).to eq(:surface_scratch)
    end

    it 'returns :canyon for deeply eroded clay' do
      10.times { clay_formation.erode!(:water, 1.0) }
      expect(clay_formation.depth_label).to eq(:canyon)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all required keys' do
      h = formation.to_h
      expect(h).to include(
        :formation_id, :material_type, :domain, :content, :resistance,
        :integrity, :erosion_depth, :integrity_label, :depth_label,
        :weathered, :canyon, :pristine, :created_at, :updated_at
      )
    end

    it 'reflects current state' do
      formation.erode!(:water, 0.3)
      h = formation.to_h
      expect(h[:integrity]).to be < 1.0
      expect(h[:erosion_depth]).to be > 0.0
    end
  end
end
