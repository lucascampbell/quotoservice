class AddPushQuoteField < ActiveRecord::Migration
  def change
    add_column :quotes, :quote_push, :text
  end
end
