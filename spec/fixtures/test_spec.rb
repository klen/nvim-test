RSpec.describe Game do
  describe '#score' do
    it 'returns 0 for an all gutter game' do
      game = Game.new
      20.times { game.roll(0) }
      expect(game.score).to eq(0)
    end
  end
end

