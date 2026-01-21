class Game < ApplicationRecord
  validates :name, presence: true
  validates :rows, :columns, presence: true, numericality: { greater_than: 0, less_than: 100 }
end
