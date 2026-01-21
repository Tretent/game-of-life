class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :name
      t.json :history, default: []
      t.integer :rows, default: 10
      t.integer :columns, default: 10

      t.timestamps
    end
  end
end
