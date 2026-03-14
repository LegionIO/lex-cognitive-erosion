# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveErosion::Helpers::Channel do
  let(:formation_id) { 'test-formation-uuid-1234' }
  let(:channel) { described_class.new(formation_id: formation_id, agent: :water) }

  describe '#initialize' do
    it 'assigns a UUID channel_id' do
      expect(channel.channel_id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets formation_id' do
      expect(channel.formation_id).to eq(formation_id)
    end

    it 'sets agent' do
      expect(channel.agent).to eq(:water)
    end

    it 'starts with depth 0.0' do
      expect(channel.depth).to eq(0.0)
    end

    it 'starts with default width 0.1' do
      expect(channel.width).to eq(0.1)
    end

    it 'starts with flow_rate 0.0' do
      expect(channel.flow_rate).to eq(0.0)
    end

    it 'accepts custom initial depth' do
      ch = described_class.new(formation_id: formation_id, agent: :wind, depth: 0.4)
      expect(ch.depth).to eq(0.4)
    end

    it 'clamps depth to 0.0-1.0 range' do
      ch = described_class.new(formation_id: formation_id, agent: :wind, depth: 5.0)
      expect(ch.depth).to eq(1.0)
    end

    it 'raises ArgumentError for invalid agent' do
      expect do
        described_class.new(formation_id: formation_id, agent: :laser)
      end.to raise_error(ArgumentError, /invalid agent/)
    end

    it 'last_active_at starts as nil' do
      expect(channel.last_active_at).to be_nil
    end
  end

  describe '#deepen!' do
    it 'increases depth' do
      channel.deepen!(0.3)
      expect(channel.depth).to be > 0.0
    end

    it 'increases flow_rate' do
      channel.deepen!(0.5)
      expect(channel.flow_rate).to be > 0.0
    end

    it 'returns hash with depth and flow_rate' do
      result = channel.deepen!(0.2)
      expect(result).to include(:depth, :flow_rate)
    end

    it 'clamps force to 0.0 minimum' do
      channel.deepen!(-1.0)
      expect(channel.depth).to eq(0.0)
    end

    it 'clamps depth at 1.0 maximum' do
      5.times { channel.deepen!(1.0) }
      expect(channel.depth).to eq(1.0)
    end

    it 'sets last_active_at' do
      channel.deepen!(0.1)
      expect(channel.last_active_at).not_to be_nil
    end

    it 'updates updated_at' do
      original = channel.updated_at
      sleep(0.001)
      channel.deepen!(0.1)
      expect(channel.updated_at).to be >= original
    end
  end

  describe '#widen!' do
    it 'increases width' do
      before = channel.width
      channel.widen!
      expect(channel.width).to be > before
    end

    it 'accepts custom amount' do
      channel.widen!(0.2)
      expect(channel.width).to be_within(0.001).of(0.3)
    end

    it 'clamps width at 1.0' do
      10.times { channel.widen!(1.0) }
      expect(channel.width).to eq(1.0)
    end

    it 'returns hash with width' do
      result = channel.widen!
      expect(result).to include(:width)
    end
  end

  describe '#dormant?' do
    it 'is true when never activated' do
      expect(channel.dormant?).to be(true)
    end

    it 'is false immediately after deepen!' do
      channel.deepen!(0.1)
      expect(channel.dormant?).to be(false)
    end
  end

  describe '#active?' do
    it 'is false when never activated' do
      expect(channel.active?).to be(false)
    end

    it 'is true immediately after deepen!' do
      channel.deepen!(0.1)
      expect(channel.active?).to be(true)
    end
  end

  describe '#depth_label' do
    it 'returns :surface_scratch for fresh channel' do
      expect(channel.depth_label).to eq(:surface_scratch)
    end

    it 'returns :canyon for deeply carved channel' do
      ch = described_class.new(formation_id: formation_id, agent: :water, depth: 0.95)
      expect(ch.depth_label).to eq(:canyon)
    end

    it 'returns :carved_channel at mid depth' do
      ch = described_class.new(formation_id: formation_id, agent: :ice, depth: 0.4)
      expect(ch.depth_label).to eq(:carved_channel)
    end
  end

  describe '#to_h' do
    it 'returns a hash with all required keys' do
      h = channel.to_h
      expect(h).to include(
        :channel_id, :formation_id, :agent, :depth, :width,
        :flow_rate, :depth_label, :dormant, :active, :created_at,
        :updated_at, :last_active_at
      )
    end

    it 'reflects current depth after deepen!' do
      channel.deepen!(0.4)
      expect(channel.to_h[:depth]).to be > 0.0
    end

    it 'reflects active state after deepen!' do
      channel.deepen!(0.1)
      expect(channel.to_h[:active]).to be(true)
    end
  end
end
