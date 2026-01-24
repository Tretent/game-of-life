class Game < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, length: { maximum: 255 }
  validates :rows, :columns, presence: true, numericality: { greater_than: 0, less_than: 100 }

  def current_generation
    history&.length || 0
  end

  def current_grid
    history&.last
  end

  def advance_generation!
    next_grid = GameOfLife::Evolution.next_generation(current_grid)
    self.history << next_grid
    save!
  end

  def reset_to_initial!
    first_index = history.index(&:itself)
    self.history = history[..first_index]
    save!
  end

  def self.build_history(generation, grid)
    Array.new(generation - 1, nil) << grid
  end

  def self.create_draft_from_parse_result(user:, name:, result:)
    user.games.create!(
      name: name,
      rows: result[:rows],
      columns: result[:columns],
      history: build_history(result[:generation], result[:grid]),
      draft: true
    )
  end
end
