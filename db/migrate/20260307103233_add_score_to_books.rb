class AddScoreToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :score, :float
  end
end
