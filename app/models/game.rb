class Game < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  validates :rows, :columns, presence: true, numericality: { greater_than: 0, less_than: 100 }

  def current_generation
    history&.length || 0
  end

  def current_grid
    history&.last
  end
end
