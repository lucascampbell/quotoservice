class AddQuoteColumns < ActiveRecord::Migration
  def up
    add_column :quotes, :topic_id, :string
    add_column :quotes, :abbreviation, :string
    add_column :quotes, :translation, :string
  end

  def down
  end
end
