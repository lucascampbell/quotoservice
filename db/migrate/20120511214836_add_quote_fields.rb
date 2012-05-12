class AddQuoteFields < ActiveRecord::Migration
  def up
    add_column :quotes, :rating, :integer
    add_column :quotes, :author, :string
  end

  def down
    remove_column :quotes, :rating
    remove_column :quotes, :author
  end
end
