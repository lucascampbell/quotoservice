class CreateQuoteCreates < ActiveRecord::Migration
  def change
    create_table :quote_creates do |t|
      t.integer :quote_id, :null => false
      t.string  :active, :default => false
      t.timestamps
    end
  end
end
