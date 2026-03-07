class AddCategoryToBooks < ActiveRecord::Migration[8.0]
  def change
    add_column :books, :category, :string
  end
end
