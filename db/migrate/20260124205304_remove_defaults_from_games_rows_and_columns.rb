class RemoveDefaultsFromGamesRowsAndColumns < ActiveRecord::Migration[8.1]
  def change
    change_column_default :games, :rows, from: 10, to: nil
    change_column_default :games, :columns, from: 10, to: nil
  end
end
