class CreateQuoteUpdates < ActiveRecord::Migration
  def change
    create_table :quote_updates do |t|
      t.integer :quote_id, :null => false
      t.string  :quote, :default => "no"
      t.string  :citation, :default => "no"
      t.string  :book, :default => "no"
      t.string  :author, :default => "no"
      t.string  :topics, :default => "no"
      t.string  :tags, :default => "no"
      t.string  :translation, :default => "no"
      t.string  :abbreviation, :default => "no"
      t.string  :rating, :default => "no"
      t.string  :active, :default => "no"
      t.timestamps
    end
  end
end
