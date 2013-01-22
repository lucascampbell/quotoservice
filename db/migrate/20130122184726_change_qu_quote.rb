class ChangeQuQuote < ActiveRecord::Migration
  def up
    change_column :quote_updates, :quote, :text
  end

  def down
  end
end
