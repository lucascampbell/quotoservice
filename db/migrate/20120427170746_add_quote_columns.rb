class AddQuoteColumns < ActiveRecord::Migration
  def up
    add_column :quotes, :topic, :string
    add_column :quotes, :tags, :string
    add_column :quotes, :abbreviation, :string
    add_column :quotes, :translation, :string
  end

  def down
  end
end
